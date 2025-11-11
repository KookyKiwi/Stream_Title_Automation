import sys
import re
import requests
from datetime import datetime, date
from bs4 import BeautifulSoup

#Grabs the date of the next Saturday from passed arguement
sab_date = sys.argv[1]

sab_date = datetime.strptime(sab_date, "%m %#d %Y")
sab_date = sab_date.strftime("%B %#d")

#https://m.egwwritings.org/en/folders/1227
with open("Scripts/.MD_URL", "r") as file:
	url = file.read().strip()

#Grabs HTML from page
html = requests.get(url)
soup = BeautifulSoup(html.text, "html.parser")

MD_Title = soup.find("a", string=re.compile(sab_date, re.IGNORECASE))
MD_Title = MD_Title.get_text(" ", strip=True)

index = MD_Title.rfind(",")
MD_Title = MD_Title[:index]

print(MD_Title)
