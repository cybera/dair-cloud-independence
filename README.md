This repository contains the code used for Cybera DAIR Cloud Independence Tutorials

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

You can now access your application at: http://public_ip/polls.
You can admin your application at: http://public_ip/admin
username `admin` and password `P@ssw0rd!`

Sensu/Monitoring can be viewed at http://public_ip:3000/. You can log in with
username `admin` and password `P@ssw0rd!`

Grafana/Metrics can be viewed at http://public_ip:3000/grafana. You can log
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
sudo docker ps -a
```

# Updating your application

Once you have changes to your application you wish to deploy you can do so by 
making changes to the `apps/docker_files` folder. 

Inside we have our `app` folder that holds the example application data. This 
is where you would put your custom code and following updates. You can modify 
the application docker container by editing the `apps/docker_files/app/Dockerfile` 
file. This file sets the base Docker image, environment variables, and various 
commands and files needed for container setup.

Inside the same `apps/docker_files` folder we have the `docker-compose.yml` file. 
Here you can find the app: service and make changes accordingly. You can see where 
the app folder is mounted on the docker instance, behaviour on failure, exposed 
ports, what services the container depends on, and the commands executed on the 
server to start your application.

### Security Gotchas

In order to make our tutorial more applicable to a variety of setups, we have
made a variety of overly permissive settings in our files. We highly recommend
securing these settings with more appropriate defaults:

* `ALLOWED_HOSTS` in Django is set to `*`. In production, this should be
  appropriately limited.
  
* In terraform/aws/terraform.tfvars a hard coded `allowed_net` variable is set to 0.0.0.0/0 allowing all traffic to the demo instnace. This should be looked into and secured if you would like to block general web traffic.

# Tool Descriptions
## Python and Django - Application Language and Framework
Python is an open source scripting language popular for its approachability. As a high level language most of the code is human readable. As an interpreted language Python scripts are flexible and portable.

Django is a framework written in Python that streamlines development of web applications.

## Git - Source Control Versioning and Management
Git is a distributed version control system (DVCS) supporting history, branching, tagging, and conflict merging. Hosted git collaboration is supported by many providers (GitHub, etc.) as well as open source self hosted solutions.

## Nginx - Load balancer and reverse proxy
Nginx [engine x] is an open source flexible reverse proxy that securely processes connections and relays them to an application service. Nginx can also terminate SSL connections, directly serve static content, and perform caching.

## PostgreSQL - Database Server
PostgreSQL is an object-relational database that holds our tutorial applications dynamic data. PostgreSQL is open source and very mature with over 30 years of development behind it.

Many public cloud providers offer managed PostgreSQL databases, or it can be self hosted as we have done in the tutorial.

## Terraform - Multi-Cloud deployment tool
Terraform is an infrastructure as code tool that provisions and configures compute, storage, networking, and many other resources needed for your applications.

Terraform uses infrastructure blueprints to build components on your chosen cloud provider. Terraform blueprints can be stored in git or other SCM tools facilitating version control and other best practices.

## Docker - Container Service
Docker is a container tool that builds and manages portable application environments. Lighter than virtual machines containers bundle code, tools, libraries, network layout, and overall environment configuration. Docker allows an application stack to run anywhere the docker service is available. Bundled requirements and interconnections remove many distribution and mobility challenges.

## Rclone - Cloud data copying tool
rclone is a lightweight tool for copying data around various cloud targets. Highly configurable, rclone will run on and talk to most storage systems allowing you to use one tool to move data between nearly all your clouds.

## Sensu - Service health monitor
Sensu (specifically Sensu Go) is an open source telemetry and service health checking solution. Easy to setup and highly scalable Sensu is designed to monitor systems across clouds. Sensu Go can also act as an event pipeline facilitating automation.

## Grafana - Data visualization
Grafana is an open source analytics & monitoring solution for every database. It works with other tools to collect and visualize data. Grafana can collect data from many sources, such as InfluxDB as shown in our tutorial. 

## InfluxDB - Time Series Database
InfluxDB is the open source time series database of our metrics that Grafana will query for visualization.

## Jenkins - Automation and CI/CD Platform
Jenkins is a mature open source automation server that is a popular CI/CD tool partially due to the large number of available plugins.
