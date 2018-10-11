# csec_465_lab_3

5 Enumeration tools are included in this repository:

## 1. DNS Enumeration tool:
Takes in a file containing DNS names to query and print corresponding DNS records if they exist
```
ps/dns_enum.ps1 -file <file containing domain names> 
```
## 2. Ping Sweep / Port Scanning tool:
This tool will perform only a ping sweep when no port_list is given and will perform a port scan on hosts that are up if port_list is supplied
```
ps/port_scanner.ps1 -ip_range <start-end IP or CIDR notation> [-port_list <comma-seperated list or start-end port>]
``` 
## 3. OS Enumeration tool:
Takes in a file containing IP addresses to test and prints out best guess at the OS of the IP address
```
python3 python/os_detection.py <file containing IP addresses to test>
```
## 4. SMB Share Enumeration tool:
Takes in a file containing SMB server names to test. It will print out all the top level directories/files of all shares on the server
```
python3 smbShareEnum.py -u <username> -p <password> -f <file containing SMB servers> [-d <domain of SMB server>]
```
