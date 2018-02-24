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
double rTol = 0.7;
int timeInterval = 60;
int tick_cnt = 0;
int prev_tick_cnt = 0;
int strong_ticks_cnt = 0;
int won_cnt = 0;
double BIDS[200];
double initialTime = GetTickCount();
double TIME[200];
double prev_bid = 0;
double previous_R = 0;
//AUDJPY, AUDUSD, EURJPY, EURUSD, GBPJPY, NZDJPY, USDJPY
double MIN[] = {0.004,0.00004,0.004,0.00004,0.003,0.0045,0.005};
double max_std = 0;
string message = Symbol()+": ";
string csv = "";
string logs = "";
int candleNum = 3;
int continuous_r_num = 0;
bool wasAscending;
bool idealTrend = false;
bool wasIdeal = false;
bool willExport = false;

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
   bool willBreak = willBreak();
   if (willBreak) {
      message += "\nBreak";
   }
     //Test一分前に鳴っていたら
   /*
   if (AlertFlag) {
      string time = TimeToStr(TimeLocal(),TIME_SECONDS);
      csv += time +",";
      if (wasIdeal) {
        csv += "ORDER"+",";
        if (isOrdered()){
         csv += 1;
         won_cnt++;
         //WindowScreenShot(TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal())+"_"+Symbol()+"_win.gif", 640, 480);
      }else{
         csv += 0;
         won_cnt = 0;
         //WindowScreenShot(TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal())+"_"+Symbol()+"_lose.gif", 640, 480);
      }
      }else{
        if (isReversed()){
         csv += "REVERSE"+",";
         csv += 1;
         won_cnt++;
         //WindowScreenShot(TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal())+"_"+Symbol()+"_win.gif", 640, 480);
         }else{
         csv += 0;
         won_cnt = 0;
         //WindowScreenShot(TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal())+"_"+Symbol()+"_lose.gif", 640, 480);
         }
      }

      csv += ","+prev_tick_cnt;
      csv += ","+max_std;
      csv += ","+previous_R; 
      willExport = true;
   } 
   */
   message += "\nwon cnt="+won_cnt;
   max_std = 0;
   //相関係数で判断
   bool likeIt = isGoodTrend();
   bool correlated = isCorrelted();
   bool willBet = false;
   int local_hour = TimeHour(TimeLocal());
   
   if (local_hour == 23 || local_hour == 0 || local_hour == 1 || local_hour == 2) {
      if ((willBreak || idealTrend) && tick_cnt > 40) willBet = true;
   } else {
      if (idealTrend || willBreak) willBet = true;
   }  
   exportData(Symbol());

   if (willBet) {
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
   prev_tick_cnt = tick_cnt;
   tick_cnt = 0;
   ArrayInitialize(BIDS,0);
   ArrayInitialize(TIME,0);
   initialTime = GetTickCount();
   message = Symbol()+": ";
   csv = "";
   logs = "";
   prev_bid = MarketInfo(Symbol(),MODE_BID);
   wasIdeal = idealTrend;
   idealTrend = false;
   willExport = false;
}

bool willBreak() {
   if (Period() != PERIOD_M5) {
      logs += " \n5foot: not 5foot.";
      return false;
   }
   double upper = getValueByText("High_Low_Plus_UpperPrice");
   double lower = getValueByText("High_Low_Plus_LowerPrice");
   
   double open = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",2,0);
   double close = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",3,0);
   double low = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",1,0);
   double high = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",0,0);
   double entity_size = getEntitySize(open, close);
   csv += entity_size;
   int entity_type = getEntity(open,close);
   if (entity_type == 0) {
      logs += " \n5foot: no entity type.";
      return false;
   }
   bool isAsc;
   if (entity_type == 1) {
      isAsc = true;
   }else if (entity_type == 2) {
      isAsc = false;
   }
   
   //抵抗線の中にロウソクがあるか判定
   if (isAsc && high > upper) {
      logs += " \n5foot: high is greater than upper.";
      return false;
   }else if(!isAsc && lower > low) {
      logs += " \n5foot: lower is greater than low.";
      return false;
   }
   
   //抵抗線に近いか判定
   if (isAsc && MathAbs(upper-high) > entity_size) {
      logs += " \n5foot: not close enough to upper.";
      return false;
   }else if(!isAsc && MathAbs(low-lower) > entity_size) {
      logs += " \n5foot: not close enough to lower.";
      return false;
   }
   
   double leadingA = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,0); //一目均衡(先行スパンA)
	double leadingB = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,0); //一目均衡(先行スパンB)
	//5分足の雲の位置
	int candle_position_one = getHeikenPosition(open,close,leadingA,leadingB);
	if (candle_position_one != 2 && candle_position_one != 3) {
	   logs += " \n5foot: at cloud";
	   return false;
	} 

   return true;
   
}

