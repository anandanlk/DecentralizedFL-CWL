
provider "aws" {
  region = "eu-north-1"
}

data "aws_security_group" "existing" {
  id = "sg-0f7a504c17e832352" # Replace with the actual security group ID
}


resource "aws_instance" "communication_server" {
  ami           = "ami-01dad638e8f31ab9a" # Replace with your desired AMI ID
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

      # docker pull anandanlk/communication_server:latest
      # sudo docker run -p 8088:8088 -d anandanlk/communication_server:latest 
      
      # Pull the Docker image
      docker pull anandanlk/communication_server:latest
      if [ $? -ne 0 ]; then
          echo "Failed to pull Docker image."
          exit 1
      fi

      # Run the Docker container and store its ID
        CONTAINER_ID=$$(sudo docker run -p 8088:8088 -d anandanlk/communication_server:latest)
        if [ $? -ne 0 ]; then
            echo "Failed to start Docker container."
            exit 1
        fi

      # Wait briefly to let the container attempt to start up
      sleep 5

      # Check if the container is still running
      if ! sudo docker ps -q --no-trunc | grep -q "^${CONTAINER_ID}\$"; then
          echo "Docker container stopped running."
          # Optionally, output the last logs from the container
          sudo docker logs ${CONTAINER_ID}
          exit 1
      fi
  EOF

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8 # Replace with your desired volume size in GB
    delete_on_termination = true
    iops                  = 3000 # Replace with your desired IOPS (optional)
  }

}
output "CommunicationServerIpDecentralized" {
  description = "CommunicationServer Public IP"
  value       = aws_instance.communication_server.public_ip
}
