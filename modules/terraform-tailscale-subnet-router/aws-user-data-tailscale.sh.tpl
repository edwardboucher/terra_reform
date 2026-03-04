#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

%{ if rh_username != "" && rh_password != "" ~}
subscription-manager register --username ${rh_username} --password ${rh_password} --auto-attach
%{ endif ~}

# Enable IP forwarding
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

# Add the Tailscale repository (retry loop to handle rpm lock race on first boot)
max_attempts=5
attempt_num=1
success=false
while [ $success = false ] && [ $attempt_num -le $max_attempts ]; do
  echo "Trying yum-config-manager (attempt $attempt_num)"
  touch /var/lib/rpm/.rpm.lock
  yum-config-manager --add-repo=https://pkgs.tailscale.com/stable/rhel/9/tailscale.repo
  if [ $? -eq 0 ]; then
    echo "yum-config-manager succeeded"
    success=true
  else
    echo "Attempt $attempt_num failed. Sleeping for 3 seconds and trying again..."
    sleep 3
    ((attempt_num++))
  fi
done

yum install firewalld -y
systemctl enable --now firewalld
firewall-cmd --permanent --add-masquerade

# Install Tailscale
yum install tailscale --nogpgcheck -y

# Enable and start tailscaled
systemctl enable --now tailscaled

# Wait for tailscaled to come up
sleep 5

# Start Tailscale and advertise routes
tailscale up \
  --advertise-routes=${routes} \
  --authkey=${tailnet_key} \
  --advertise-tags=tag:${tailscale_tag}
