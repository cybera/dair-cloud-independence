This repository contains the code for the DAIR Cloud Independence Tutorial 1

# Repository Basics

The repository structure is as below:

* `/bin`: contains Terraform binaries for Mac and Linux.
* `/key`: directory for generated keys.
* `/sample-app`: Deploy code and the Django example web application.
* `/terraform`: Terraform deployments for AWS, Azure, and OpenStack.

# Prerequisites

* Mac or Linux-based workstation.
* Access to a cloud provider (ex. Openstack, AWS, Azure)

# Cloud Provider Authentication

This repository supports deployments for AWS, Azure, and OpenStack. In order to deploy
to each of these clouds, you will need to obtain your authentication credentials

## AWS

In order to authenticate with AWS, you will need to generate an Access Key ID and a
Secret Access Key. If you are unfamiliar with this process, please read
[this](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html) article.

One you have obtained the Access Key ID and Secret, export them as environment
variables in your shell.

```
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_DEFAULT_REGION="us-west-2"
```


> Note: We highly recommend deleting the access key ID and secret once you're done with
> this tutorial.

## Azure

To authenticate with Azure, first install the Azure `az` command-line tool as described
[here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

Once installed, run the following:

```
az login
az account show --query "{subscriptionId:id, tenantId:tenantId}"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"
```

Use the results of the above commands to set the following environment variables:

```
export ARM_SUBSCRIPTION_ID=your_subscription_id
export ARM_CLIENT_ID=your_appId
export ARM_CLIENT_SECRET=your_password
export ARM_TENANT_ID=your_tenant_id
```

## OpenStack

To authenticate with OpenStack, use the OpenStack web dashboard (also called Horizon) to
download your `openrc` file. You can do this by:

1. Log into the dashboard
2. Click on the Compute menu on the left.
3. Click on the API Access sub-menu.
4. Click "Download OpenStack RC File v3".

Once you have downloaded the `openrc` file, run the following in your shell:

```
source /path/to/downloaded/openrc/file
```

# Deployment

Once you have obtained your authentication credentials for the target cloud (or clouds),
do the following:

* Clone this repository to your desktop and change into the new directory:

```
cd dair-cloud-independence
```

* Generate an SSH key:

```
make create-sshkey
```

## Configure the Deployment

Each directory of `terraform/aws`, `terraform/azure`, and `terraform/openstack` contains a
file called `terraform.tfvars`. Edit this file with a text editor of your choice and make
any changes as you see fit.

## Deploy to AWS

Run:

```
make plan ENV=aws
make apply ENV=aws
```

## Deploy to Azure

```
make plan ENV=azure
make apply ENV=azure
```

## Deploy to OpenStack

```
make plan ENV=openstack
make apply ENV=openstack
```

> Note: If the process times out, you can try re-running the command again.

You can now access your application at: http://<public_ip>/polls.

Sensu/Monitoring can be viewed at http://<public_ip>:3000/. You can log in with
username `admin` and password `P@ssw0rd!`.

Grafana/Metrics can be viewed at http://<public_ip>:3000/grafana. You can log
in with username `admin` and password `P@ssw0rd!`

# Tear Down

When you're finished with the tutorial, you can delete all cloud resources
by doing:

```
make destroy ENV=<aws azure or openstack>
```

# Docker Status

You can see the status of your Docker contains by first SSH'ing to the remote
virtual machine / instance:

```
ssh -i key/id_rsa ubuntu@<public_ip>
```

Then run:

```
docker ps -a
```

# Updating your application

Once you have changes to your application you wish to deploy you can do so by:

### Security Gotchas

In order to make our tutorial more applicable to a variety of setups, we have
made a variety of overly permissive settings in our files. We highly recommend
securing these settings with more appropriate defaults:

* `ALLOWED_HOSTS` in Django is set to `*`. In production, this should be
  appropriately limited.
