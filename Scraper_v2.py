# %% Setup
import getopt
import sys
import datetime as dt
import os
import openpyxl  # requred dependency!

import pandas as pd
import tweepy as tw
from tweepy import OAuthHandler


# %% Functions
def getCmdInput(argv):
    """ Parse the command line arguments. """
    argv = argv[1:]  # remove path (arg[0])
    # Get options and arguments from command line input
    try:
        short_options = "s:e:"
        long_options = ["startdate=", "enddate="]
        opts, args = getopt.getopt(argv, short_options, long_options)
    except getopt.GetoptError as err:
        print("Command line error: {}".format(err))
        print('Use: Scraper.py -s <startdate %d-%m-%Y> -e <enddate %d-%m-%Y>')
        sys.exit(2)

    # Define variables
    for opt, arg in opts:
        if opt in ("-s", "--startdate"):
            start_date = arg
        elif opt in ("-e", "--enddate"):
            end_date = arg

    return start_date, end_date


def init_api():
    """ Initializes twitter API. """
    # Twitter credentials
    consumer_key = '32cWJQQEPcgzWsmGvdaJMkmm7'
    consumer_secret = 'fv5lHHijgxuwSSYvq5ta0a8ae7oxc4J6wDbPCqXCyTtGSMS7pV'
    access_key = '1272871921315610624-nN40YfAWPTJLY9C46ONuuJnwr7X2G0'  # Private: Stefan Diener
    access_secret = 'R9OxEoTq9kuP5GbYT0B2auqIJGL1PUeOC744ATCKl8XxG'  # Private: Stefan Diener

    # Pass your twitter credentials to tweepy via its OAuthHandler
    auth = OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_key, access_secret)
    api = tw.API(auth, wait_on_rate_limit=True, wait_on_rate_limit_notify=True)

    return api


def convert_to_df(cursor_obj):
    """ Converts tweepy cursor object to pandas dataframe. """
    data = []

    for tweet in cursor_obj:
        username = tweet.user.screen_name
        date = tweet.created_at
        text = tweet.text
        hashtags = tweet.entities['hashtags']

        # append to data list
        ith_tweet = [username, date, text, hashtags]

        data.append(ith_tweet)

    # convert to dataframe
    df = pd.DataFrame(columns=['username', 'date', 'text', 'hashtags'], data=data)

    return df


# %% Main

def main():
    data_dir = 'data/'
    # Read command line input
    start_date, end_date = getCmdInput(sys.argv)
    username = '@financialtimes'  # + @WSJ, @business (bloomberg), @FT
    max_tweets = 100

    api = init_api()
    tweets = tw.Cursor(api.user_timeline, id=username).items(max_tweets)



    df = convert_to_df(tweets)
    df.to_excel('{}/tweet_df_{}.xlsx'.format(data_dir, str(dt.date.today()), index=False))


# %% Run

if __name__ == "__main__":
    main()
