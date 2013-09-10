from ctypes import cdll
import ctypes
import sys

def main(arg):
  lib = cdll.LoadLibrary('./libparser.so')
  print arg
  argv = (ctypes.c_char_p * (len(arg) + 1))()
  argv[:-1] = arg
  lib.parser(len(arg),argv) 

  
if __name__== "__main__":
 if len(sys.argv) < 2:
   print 'Usage: python <cfile> [outputfile]'
 main(sys.argv)
