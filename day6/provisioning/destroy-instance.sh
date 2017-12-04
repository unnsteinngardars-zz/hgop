INSTANCE_ID=$(cat ./ec2_instance/instance-id.txt)
SECURITY_GROUP_ID=$(cat ./ec2_instance/security-group-id.txt)
JENKINS_SECURITY_GROUP=$(cat ./ec2_instance/jenkins-security-group.txt)
PEM_NAME=$(cat ./ec2_instance/pem.txt)

aws ec2 terminate-instances --instance-ids ${INSTANCE_ID}

aws ec2 wait --region us-east-2 instance-terminated --instance-ids ${INSTANCE_ID}
aws ec2 delete-security-group --group-id ${SECURITY_GROUP_ID}

aws ec2 delete-key-pair --key-name ${PEM_NAME}

rm  -rf ec2_instance
