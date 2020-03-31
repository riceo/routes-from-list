# Routes-From-List
_A hacky solution to route a list of networks over a specific gateway_

This tool will add custom routes for specific networks to your routing table on Windows 10. Where your machine is connected to more than one network (e.g. when connected to a VPN), this will allow you to decide which network to use for specified routes. 

Routes are only added to the active routing table, meaning anything modified will be dropped upon reboot. This is by design so as not to accidentally cause a big routing table mess :) 

After running, a file called `delete-routes.txt` will be created in the directory the script was run from. This file will contain commands to run that will remove any added routes.

## Requirements

* Access to Powershell
* Admin access to your machine

## Usage

The script takes a list of networks in CIDR format either from a new-line separated text file, or commar separated argument, e.g:

ips.txt
```
1.2.3.4/32
1.5.2.5/32 # comments after the network are OK, too.
1.3.2.6/32
```

`Powershell -ExecutionPolicy Bypass -F routes-from-list.ps1 -f ips.txt`

OR

`Powershell -ExecutionPolicy Bypass -F routes-from-list.ps1 1.2.3.4/32,1.5.2.5/32`
