import os
import numpy as np
import pandas as pd
import scipy.stats
import datetime
from datetime import datetime as dt

def read(file):
    try:
        df = pd.read_csv(file, header=None)
        return df
    except Exception as e:
        print(e)

def save(name,output):
    rename = name.replace(':', '-')
    df = pd.DataFrame(output)
    newpath = "processed/"+rename+".csv"
    df.to_csv(newpath,header=False,index=False)

def loadFile(pair,date):
    filename = pair+"_"+str(date.month)+"_"+str(date.day)+"_ticks.csv"
    raw = read(filename)
    # datetime型に変換
    raw[0] = raw[0].apply(lambda x: dt.strptime(x, '%Y-%m-%d %H:%M:%S'))
    # microseconds列をゼロ埋めしてから、1秒以下を出力
    raw['microsecond'] = raw[1].apply(lambda x: int(((str(x)).zfill(8))[2:8]))
    # 生成したmicrosecondsでdatetimeオブジェクトを更新
    raw[0] = raw.apply(lambda x: x[0].replace(microsecond=x['microsecond']), axis=1)

    return pd.DataFrame({'time':raw[0],'bid':raw[2]})

def extract(df, alerted):
    #アラート1分前から相場を予測したいので、16分前~1分前の15分間を取る
    to =  alerted - datetime.timedelta(minutes=1)
    frm = to - datetime.timedelta(minutes=15)
    return df[(df['time'] >= frm) & (df['time'] < to)]

result = read("result.csv")
# datetime型に変換
result[0] = result[0].apply(lambda x: dt.strptime(x, '%Y-%m-%d %H:%M:%S'))

for index, row in result.iterrows():
    tickdata = loadFile(row[1],row[0])
    extracted = extract(tickdata,row[0])
    extracted['time'] = pd.to_datetime(extracted['time'])
    extracted.set_index('time', inplace=True)
    print(extracted.resample('L').mean())


#print(wip_date)
