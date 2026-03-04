{
  "autoApprovers": {
    "routes": {
      "0.0.0.0/0": [
        "tag:${tailscale_tag}",
        "autogroup:admin"
      ]
    }
  },
  "tagOwners": {
    "tag:${tailscale_tag}": ["autogroup:admin"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["*"],
      "dst": ["*:*"]
    }
  ],
  "ssh": [
    {
      "action": "check",
      "src": ["autogroup:member"],
      "dst": ["autogroup:self"],
      "users": ["autogroup:nonroot", "root"]
    }
  ]
}
