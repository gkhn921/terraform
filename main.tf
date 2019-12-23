provider "aws" {
region="us-east-1"
}

resource "aws_launch_configuration" "example"{

image_id="ami-40d28157"
instance_type="t2.micro"
security_groups=["${aws_security_group.instance.id}"]
user_data = <<-EOF
	#!/bin/bash
	echo "Hello, world">index.html
	nohup busybox httpd -f -p "${var.server_port}" &
	EOF
lifecycle {
create_before_destroy=true
}

}
variable "server_port"{

description="The port the server will use for http requests"
default=8080
}


resource "aws_security_group" "instance"{
name="terraform-example-instance"

ingress{
	from_port="${var.server_port}"
	to_port="${var.server_port}"
	protocol="tcp"
	cidr_blocks=["0.0.0.0/0"]
}

lifecycle {
create_before_destroy=true
}
}

data "aws_availability_zones" "all" { state="available"}

resource "aws_autoscaling_group" "example"{

launch_configuration="${aws_launch_configuration.example.id}"
availability_zones=["${data.aws_availability_zones.all.names[0]}"]

min_size=2
max_size=10

tag{

key ="Name"
value="terraform-asg-example"
propagate_at_launch=true

}


}
