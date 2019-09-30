import numpy as np
import os
import pandas as pd
import json
import urllib.request
import requests
import scipy.stats
from scipy.optimize import leastsq
from matplotlib import pyplot as plt

def createX(num):
    x = []
    for i in range(num):
        x.append(i+1)
    return np.array(x)

# Polynomial Regression
def polyfit(x, y, degree):
    results = {}

    coeffs = np.polyfit(x, y, degree)

     # Polynomial Coefficients
    results['polynomial'] = coeffs.tolist()

    # r-squared
    p = np.poly1d(coeffs)
    # fit values, and mean
    yhat = p(x)                         # or [p(z) for z in x]
    ybar = np.sum(y)/len(y)          # or sum(y)/len(y)
    ssreg = np.sum((yhat-ybar)**2)   # or sum([ (yihat - ybar)**2 for yihat in yhat])
    sstot = np.sum((y - ybar)**2)    # or sum([ (yi - ybar)**2 for yi in y])
    results['determination'] = ssreg / sstot

    return results

def rsquare(y,yhat):
    ybar = np.sum(y)/len(y)
    ssreg = np.sum((yhat-ybar)**2)   # or sum([ (yihat - ybar)**2 for yihat in yhat])
    sstot = np.sum((y - ybar)**2)
    if not sstot == 0:
        return ssreg / sstot
    else:
        return 0

def read(pair):
    try:
        df = pd.read_csv(pair+'.csv', header=None)
        return df[0]
    except Exception as e:
        return np.array([])

def send(pair,arr):
    url = 'http://localhost/transit/rsquare'
    data = {
        "pair":pair,
        "data":arr
    }
    headers = {
        'Content-Type': 'application/json',
        }
    #print(json.dumps(data))
    req = urllib.request.Request(url, json.dumps(data).encode(), headers)
    with urllib.request.urlopen(req) as res:
        body = res.read()

def slack(msg):
    WEB_HOOK_URL = "https://hooks.slack.com/services/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"
    requests.post(WEB_HOOK_URL, data = json.dumps({
    'text': msg,  #通知内容
    'username': u'.',  #ユーザー名
    }))

def graph (x,y,w):
    # xs = np.linspace(np.min(x),np.max(x),100)
    # ys = np.polyval(w,xs)
    #
    # fig = plt.figure()
    # ax = fig.add_subplot(111)
    # ax.scatter(x, y,label='input')
    # ax.plot(xs, ys, 'r-', lw=2, label='polyfit')
    # ax.set_title('polyfit w = [%.2f, %.2f, %.2f, %.2f, %.2f, %.2f]' % (w[0],w[1],w[2],w[3],w[4],w[5]))
    # ax.set_xlabel('x')
    # ax.set_ylabel('y')
    # ax.legend(loc='best',frameon=False)
    # ax.grid(True)
    plt.scatter(x , y)
    # `np.polyfit` で、4次式で近似
    plt.plot(x, np.poly1d(w)(x), label='graph', color="green")
    plt.show()

def outliers(data):
    outliers = []
    threshold=1.5
    mean = np.mean(data)
    std =np.std(data)

    for y in data:
        z_score= (y - mean)/std
        if np.abs(z_score) > threshold:
            outliers.append(y)
    return outliers

def outlier_distance(data,slope,intercept):
    a = slope * -1
    b = 1
    c = intercept * -1
    cnt = 1
    last_long = 0
    threshold = 1.5
    pos = 0
    neg = 0
    for y in data:
        val = a*cnt + b*y + c
        d = (np.abs(val)) /(np.sqrt(a*a + b*b))
        if d > threshold:
            if (cnt - last_long) > 10:
                last_long = cnt
                if val > 0:
                    pos += 1
                else:
                    neg += 1
        cnt += 1
    results = {}
    results["pos"] = pos
    results["neg"] = neg
    return results

def findDistance(y):
    x = createX(len(y))
    w1 = polyfit(x, y, 1)
    distance = outlier_distance(y,w1['polynomial'][0],w1['polynomial'][1])
    if (distance['pos'] > 1):
        slack(pair+" has concavity pos="+str(distance['pos'])+" neg="+str(distance['neg']))
    return distance

def existConcavity(y):
    period = 120
    step = 10
    start = 0
    interval = int((len(y)-period)/10)
    x = createX(period)
    exist = False

    for i in range(interval):
        stop = period+start
        current = y[start:stop]
        result = fitSin(current)
        rsquare = result["r2"]
        nu = result["nu"]
        if rsquare> 0.75 and nu > 0.6:
            exist = True
        start += step
    return exist

def fitSin(data):
    N = len(data) # number of data points
    t = np.linspace(0, 4*np.pi, N)

    guess_mean = np.mean(data)
    guess_std = 3*np.std(data)/(2**0.5)/(2**0.5)
    guess_phase = 0
    guess_freq = 1
    guess_amp = 1

    # we'll use this to plot our first estimate. This might already be good enough for you
    data_first_guess = guess_std*np.sin(t+guess_phase) + guess_mean

    # Define the function to optimize, in this case, we want to minimize the difference
    # between the actual data and our "guessed" parameters
    optimize_func = lambda x: x[0]*np.sin(x[1]*t+x[2]) + x[3] - data
    est_amp, est_freq, est_phase, est_mean = leastsq(optimize_func, [guess_amp, guess_freq, guess_phase, guess_mean])[0]

    # recreate the fitted curve using the optimized parameters
    data_fit = est_amp*np.sin(est_freq*t+est_phase) + est_mean

    # recreate the fitted curve using the optimized parameters

    result = {}
    result["r2"] = rsquare(data,data_fit)
    result["nu"] = est_freq

    # if result["r2"] > 0.75 and result["nu"] > 0.6:
    #     fine_t = np.arange(0,max(t),0.1)
    #     data_fit=est_amp*np.sin(est_freq*fine_t+est_phase)+est_mean
    #     plt.plot(t, data, '.')
    #     # plt.plot(t, data_first_guess, label='first guess')
    #     plt.plot(fine_t, data_fit, label=str(est_freq))
    #     plt.legend()
    #     plt.show()

    return result

def collect():
    pairs = np.array(["USDJPY","EURUSD","GBPJPY","EURJPY","AUDUSD","AUDJPY","NZDJPY"])
    #pairs = np.array(["GBPJPYg"])
    for pair in pairs:
        df = read(pair)
        if df.size != 0:
            normed = scipy.stats.zscore(df)
            #findDistance(normed)
            exist = existConcavity(normed)
            if exist == True:
                slack(pair+" is wave.")
            else:
                print(pair+" has no concavity")
            os.remove(pair+".csv")


collect()
