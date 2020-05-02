import os
import sys
import numpy as np
from sklearn.linear_model import LinearRegression
import pandas as pd

def read(file):
    try:
        df = pd.read_csv(file+'.csv', header=None)
        return df
    except Exception as e:
        print(e)

df = read('5mr')
x = df[[0,1,2,3,4,5,6]]
y = df[[7]]

model_lr = LinearRegression()
model_lr.fit(x, y)

print(model_lr.coef_)
print(model_lr.intercept_)
print(model_lr.score(x, y))
