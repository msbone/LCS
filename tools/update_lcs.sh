cd "/lcs"
echo "Downloading code....."
wget https://github.com/msbone/lcs/archive/master.zip
unzip -u master.zip;
rsync -a LCS-master/ /lcs
rm master.zip
rm -R LCS-master

#Do dlinkac magic
sudo chmod -R 777 /lcs/dlinkac/tftp
sudo chown -R nobody /lcs/dlinkac/tftp
