#
# File:        dns_enum.ps
# Author:      Grant Miller <gem1086@rit.edu>
# Description: Enumerates a file that contains a series of fqdn to query
#

# Get the file name from the commandline
param(
    [string]$file
)

function dns_enum([string]$file){

    # For every line in the file given
    foreach($line in Get-Content -Path $file){

        # Report to user what is going on
        Write-Host "Querying $line..."

        # Get the query then print each response
        $response = Resolve-DnsName -Name $line -ErrorAction SilentlyContinue
        foreach($dns_reponse in $response){
            $ipaddr = $dns_reponse.IPAddress
            if($ipaddr){
                Write-Host "Found IP: $ipaddr"
            }
        }

        Write-Host ""
    }
}

# If no file supplied exit
if(-not $file){
    Write-Host "File must be supplied"
    return
}

# Otherwise run our function
dns_enum $file