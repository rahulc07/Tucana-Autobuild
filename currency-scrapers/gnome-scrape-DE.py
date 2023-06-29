from bs4 import BeautifulSoup
import requests
import sys
import re
from natsort import natsorted
from packaging.version import parse as parseVersion
import copy
#url=sys.argv[1]
#url="https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/"



def return_latest_ver(url):
  versions=[]
  page = requests.get(url).text
  doc = BeautifulSoup(page, "html.parser")
  links = doc.find_all('a')
  for link in links: 
    version = re.search(r'[0-9]+', link.string)
    if version:
       versions.append(copy.deepcopy(version.group()))
  versions.sort(key = parseVersion)
  print(versions)
  latest_ver=versions[-1]
  return latest_ver




url=sys.argv[1]
url2 = url + '/' + return_latest_ver(url)
print(url2)

page = requests.get(url2).text
doc = BeautifulSoup(page, "html.parser")
links = doc.find_all('a')
for link in links:
  print(link.string)


