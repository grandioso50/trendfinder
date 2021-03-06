//+------------------------------------------------------------------+
//|                                                       Haruto.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
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
  bool signal = testHaruto();
  if (signal) Alert("HARUTO");
   
  }
//+------------------------------------------------------------------+
bool testHaruto() {
   string logs = "";
   double open;
   double close;
   double ema3;
   double ema5;
   double ema20;
   double ema70;
   double ema60;
   double ema200;
   double RSI;
   bool isAsc;
   
   ema3 = iMA(Symbol(),PERIOD_M1,3,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(3)
   ema60 = iMA(Symbol(),PERIOD_M1,60,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(60)
   ema5 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(3)
   ema20 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(60)
   ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(3)
   ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(60)
   open = iOpen(Symbol(),PERIOD_M1,0);
   close = iClose(Symbol(),PERIOD_M1,0);
   RSI = iRSI(Symbol(),PERIOD_M1,5,PRICE_CLOSE,1);
   isAsc = close > open;
   
   bool isTrend = (ema5 > ema20 && ema5 > ema70 && ema5 > ema200)
   || (ema5 < ema20 && ema5 < ema70 && ema5 < ema200);

   if (ema3 > ema60) {
      //is candle not touching MA3
      if (open > ema3 && close > ema3) {
         if (!isAsc) {
            if (RSI > 70) {
               if (isTrend) {
                  return true;
               }      
            }
         }
      }
   }else if (ema3 < ema60) {
      //is candle not touching MA3
      if (open < ema3 && close < ema3) {
         if (isAsc) {
            if (RSI < 30) {
               if (isTrend) {
                  return true;
               }
            }
         }
      }
   }
   return false;

}