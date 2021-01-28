@echo off

set dir1=C:\Program Files\MetaTrader 4\MQL4\Files\

set dir2=C:\python\

set MM=%date:~5,2%
set DD=%date:~8,2%
set /a MM=1%MM% * 2 - 2%MM%
set /a DD=1%DD% * 2 - 2%DD%

echo waiting...
timeout /t 15 /nobreak >nul

copy "%dir1%USDJPY_%MM%_%DD%_ticks.csv" "%dir2%USDJPY_%MM%_%DD%_ticks.csv"
copy "%dir1%EURJPY_%MM%_%DD%_ticks.csv" "%dir2%EURJPY_%MM%_%DD%_ticks.csv"
copy "%dir1%EURUSD_%MM%_%DD%_ticks.csv" "%dir2%EURUSD_%MM%_%DD%_ticks.csv"
copy "%dir1%AUDJPY_%MM%_%DD%_ticks.csv" "%dir2%AUDJPY_%MM%_%DD%_ticks.csv"
copy "%dir1%AUDUSD_%MM%_%DD%_ticks.csv" "%dir2%AUDUSD_%MM%_%DD%_ticks.csv"
copy "%dir1%GBPJPY_%MM%_%DD%_ticks.csv" "%dir2%GBPJPY_%MM%_%DD%_ticks.csv"
copy "%dir1%NZDJPY_%MM%_%DD%_ticks.csv" "%dir2%NZDJPY_%MM%_%DD%_ticks.csv"

move "%dir1%USDJPY_senddjango.csv" "%dir2%USDJPY_senddjango.csv"
move "%dir1%EURJPY_senddjango.csv" "%dir2%EURJPY_senddjango.csv"
move "%dir1%EURUSD_senddjango.csv" "%dir2%EURUSD_senddjango.csv"
move "%dir1%AUDJPY_senddjango.csv" "%dir2%AUDJPY_senddjango.csv"
move "%dir1%AUDUSD_senddjango.csv" "%dir2%AUDUSD_senddjango.csv"
move "%dir1%GBPJPY_senddjango.csv" "%dir2%GBPJPY_senddjango.csv"
move "%dir1%NZDJPY_senddjango.csv" "%dir2%NZDJPY_senddjango.csv"

cd %dir2%
rem C:\Users\Kiyoshi\AppData\Local\Programs\Python\Python36-32\python.exe analyzer.py
C:\Users\Kiyoshi\AppData\Local\Programs\Python\Python36-32\python.exe senddjango.py
rem pause
