ssh-keygen -t rsa -b 4096 -C "peterpiekarczyk@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
