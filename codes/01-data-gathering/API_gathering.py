import pandas as pd
import os
import time
import requests
import json
import csv
from tqdm import tqdm

import tweepy

import requests
import pandas as pd
import os

api = pd.read_csv("twitter_api_info.txt")

# LOAD KEYS INTO API
consumer_key = api.at[0, 'Key']
consumer_secret = api.at[1, 'Key']
access_token = api.at[2, 'Key']
access_token_secret = api.at[3, 'Key']
bearer_token = api.at[4, 'Key']


import tweepy
# Set up Connection
auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

api = tweepy.API(auth) 

#print username
my_user_name=api.verify_credentials().screen_name
print("username=",my_user_name)

import requests 

api = tweepy.API(auth)
headers = {"Authorization": "Bearer {}".format(bearer_token)}

#print username
my_user_name = api.verify_credentials().screen_name
print("username=",my_user_name)



def search_twitter(query, tweet_fields, max_results, bearer_token = bearer_token):
    client = tweepy.Client(bearer_token=bearer_token)
    
    tweets = tweepy.Paginator(client.search_recent_tweets, query = query,
                              tweet_fields = tweet_fields, max_results=100).flatten(limit = max_results)
    
    tweet_dict = {}
    
    i = 1
    for t in tweets:
        tweet_dict['Tweet{}'.format(i)] = (t.data)
        i += 1
        
    return tweet_dict

# search term
query = "China Fertility OR Japan Fertility OR Korea Fertility OR East Asia Fertility OR Taiwan Fertility OR Hong Kong Fertility OR Mongolia Fertility"

# twitter fields to be returned by api call
tweet_fields = "text,author_id,created_at"

max_results = 1000

# twitter api call
json_response = search_twitter(query, tweet_fields, max_results)

# writing response json to local file
with open("../../data/00-raw-data/twitter_api_data/Tweets_EN.json", "w") as outfile:
    outfile.write(json.dumps(json_response, indent=4))



