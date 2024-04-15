


data "aws_security_group" "existing" {
  id = "sg-0f7a504c17e832352" # Replace with the actual security group ID
}


resource "aws_instance" "communication_server" {
  ami           = "ami-01dad638e8f31ab9a"  # Replace with your desired AMI ID
  instance_type = "t3.micro"
  key_name      = "server"
  
  tags = {
    "Name" = "Communication_server_terraform"
  }

  vpc_security_group_ids = [data.aws_security_group.existing.id]

  

  credit_specification {
    cpu_credits = "standard"
  }
  
  user_data = <<-EOF
      #!/bin/bash
      yum update -y
      yum install -y docker
      service docker start
      docker pull anandanlk/communication_server:latest
      sudo docker run -p 8088:8088 -d anandanlk/communication_server:latest 
  EOF

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8  # Replace with your desired volume size in GB
    delete_on_termination = true
    iops                  = 3000  # Replace with your desired IOPS (optional)
  }
 
}
 output "CommunicationServerIpDecentralized" {
  description = "CommunicationServer Public IP"
  value       = aws_instance.communication_server.public_ip
 }
