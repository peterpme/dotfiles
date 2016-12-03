ssh-keygen -t rsa -b 4096 -C "peter@gmail"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
