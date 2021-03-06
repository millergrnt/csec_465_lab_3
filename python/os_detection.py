#
# File:        os_detection.py
# Author:      Franco Graziano <fg8643@rit.edu>
# Description: iterates through a file of IP addresses to detect the OS.
#              Only uses pings as of now.
#
#              usage: "python3 os_detection.py filename.txt"
#

from multiprocessing.dummy import Pool
from scapy.all import *
from scapy.layers.inet import IP, ICMP
import sys


def send_ping(ip):
    packet = IP(dst=str(ip), ttl=20) / ICMP()
    # print(str(ip))
    ply = sr1(packet, timeout=2,verbose=False)
    if ply == None:
        # print("no response")
        return
    if IP in ply:
        # print(ply.getlayer(IP).ttl)
        if ply.getlayer(IP).ttl <= 64 and ply.getlayer(IP).ttl >32:
            operating_system = "Linux"
            print(ip + "   " + operating_system)

        if ply.getlayer(IP).ttl > 64 or ply.getlayer(IP).ttl == 32:
            operating_system = "Windows"
            print(ip + "   " +operating_system)




def main(file):
    lst = []
    fp = open(file)

    for line in fp:
        lst.append(line.strip())


    if len(lst) >1:
        pool = Pool(2)
        threadedFunc = pool.map(send_ping, lst)
        pool.close()
        pool.join()

    if len(lst)==1:
        send_ping(lst[0])



main(sys.argv[1])















