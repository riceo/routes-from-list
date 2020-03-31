$deleteFile = "delete-routes.txt"

function Write-Usage {

    Write-Host "A simple script designed to route passed CIDR networks over a specific interface."
    Write-Host "Usage: [-f <new-line separated file of IPs in CIDR notation>]|[<comma separated IPs in CIDR notation>]"
    Write-Host "EXAMPLE: -f ips.txt"
    Write-Host "EXAMPLE: 1.2.3.4/32,0.0.0.0/8"
}

function Get-IPsFromFile {

    $ips = Get-Content $args[0]
    $output = @()

    foreach ( $line in $ips ) {
        $output += $line | Select-String -Pattern "([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\/([0-9]{1,2})" -All | ForEach-Object { $_.Matches[0].Value }
    }
    
    return $output
}

function Get-IPsFromList {

    $ips = $args[0].Split(",")
    return $ips
}

function Write-Interfaces {
    $interfaces = Get-NetIPInterface -AddressFamily IPv4 -ConnectionState connected | Where-Object -FilterScript { $_.ifIndex -Gt 1} 

    Write-Host ($interfaces | Select-Object ifIndex,InterfaceAlias | Out-String)
}

function Write-Deletes {
    $deletes | Out-File -FilePath $deleteFile
    Write-Host "Delete commands can be found in delete-routes.txt"    
}


if ($args[0] -eq $null ) {

    Write-Usage
    exit 1
}

if ($args[0] -eq "-f") {

    
    if ($args[1] -eq $null) {
        Write-Usage
        exit 1
    }
    
    Write-Host "Running from file..."

    $ips = Get-IPsFromFile $args[1]

} else {
    
    $ips = Get-IPsFromList $args[0]
}

if ($ips -eq $null) {
    Write-Host "No IPs to work on."
    exit 1
}

Write-Interfaces
$interface = Read-Host -Prompt 'Which interface would you like to route these networks over? (HINT: Probably the lowest interface number)'
$nextHop = (Get-NetIPConfiguration -InterfaceIndex $interface | Foreach IPv4DefaultGateway).nextHop

$deletes = @()

foreach ($ip in $ips) {
    Write-Host "Adding ${ip} to interface ${interface} with next hop ${nextHop}..."
    New-NetRoute -DestinationPrefix $ip -InterfaceIndex $interface -NextHop $nextHop -PolicyStore ActiveStore
    $deletes += "Remove-NetRoute -DestinationPrefix ${ip} -InterfaceIndex ${interface}"
}

Write-Deletes $deletes $deleteFile

