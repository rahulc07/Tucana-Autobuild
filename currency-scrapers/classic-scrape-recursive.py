from bs4 import BeautifulSoup
import requests
import sys
import re
from natsort import natsorted
from packaging.version import parse as parseVersion
from distutils.version import StrictVersion
import copy
#url=sys.argv[1]
#url="https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/"



def return_versions(url):
  versions=[]
  page = requests.get(url).text
  doc = BeautifulSoup(page, "html.parser")
  links = doc.find_all('a')
  for link in links: 
    version = link.string
    print(version)




url=sys.argv[1]
return_versions(url)


