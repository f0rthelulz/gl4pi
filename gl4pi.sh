#!/bin/bash

#Assigns a variable (getver) and (url) respectively, which scrape packages.gitlab.com for latest stable release of GitLab for Debian GNU/Linux
getver=$(curl -s https://packages.gitlab.com/gitlab/raspberry-pi2 | grep gitlab-ce_ | cut -d\" -f2 | sed 1q)
url=$(echo 'https://packages.gitlab.com/gitlab/raspberry-pi2/packages/raspbian/stretch/'"$getver")
#The following variable (piip) determines the IP address of the pi, and is used in gitlab.rb after download/installation.
piip=$(hostname -I | cut -d ' ' -f1)


#Move to home directory
cd ~/

#Initiates the download of the most current stable version of Omnibus-GitLab-CE for Debian GNU/Linux
curl -Lo "$getver" "$url"/download.deb

#Initiates the installation of the GitLab package obtained by this script
sudo apt install ./"$getver"

#Invokes sed command to add the previously determined Pi IP address, which is set to be the value of variable ("$piip")
sudo sed -i -e '/external_url/s/GENERATED_EXTERNAL_URL/http:\/\/'"$piip"'/g' /etc/gitlab/gitlab.rb

#Set Unicorn Worker Process
sudo sh -c 'echo "unicorn['\''worker_processes'\''] = 2" >> /etc/gitlab/gitlab.rb'

#Set Sidekiq
sudo sed -i '/= 25/s/#//g' /etc/gitlab/gitlab.rb && sudo sed -i '/= 25/s/= 25/= 9/g' /etc/gitlab/gitlab.rb

#Disable Prometheus Monitoring
sudo sed -i -e '/prometheus_monitoring/s/#//g' /etc/gitlab/gitlab.rb && sudo sed -i -e '/prometheus_monitoring/s/true/false/g' /etc/gitlab/gitlab.rb

sudo gitlab-ctl reconfigure

#(optional) Enable ZRAM
