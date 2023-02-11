
- EC2 instance ismini "aws-cli" olarak değiştirelim:
sudo hostnamectl set-hostname aws-cli

- Değişikliği görmek için komut girelim:
bash

- aws-cli versiyonunu kontrol edelim:
aws --version

- version2 yi yükleyelim:
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
/usr/local/bin/aws --version

- aws-cli da kendimizi tanıtalım:
aws configure

Access key ID: XXXXXXXXXXXXXXXXXXX
Secret access key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Default region name [None]: us-east-1
Default output format [None]: json

- konfigürasyonun tamamlandığını kontrol edelim:
aws sts get-caller-identity --query Account --output text

1. Security Groupların oluşturulması:
aws ec2 create-security-group \
    --group-name roman_numbers_sec_grp \
    --description "This Sec Group is to allow ssh and http from anywhere"

- We can check the security Group with these commands:
aws ec2 describe-security-groups --group-names roman_numbers_sec_grp

- You can check IPs with this command into the EC2:
curl https://checkip.amazonaws.com


2. Security Gorup a ait kuralların oluşturulması:
aws ec2 authorize-security-group-ingress \
    --group-name roman_numbers_sec_grp \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-name roman_numbers_sec_grp \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

3. Security Group u oluşturduktan sonra şimdi de EC2 muzu oluşturalım. Güncel "AMI id" ye ihtiyacımız olacak.

- İlk olarak son ami bilgilerini çekelim
aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --region us-east-1

- ikinci aşamada query çalıştırarak son ami numarasını elde edelim 
aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --query 'Parameters[0].[Value]' --output text

- sonra bu değeri bir variable a atayalım:
LATEST_AMI=$(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --query 'Parameters[0].[Value]' --output text)

echo $LATEST_AMI

- userdata dosyamızı oluşturalım
sudo vim userdata.sh


- şimdi de instance ı çalıştıralım:
aws ec2 run-instances --image-id $LATEST_AMI --count 1 --instance-type t2.micro --key-name xxxxxxx --security-groups roman_numbers_sec_grp --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=roman_numbers}]' --user-data file:///Users/ODG/Desktop/git_dir/serdar-cw/porfolio_lesson_plan/week_6/CLI_solution/userdata.sh

veya

aws ec2 run-instances \
    --image-id $LATEST_AMI \
    --count 1 \
    --instance-type t2.micro \
    --key-name alper \
    --security-groups roman_numbers_sec_grp \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=roman_numbers}]' \
    --user-data file:///home/ec2-user/userdata.sh

- Yeni oluşan instance a ait bilgileri görelim:
aws ec2 describe-instances --filters "Name=tag:Name,Values=roman_numbers"

- Yeni oluşan instance a ait "public IP" ve "instance ID" bilgilerini görelim:
aws ec2 describe-instances --filters "Name=tag:Name,Values=roman_numbers" --query 'Reservations[].Instances[].PublicIpAddress[]'

aws ec2 describe-instances --filters "Name=tag:Name,Values=roman_numbers" --query 'Reservations[].Instances[].InstanceId[]'

- EC2 silmek için:
aws ec2 terminate-instances --instance-ids xxxxxxxxxxxx

- security-groups silmek için:
aws ec2 delete-security-group --group-name roman_numbers_sec_grp



- dokumantasyon:
https://docs.aws.amazon.com/cli/latest/userguide
