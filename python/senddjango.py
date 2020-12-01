import os
import pandas as pd
import json
import datetime
import urllib.request
import requests
#matplotlib.use('Agg')

pairs = ['USDJPY','NZDJPY','GBPJPY','AUDJPY','AUDUSD','EURJPY','EURUSD']

def fail_request(output):
    now = datetime.datetime.now()
    id = str(now.month)+str(now.day)+str(now.hour)+str(now.minute)
    df = pd.DataFrame(output)
    newpath = "django_fail/"+id+".csv"
    df.to_csv(newpath,header=False,index=False)

def read(file):
    try:
        df = pd.read_csv(file, header=None)
        return df
    except Exception as e:
        print(e)


def senddjango(pair):

    filename = pair+"_senddjango.csv"
    if not os.path.exists('./'+filename):
        return

    data = read(filename)

    pair = data.iloc[0][0]
    alert_at = data.iloc[0][1]
    detail = data.iloc[0][2]

    try:
        URL = "http://192.168.11.69:8000/api/result"
        requests.post(URL, data = json.dumps({
        'pair': pair,
        'alert_at': alert_at,
        'detail':detail
        }))
        os.remove(filename)
        return
    except Exception as e:
        print(e)
        fail_request(data)


for pair in pairs:
    senddjango(pair)
