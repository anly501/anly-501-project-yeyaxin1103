### IMPORT PACKAGES 
from sklearn.feature_extraction.text import CountVectorizer
import numpy as np
import string
import nltk
nltk.download('words')
import json
import re

# read json file as dictionary
with open ("../../data/00-raw-data/twitter_api_data/Tweets_EN.json") as tweetFile:
    tweets = json.load(tweetFile)


# extract all tweet texts from dict to a corpus list
def corpusTweets(t_dict):
    t_list = []
    for t in t_dict:
        t_list.append(t_dict[t]['text'])
    return t_list
        

tweet_corpus = corpusTweets(tweets)

# initiate count vectorizer
vectorizer = CountVectorizer()

# run count vectorizer on tweets corpus
new_tweets = vectorizer.fit_transform(tweet_corpus)

### EXPLORE THE OBJECT ATTRIBUTES 

# VOCABULARY DICTIONARY
print("vocabulary = ", vectorizer.vocabulary_)   

# STOP WORDS 
print("stop words =", vectorizer.stop_words)

# col_names
col_names=vectorizer.get_feature_names_out()
print("col_names=",col_names)

# corpus text cleaning
def corpus_cleaner(corpus):
    cleaned = []
    for s in corpus:
        if type(s) == np.float:
            return ""
        # lowercasing all the letters
        temp = s.lower()
        # removing hashtags and mentions
        temp = re.sub("@[A-Za-z0-9_]+","", temp)
        temp = re.sub("#[A-Za-z0-9_]+","", temp)
        # removing links
        temp = re.sub(r"http\S+", "", temp)
        temp = re.sub(r"www.\S+", "", temp)
        # removing punctuations
        temp = re.sub('[()!?]', ' ', temp)
        temp = re.sub('\[.*?\]',' ', temp)
        # removing non-alphanumeric characters
        temp = re.sub("[^a-z0-9]"," ", temp)
        # removing non-English words
        words = set(nltk.corpus.words.words())
        temp = " ".join(w for w in nltk.wordpunct_tokenize(temp) if w.lower() in words or not w.isalpha()) 
        # adding cleaned text to the corpus list
        cleaned.append(temp)
    return cleaned

tweet_corpus = corpus_cleaner(tweet_corpus)

with open("../../data/01-modified-data/tweetEN_corpus_clean", "w") as f:
    for text in tweet_corpus:
        # write each item on a new line
        f.write("%s\n" % text)