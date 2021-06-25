#!/bin/bash

target=$1
REDCOLOR="\e[31m"
GREENCOLOR="\e[32m"
if [ ! -d $target ]
then
  mkdir $target
fi

cd $target

echo -e "$REDCOLOR [+] Finding subdomains with sublist3r"
python3 /opt/SubWalker/tools/Sublist3r/sublist3r.py -d $target -t 35 -o subdomains.txt


echo -e "$REDCOLOR [+] Finding subdomains with assetfinder"
python3 /opt/SubWalker/tools/assetfinder/assetfinder.py -subs-only $target >> subdomains.txt

echo -e "$REDCOLOR [+] Sorting and filetering subsdomains"

cat subdomains.txt | sort | uniq >> subdomains

echo -e "$REDCOLOR [+] Finding alive subdomains"
cat subdomains | httprobe > alive.txt

echo -e "$REDCOLOR [+] Finding JS files"
cat alive.txt | subjs > jsfiles

echo -e "$REDCOLOR [+] Finding sub domain takeovers"
subjack -w subdomains -c /home/kali/go/src/github.com/haccer/subjack/fingerprints.json -t 25 -ssl - o takeovers.txt

while read -r line
do
  dirsearch /opt/dirsearch/dirsearch.py -u alive.txt -w /home/kali/Downloads/wordlists/dirbuster/directory-list-2.3-medium.txt >> alive.txt
done
echo "$GREENCOLOR [+] Done"
