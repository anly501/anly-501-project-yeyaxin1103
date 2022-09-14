import numpy as np
import json

# READ FILE
f = open("/Users/yaxin/anly-501-project-yeyaxin1103/codes/01-data-gathering/api-keys.json")
input=json.load(f); #print(input)

# LOAD KEYS INTO API
consumer_key=input["consumer_key"]    
consumer_secret=input["consumer_secret"]    
access_token=input["access_token"]    
access_token_secret=input["access_token_secret"]    
bearer_token=input["bearer_token"]

import tweepy
# Set up Connection
auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth) 

#print username
my_user_name=api.verify_credentials().screen_name
print("username=",my_user_name)

import requests 

# Define search twitter function
def search_twitter(query, tweet_fields, bearer_token = bearer_token):
    headers = {"Authorization": "Bearer {}".format(bearer_token)}

    url = "https://api.twitter.com/2/tweets/search/recent?query={}&{}".format(query, tweet_fields)
    
    print("--------------",url,"--------------")
    response = requests.request("GET", url, headers=headers)
    #print(response.status_code)
    # print(response.text)

    if response.status_code != 200:
        raise Exception(response.status_code, response.text)
    return response.json()

json_response = search_twitter(query="east asia+fertility", tweet_fields="tweet.fields=text,author_id,created_at", bearer_token=bearer_token)

#print(json.dumps(json_response, indent=4, sort_keys=True))

with open("/Users/yaxin/anly-501-project-yeyaxin1103/codes/01-data-gathering/tweets_result.json", "w") as outfile:
    outfile.write(json.dumps(json_response, indent=4, sort_keys=True))

