import sys
import argparse
from smb.SMBConnection import SMBConnection

def main(argv):
    parser = argparse.ArgumentParser(description='Process SMB information.')
    parser.add_argument("-u", "--username")
    parser.add_argument("-p", "--password")
    parser.add_argument("-f", "--file", dest="filename")
    parser.add_argument("-d", "--domain")

    args = parser.parse_args()

    with open(args.filename) as f:
        for system_name in f:
            print('### Analyzing system: ' + system_name)
            conn = SMBConnection(args.username, args.password, 'enumerator', system_name, args.domain,
            use_ntlm_v2=True, sign_options=SMBConnection.SIGN_WHEN_SUPPORTED, is_direct_tcp=True)

            #Attempt to connect
            conn.connect(system_name,445)


            Response = conn.listShares(timeout=30)  # Set response variable that contains list of shares
            print('Shares for: ' + system_name)
            for i in range(len(Response)):  # iterate through the list of shares
                print("  Share: ",i," =", Response[i].name)
                Files = conn.listPath(Response[i].name,'/',timeout=30) #Get a list of files in the share
                print('    Files for: ' + system_name + '/' + "  Share: ",i," =",Response[i].name)
                for i in range(len(Files)):
                    print("    File[",i,"] =", Files[i].filename)


if __name__ == "__main__":
    main(sys.argv[1:])