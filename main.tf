provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "akshataEC2" {
    ami = var.ami
    instance_type = "t2.micro"
    key_name = "akshata"
    vpc_security_group_ids = [aws_security_group.akshata-sg.id]
    
    tags = {
        Name = "akshataEC2"
    }
}

resource "aws_instance" "awEC2" {
    ami = "ami-078af5745f1d9ccc6"
    instance_type = "t2.micro"
    key_name = "akshata"
    vpc_security_group_ids = [aws_security_group.akshata-sg.id]
    
    tags = {
        Name = "awEC2"
    }
}

resource "aws_security_group" "akshata-sg" {
    name = "akshata-sg"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["172.31.0.0/16"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "akshata-lb-sg" {
    name = "akshata-lb-sg"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb" "akshata-lb" {
    name = "akshata-lb"
    internal = false
    load_balancer_type = "application"
    subnets = [var.subnet1, var.subnet2]
    security_groups = [aws_security_group.akshata-lb-sg.id]
    idle_timeout = 400
    
    tags = {
        Name = "akshata-elb"
    }
}

resource "aws_lb_target_group" "akshata-tg" {
    name = "akshata-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc
    
    tags = {
        Name = "akshata-tg"
    }
    
    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 5
        interval = 30
        path = "/"
        port = 80
    }
}

resource "aws_lb_target_group_attachment" "akshata-lb-tg" {
    target_group_arn = aws_lb_target_group.akshata-tg.arn
    target_id = aws_instance.akshataEC2.id
    port = 80
}

resource "aws_lb_target_group_attachment" "aw-lb-tg" {
    target_group_arn = aws_lb_target_group.akshata-tg.arn
    target_id = aws_instance.awEC2.id
    port = 80
}

resource "aws_lb_listener" "akshata-listener" {
    load_balancer_arn = aws_lb.akshata-lb.arn
    port = 80
    protocol = "HTTP"
    
    default_action {
        target_group_arn = aws_lb_target_group.akshata-tg.id
        type = "forward"
    }
}
