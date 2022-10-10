### IMPORT PACKAGES 
from sklearn.feature_extraction.text import CountVectorizer
import numpy as np
import string
import nltk
# nltk.download('words')
# nltk.download('punkt')
# nltk.download('averaged_perceptron_tagger')
# nltk.download('wordnet')
# nltk.download('stopwords')
# nltk.download([
#     "names",
#     "stopwords",
#     "state_union",
#     "twitter_samples",
#     "movie_reviews",
#     "averaged_perceptron_tagger",
#     "vader_lexicon",
#     "punkt",
#     "omw-1.4"
# ])
import json
import re
from nltk.sentiment import SentimentIntensityAnalyzer


# read json file as dictionary
with open ("../../data/00-raw-data/twitter_api_data/Tweets_EN.json") as tweetFile:
    tweets1 = json.load(tweetFile)
    
with open ("../../data/00-raw-data/twitter_api_data/Tweets_EN2.json") as tweetFile:
    tweets2 = json.load(tweetFile)



# Read JSON file to pandas dataframe
import pandas as pd

def json_to_df(json_response):
    text = []
    id = []
    author_id = []
    created_at = []
    for tweet in json_response:
        text.append(json_response[tweet]['text'])
        id.append(json_response[tweet]['id'])
        author_id.append(json_response[tweet]['author_id'])
        created_at.append(json_response[tweet]['created_at'])
    df = pd.DataFrame({'author_id':author_id, 'id':id, 'created_at':created_at, 'text':text, 'clean_text':text})
    return df   


df1 = json_to_df(tweets1)
df2 = json_to_df(tweets2)

# merge df1 and df2 into one df
df = pd.concat([df1, df2])

def text_cleaner(text):
    text = text.lower()
    # removing hashtags and mentions
    text = re.sub("@[A-Za-z0-9_]+"," ", text)
    text = re.sub("#[A-Za-z0-9_]+"," ", text)
    # removing links
    text = re.sub(r"http\S+", " ", text)
    text = re.sub(r"www.\S+", " ", text)
    # removing punctuations
    text = re.sub('[()!?]', ' ', text)
    text = re.sub('\[.*?\]',' ', text)
    text = re.sub('[0-9]+', ' ', text)
    # removing non-alphanumeric characters
    text = re.sub("[^a-z0-9]"," ", text)
    return text


# ------------- Text Cleaning --------------

# Cleaning text
df['clean_text'] = df['clean_text'].apply(lambda x: text_cleaner(x))

# Remove words that have less than 3 characters
df['clean_text'] = df['clean_text'].apply(lambda x: " ".join([w for w in x.split() if len(w)>3]))

# Tokenization
def tokenization(text):
    text = re.split('\W+', text)
    return text

df['tweet_tokenized'] = df['clean_text'].apply(lambda x: tokenization(x.lower()))

# remove stopwords
def remove_stopwords(text):
    # remove stopwords
    stopwords = nltk.corpus.stopwords.words('english')
    text = [word for word in text if word not in stopwords]
    return text

df['tweet_nonstop'] = df['tweet_tokenized'].apply(lambda x: remove_stopwords(x))

# Stemming 
ps = nltk.PorterStemmer()

def stemming(text):
    text = [ps.stem(word) for word in text]
    return text

df['tweet_stemmed'] = df['tweet_nonstop'].apply(lambda x: stemming(x))

# Lemmatization
wordnet = nltk.WordNetLemmatizer()

def lemmatizer(text):
    text = [wordnet.lemmatize(word) for word in text]
    return text

df['tweet_lemmatized'] = df['tweet_nonstop'].apply(lambda x: lemmatizer(x))

# labeling data
sia = SentimentIntensityAnalyzer()

def sentiment_label(df, colName):
    sentiment = []
    label = []
    for txt in df[colName]:
        score = (sia.polarity_scores(txt))['compound']
        sentiment.append(score)
        if score >= 0.05:
            label.append("positive")
        elif score < 0.05 and score > -0.05:
            label.append("neutral")
        else:
            label.append("negative")
    df['sentiment'] = sentiment
    df['label'] = label
    return df

df = sentiment_label(df, 'clean_text')