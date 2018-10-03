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
# Performs a ping sweep on 
#
function ping_sweep([string]$ip_range){
        
    #Split the range into its two IPs
    $ip_arr = $ip_range -Split '-'
        
    # Split the IP addresses into their bytes
    $ip_1_bytes = $ip_arr[0] -Split '\.'
    $ip_2_bytes = $ip_arr[1] -Split '\.'

    # Iterate over IP range
    foreach($a in $ip_1_bytes[0]..$ip_2_bytes[0]){
       foreach($b in $ip_1_bytes[1]..$ip_2_bytes[1]){
            foreach($c in $ip_1_bytes[2]..$ip_2_bytes[2]){
                foreach($d in $ip_1_bytes[3]..$ip_2_bytes[3]){

                    # Test the connection
                    if(Test-Connection -ComputerName "$a.$b.$c.$d" -Count 3){
                       Write-Host "[$a.$b.$c.$d] is up."
                    }
                }
            }
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
}