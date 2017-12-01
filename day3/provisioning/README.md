# Setup AWS account
We created an AWS account following the link provided
We created an Administrator account for the amazon account
We created a key-pair for the Administrator account

## Key-pair file
The key-pair file got downloaded, we had to give the current user permission by entering
'''chmod 400 key-pair-file-name.pem'''

## Preparing AWS CLI
run following commands in console
'''sudo easy_install pip'''
'''pip3 install awscli --upgrade --user'''

### Export aws to path
run
'''vim ~/.zshrc'''
or use the appropriate shell configuration file 
add to file: export PATH=~/Library/Python/3.6/bin:$PATH

run in console
'''aws configure'''

locate AWS access key ID in iam console.
Select users, select security credentials, copy access key and paste as first request
click on show link in same row to retrieve secret key and paste in as second request
paste your region name as third request
and enter the word "text" as fourth request

## Log in to aws server
PUBLICIP is a placeholder for the public IP of the instance, can be found in the ec2 console
ssh -i key-pair-file-name.pem ec2-user@PUBLICIP

When logged in run the following commands
'''sudo yum update -y'''
'''sudo yum install -y docker'''
'''sudo services docker start'''
'''sudo usermod -a -G docker ec2-user'''
'''exit'''

## run application
enter in console
'''docker run -d -p 80:3000 username/repository:tag node app.js
