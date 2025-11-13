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
	# Browser-like User-Agent header to avoid blocking
	headers = {
    	"User-Agent": (
			"Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
			"AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/120.0.0.0 Safari/537.36"
		)
	}

	# Get the HTML of the page
	response = requests.get(url, headers=headers)
	if response.status_code == 404:
		print(response.status_code)
		break
	
	html = response.text
	soup = BeautifulSoup(html, "html.parser")

	Dev_date = soup.find_all("span", class_="date")
	Dev_date = Dev_date[len(Dev_date)-1]
	Dev_date = Dev_date.get_text(strip=True) + " " + str(date.today().year)
	Dev_date = datetime.strptime(Dev_date, "%B %d %Y").date() + timedelta(days=1)

	# Checks if today is before or is the devotional date
	if today <= Dev_date:
		break
	# Gets the new url link from the next page button
	new_url = soup.find("a", string=re.compile("next", re.IGNORECASE))
	new_url = new_url["href"]

	index = url.rfind("/") + 1
	
	# checks if the relative link has ../ so it changes the parent directory
	if ".." in new_url:
		index = url.rfind("/", 0, index-1)
		new_url = new_url[2:]
	url = url[:index] + new_url

# if the page does work then saves the url to the SSL url file
if response.status_code == 200:
	with open("Scripts/SSL_URL.url", "w") as file:
		file.write(url)
	print(response.status_code)

# Find all elements that contain devotional titles
# (Inspect the page to find the right tag/class!)
titles = soup.find_all("h4", class_="text-center text-muted")

SSL = ""
# Print or store them
for title in titles:
	SSL = SSL + title.get_text(" ", strip=True)

# Finds the lesson number
lesson_match = re.search(r'lesson\s+(\d+)', SSL, re.IGNORECASE)
SSL_Num = int(lesson_match.group(1)) if lesson_match else None

# After the lesson number finds the "-" and copies title after it
index = SSL.find("-")
SSL_Title = SSL[index + 2:].strip() if index != -1 else "Unkown Title"

print(Dev_date)
print(int(SSL_Num))
print(SSL_Title)

