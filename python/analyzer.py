import os
import numpy as np
import pandas as pd
import scipy.stats
import datetime
from datetime import datetime as dt
import requests
import json
#matplotlib.use('Agg')

def r2(y,yhat):
    ybar = np.sum(y)/len(y)
    ssreg = np.sum((yhat-ybar)**2)   # or sum([ (yihat - ybar)**2 for yihat in yhat])
    sstot = np.sum((y - ybar)**2)
    if not sstot == 0:
        return ssreg / sstot
    else:
        return 0

def read(file):
    try:
        df = pd.read_csv(file, header=None)
        return df
    except Exception as e:
        print(e)

def save(name,r,suffix):
    df = pd.DataFrame(r)
    newpath = "C:/Program Files/MetaTrader 4/MQL4/Files/"+name+"_"+suffix+".csv"
    df.to_csv(newpath,header=False,index=False)

def set_mean_estimate(target_dt):
    filename = str(target_dt.year)+"_"+str(target_dt.month)+"_"+str(target_dt.day)+"_predicts.csv"

    if not os.path.exists('./'+filename):
        return
    data = read(filename)

    # 7 pair x 25 minutes = 175
    if (data[0].count() < 175):
        return

    actual = data.iloc[175:]
    x_0,x_1 = t(actual.values)

    df = pd.DataFrame([[x_0,x_1]])
    newpath = "C:/Program Files/MetaTrader 4/MQL4/Files/mean_estimate.csv"
    df.to_csv(newpath,header=False,index=False)


def logr(pair,r,frm,last):
    newpath = "C:/python/"+pair+"_"+str(frm.month)+"_"+str(frm.day)+"_logs.csv"
    df = pd.DataFrame({'frm':[str(frm.hour)+":"+str(frm.minute)],
    'to':[str(last.hour)+":"+str(last.minute)],
    'r':[r]})
    df.to_csv(newpath, mode='a', header=False,index=False)

def save_predict(val, frm):
    newpath = "C:/python/"+str(frm.year)+"_"+str(frm.month)+"_"+str(frm.day)+"_predicts.csv"
    df = pd.DataFrame({'val':[val]})
    df.to_csv(newpath, mode='a', header=False,index=False)

def set_resquare(pair,target_dt):

    filename = pair+"_"+str(target_dt.month)+"_"+str(target_dt.day)+"_ticks.csv"
    if not os.path.exists('./'+filename):
        return

    data = read(filename)
    # datetime型に変換
    data[0] = data[0].apply(lambda x: dt.strptime(x, '%Y-%m-%d %H:%M:%S'))
    # microseconds列をゼロ埋めしてから、1秒以下を出力
    data['microsecond'] = data[1].apply(lambda x: int(((str(x)).zfill(8))[2:8]))
    # 生成したmicrosecondsでdatetimeオブジェクトを更新
    data[0] = data.apply(lambda x: x[0].replace(microsecond=x['microsecond']), axis=1)
    #最後の時間
    last = data[0][data.index[-1]]

    #ラスト15分を取得
    frm = last - datetime.timedelta(minutes=15)
    filtered = data[(data[0] >= frm) & (data[0] <= last)]

    x = list(range(1, len(filtered[2])+1))
    w = np.poly1d(np.polyfit(x, filtered[2], 1))(x)
    #print("pair="+pair+" r2="+str([r2(filtered[2],w)]))
    r = r2(filtered[2],w)
    print(pair+" r="+str(r))
    save(pair,[r],"r")
    #print("saving log")
    logr(pair,r,frm,last)

def set_highRnum(pair,target_dt):
    filename = pair+"_"+str(target_dt.month)+"_"+str(target_dt.day)+"_logs.csv"
    if not os.path.exists('./'+filename):
        print(filename+" DNE")
        return
    data = read(filename)
    last5 = data.tail(5)
    highrnum = (last5[2] > 0.6).sum()
    print(pair+" rnum="+str(highrnum))
    save(pair,[highrnum],"last5r")


pairs = ['USDJPY','NZDJPY','GBPJPY','AUDJPY','AUDUSD','EURJPY','EURUSD']
target_dt = datetime.datetime.now()
#target_dt = datetime.date(2020, 6, 22)

def max_height(data, within):
    dmax = 0
    cmax = 0
    for i in range(len(data)):
        if (i + within < len(data)):
            cmax = abs(data[i + within] - data[i])
            if (cmax > dmax):
                dmax = cmax
        else:
            return dmax
    return None

def corr(data):
    x = np.arange(len(data))
    return abs(data.corr(pd.Series(x)))

def t(samples):
    # 標本分散
    S2 = np.var(samples, ddof=1)
    # 標本サイズ
    N = len(samples)
    # 標本平均
    sample_mean = np.mean(samples)

    # 自由度N-1のt分布の上側2.5%点
    t_a = scipy.stats.t.ppf(0.975, N - 1)

    # 信頼区間
    x_0 = sample_mean - (t_a * (np.sqrt(S2 / N)))
    x_1 = sample_mean + (t_a * (np.sqrt(S2 / N)))

    return x_0, x_1

