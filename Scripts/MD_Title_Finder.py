import sys
import re
import requests
from datetime import datetime, date
from bs4 import BeautifulSoup

# Grabs the date of the next Saturday from passed arguement
sab_date = sys.argv[1]

sab_date = datetime.strptime(sab_date, "%m %d %Y")
sab_date = sab_date.strftime("%B %d")

# https://m.egwwritings.org/en/folders/1227
with open("Scripts/MD_URL.url", "r") as file:
	url = file.read().strip()

# Browser-like User-Agent header to avoid blocking
headers = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0.0.0 Safari/537.36"
    )
}

# Grabs HTML from page
response = requests.get(url, headers=headers)
if response.status_code == 404:
	print(response.status_code)
	sys.exit(1)

html = response.text
soup = BeautifulSoup(html, "html.parser")

# Finds html element with the date of the next Saturday
MD_Title = soup.find("a", string=re.compile(sab_date, re.IGNORECASE))

if not MD_Title:
	print("Could not find title")
	sys.exit(1)

MD_Title = MD_Title.get_text(" ", strip=True)

# splits the text before the title and the date using the ","
index = MD_Title.rfind(",")
MD_Title = MD_Title[:index]

print(MD_Title)