double getValueByText(string objectName) {
   if(ObjectType(objectName)==OBJ_TEXT || ObjectType(objectName)==OBJ_LABEL){
      return StrToDouble(ObjectDescription(objectName));
   }
   return 0;
}

bool isVigorousTime() {
   int local_hour = TimeHour(TimeLocal());
   int local_min = TimeMinute(TimeLocal());
   if (local_hour == 8) {
      if (local_min >= 30) {
         return true;
      }
   }
   if (local_hour == 9) {
      if (local_min <= 30) {
         return true;
      }
   }
   if (local_hour == 16) {
      if (local_min >= 30) {
         return true;
      }
   }
   if (local_hour == 17) {
      if (local_min <= 30) {
         return true;
      }
   }
   if (local_hour == 21) {
      if (local_min >= 30) {
         return true;
      }
   }
   if (local_hour == 22) {
      if (local_min <= 30) {
         return true;
      }
   }
   return false;
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

bool isReversed() {
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

bool isOrdered() {
   double bid = MarketInfo(Symbol(),MODE_BID);
   if (wasAscending) {
      if (prev_bid < bid) {
         return true;
      }
   }else {
      if (prev_bid > bid) {
         return true;
      }
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
   isStrong(isAscOne);
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
   
   int local_hour = TimeHour(TimeLocal());
   
   if (local_hour == 22 || local_hour == 21 || local_hour == 20) {
      return false;
   }
   
   int isContinuous = isContinuous(isAscOne);
   
   if (isContinuous == -1) {
      //message += " \ngood stable past candles";
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

int isStrong (bool isAsc) {
   double high;
   double low;
   double open;
   double close;
   double min_size = MIN[getIndex()];
   double size;
   double ratio;
   int whiskerLength = 0;
   int whiskerCount = 0;
   int badSizes = 0;
   
   if (isAsc) {
      for (int i=0; i<10; i++) {
         open = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",2,i);
         close = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",3,i);
         low = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",1,i);
         high = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",0,i);
         size = getEntitySize(open,close);
         ratio = (high-close)/size;
         if (size < min_size) {
            badSizes++;
         } 
         if (getEntity(open,close) != 1) {
            return i;
         } 
         if (low < open) {
            whiskerCount++;
         }
         
         if (ratio > 1) {
           whiskerLength++;
         }
         
       }
   } else {
       for (int i=0; i<10; i++) {
         open = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",2,i);
         close = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",3,i);
         low = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",1,i);
         high = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",0,i);
         size = getEntitySize(open,close);
         ratio = (close -low)/size;
         if (size < min_size) {
            badSizes++;
         } 
         if (getEntity(open,close) != 2) {
            return i;
         } 
         if (high > open) {
            whiskerCount++;
         } 
         
         if (ratio > 1) {
            whiskerLength++;
         }
         
      }
   }
   if ((whiskerLength/10) < 0.85 && (whiskerCount/10) < 0.85 && (badSizes/10) < 0.85) {
      idealTrend = true;
      message += "\nIDEAL";
   }else{
      logs += "\nBad whisker num="+whiskerCount+" Bad whisker length num="+whiskerLength+" bad size nums="+badSizes;
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

void updateMaxStd (double std) {
   if (std > max_std) {
      max_std = std;
   }
}

bool isCorrelted () {
   double bidSum = 0;
   double timeSum = 0;
   double max = 0;
   double min = 0;
   int count = 0;

   while(BIDS[count] != 0){
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
       updateMaxStd(MathPow((
         BIDS[i]-bidMean
       ),2));
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
   logs += " \nR="+CC+" \nticks="+tick_cnt+" \nbidstd="+bidStd+" \nmaxstd="+max_std;
   if (tick_cnt < 20) {
      message += "\n WAIT!!!!";
   }
   message += "\nticks="+tick_cnt;
   previous_R = CC;
   if (MathAbs(CC) > rTol) {
      continuous_r_num++;
   }else{
      continuous_r_num = 0;
   }
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