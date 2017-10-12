#!/usr/local/bin/python2.7
#
# *** check fsu nodeq, if 'cant connect' then reconnect ***
# 
# update:
# 10/8/2017 first commit

import pynm

fsu = pynm.Test(debug=1, timeout=10)

print fsu.CheckFSU()
