# EC2 with Terraform

![](https://github.com/akshataw/EC2WithTerraform/images/terraform.png?raw=true)

Terraform is an open-source infrastructure as code software tool created by HashiCorp.

The following are the steps to create the **EC2 instace on AWS** along with the **Security Group and Loadbalancer**.

#### Clone it:
```
    git clone git@github.com:akshataw/EC2WithTerraform.git
```
or 
```
    git clone https://github.com/akshataw/EC2WithTerraform.git
```

### Add variables.tf file
Create **variables.tf** file and add the following code to it, with your **default VPC and default Subnet ids**.
```
    variable "vpc" {
        default = "********"
    }
    
    variable "subnet1" {
        default = "********"
    }

    variable "subnet2" {
        default = "********"
    }
```

### Run it:
```
    terraform init
    terraform plan
    terraform apply
```

##### ***Now let's understand it.***

We have **main.tf** file, where we have mentioned all the resources we need to create our EC2 instace, security group and load balancer.

```
    provider "aws" {
        region = "us-east-1"
    }
```
The Amazon Web Services (AWS) provider is used to interact with the many resources supported by AWS. The provider needs to be configured with the proper credentials before it can be used.

```
    resource "aws_instance" "akshataEC2" {
        ami = "ami-******"
        instance_type = "t2.micro"
        key_name = "key-name"
        vpc_security_group_ids = [aws_security_group.akshata-sg.id]
        
        tags = {
            Name = "akshataEC2"
        }
    }
```
Provides an EC2 instance resource.
**ami** is required to use for the instance.
**vpc_security_group_ids** defines the security group attached to the instance.

```
    resource "aws_security_group" "akshata-sg" {
    name = "security-group-name"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["172.31.0.0/16"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
```
**aws_security_group** provides a security group resource.
Here we are allowing traffic to and from on port 80(HTTP).

```
    resource "aws_lb" "akshata-lb" {
        name = "name_for_loadbalancer"
        internal = false
        load_balancer_type = "application"
        subnets = [var.subnet1, var.subnet2]
        security_groups = [aws_security_group.akshata-lb-sg.id]
        idle_timeout = 400
        tags = {
            Name = "akshata-elb"
        }
    }
```
**aws_lb** provides a Load Balancer resource. A load balancer serves as the single point of contact for clients. The load balancer distributes incoming application traffic across multiple targets, such as EC2 instances, in multiple Availability Zones. This increases the availability of your application.

Then we need a target group and we need to attach the target group to our load balancer.
```
    resource "aws_lb_target_group" "akshata-tg" {
        name = "akshata-tg"
        port = 80
        protocol = "HTTP"
        vpc_id = var.vpc
    }
    
    resource "aws_lb_target_group_attachment" "akshata-lb-tg" {
        target_group_arn = aws_lb_target_group.akshata-tg.arn
        target_id = aws_instance.akshataEC2.id
        port = 80
    }
```
Finally we'll add a load balancer listener.
```
    resource "aws_lb_listener" "akshata-listener" {
        load_balancer_arn = aws_lb.akshata-lb.arn
        port = 80
        protocol = "HTTP"
        default_action {
            target_group_arn = aws_lb_target_group.akshata-tg.id
            type = "forward"
        }
    }
```

You are all set.