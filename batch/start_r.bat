@echo off
schtasks /create /tn "R" /tr C:\Users\Kiyoshi\Desktop\batch\r.vbs /sc minute /mo 1
pause
