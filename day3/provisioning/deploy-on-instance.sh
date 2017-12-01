#!/bin/bash -xv
if [ $2 -z ];
then
  INSTANCE_ID=$(cat ./ec2_instance/instance-id.txt)
else
  INSTANCE_ID=$2;
fi

if [$1 -z ];
then
  GIT_COMMIT=$(git rev-parse HEAD)
else
  GIT_COMMIT=$1
fi

INSTANCE_PUBLIC_NAME=$(cat ./ec2_instance/instance-public-name.txt)
SECURITY_GROUP_NAME=$(cat ./ec2_instance/security-group-name.txt)

errc=$?
if [ $errc -ne 0 ];
then
  echo "Instance id, public name and group name not fetched from files, have to run create script first";
  echo "Exit with error code $errc"
  exit $errc
fi

status='unknown'
while [ ! "${status}" == "ok" ]
do
   status=$(ssh -i "./ec2_instance/${SECURITY_GROUP_NAME}.pem"  -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 ec2-user@${INSTANCE_PUBLIC_NAME} echo ok 2>&1)
   sleep 2
done

scp -o StrictHostKeyChecking=no -i "./ec2_instance/${SECURITY_GROUP_NAME}.pem" ./ec2-instance-check.sh ec2-user@${INSTANCE_PUBLIC_NAME}:~/ec2-instance-check.sh
scp -o StrictHostKeyChecking=no -i "./ec2_instance/${SECURITY_GROUP_NAME}.pem" ./docker-compose.yaml ec2-user@${INSTANCE_PUBLIC_NAME}:~/docker-compose.yaml
scp -o StrictHostKeyChecking=no -i "./ec2_instance/${SECURITY_GROUP_NAME}.pem" ./docker-compose-and-run.sh ec2-user@${INSTANCE_PUBLIC_NAME}:~/docker-compose-and-run.sh
scp -o StrictHostKeyChecking=no -i "./ec2_instance/${SECURITY_GROUP_NAME}.pem" ./.env ec2-user@${INSTANCE_PUBLIC_NAME}:~/.env


ssh -o StrictHostKeyChecking=no -i "./ec2_instance/${SECURITY_GROUP_NAME}.pem" ec2-user@${INSTANCE_PUBLIC_NAME} "cat ~/ec2-instance-check.sh"
ssh -o StrictHostKeyChecking=no -i "./ec2_instance/${SECURITY_GROUP_NAME}.pem" ec2-user@${INSTANCE_PUBLIC_NAME} "cat ~/docker-compose-and-run.sh"
ssh -o StrictHostKeyChecking=no -i "./ec2_instance/${SECURITY_GROUP_NAME}.pem" ec2-user@${INSTANCE_PUBLIC_NAME} "~/docker-compose-and-run.sh ${GIT_COMMIT}"
