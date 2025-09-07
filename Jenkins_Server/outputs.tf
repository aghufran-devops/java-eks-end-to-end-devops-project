output "jenkins_public_ip" {
  value = module.ec2_instance_jenkins.public_ip
}

output "tomcat_public_ip" {
  value = module.ec2_instance_Tomcat.public_ip
}