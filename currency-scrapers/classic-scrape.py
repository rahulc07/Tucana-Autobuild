from bs4 import BeautifulSoup
import requests
import sys
url=sys.argv[1]
#url="https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/"

page = requests.get(url).text
doc = BeautifulSoup(page, "html.parser")
links = doc.find_all('a')
for link in links: 
 print(link.string)



