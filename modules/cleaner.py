import os
import pandas as pd
import numpy as np
import time
import textwrap
import matplotlib
from matplotlib import pyplot as plt
import seaborn as sns
from wordcloud import WordCloud

import re
from textblob import TextBlob
from nltk import WordNetLemmatizer
from nltk.tokenize import word_tokenize, sent_tokenize
from nltk.corpus import stopwords


# import nltk
# nltk.download('stopwords')
# nltk.download('punkt')
# nltk.download('wordnet')

# %% Functions
def clean_texts(text_col):
    start_time = time.time()
    print("Cleaning {} texts...".format(len(text_col)))

    # define stop words
    stop_words = set(stopwords.words('english'))
    stop_words.update(('wwwsnbchsnbsnbchzurich', 'press', 'relationspo', 'box', 'zurichtelephone',
                       'suisse', 'swiss', 'schweizerische', 'svizzera', 'national', 'nationale', 'naziunala',
                       'nazionale', 'bank', 'banca', 'nationalbankbanque', 'pcommunicationspo', 'ch', 'suissebanca',
                       'svizzerabanca', 'svizraswiss', 'release', 'svizrapress', 'communicationssnbchberne',
                       
                       '@oekonomenstimme', '@ifo_Institut','ifoinstitut', '#KOFBulletin', 'kofeth', 'kofethen', 
                       'kof', ))

    # clean on tweet level
    text_col = text_col.apply(lambda x: re.sub(r'', '', x))  #
    text_col = text_col.apply(lambda x: re.sub(r'\w+:\/{2}[\d\w-]+(\.[\d\w-]+)*(?:(?:\/[^\s/]*))*', '', x))  # rm links
    text_col = text_col.apply(lambda x: re.sub('[^A-Za-z0-9 ]+', '', x))  # remove special characters
    text_col = text_col.apply(lambda x: re.sub('[^A-Za-z ]+', '', x))  # remove numbers
    text_col = text_col.apply(lambda x: x.lower())  # convert to lower

    # Clean at word level
    tokens = text_col.apply(lambda x: [w for w in word_tokenize(x)])  # splits text_col into tokens / words.
    tokens = tokens.apply(lambda x: [w for w in x if w not in stop_words])  # remove stopwords
    tokens = tokens.apply(lambda x: [WordNetLemmatizer().lemmatize(t) for t in x])  # lemmatize tokens
    text_col = tokens.apply(lambda x: ' '.join(x))  # lemmatize tokens

    text_col = text_col.apply(lambda x: re.sub(r"\b[a-zA-Z]\b", "", x))  # remove all single

    print("Cleaning done --- runtime {} s ---".format(int(round(time.time() - start_time, 0))))

    return text_col


def get_sentiment(text_col):
    date = text_col.date
    text_col = text_col.text_clean
    start_time = time.time()
    print("Calculating sentiment of {} texts...".format(len(text_col)))

    polarity = text_col.apply(lambda x: TextBlob(x).sentiment.polarity)
    subjectivity = text_col.apply(lambda x: TextBlob(x).sentiment.subjectivity)

    print("Calculation finished  --- runtime {} s ---".format(int(round(time.time() - start_time, 0))))
    
    #save trading signals with rule based on sentiment scores
    trading_signals = pd.concat([date, polarity], axis=1)
    
    conditions = [(trading_signals['text_clean']>=0.5),  #buy signal
                  (trading_signals['text_clean']<=-0.5)] #sell signal
    values = [1,-1]
    
    trading_signals['signal'] = np.select(conditions, values) #new dataframe with buy and sell signals
    trading_signals[['date','signal']].to_csv('data/twitter_signals.csv')


    return polarity, subjectivity



def plot_wordcloud(text_col):
    text = ' '.join(text_col)
    # stop_words = ["covid19", "coronavirus"]

    wordcloud = WordCloud(width=2000, height=1000, collocations=False, background_color="white").generate(text)

    plt.figure(figsize=(18, 10))
    plt.title("Top Words")
    plt.imshow(wordcloud, interpolation='bilinear')
    plt.axis("off")
    plt.savefig('data/wordcloud.png')

# def plot_sentiment_dist(sent_col):
#     sns.distplot(sent_col)
#     plt.title("Distribution of sentiment")
#     plt.show()

def plot_sentiment_dev(sent_col, date_col):
    plt.figure(figsize=(18, 10))
    dates = matplotlib.dates.date2num(date_col)
    matplotlib.pyplot.plot_date(dates, sent_col)
    plt.title("Sentiment Score over time")
    
    # define the buy and sell signals in the plot
    buy = plt.axhspan(0.5, 1, facecolor='#deffe8', edgecolor = '#00691f', label='test') 
    sell = plt.axhspan(-0.5, -1, facecolor='#ffdbdb', edgecolor = '#ad3232')
    
    plt.legend([buy, sell], ["Good Sentiment (buy signal)", "Bad Sentiment (sell signal)"], loc=9)
    
    plt.savefig('data/sentiment_dev.png')



# %% Main
def clean_twitter():
    # Cleaning
    data_dir = "data/"
    df = pd.read_excel(data_dir + 'twitter_data.xlsx', index_col=0)
    df['date'] = pd.to_datetime(df['date'])

    df['text_clean'] = clean_texts(df['text'])
    df['polarity'], df['sent'] = get_sentiment(df[['date','text_clean']])

    df = df[df['sent'] != 0]

    # df = df.groupby('filename').agg({'date': 'first',
    #                                  'polarity': 'mean',
    #                                  'sent': 'mean',
    #                                  'text': lambda x: ''.join(x),
    #                                  'text_clean': lambda x: ','.join(x)})

    # EDA
    # print(df.text_clean[90])

    # plot_missing_values(df)
    # pd.Series(' '.join(df['text']).split()).value_counts()[:10].plot.bar()
    # pd.Series(' '.join(df['text_clean']).split()).value_counts()[:10].plot.bar()
    plot_wordcloud(df['text_clean'])
    
    # plot_sentiment_dist(df['sent'])
    plot_sentiment_dev(df['polarity'], df['date'])

