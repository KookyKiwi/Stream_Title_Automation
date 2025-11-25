import sys
import re
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from datetime import datetime, date
from bs4 import BeautifulSoup

# Grabs the date of the next Saturday from passed arguement
sab_date = sys.argv[1]

sab_date = datetime.strptime(sab_date, "%m %d %Y")
sab_date = sab_date.strftime("%B %d")
month = sab_date.split(" ")
month_name = month[0]

# https://m.egwwritings.org/en/folders/1227
with open("Scripts/MD_URL.url", "r") as file:
    url = file.read().strip()

# Allows the browser to run headless and helps with performance
options = Options()
options.add_argument("--headless")
options.add_argument("--disable-gpu")
options.add_argument("--window-size=1920,1080")

# Calls chrome broswer and opens webpage
driver = webdriver.Chrome(options=options)
driver.get(url)

wait = WebDriverWait(driver, 500)

# Checks if page is loaded
try:
    wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "ul.toc")))
except TimeoutException:
    print("Error: Page elements never appeared.")
    driver.quit()
    sys.exit(1)

# Finds the button that is before the <a> tag containing the month
xpath = (
    f"//li[@class='has-children']/a"
    f"[starts-with(translate(normalize-space(text()), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'), "
    f"'{month_name.lower()}')]"
    f"/preceding-sibling::span[@class='toggle-btn']"
)


toggle_button = wait.until(EC.element_to_be_clickable((By.XPATH, xpath)))

# Clicks on button element and waits untill the content is loaded
toggle_button.click()

# XPath to the *UL* that gets filled after clicking
month_ul_xpath = (
    f"//li[@class='has-children']/a"
    f"[starts-with(translate(normalize-space(text()), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'), "
    f"'{month_name.lower()}')]"
    f"/following-sibling::ul"
)

month_ul = driver.find_element(By.XPATH, month_ul_xpath)

# Wait for THIS ul to fill up
wait.until(lambda d: len(month_ul.find_elements(By.TAG_NAME, "li")) > 0)

html = driver.page_source

# Sets Bs4 parser to html and uses source html from Selenium
soup = BeautifulSoup(html, "html.parser")

# Finds html element with the date of the next Saturday
MD_Title = soup.find("a", string=re.compile(sab_date, re.IGNORECASE))

if not MD_Title:
    print("Could not find title")
    driver.quit()
    sys.exit(1)

# Gets text and cleans the format and any enters are turned into spaces
MD_Title = MD_Title.get_text(" ", strip=True)

driver.quit()

# splits the text before the title and the date using the ","
index = MD_Title.rfind(",")
MD_Title = MD_Title[:index]

print("200")
print(MD_Title)
