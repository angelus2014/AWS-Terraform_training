touch test1.txt
touch test2.txt
sudo amazon-linux-extras install nginx1 -y
touch test3.txt
sudo systemctl start nginx
touch test4.txt
sudo systemctl enable nginx