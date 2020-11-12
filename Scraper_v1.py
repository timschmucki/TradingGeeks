# %% Setup
import getopt
import sys
import time
import math
import os

import numpy
import pandas as pd
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# %% Functions
def getCmdInput(argv):
    """ Parse the command line arguments. """
    argv = argv[1:]  # remove path (arg[0])

    # Get options and arguments from command line input
    try:
        opts, args = getopt.getopt(argv, "q:s:e:")
    except getopt.GetoptError as err:
        print("Command line error: {}".format(err))
        sys.exit(2)

    # Define variables
    for opt, arg in opts:
        if opt in ("-q"):
            searchquery = arg
        elif opt in ("-s"):
            start_date = arg
        elif opt in ("-e"):
            end_date = arg

    return searchquery, start_date, end_date


def selectSaveDir(searchquery):
    """ Select saving directory based on query. """

    if "schweiz" in searchquery.split():
        path = 'Data/News/NZZ/dom'
    else:
        path = 'Data/News/NZZ/for'

    return path


def initBrowser(url):
    """ Initialize selenium browser. """
    # Operating in headless mode
    opts = Options()
    opts.headless = False

    # Start Browser and search for articles in German containing words: Inflation, Arbeitsmarkt, Konjunktur
    browser = webdriver.Firefox(options=opts, executable_path=os.path.dirname(__file__) + "/geckodriver.exe")
    browser.get(url)

    time.sleep(5)

    return browser


def executeSearch(browser, searchquery, date):
    """ Populates NZZ archive mask and executes search. """
    # Convert date to correct format
    datestr = date.strftime("%d.%m.%Y")

    # Populate search mask
    query = browser.find_element_by_class_name("fup-archive-query-input")
    query.clear()
    query.send_keys(searchquery)

    time.sleep(1)

    strt = browser.find_element_by_class_name("fup-s-date-start")
    strt.clear()
    strt.send_keys(datestr)

    time.sleep(1)

    end = browser.find_element_by_class_name("fup-s-date-end")
    end.clear()
    end.send_keys(datestr)

    time.sleep(1)

    # Execute search
    such = browser.find_element_by_class_name("fup-s-exec-search")
    such.click()

    time.sleep(10)


def scrollToBottom(browser):
    """ Scolls to bottom of page to load all articles. """

    # Calculate number of hits for search query
    nr_hits = browser.find_element_by_class_name("fup-archive-result-hits").text
    nr_hits = int(nr_hits.split()[0])
    # try:
    #     pass
    # except Exception as err:
    #     print("Error reading nr of hits: ", err)
        # browser.refresh()

        # time.sleep(10)

        # nr_hits = browser.find_element_by_class_name("fup-archive-result-hits").text
        # nr_hits = int(nr_hits.split()[0])

    # Calculate number of scrolls
    nr_scrolls = math.ceil(nr_hits / 50)

    # Perform the scrolls
    for i in range(nr_scrolls):
        try:
            actions = ActionChains(browser)
            element = browser.find_elements_by_class_name("fup-common-scroll")[1]
            length = element.size["height"]
            browser.execute_script("arguments[0].scrollIntoView();", element)
            actions.move_to_element_with_offset(element, 4, length - 5)
            actions.click()
            actions.perform()
            WebDriverWait(browser, 5).until_not(EC.invisibility_of_element_located((By.CLASS_NAME, "fup-archive"
                                                                                                   "-result-loader")))
            time.sleep(2)

            print("Scrolling worked. Hits: {}, Clicks: {}".format(nr_hits, nr_scrolls))
        except Exception as err:
            print("Scrolling failed. Hits: {}, Clicks: {}".format(nr_hits, nr_scrolls))
            print("Err msg: ", err)
            break

def extractText(browser, date):
    """ Extracts text and title of newspaper archives. """
    parent = browser.find_elements_by_class_name("fup-archive-result-item")[1:]

    list_date = []
    list_text = []
    list_title = []

    for div in parent:
        title = div.find_element_by_class_name("fup-archive-result-item-article-title").get_attribute('innerHTML')
        text = div.find_element_by_class_name("fup-archive-result-item-article-text").get_attribute('innerHTML')
        list_date.append(date.strftime("%d.%m.%Y"))
        list_text.append(text)
        list_title.append(title)

    df = pd.DataFrame({'date': list_date, 'title': list_title, 'text': list_text})

    return df


# %% Main

def main():
    # Read command line input
    searchquery, start_date, end_date = getCmdInput(sys.argv)

    # Select saving directory based on query
    savedir = selectSaveDir(searchquery)  # path for saving data

    # Start selenium webdriver
    url = "https://zeitungsarchiv.nzz.ch/#archive"
    browser = initBrowser(url)
    print("Scraping NZZ archive...")

    # Loop through each day and scrape articles
    daterange = pd.date_range(start=start_date, end=end_date)
    for date in daterange:
        print(date)
        executeSearch(browser, searchquery, date)
        scrollToBottom(browser)

        df = extractText(browser, date)

        df.to_excel(savedir + "/" + searchquery + "_" + str(date.strftime("%Y%m%d")) + ".xlsx", index=False)

        time.sleep(2)

    browser.close()
    browser.quit()


# %% Run

if __name__ == "__main__":
    main()