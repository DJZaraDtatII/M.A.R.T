#!/data/data/com.termux/files/usr/bin/env python
# -*- coding: utf-8 -*-
# File       : tools/data/xml_translator/gtranslate.py
# Author     : rendiix <vanzdobz@gmail.com>
# Create date: 19-Oct-2019 05:40
#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#   SUBROUTINES
#

# This subroutine extracts the string including html tags
# and may replace "root[i].text".  
# It cannot digest arbitrary encodings, so use it only if necessary.
def findall_content(xml_string, tag):
    pattern = r"<(?:\w+:)?%(tag)s(?:[^>]*)>(.*)</(?:\w+:)?%(tag)s" % {"tag": tag}
    return re.findall(pattern, xml_string, re.DOTALL)

# This subroutine calls Google translate and extracts the translation from
# the html request
def translate(to_translate, to_language="auto", language="auto"):
 # send request
 r = requests.get("https://translate.google.com/m?hl=%s&sl=%s&q=%s"% (to_language, language, to_translate.replace(" ", "+")))

 # set markers that enclose the charset identifier
 beforecharset='charset='
 aftercharset='" http-equiv'
 # extract charset 
 parsed1=r.text[r.text.find(beforecharset)+len(beforecharset):]
 parsed2=parsed1[:parsed1.find(aftercharset)]
 # Display warning when encoding mismatch 
 if(parsed2!=r.encoding):
     print('\x1b[1;31;40m' + 'Warning: Potential Charset conflict' )
     print(" Encoding as extracted by SELF    : "+parsed2)
     print(" Encoding as detected by REQUESTS : "+r.encoding+ '\x1b[0m')

 # Work around an AGE OLD Python bug in case of windows-874 encoding
 # https://bugs.python.org/issue854511
 if(r.encoding=='windows-874' and os.name=='posix'):
     print('\x1b[1;31;40m' + "Alert: Working around age old Python bug (https://bugs.python.org/issue854511)\nOn Linux, charset windows-874 must be labeled as charset cp874"+'\x1b[0m')
     r.encoding='cp874'

 # convert html tags  
 text=html.unescape(r.text)    
 # set markers that enclose the wanted translation
 before_trans = 'class="t0">'
 after_trans='</div><form'
 # extract translation and return it
 parsed1=r.text[r.text.find(before_trans)+len(before_trans):]
 parsed2=parsed1[:parsed1.find(after_trans)]
 return html.unescape(parsed2).replace("'", r"\'")



#
# MAIN PROGRAM
#

# import libraries
import html
import requests
import os
import xml.etree.ElementTree as ET
import sys
from io import BytesIO
import re

# read argument vector
INPUTLANGUAGE=sys.argv[1]
OUTPUTLANGUAGE=sys.argv[2]
INFILE=sys.argv[3]

class Base:
    # Foreground:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    # Formatting
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    # End colored text
    END = '\033[0m'
    NC ='\x1b[0m' # No Color

# create outfile name by appending the language code to the infile name
name, ext=os.path.splitext(INFILE)
OUTFILE= "{name}_{OUTPUTLANGUAGE}{ext}".format(name=name,OUTPUTLANGUAGE=OUTPUTLANGUAGE,ext=ext)

# read xml structure
tree = ET.parse(INFILE)
root = tree.getroot()

# cycle through elements 
for i in range(len(root)):
#	for each translatable string call the translation subroutine
#   and replace the string by its translation,
#   descend into each string array  
    isTranslatable=root[i].get('translatable')
    print(Base.OKGREEN + "\nLine ke   : " + Base.NC + Base.BOLD + (str(i)) + Base.END)
    if(isTranslatable=='false'):
        print(Base.WARNING + "Not translatable" + Base.END)
    if(root[i].tag=='string') & (isTranslatable!='false'):
# Here you might want to replace root[i].text by the findall_content function
# if you need to extract html tags
        # ~ totranslate="".join(findall_content(str(ET.tostring(root[i])),"string"))
        totranslate=root[i].text
        if(totranslate!=None):
            print(Base.OKGREEN + "Sumber    : " + Base.END + totranslate +Base.OKGREEN + "\nTerjemahan: " + Base.END, end='')
            root[i].text=translate(totranslate,OUTPUTLANGUAGE,INPUTLANGUAGE)
            print(root[i].text)
    if(root[i].tag=='string-array'):
        print("Entering string array...")
        for j in range(len(root[i])):
#	for each translatable string call the translation subroutine
#   and replace the string by its translation,
            isTranslatable=root[i][j].get('translatable')
            print(Base.OKGREEN + "\nLine ke " + Base.NC + Base.BOLD (str(i)+" " + str(j)) + Base.END)
            if(isTranslatable=='false'):
                print("Not translatable")
            if(root[i][j].tag=='item') & (isTranslatable!='false'):
# Here you might want to replace root[i].text by the findall_content function
# if you need to extract html tags
                # ~ totranslate="".join(findall_content(str(ET.tostring(root[i][j])),"item"))
                totranslate=root[i][j].text
                if(totranslate!=None):
                    print(Base.OKGREEN + "Sumber    : " + Base.END + totranslate +Base.OKGREEN + "\nTerjemahan: " + Base.END, end='')
                    root[i][j].text=translate(totranslate,OUTPUTLANGUAGE,INPUTLANGUAGE)
                    print(root[i][j].text)

# write new xml file
tree.write(OUTFILE, encoding='utf-8')

