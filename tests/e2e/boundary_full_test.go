package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

type config struct {
	awsAccessKeyID     string
	awsSecretAccessKey string
	awsSessionToken    string
	awsRegion          string
}

func getAwsConfig(t *testing.T) *config {
	t.Helper()

	config := config{
		awsAccessKeyID:     os.Getenv("AWS_ACCESS_KEY_ID"),
		awsSecretAccessKey: os.Getenv("AWS_SECRET_ACCESS_KEY"),
		awsSessionToken:    os.Getenv("AWS_SESSION_TOKEN"),
		awsRegion:          aws.GetRandomRegion(t, nil, nil),
	}
	if config.awsAccessKeyID == "" || config.awsSecretAccessKey == "" || config.awsSessionToken == "" {
		t.Fatal("AWS credentials are not set")
	}

	return &config
}

type boundaryFullTestOptions struct {
	exampleDir         string
	controllerSizing   string
	workerSizing       string
	createVPC          bool
	useACM             bool
	useSSM             bool
	useRoute53         bool
	useCloudwatch      bool
	loggingEnabled     bool
	route53Zone        string
	boundaryArecord    string
	boundaryAdminUsers []string
	tags               map[string]string
}

func getBoundaryFullTestOptions(t *testing.T) *boundaryFullTestOptions {
	t.Helper()

	return &boundaryFullTestOptions{
		exampleDir:         "../../examples/full",
		controllerSizing:   "development",
		workerSizing:       "development",
		createVPC:          true,
		useACM:             true,
		useSSM:             true,
		useRoute53:         true,
		useCloudwatch:      true,
		loggingEnabled:     true,
		route53Zone:        "adfinis.dev.",
		boundaryArecord:    "terratest-boundary.adfinis.dev",
		boundaryAdminUsers: []string{"roel.decort@adfinis.com"},
		tags: map[string]string{
			"Owner":       "Adfinis NL",
			"Deployed-By": "Terratest",
			"Type":        "Test",
			"Service":     "Hashicorp Boundary",
		},
	}
}

func TestBoundaryFull(t *testing.T) {
	t.Parallel()

	config := getAwsConfig(t)
	options := getBoundaryFullTestOptions(t)

	expectedName := fmt.Sprintf("terratest-boundary-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: options.exampleDir,

		Vars: map[string]interface{}{
			"name":                       expectedName,
			"controller_deployment_type": options.controllerSizing,
			"worker_deployment_type":     options.workerSizing,
			"create_vpc":                 options.createVPC,
			"use_acm":                    options.useACM,
			"use_ssm":                    options.useSSM,
			"use_route53":                options.useRoute53,
			"use_cloudwatch":             options.useCloudwatch,
			"logging_enabled":            options.loggingEnabled,
			"aws_route53_zone":           options.route53Zone,
			"boundary_a_record":          options.boundaryArecord,
			"boundary_admin_users":       options.boundaryAdminUsers,
			"tags":                       options.tags,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": config.awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndPlan(t, terraformOptions)
	terraform.ApplyAndIdempotent(t, terraformOptions)

}
