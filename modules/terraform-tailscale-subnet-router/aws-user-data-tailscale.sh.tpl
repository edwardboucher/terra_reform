#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
  
subscription-manager register --username ${rh_username} --password ${rh_password}  --auto-attach
echo 'tailnet.key = ${tailnet_key}'
# Add the tailscale repository
#service rpm restart
#dnf config-manager --add-repo https://pkgs.tailscale.com/stable/rhel/9/tailscale.repo -y
#yum is failing with rmp.lock - to remedy, a loop###
max_attempts=5
attempt_num=1
success=false
while [ $success = false ] && [ $attempt_num -le $max_attempts ]; do
  echo "Trying yum install"
  #what is running lock?
  # ps -ef|grep rpm | grep -v 'grep'
  # rm -f $(rpm --root=/mnt/fedRoot -E '%%{_rpmlock_path}')
  # rm -f /var/lib/rpm/.rpm.lock
  touch /var/lib/rpm/.rpm.lock
  yum-config-manager --add-repo=https://pkgs.tailscale.com/stable/rhel/9/tailscale.repo
  # Check the exit code of the command
  if [ $? -eq 0 ]; then
    echo "Yum install succeeded"
    success=true
  else
    echo "Attempt $attempt_num failed. Sleeping for 3 seconds and trying again..."
    sleep 3
    ((attempt_num++))
  fi
done

##############loop end####
#yum-config-manager --add-repo=https://pkgs.tailscale.com/stable/rhel/9/tailscale.repo
#yum -y install https://pkgs.tailscale.com/stable/rhel/9/tailscale.repo
#dnf update -y
#curl -fsSL https://tailscale.com/install.sh | sh
yum install firewalld -y
systemctl enable --now firewalld
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
firewall-cmd --permanent --add-masquerade
#####################install TAILSCALE
# Install Tailscale
yum install tailscale --nogpgcheck -y
# Enable and start tailscaled
systemctl enable --now tailscaled
# Wait a few for tailscaled to come up
sleep 5

# Start tailscale
# We pass --advertise-tags below even though the authkey being created with those tags should result
# in the same effect. This is to be more explicit because tailscale tags are a complicated topic.
tailscale up \
  --advertise-routes=${routes} \
  --authkey=${tailnet_key}  \
  --advertise-tags=tag:${tailscale_tag}

