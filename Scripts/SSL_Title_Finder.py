import re
import requests
from datetime import datetime, date, timedelta
from bs4 import BeautifulSoup

#Sets todays date
today = date.today()

#https://ssnet.org/study-guides/lesson-archives/2020-2029/2025-q4-lessons-of-faith-from-joshua/
with open("Scripts/SSL_URL.url", "r") as file:
	url = file.read().strip()

while True:
	# Get the HTML of the page
	html = requests.get(url)
	soup = BeautifulSoup(html.text, "html.parser")

	Dev_date = soup.find_all("span", class_="date")
	Dev_date = Dev_date[len(Dev_date)-1]
	Dev_date = Dev_date.get_text(strip=True) + " " + str(date.today().year)
	Dev_date = datetime.strptime(Dev_date, "%B %d %Y").date() + timedelta(days=1)

	if today <= Dev_date:
		break
	new_url = soup.find("a", string=re.compile("next", re.IGNORECASE))
	new_url = new_url["href"]
	index = url.rfind("/") + 1
	if ".." in new_url:
		index = url.rfind("/", 0, index-1)
		new_url = new_url[2:]
	url = url[:index] + new_url

with open("Scripts/SSL_URL.url", "w") as file:
	file.write(url)

# Find all elements that contain devotional titles
# (Inspect the page to find the right tag/class!)
titles = soup.find_all("h4", class_="text-center text-muted")

SSL = ""
# Print or store them
for title in titles:
	SSL = SSL + title.get_text(" ", strip=True)

lesson_match = re.search(r'lesson\s+(\d+)', SSL, re.IGNORECASE)
SSL_Num = int(lesson_match.group(1)) if lesson_match else None

index = SSL.find("-")
SSL_Title = SSL[index + 2:]

print(Dev_date)
print(int(SSL_Num))
print(SSL_Title)