def predict_ff(pair, target_dt):
    # filename = pair+"_9_11_ticks.csv"

    filename = pair+"_"+str(target_dt.month)+"_"+str(target_dt.day)+"_ticks.csv"
    if not os.path.exists('./'+filename):
        return

    data = read(filename)
    # datetime型に変換
    data[0] = data[0].apply(lambda x: dt.strptime(x, '%Y-%m-%d %H:%M:%S'))
    # microseconds列をゼロ埋めしてから、1秒以下を出力
    data['microsecond'] = data[1].apply(lambda x: int(((str(x)).zfill(8))[2:8]))
    # 生成したmicrosecondsでdatetimeオブジェクトを更新
    data[0] = data.apply(lambda x: x[0].replace(microsecond=x['microsecond']), axis=1)
    #最後の時間
    last = data[0][data.index[-1]]

    #ラスト30分を取得
    frm = last - datetime.timedelta(minutes=30)
    filtered = data[(data[0] >= frm) & (data[0] <= last)]

    dateTimeIndex = pd.DatetimeIndex(filtered[0])
    filtered.index = dateTimeIndex
    sample = filtered.drop([0,1,'microsecond'],axis=1)

    # 前後の値から線形補間　時間を考慮
    resampled = sample.resample('S').mean().interpolate('time')
    resampled[2] = scipy.stats.zscore(resampled[2])
    resample_size = 1500
    resampled = resampled.tail(resample_size)

    resampled = resampled.reset_index()
    resampled = resampled.drop([0],axis=1)

    within = 1
    height = resampled.apply(lambda row: max_height(list(row), within))
    coef = resampled.apply(lambda row: corr(row))
    std = resampled.apply(lambda row: np.array(row).std())

    url = "http://192.168.11.69:8000/api/predict?height="+str(height[2])+"&coef="+str(coef[2])+"&std="+str(std[2])
    #requests.getを使うと、レスポンス内容を取得できるのでとりあえず変数へ保存
    response = requests.get(url)
    #response.json()でJSONデータに変換して変数へ保存
    jsonData = response.json()
    #このJSONオブジェクトは、連想配列（Dict）っぽい感じのようなので
    #JSONでの名前を指定することで情報がとってこれる
    prediction = jsonData["predict"]

    save(pair,[prediction],"r")

    save_predict(prediction,frm)

def predict_badday(target_dt):
    filename = str(target_dt.month)+"_"+str(target_dt.day)+"_serials.csv"
    if not os.path.exists('./'+filename):
        return

    data = read(filename)
    # datetime型に変換
    data[0] = data[0].apply(lambda x: dt.strptime(x, '%Y-%m-%d %H:%M:%S'))
    # microseconds列をゼロ埋めしてから、1秒以下を出力
    data['microsecond'] = data[1].apply(lambda x: int(((str(x)).zfill(8))[2:8]))
    # 生成したmicrosecondsでdatetimeオブジェクトを更新
    data[0] = data.apply(lambda x: x[0].replace(microsecond=x['microsecond']), axis=1)
    #最後の時間
    last = data[0][data.index[-1]]

    #ラスト30分を取得
    frm = last - datetime.timedelta(minutes=30)
    filtered = data[(data[0] >= frm) & (data[0] <= last)]

    dateTimeIndex = pd.DatetimeIndex(filtered[0])
    filtered.index = dateTimeIndex
    sample = filtered.drop([0,1,'microsecond'],axis=1)

    # 前後の値から線形補間　時間を考慮
    resampled = sample.resample('S').mean().interpolate('time')
    resampled[2] = scipy.stats.zscore(resampled[2])
    resample_size = 1500
    resampled = resampled.tail(resample_size)

    resampled = resampled.reset_index()
    resampled = resampled.drop([0],axis=1)

    within = 1
    height = resampled.apply(lambda row: max_height(list(row), within))
    coef = resampled.apply(lambda row: corr(row))
    std = resampled.apply(lambda row: np.array(row).std())

    url = "http://192.168.11.69:8000/api/predict?height="+str(height[2])+"&coef="+str(coef[2])+"&std="+str(std[2])
    #requests.getを使うと、レスポンス内容を取得できるのでとりあえず変数へ保存
    response = requests.get(url)
    #response.json()でJSONデータに変換して変数へ保存
    jsonData = response.json()
    #このJSONオブジェクトは、連想配列（Dict）っぽい感じのようなので
    #JSONでの名前を指定することで情報がとってこれる
    prediction = jsonData["predict"]

    save(pair,[prediction],"r")

    save_predict(prediction,frm)

predict_badday(target_dt)
#for pair in pairs:
    #predict_ff(pair,target_dt)

set_mean_estimate(target_dt)
set_highRnum("USDJPY",target_dt)
