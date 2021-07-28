import glob
import re
import os

file_list = glob.glob('*.v')
for item in file_list:
    f = open(item, "r")
    newfile = item+".tmp"
    f2 = open(newfile, "w")
    for line in f:
        if re.search(r'module\s+(\w+)', line) :
            line = line.rstrip() + " #(parameter PROP = \"DEFAULT\")"
        f2.write(line)
        print(line)
    f.close()
    f2.close()
    os.rename(newfile, item)
