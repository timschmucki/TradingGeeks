import getopt
import sys
import os
from selenium import webdriver
from selenium.webdriver.firefox.options import Options

def main(argumentlist):
    print("Scraping started")
    nrarguments = (len(argumentlist) - 1) / 2
    argumentlist = argumentlist[1:]
    try:
        short_options = "hk:s:e:"
        long_options = ["help", "searchey=", "startdate=", "enddate="]
        arguments, values = getopt.getopt(argumentlist, short_options, long_options)
    except getopt.GetoptError:
        print('tagi_args.py -k <searchkey> -s <startdate %d.%m-%Y> -e <enddate %d.%m-%Y>')
        sys.exit(2)

    for current_argument, current_value in arguments:
        if current_argument in ("-k", "--searchkey"):
            searchkey = current_value
        elif current_argument in ("-h", "--help") or nrarguments != 3:
            print('tagi_args.py -k <searchkey> -s <startdate %Y-%m-%d> -e <enddate %Y-%m-%d>')
            sys.exit()
        elif current_argument in ("-s", "--startdate"):
            strt = current_value
        elif current_argument in ("-e", "--enddate"):
            end = current_value

    if len(searchkey.split()) != 2:
        print("Two searchkeys needed. Only got one: '{}'".format(searchkey))
        sys.exit()

    dirname = os.path.dirname(__file__)  # dirname = "C:/Users/sdien/PycharmProjects/MyFCurve/Data/News"

    url = "https://zeitungsarchiv.nzz.ch/#archive"

    # Operating in headless mode
    opts = Options()
    opts.headless = True

    # Start Browser and search for articles in German containing words: Inflation, Arbeitsmarkt, Konjunktur
    browser = webdriver.Firefox(options=opts, executable_path=os.path.join(dirname, "geckodriver.exe"))
    browser.get(url)

    time.sleep(5)

    for date in daterange:
        print("Scraping articles from {}".format(date))
        datestr = date.strftime("%d.%m.%Y")

        key = browser.find_element_by_class_name("fup-archive-query-input")
        key.clear()
        key.send_keys(searchkey)

        time.sleep(1)

        beg = browser.find_element_by_class_name("fup-s-date-start")
        beg.clear()
        beg.send_keys(datestr)

        time.sleep(1)

        end = browser.find_element_by_class_name("fup-s-date-end")
        end.clear()
        end.send_keys(datestr)

        time.sleep(1)

        such = browser.find_element_by_class_name("fup-s-exec-search")
        such.click()

        time.sleep(10)

if __name__ == "__main__":
    main(sys.argv)

    #argumentlist = [sys.argv[0], "-k", "rezession schweiz", "-s", "2020-10-01", "-e", "2020-10-11"]
    #main(argumentlist)