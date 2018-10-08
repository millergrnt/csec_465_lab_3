from multiprocessing.dummy import Pool

import scapy

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
        if ply.getlayer(IP).ttl <= 64:
            operating_system = "Linux"
        if ply.getlayer(IP).ttl > 64:
            operating_system = "Windows"
    print(ip + "   " +operating_system)




def main(file):
    lst = []
    fp = open(file)

    for line in fp:
        lst.append(line.strip())

    pool = Pool(2)
    threadedFunc = pool.map(send_ping, lst)
    pool.close()
    pool.join()








main(sys.argv[1])















