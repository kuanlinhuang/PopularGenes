#!/bin/python
#Jan 2018 - Kuan-Lin Huang @ WashU

import sys
import getopt
import gzip

def main():
    def usage():
        print """
    .py : why do I exist?

    USAGE: .py [-h] <file>
     -h    print this message
     <filename>    input file
        """

    #use getopt to get inputs
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'h') #:after option meaning required arguments
    except getopt.GetoptError:
        print "format.py <input>"

    for opt, arg in opts: #store the input options
        if opt == '-h': # h means user needs help
            usage(); sys.exit()

    args = sys.argv[1:]
    if len(args) < 1:
        usage(); sys.exit("input file missing")

    #open input file
    try:
        fn = args[0]
        inputF = open(fn ,"r")
    except IOError:
        print("File , args[0], does not exist!")

    # batch number
    i = 1
    header = []
    geneIndex = {}

    #read input file
    for line in inputF:
        line=line.strip()
        F = line.split(",")

        if F[0].startswith("Month"): # set new header: to be melted 
            F = [s.replace(": (Worldwide)","") for s in F]
            header = F
            i = i + 1
            
        else:
            date=F[0]
            for k in range(1,len(F)):
                queryCount = str(F[k])
                print str(i) + "\t" + date + "\t" + header[k] + "\t" + queryCount + "\t" 

    inputF.close()


if __name__ == "__main__":
    main()
