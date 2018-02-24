//+------------------------------------------------------------------+
//|                                           trendfinder_ver0.2.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

bool AlertFlag = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//ティックが順な閾値
double rTol = 0.8;
int timeInterval = 60;
int tick_cnt = 0;
int strong_ticks_cnt = 0;
double BIDS[200];
double initialTime = GetTickCount();
double TIME[200];
double prev_bid = 0;
//AUDJPY, AUDUSD, EURJPY, EURUSD, GBPJPY, NZDJPY, USDJPY
double MIN[] = {0.005,0.00005,0.005,0.00004,0.0035,0.0045,0.005};
double max_tick_diff = 0;
string message = Symbol()+": ";
string csv = "";
string logs = "";
int candleNum = 3;
bool wasAscending;

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
   BIDS[tick_cnt] = MarketInfo(Symbol(),MODE_BID);
   TIME[tick_cnt] = GetTickCount() - initialTime;
   tick_cnt++;
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {

     //Test一分前に鳴っていたら
   if (AlertFlag) {
      bool isWon = isWon();
      string time = TimeToStr(TimeLocal(),TIME_SECONDS);
      csv += time +",";
      if (isWon){
         csv += 1;
        // WindowScreenShot(TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal())+"_"+Symbol()+"_win.gif", 640, 480);
      }else{
         csv += 0;
        // WindowScreenShot(TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal())+"_"+Symbol()+"_lose.gif", 640, 480);
      }
      csv += ","+tick_cnt;
      csv += ","+max_tick_diff;
      Print(Symbol()+" csv="+csv);
      exportData(Symbol());
   } 
   max_tick_diff = 0;
   //相関係数で判断
   bool correlated = isCorrelted();
   bool isStrong = isStrongTicks();
   bool likeIt = isGoodTrend();
   

   if (likeIt) {
      slack(message);
      Alert(message);
      AlertFlag = true;
    }else{
      Print(logs);
      AlertFlag = false;
    }
   
   deinitialize();
  }
//+------------------------------------------------------------------+

void deinitialize(){
   tick_cnt = 0;
   ArrayInitialize(BIDS,0);
   ArrayInitialize(TIME,0);
   initialTime = GetTickCount();
   message = Symbol()+": ";
   csv = "";
   logs = "";
   prev_bid = MarketInfo(Symbol(),MODE_BID);
}

double getEntitySize (double open, double close) {
   if (open > close) {
      return open - close;
   }
   if (close > open) {
      return close - open;
   }
   return 0;
}

bool isWon() {
   double bid = MarketInfo(Symbol(),MODE_BID);
   if (wasAscending) {
      if (prev_bid > bid) {
         return true;
      }
   }else {
      if (prev_bid < bid) {
         return true;
      }
   }
   return false;
}

bool isStrongTicks() {
   if (tick_cnt > 80) {
      strong_ticks_cnt++;
   }else{
      strong_ticks_cnt = 0;
   }
   if (strong_ticks_cnt > 2) {
      message += "strong ticks in a roll="+strong_ticks_cnt;
      return true;
   }
   return false;
}

