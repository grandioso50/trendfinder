import os
import sys
import numpy as np
import pandas as pd
import scipy.stats
from matplotlib import pyplot as plt
import matplotlib
import math
import datetime
from datetime import datetime as dt
import matplotlib.dates as mdates
from sklearn.preprocessing import MinMaxScaler
from pandas.plotting import register_matplotlib_converters
from numpy import diff
import statistics
from scipy import stats

register_matplotlib_converters()
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

def polyfit(pair,at,period):
    y = read(pair+'.csv',at,period)
    normed_y = scipy.stats.zscore(y)
    x = list(range(1, len(normed_y)+1))
    #2次元式で多項回帰
    w = np.poly1d(np.polyfit(x, normed_y, 2))(x)

    plt.figure()
    # プロット
    plt.plot(x,normed_y, label=pair)
    plt.plot(x,w, label=r2(normed_y,w), color="red")
    # 凡例の表示
    plt.legend()
    # プロット表示(設定の反映)
    plt.show()
    #return r2(normed_y,w)

def save(name,output):
    rename = name.replace(':', '-')
    df = pd.DataFrame(output)
    newpath = "processed/"+rename+".csv"
    df.to_csv(newpath,header=False,index=False)

#微分のゼロ点インデックスを取得
def extrema(x,y):
    dydx = diff(y)/diff(x)
    dydx = [abs(i) for i in dydx]
    return dydx.index(min(dydx))

#ターニングポイントリストを生成
def get_tp(sample,window_size):
    print("retrieving turning points")
    #sampleを時系列順にwindow_size分走査
    #二次元曲線に回帰させてr2が0.7以上かつamplitudeが一定以上を取得
    #微分したゼロ点の時間をリストに追加

def priceToPips(pair,price):
    base = pair[-3:]
    if base == "JPY":
        pips = price/0.01
    else:
        pips = price/0.0001
    return pips

def graph(pair, month, date, hr_0,min_0,hr_1,min_1):
    raw = read(pair+"_"+str(month)+"_"+str(date)+"_ticks.csv")

    # datetime型に変換
    raw[0] = raw[0].apply(lambda x: dt.strptime(x, '%Y-%m-%d %H:%M:%S'))
    # microseconds列をゼロ埋めしてから、1秒以下を出力
    raw['microsecond'] = raw[1].apply(lambda x: int(((str(x)).zfill(8))[2:8]))
    # 生成したmicrosecondsでdatetimeオブジェクトを更新
    raw[0] = raw.apply(lambda x: x[0].replace(microsecond=x['microsecond']), axis=1)

    data = pd.DataFrame({'time':raw[0],'bid':raw[2]})

    #期間抽出
    frm = datetime.datetime(2020,month,date,hr_0,min_0)
    to = datetime.datetime(2020,month,date,hr_1,min_1)
    filtered = data[(data['time'] >= frm) & (data['time'] <= to)]
    filtered_indices = filtered.index
    filtered = filtered.reset_index()
    #正規化
    normed_bid = scipy.stats.zscore(filtered['bid'])

    x = list(range(1, len(filtered['bid'])+1))
    w = np.poly1d(np.polyfit(x, filtered['bid'], 1))(x)

    #転換した時間
    converted_at = filtered['time'][extrema(x,w)]

    plt.figure()
    # プロット
    plt.plot(filtered['time'],filtered['bid'], label=pair)
    plt.plot(filtered['time'],w,label=r2(filtered['bid'],w), color="red")
    slope, intercept, r_value, p_value, std_err = stats.linregress(x,filtered['bid'])
    print("slope="+str(slope))
    max_pip = priceToPips(pair,max(filtered['bid']))
    min_pip = priceToPips(pair,min(filtered['bid']))
    print("pips="+str(max_pip-min_pip))
    print("r-squared="+str(r_value**2))

    plt.grid(which='major',color='black',linestyle='-')
    # 凡例の表示
    plt.legend()
    # プロット表示(設定の反映)
    plt.show()

    pd.set_option('display.max_rows', None)
    #print(data[21430:21634])

    #間隔の取得
    filtered_raw = raw[min(filtered_indices):max(filtered_indices)]
    filtered_raw = filtered_raw.reset_index()
    interval = []
    t = []
    for index,row in filtered_raw.iterrows():
        #間隔
        if not index is 0:
            if row[1] < t[len(t)-1]:
                delta = 60000000 + row[1]-t[len(t)-1]
            else :
                delta = row[1]-t[len(t)-1]
                interval.append(delta/1000000)
                t.append(row[1])

                #昇順にソート
                #interval.sort()
                #mean = statistics.mean(interval)
                #std = statistics.stdev(interval)
                ##3σ離れた大きい外れ値を除外
                #interval = [e for e in interval if e < (3*std)+mean]

                #[print(e) for e in interval]
                #[print(e) for e in interval]
                print("ticks="+str(len(interval)+1))
                x = list(range(1, len(interval)+1))
                plt.figure()
                ## プロット
                plt.plot(x,interval, label="interval")

                plt.grid(which='major',color='black',linestyle='-')
                # 凡例の表示
                plt.legend()
                # プロット表示(設定の反映)
                #plt.show()

                plt.hist(interval,bins=30,rwidth=0.8,histtype="bar")
                #plt.show()


pair = "AUDUSD"
month = 6
date = 17
hr_0 = 17
min_0 = 15
hr_1 = 17
min_1 = 31

graph(pair, month, date, hr_0,min_0,hr_1,min_1)
