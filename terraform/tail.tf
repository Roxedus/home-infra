resource "tailscale_acl" "acl" {
  acl = jsonencode({
    "acls" : [
      { "action" : "accept", "src" : ["*"], "dst" : ["*:*"] },
    ],

    "ssh" : [
      {
        "action" : "check",
        "src" : ["autogroup:members"],
        "dst" : ["autogroup:self"],
        "users" : ["autogroup:nonroot"],
      },
    ],

    // Test access rules every time they're saved.
    // "tests": [
    //  	{
    //  		"src": "alice@example.com",
    //  		"accept": ["tag:example"],
    //  		"deny": ["100.101.102.103:443"],
    //  	},
    // ],
  })
}

data "tailscale_devices" "all_devices" {}

data "tailscale_device" "unraid" {
  name = "unraid.little-roach.ts.net"
}


output "devices" {
  value = data.tailscale_devices.all_devices.devices[*].name

}
