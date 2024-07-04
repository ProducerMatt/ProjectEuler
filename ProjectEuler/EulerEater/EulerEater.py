#!/usr/bin/env python3

import sys
import argparse

parser = argparse.ArgumentParser(\
                    description="Checks answers to Project Euler problems.\
                                 Pass the problem # for info, and the     \
                                 problem # and target executable to test it.")
parser.add_argument('ID', metavar="ID", type=int, nargs='?', \
                    help="PE problem number")
parser.add_argument('Testee', metavar="Testee", nargs='?', type=argparse.FileType('rx'),\
                    help="Your program to be checked")

args = parser.parse_args()

print(args)

if args.ID == None:
    parser.print_help()
elif args.Testee == None:
    sleep(1)
    # TODO print problem API

Problems = {
    1: { "Variables": [
        { "N": "int" }
        ],
         "KnownAnswer": { "Given": { "N": 1000 },
                          "md5": "e1edf9d1967ca96767dcc2b2d6df69f4" }
         }
}
