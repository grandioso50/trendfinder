import os
import sys
import numpy as np
import pandas as pd
import scipy.stats
from scipy import stats
from matplotlib import pyplot as plt
import datetime
import matplotlib
import math
#matplotlib.use('Agg')

def r2(y,yhat):
    ybar = np.sum(y)/len(y)
    ssreg = np.sum((yhat-ybar)**2)   # or sum([ (yihat - ybar)**2 for yihat in yhat])
    sstot = np.sum((y - ybar)**2)
    if not sstot == 0:
        return ssreg / sstot
    else:
        return 0

def read(file,at,range):
    try:
        df = pd.read_csv(file, header=None)
        # 時間 at に該当する最小添字
        end_idx = min(df[df[0].str.startswith(at)].index.values.tolist())
        if end_idx - range + 1 >= 0:
            start_idx = end_idx - range + 1
        else:
            start_idx = 0
        # range期間内のデータ
        filtered = df.query('index >= @start_idx & index <= @end_idx')
        return filtered[1]
    except Exception as e:
        print(e)

def rsquare(pair,at,period):
    y = read(pair+'.csv',at,period)
    normed_y = scipy.stats.zscore(y)
    x = list(range(1, len(normed_y)+1))
    slope, intercept, r_value, p_value, std_err = stats.linregress(x,normed_y)
    w = [i*slope+intercept for i in x]
    plt.figure()
    # プロット
    plt.plot(x,normed_y, label=pair)
    plt.plot(x,w, label="slope", color="red")
    # 凡例の表示
    plt.legend()
    # プロット表示(設定の反映)
    plt.show()
    #graph(x,y,pair,at,period)
    return r_value**2

def polyfitr2(pair,at,period):
    y = read(pair+'.csv',at,period)
    normed_y = scipy.stats.zscore(y)
    x = list(range(1, len(normed_y)+1))
    #4次元式で多項回帰
    w = np.poly1d(np.polyfit(x, normed_y, 4))(x)

    plt.figure()
    # プロット
    plt.plot(x,normed_y, label=pair)
    plt.plot(x,w, label=r2(normed_y,w), color="red")
    # 凡例の表示
    plt.legend()
    # プロット表示(設定の反映)
    plt.show()
    #return r2(normed_y,w)

def graph (x,y,_label,at,period):
    plt.figure()
    # プロット
    plt.plot(x, y, label=_label)
    # 凡例の表示
    plt.legend()
    # プロット表示(設定の反映)
    plt.show()
    name = at.replace(':', '-')
    #plt.savefig(name+'_'+str(period)+'_'+_label+'_.png')

def save(name,output):
    rename = name.replace(':', '-')
    df = pd.DataFrame(output)
    newpath = "processed/"+rename+".csv"
    df.to_csv(newpath,header=False,index=False)

pairs = ['USDJPY','NZDJPY','GBPJPY','AUDJPY','AUDUSD','EURJPY','EURUSD']

for pair in pairs:
    if not os.path.exists('./'+pair+'.csv'):
        print(pair+' dne.')

#df = pd.DataFrame(columns=pairs,index=['1H','30m','15m','5m'])
df = pd.DataFrame(columns=pairs)

args = sys.argv
signal = args[1]

for pair in pairs:
#    df[pair] = np.array([rsquare(pair,signal,3600), rsquare(pair,signal,1800), rsquare(pair,signal,900),rsquare(pair,signal,300)])
    #df[pair] = np.array([polyfitr2(pair,signal,300)])
    polyfitr2(pair,signal,300)
#save(signal,df)
