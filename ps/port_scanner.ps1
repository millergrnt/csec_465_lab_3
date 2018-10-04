#
# File:        port_scanner.ps1
# Author:      Grant Miller <gem1086@g.rit.edu>
# Description: Implements a simple port scanner via Powershell
#

param(
    [string]$ip_range,
    [string]$port_list
)


#
# Gets the first IP address from the CIDR notation network string
# Params:
#    $cidr     - CIDR notation network address
# Return:
#    $start_ip - First IP Address in that network
#
function get_start_ip([string]$cidr){

    # Get the network from the CIDR notation and transform it into its bytes
    $network = $($cidr -Split "/")[0]
    $network_bytes = ([System.Net.IPAddress]$network).GetAddressBytes()

    # Flip the bytes array
    [Array]::Reverse($network_bytes)

    # Transform it back into an IP address then add one to account for network address
    # being unusable
    $network_bytes = ([System.Net.IPAddress]($network_bytes -join ".")).Address
    $start_ip = $network_bytes + 1
    
    # Convert to double to prevent string math from failing and program starting
    # at 0.x.x.x even if any number larger than 0 is supplied. i.e. 10.1.5.0/24
    # would start from 0.1.5.1 and go until 10.1.5.255
    if (($start_ip.Gettype()).Name -ine "double"){
        $start_ip = [Convert]::ToDouble($start_ip)
    }
    
    # Convert it back to an IP address and return it
    $start_ip = [System.Net.IPAddress]$start_ip
    Return $start_ip
}

#
# Gets the last IP address from the CIDR notation network string
# Params:
#    $cidr   - CIDR notation string
# Return:
#    $end_ip - Last IP in the network
#
function get_end_ip([string]$cidr){

    # Get the network address from the CIDR notation
    $cidr_arr = $cidr -Split "/"
    $network = $cidr_arr[0]
    [int]$mask = $cidr_arr[1]
    $network_bits = 32 - $mask

    # Get the number of addresses from the mask and subtract one for broadcast address
    $num_network_addresses = ([System.Math]::Pow(2, $network_bits)) - 1

    # Same process as StartIP but for the last address so add the number of total addresses
    # instead of just one
    $network_bytes = ([System.Net.IPAddress]$network).GetAddressBytes()
    [Array]::Reverse($network_bytes)
    $network_bytes = ([System.Net.IPAddress]($network_bytes -join ".")).Address

    # add total number of addresses to the start address
    $end_ip = $network_bytes + $num_network_addresses

    # Convert to double to prevent string math from failing causing wrong range to be iterated over
    if (($end_ip.Gettype()).Name -ine "double"){
        $end_ip = [Convert]::ToDouble($end_ip)
    }
    
    $end_ip = [System.Net.IPAddress]$end_ip
    Return $end_ip
}

#
# Performs a ping sweep on range of IP addresses supplied
# Params:
#    [string]$ip_range    - Range of IPs to iterate
# Return:
#    array of ip addresses which were successfully pinged which can be used in port scan
#
function ping_sweep([string]$ip_range){

    # If / character in the string, CIDR was offered
    if($ip_range -Match "/"){

        # Get the start and end IP from the CIDR range
        $start_range = get_start_ip $ip_range
        $end_range = get_end_ip $ip_range

        # Convert it into format already used in IP range
        $ip_range = "$start_range-$end_range"
    }

        
    #Split the range into its two IPs
    $ip_arr = $ip_range -Split '-'
        
    # Split the IP addresses into their bytes
    $ip_1_bytes = $ip_arr[0] -Split '\.'
    $ip_2_bytes = $ip_arr[1] -Split '\.'

    $up_hosts = @()

    # Iterate over IP range
    foreach($a in $ip_1_bytes[0]..$ip_2_bytes[0]){
       foreach($b in $ip_1_bytes[1]..$ip_2_bytes[1]){
            foreach($c in $ip_1_bytes[2]..$ip_2_bytes[2]){
                foreach($d in $ip_1_bytes[3]..$ip_2_bytes[3]){

                    if($($d % 5) -eq 0){
                        $next_d = $d + 5
                        Write-Host "Testing $a.$b.$c.$d-$a.$b.$c.$next_d"
                    }

                    # Test the connection
                    if(Test-Connection -ComputerName "$a.$b.$c.$d" -Count 2 -ErrorAction SilentlyContinue){
                       Write-Host "[$a.$b.$c.$d] is up."
                       $up_hosts += "$a.$b.$c.$d"
                    }
                }
            }
        }
    }

    return $up_hosts
}


#
# Performs a port scan on the list of up hosts within the range supplied
# Params:
#    $up_hosts    - Array of hosts that are connected
#    $port_range  - Range of ports to test
# Return:
#    Nothing
#
function port_scan([Array]$up_hosts, [string]$port_range){

    if($port_range -Match '-'){
        
        $ports = $port_range -Split '-'
        $port_arr = @($ports[0]..$ports[1])
    } else {
        $port_arr = $ports -Split ','
    }

    foreach($ip in $up_hosts){

        $open_ports = @()
        foreach($port in $port_arr){
            $socket = new-Object System.Net.Sockets.TcpClient($ip, $port)
            if($socket.Connected){
                $open_ports += $port
            }
        }

        Write-Host "$ip`:\t" -NoNewLine
        foreach($port in $open_ports){
            Write-Host "$port, " -NoNewLine
        }
    }
}

if(!$ip_range){
    Write-Host "Error: Please supply IP Range"
    return
}

if(!$port_list){
    Write-Host "Only IP Range supplied, performing ping sweep..."
    $up_ips = ping_sweep($ip_range)

    $up_ips
} else {
    Write-Host "Port range supplied, performing port scan..."
    $up_ips = ping_sweep($ip_range)

    port_scan($up_ips, $port_list)
}