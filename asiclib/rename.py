import glob
import re
import os
file_list = glob.glob('*.v')
for item in file_list:
    newfile = item.replace("oh_", "asic_")
    print (item, newfile)
    os.rename(item, newfile)
