import os
import sys
import numpy as np
import pandas as pd
import scipy.stats
import datetime
from datetime import datetime as dt
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

def set_resquare(pair,target_dt):
    filename = pair+"_"+str(target_dt.month)+"_"+str(target_dt.day)+"_ticks.csv"
    if not os.path.exists('./'+filename):
        print(filename+" DNE")
        return

    data = read(filename)
    # datetime型に変換
    data[0] = data[0].apply(lambda x: dt.strptime(x, '%Y-%m-%d %H:%M:%S'))
    # microseconds列をゼロ埋めしてから、1秒以下を出力
    data['microsecond'] = data[1].apply(lambda x: int(((str(x)).zfill(8))[2:8]))
    # 生成したmicrosecondsでdatetimeオブジェクトを更新
    data[0] = data.apply(lambda x: x[0].replace(microsecond=x['microsecond']), axis=1)

    #最後の時間
    frm = data[0][data.index[0]]
    to = frm + datetime.timedelta(minutes=15)
    filtered = data[(data[0] >= frm) & (data[0] <= to)]
    diff = filtered[0][filtered.index[-1]]-filtered[0][filtered.index[0]]
    r = calc_r(filtered)
    df = pd.DataFrame({'frm':[str(frm.hour)+":"+str(frm.minute)],
    'to':[str(to.hour)+":"+str(to.minute)],
    'r':[r]})

    while not diff.seconds <= 840:
        frm = frm + datetime.timedelta(minutes=1)
        to = to + datetime.timedelta(minutes=1)
        filtered = data[(data[0] >= frm) & (data[0] <= to)]
        diff = filtered[0][filtered.index[-1]]-filtered[0][filtered.index[0]]
        r = calc_r(filtered)
        df = df.append({'frm': str(frm.hour)+":"+str(frm.minute), 'to': str(to.hour)+":"+str(to.minute), 'r': r}, ignore_index=True)

    newpath = "C:/python/"+pair+"_"+str(frm.month)+"_"+str(frm.day)+"_logs_man.csv"
    df.to_csv(newpath, mode='a', header=False,index=False)

def calc_r(filtered):
    x = list(range(1, len(filtered[2])+1))
    w = np.poly1d(np.polyfit(x, filtered[2], 1))(x)
    #print("pair="+pair+" r2="+str([r2(filtered[2],w)]))
    r = r2(filtered[2],w)
    return r

pairs = ['USDJPY','NZDJPY','GBPJPY','AUDJPY','AUDUSD','EURJPY','EURUSD']
#pairs = ['USDJPY']
args = sys.argv
month = args[1]
args = sys.argv
date = args[2]
d = datetime.date(2020, int(month), int(date))
for pair in pairs:
    set_resquare(pair,d)
