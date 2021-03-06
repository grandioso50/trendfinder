//+------------------------------------------------------------------+
//|                                                    collector.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import
int timeInterval = 1;
int cnt = 0;
double USDJPY[800];
double EURUSD[800];
double GBPJPY[800];
double EURJPY[800];
double AUDUSD[800];
double AUDJPY[800];
double NZDJPY[800];
string TIME[800];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(timeInterval);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if (cnt == 600) {
      cnt = 0;
      //clear("USDJPY");
      //clear("EURUSD");
      //clear("GBPJPY");
      //clear("EURJPY");
      //clear("AUDUSD");
      //clear("AUDJPY");
      //clear("NZDJPY");

      exportData("USDJPY_"+TimeMonth(TimeLocal())+"_"+TimeDay(TimeLocal())+"_bid",bidsToString2(USDJPY,TIME),false);
      //exportData("USDJPY_today",bidsToString2(USDJPY,TIME),true);
      exportData("EURUSD_"+TimeMonth(TimeLocal())+"_"+TimeDay(TimeLocal())+"_bid",bidsToString2(EURUSD,TIME),false);
      exportData("GBPJPY_"+TimeMonth(TimeLocal())+"_"+TimeDay(TimeLocal())+"_bid",bidsToString2(GBPJPY,TIME),false);
      exportData("EURJPY_"+TimeMonth(TimeLocal())+"_"+TimeDay(TimeLocal())+"_bid",bidsToString2(EURJPY,TIME),false);
      exportData("AUDUSD_"+TimeMonth(TimeLocal())+"_"+TimeDay(TimeLocal())+"_bid",bidsToString2(AUDUSD,TIME),false);
      exportData("AUDJPY_"+TimeMonth(TimeLocal())+"_"+TimeDay(TimeLocal())+"_bid",bidsToString2(AUDJPY,TIME),false);
      exportData("NZDJPY_"+TimeMonth(TimeLocal())+"_"+TimeDay(TimeLocal())+"_bid",bidsToString2(NZDJPY,TIME),false);

      ArrayInitialize(USDJPY,0);
      ArrayInitialize(EURUSD,0);
      ArrayInitialize(GBPJPY,0);
      ArrayInitialize(EURJPY,0);
      ArrayInitialize(AUDUSD,0);
      ArrayInitialize(AUDJPY,0);
      ArrayInitialize(NZDJPY,0);
      //ShellExecuteW(NULL,"open","C:\Users\Kiyoshi\Desktop\batch\minute.bat",NULL,NULL,1);
   }
   USDJPY[cnt] = MarketInfo("USDJPY",MODE_BID);
   EURUSD[cnt] = MarketInfo("EURUSD",MODE_BID);
   GBPJPY[cnt] = MarketInfo("GBPJPY",MODE_BID);
   EURJPY[cnt] = MarketInfo("EURJPY",MODE_BID);
   AUDUSD[cnt] = MarketInfo("AUDUSD",MODE_BID);
   AUDJPY[cnt] = MarketInfo("AUDJPY",MODE_BID);
   NZDJPY[cnt] = MarketInfo("NZDJPY",MODE_BID);
   TIME[cnt] = TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+":"+TimeSeconds(TimeLocal());
   cnt++;

  }

void clear(string symbol) {
   if (FileIsExist(symbol+"_bid.csv")) {
      FileDelete(symbol+"_bid.csv");
   }
}
string bidsToString (double &bids[]) {
   string bid_string = "";
   int count = 0;

   while(bids[count] != 0 && count+1 < ArraySize(bids)){
      bid_string += bids[count]+"\n";
      count++;
   }
   return bid_string;
}

string bidsToString2 (double &bids[], string &time[]) {
   string bid_string = "";
   int count = 0;

   while(bids[count] != 0 && count+1 < ArraySize(bids)){
      bid_string += time[count]+","+bids[count];
      if (count+1 < ArraySize(bids)) bid_string += "\n";
      count++;
   }
   return bid_string;
}

string getTime() {
    return TimeDay(TimeLocal())+"_"+TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal());
}
//+------------------------------------------------------------------+
void exportData (string prefix, string text, bool overwrite) {
   string filename = prefix+".csv";
   int handle = FileOpen(filename, FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ',');
   //末尾にポインターを移動
   if (!overwrite) {
     FileSeek(handle,0,SEEK_END);
   }
   FileWrite(handle,text);
   FileClose(handle);
 }
