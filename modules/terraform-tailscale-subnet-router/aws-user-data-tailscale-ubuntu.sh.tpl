#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Enable IP forwarding
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
sysctl -p /etc/sysctl.d/99-tailscale.conf

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Enable and start tailscaled
systemctl enable --now tailscaled

# Wait for tailscaled to come up
sleep 5

# Start Tailscale and advertise routes
tailscale up \
  --advertise-routes=${routes} \
  --authkey=${tailnet_key} \
  --advertise-tags=tag:${tailscale_tag}
