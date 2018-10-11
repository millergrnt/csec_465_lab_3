############################################################
#       Author: Gunnar Sorensen                            #
#       Contact: gs6601@rit.edu                            #
#       Description: SMB share enumerator which takes in   #
#       a username, password, file, and domain name and    #
#       gives the user information the shares on smb and   #
#       what files those shares contain.                   #
############################################################


import sys
import argparse
from smb.SMBConnection import SMBConnection

def main(argv):
    parser = argparse.ArgumentParser(description='Process SMB information.')
    parser.add_argument("-u", "--username")                 #argument to provide username
    parser.add_argument("-p", "--password")                 #argument to provide password
    parser.add_argument("-f", "--file", dest="filename")    #argument to provide file with a list of all systems you want to enumerate
    parser.add_argument("-d", "--domain")                   #argument to provide domain containing smb

    args = parser.parse_args()

###################################################################
# Opens a file that contains a list of system names to go through #
# and find all shares and the files with in those shares.         #
###################################################################

    with open(args.filename) as f:

        # Open file with system names
        for system_name in f:# Loop through file
            print('Enumerating over system: ' + system_name)
            conn = SMBConnection(args.username, args.password, 'enumerator', system_name, args.domain,
            use_ntlm_v2=True, sign_options=SMBConnection.SIGN_WHEN_SUPPORTED, is_direct_tcp=False)
            conn.connect(system_name, 139) # Attempt to connect to the system
            Shares = conn.listShares(timeout=30)  # Set Shares variable that contains list of shares
            print('Shares for: ' + system_name)
            for i in range(len(Shares)):  # iterate through the list of shares
                if "$" in Shares[i].name:
                    continue
                print("Share: ",i," =", Shares[i].name)
                Files = conn.listPath(Shares[i].name,'/',timeout=30) # Get a list of files in the share
                print('Files for: ' + system_name + '/' + "  Share: ",i," =",Shares[i].name)
                for i in range(len(Files)):
                    print("File[",i,"] =", Files[i].filename)
            conn.close()

if __name__ == "__main__":
    main(sys.argv[1:])