# Introduction to Terraform with the Honeycomb Provider

## What is Terraform?
Terraform is an infrastructure-as-code provisioning tool comprised of the Terraform language and the Terraform CLI. It lets you treat all parts of operations like software - defining, creating, updating, and destroying your infrastructure with code. 
   * Written in Go
   * Language is declarative, meaning your configurations describe your desired end state, not the steps necessary to get there. Terraform handles the underlying logic of figuring out how to get to the end state by creating a graph of resource dependencies and using that to determine the correct order to make changes. 
   * Terraform generally takes an immutable infrastructure approach, meaning once something is created, it doesn't get changed. Any changes needed are generally made by destroying the existing resource and recreating it with the desired configuration. 

## Why use Terraform?
* Allows you to automate your provisioning workflows. This allows for less human errors, speeds up how long it takes to provision new infrastructure, and makes things more consistent. 
* Defines infrastruture in human-readable configuration files that can be put in version control. Once in version control, you can run tests, do code reviews, and track changes over time. 
* Enables reused through composable modules.
* Supports encoding security and other standards as code so you can have consistently applied policies across all of your infrastruture.

## The Core Terraform Workflow Using the Honeycomb Provider
### Write
   1. Make sure you have the latest version of Terraform [installed](https://developer.hashicorp.com/terraform/downloads). You can do this however you like. I use [asdf](https://asdf-vm.com/) to manage multiple Terraform versions. 
   1. Make sure Terraform is working by running `terraform -version`. You can see other commands avaialble with `terraform -help`
   1. Clone this repository and navigate into the `honeycomb-configuration` directory. You should see 3 files in this directory: main.tf, variables.tf, and outputs.tf.
   1. Create a new team in Honeycomb.
   1. In Honeycomb, add a new PagerDuty integration called "NoOp Test Service" by going to the Account > Team Settings > Integrations page, "Trigger and SLO Recipients" section.
   1. Generate a new API token in Honeycomb for your team that has all of the permissions checked.
   1. The variables you need to set to run the scenario are defined in variables.tf. There are lots of different [ways to set variables in Terraform](https://developer.hashicorp.com/terraform/language/values/variables#assigning-values-to-root-module-variables). These instructions use environment variables but you can use whatever way you prefer.
   1. Export the API key you generated in Honeycomb to the environment variable TF_VAR_honeycomb_api_key
      ```
      export TF_VAR_honeycomb_api_key=YOUR_API_KEY_HERE
      ```
   1. Export the API URL for Honeycomb to the environment variable TF_VAR_honeycomb_api_url
      ```
      export TF_VAR_honeycomb_api_url=YOUR_HONEYCOMB_API_URL_HERE
      ```
   1. Go to https://webhook.site/ to generate a new test webhook for yourself. Copy the webhook URL and use it to replace `<YOUR-WEBHOOK-URL-HERE>` on line 36.
   1. Replace `<YOUR-EMAIL-HERE>` with your email address on line 31.  
   1. Run `terraform init` to download any necessary providers needed to work with your configuration.
   1. Run `terraform fmt` to automatically format your configuration with the standard Terraform style.
   1. Run `terraform validate` to check whether your current configuration is valid.
### Plan
   1. Run `terraform plan`. This will show a preview of everything that will be created if your run `terraform apply` with your current configuration.
### Apply
   1. Run `terraform apply`. This will generate another plan and ask for your approval before creating anything. Type 'yes' and then look in the Honeycomb UI to see your applied changes.
   1. Run `terraform apply` again. Since nothing has changed in your Terraform config or in the UI, there should be nothing to update. Terraform should report "No changes. Your infrastructure matches the configuration."
   1. Update your configuration by changing the attributes of a few resources. Save your changes.
   1. Run `terraform apply` again. This will generate another plan and ask for your approval before changing anything. Type 'yes' and then look in the Honeycomb UI to see your applied changes.
   1. Modify something in the UI outside of Terraform.
   1. Run `terraform apply` again. This will generate another plan and ask for your approval before changing anything. Type 'yes' and then look in the Honeycomb UI to see your applied changes.
   1. Run `terraform destroy`. This will generate another plan and ask for your approval before destroying anything. Type 'yes' and then look in the Honeycomb UI to see that everything was destroyed.

## Learning Resources
1. [Intro to Terraform documentation](https://developer.hashicorp.com/terraform/intro)
1. [Intro to Terraform CLI tutorial](https://developer.hashicorp.com/terraform/tutorials/cli/init)
1. [HashiCorp Learn](https://developer.hashicorp.com/terraform/tutorials)
1. [Terraform CLI documentation](https://developer.hashicorp.com/terraform/cli)
1. [Terraform Language documentation](https://developer.hashicorp.com/terraform/language)
1. [Honeycomb Terraform provider documentation](https://registry.terraform.io/providers/honeycombio/honeycombio/latest/docs)
1. [Honeycomb Terraform provider repository](https://github.com/honeycombio/terraform-provider-honeycombio)