bool isGoodTrend() {
   double open = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",2,0);
   double close = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",3,0);
   double entity_size = getEntitySize(open, close);
   int entity_type = getEntity(open,close);
   if (entity_type == 0) {
      logs += " \n1foot: no entity type.";
      return false;
   }
   bool isAscOne;
   if (entity_type == 1) {
      isAscOne = true;
   }else if (entity_type == 2) {
      isAscOne = false;
   }
   wasAscending = isAscOne;
   double leadingA = iIchimoku(Symbol(),PERIOD_M1,9,26,52,3,0); //一目均衡(先行スパンA)
	double leadingB = iIchimoku(Symbol(),PERIOD_M1,9,26,52,4,0); //一目均衡(先行スパンB)
	//1分足の雲の位置
	int candle_position_one = getHeikenPosition(open,close,leadingA,leadingB);

	if (candle_position_one != 2 && candle_position_one != 3) {
	   logs += " \n1foot: at cloud";
	   return false;
	} 
	
	if ((isAscOne && candle_position_one != 2) || (!isAscOne && candle_position_one != 3)) {
		logs += " \n1foot: trend and candle position no match.";
	   return false;
	}
	
	open = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",2,0);
   close = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",3,0);
   leadingA = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,0); //一目均衡(先行スパンA)
	leadingB = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,0); //一目均衡(先行スパンB)
	int candle_position_five = getHeikenPosition(open,close,leadingA,leadingB);
	entity_type = getEntity(open,close);
   if (entity_type == 0) {
      logs += " \n5foot: no entity type.";
      return false;
   }
	
	if (candle_position_five != 2 && candle_position_five != 3) {
		logs += " \n5foot: at cloud.";
	   return false;
	}
	
	double ema5 = iMA(Symbol(),PERIOD_M1,5,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(5)
   double ema20 = iMA(Symbol(),PERIOD_M1,20,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(20)
   double ema70 = iMA(Symbol(),PERIOD_M1,70,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(70)
   double ema200 = iMA(Symbol(),PERIOD_M1,200,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(200)
   
   if (candle_position_one == 2) {
      if (!(ema5 > ema20 && ema5 > ema70 && ema5 > ema200)) {
          logs += " \nbad ema lineup on up cloud";
          return false;
      }
   }else{
      if (!(ema5 < ema20 && ema5 < ema70 && ema5 < ema200)) {
          logs += " \nbad ema lineup on down cloud";
          return false;
      }
   }
   
   int isContinuous = isContinuous(isAscOne);
   
   if (isContinuous == -1) {
      logs += " \ngood stable past candles";
      return true;
   } else {
      return false;
   }
}

int isContinuous (bool isAsc) {
   double high;
   double low;
   double open;
   double close;
   double min_size = MIN[getIndex()];
   double size;
   double ratio;
   csv = "";
   
   if (isAsc) {
      for (int i=0; i<candleNum; i++) {
         open = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",2,i);
         close = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",3,i);
         low = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",1,i);
         high = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",0,i);
         size = getEntitySize(open,close);
         ratio = (high-close)/size;
         if (size < min_size) {
            logs += " \nentity size too small at "+i+" before";
            return i;
         } 
         if (getEntity(open,close) != 1) {
            logs += " \nasc but not asc at "+i+" before";
            return i;
         } 
         if (low < open) {
            logs += " \nhas whisker at "+i+" before";
            return i;
         }
         
         if (ratio > 1) {
            logs += " \ntop whisker too long at "+i+" before ratio="+ratio;
           return i;
         }
         
       }
   } else {
       for (int i=0; i<candleNum; i++) {
         open = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",2,i);
         close = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",3,i);
         low = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",1,i);
         high = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",0,i);
         size = getEntitySize(open,close);
         ratio = (close -low)/size;
         if (size < min_size) {
            logs += " \nentity size too small at "+i+" before";
            return i;
         } 
         if (getEntity(open,close) != 2) {
            logs += " \ndesc but not desc at "+i+" before";
            return i;
         } 
         if (high > open) {
            logs += " \nhas whisker at "+i+" before";
            return i;
         } 
         
         if (ratio > 1) {
            logs += " \nbottom whisker too long at "+i+" before ratio="+ratio;
            return i;
         }
         
      }
   }
   return -1;
}

int getIndex () {
   string symbol = Symbol();
   if (symbol == "AUDJPY") {
      return 0;
   } else if (symbol == "AUDUSD") {
      return 1;
   } else if (symbol == "EURJPY") {
      return 2;
   } else if (symbol == "EURUSD") {
      return 3;
   } else if (symbol == "GBPJPY") {
      return 4;
   } else if (symbol == "NZDJPY") {
      return 5;
   } else if (symbol == "USDJPY") {
      return 6;
   }
   return 0;
}

void updateMaxTick (double tick1, double tick2) {
   if (tick1 == tick2) return;
   if (MathAbs(tick1-tick2) > max_tick_diff) {
      max_tick_diff = MathAbs(tick1-tick2);
   }
}

bool isCorrelted () {
   double bidSum = 0;
   double timeSum = 0;
   double max = 0;
   double min = 0;
   int count = 0;

   while(BIDS[count] != 0){
      if (BIDS[count+1] != 0) {
         updateMaxTick(BIDS[count],BIDS[count+1]);
      }
      count++;
   }
   
   //ティックが時間内に一回もなかった
   if (count == 0) {
      logs += " \nno ticks";
      return false;
   }
   
   for (int i=0; i<count; i++) {
      bidSum += BIDS[i];
      timeSum += TIME[i];
   }
   double bidMean = bidSum/count;
   double timeMean = timeSum/count;
   double bidDevSum = 0;
   double timeDevSum = 0;
   double productSum = 0;
   
   for (int i=0; i<count; i++) {
       bidDevSum += MathPow((
         BIDS[i]-bidMean
       ),2);
       timeDevSum += MathPow((
         TIME[i]-timeMean
       ),2);
       productSum += (BIDS[i]-bidMean) * (TIME[i]-timeMean);
   }
   
   double bidVariance = bidDevSum/count;
   double timeVariance = timeDevSum/count;
   double covariance = productSum/count;
   double bidStd = MathSqrt(bidVariance);
   double timeStd = MathSqrt(timeVariance);
   if ((bidStd * timeStd) == 0) {
      return false;
   }
   double CC = covariance/(bidStd * timeStd);
   logs += " \nR="+CC+" \nticks="+tick_cnt;
   message += "\n Correlated R="+CC+" \nticks="+tick_cnt+" \nmax tick diff="+max_tick_diff;
   if (MathAbs(CC) > rTol && tick_cnt > 85) return true;
   return false;
 
}

/**
0は変化なし
1は上昇
2は下降
*/
int getEntity(double open, double close) {
   if (open == close) {
      return 0;
   }
   if (open > close) {
      return 2;
   }else{
      return 1;
   }
}

int getHeikenPosition (double open, double close, double leading_a, double leading_b) {
	//陽線判定
	if (close > open) {
		if (close > leading_a && close > leading_b && open < leading_a && open < leading_b) {
			return 1; //ねじれの中
		}
		if (open > leading_a && open >leading_b) {
			return 2; //雲の上
		}
		if (close < leading_a && close <leading_b) {
			return 3; //雲の下
		}
		if (leading_a < close && leading_a > open) {
			return 4; //先行スパンAの出口
		}
		if (leading_b < close && leading_b > open) {
			return 5; //先行スパンBの出口
		}
		if (leading_a > leading_b) {
			if (leading_a > close && leading_b < open) {
				return 6; //雲の中
			}
		}else{
			if (leading_b > close && leading_a < open) {
				return 6; //雲の中
			}
		}

	} else {
		if (open > leading_a && open > leading_b && close < leading_a && close < leading_b) {
         return 1; //ねじれの中
		}
		if (close > leading_a && close >leading_b) {
			return 2; //雲の上
		}
		if (open < leading_a && open <leading_b) {
			return 3; //雲の下
		}
		if (leading_a < open && leading_a > close) {
			return 4; //先行スパンAの出口
		}
		if (leading_b < open && leading_b > close) {
			return 5; //先行スパンBの出口
		}
		if (leading_a > leading_b) {
			if (leading_a > open && leading_b < close) {
				return 6; //雲の中
			}
		}else{
			if (leading_b > open && leading_a < close) {
				return 6; //雲の中
			}
		}

	}
	return 0;
}

int slack(string text)
{
   
   int WebR; 
   string URL = "https://hooks.slack.com/services/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";
   int timeout = 5000;
   string cookie = NULL,headers; 
   char post[],FTPdata[]; 
   string str= "&payload="+"{\"text\":\""+text+"\"}";
 
   StringToCharArray( str, post );
   WebR = WebRequest( "POST", URL, cookie, NULL, timeout, post, 0, FTPdata, headers );
   return(WebR);
}

void exportData (string prefix) {
   string filename = prefix+".csv";
   int handle = FileOpen(filename, FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ',');
   //末尾にポインターを移動
   FileSeek(handle,0,SEEK_END);
   FileWrite(handle,csv);
   FileClose(handle);
      
 }