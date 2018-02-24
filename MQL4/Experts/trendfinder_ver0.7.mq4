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
int sinceAlerted_big = 0;
int sinceAlerted_broken = 0;
int sinceAlerted_break = 0;
int sinceAlerted_ideal = 0;
int sinceAlerted_extreme = 0;
double BIDS[400];
double initialTime = GetTickCount();
double TIME[400];
double TICKS[60];
double tickMean;
double tickStd;
double prev_bid = 0;
double previous_R = 0;
double CC = 0;
//AUDJPY, AUDUSD, EURJPY, EURUSD, GBPJPY, NZDJPY, USDJPY
double MIN[] = {0.005,0.00004,0.01,0.00004,0.01,0.005,0.002};
double IDEAL_MIN[] = {0.005,0.00005,0.005,0.00005,0.005,0.005,0.15};
double IDEAL_MAX[] = {0.01,0.0001,0.01,0.0001,0.01,0.01,0.1};
double BIG[] = {0.1,0.001,0.1,0.001,0.1,0.1,0.1};
double max_std = 0;
string message = Symbol()+": ";
string csv = "";
string logs = "";
int candleNum = 3;
int continuous_r_num = 0;
int orderNum = 0;
int reverseNum = 0;
bool isBig = false;
bool isExtreme = false;
bool wasAscending;
bool idealTrend = false;
bool wasIdeal = false;
bool willExport = false;
bool willEvaluate = false;
bool broken = false;
bool willBreak = false;
bool badCandlePos = false;
bool isTurningPoint = false;
int ascend_num = 0;
int descend_num = 0;

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
   setTicks(GetTickCount() - initialTime);
   tick_cnt++;
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   setStdTicksPerSecond();
   haveBroken();
   /*
   if (willBreak) {
      message += " \nwillBreak";
   }
   */

   message += " \ntickMean="+tickMean+" \ntickStd="+tickStd;
   logs += " tickMean="+tickMean+" tickStd="+tickStd;
   max_std = 0;
   //相関係数で判断
   bool likeIt = isGoodTrend();
   bool correlated = isCorrelated();
   bool willBet = false;
   int local_hour = TimeHour(TimeLocal());
 /*  
   if (willExport) {
//      Print(csv);
//      exportData(Symbol());
   }
  */ 
  
   controlAlerts();
   logs += " tickCnt="+tick_cnt;
 //  Print(" cnt="+tick_cnt+" Sym="+Symbol()+" goodPos="+!badCandlePos+" TP="+isTurningPoint+" mean?="+(tickMean > 0.7));
   if (tick_cnt > 20 && (
         (!badCandlePos && isBig && sinceAlerted_big == 0) || 
       //  (!badCandlePos && willBreak && sinceAlerted_break == 0) ||
       //  (!badCandlePos && isExtreme && sinceAlerted_extreme == 0)||
         (!badCandlePos && isTurningPoint && tickMean > 0.7 && MathAbs(CC) > 0.9 && MathAbs(tickMean - tickStd) < 0.5)
         )) {
      slack(message);
      Alert(message);
      AlertFlag = true;
      if (!badCandlePos && isBig && sinceAlerted_big == 0) sinceAlerted_big++;
    //  if (!badCandlePos && willBreak && sinceAlerted_break == 0) sinceAlerted_break++;
    //  if (!badCandlePos && isExtreme && sinceAlerted_extreme == 0) sinceAlerted_extreme++;
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
   ArrayInitialize(TICKS,0);
   initialTime = GetTickCount();
   message = Symbol()+": ";
   csv = "";
   logs = "";
   prev_bid = MarketInfo(Symbol(),MODE_BID);
   wasIdeal = idealTrend;
   idealTrend = false;
   willExport = false;
   isBig = false;
   isExtreme = false;
   tickMean = 0;
   tickStd  = 0;
   broken = false;
   willBreak = false;
   badCandlePos = false;
   CC = 0;
   isTurningPoint = false;
}

void controlAlerts() {
  //5分以内にアラートしたらアラートしない
   if (sinceAlerted_big != 0) {
      if (sinceAlerted_big > 5) {
        sinceAlerted_big = 0;
      }else{
        StringReplace(message, " \nBIG","");
        sinceAlerted_big++;
      }
   }
   if (sinceAlerted_break != 0) {
      if (sinceAlerted_break > 5) {
        sinceAlerted_break = 0;
      }else{
        StringReplace(message, " \nwillBreak","");
        sinceAlerted_break++;
      }
   }
   if (sinceAlerted_broken != 0) {
      if (sinceAlerted_broken > 5) {
        sinceAlerted_broken = 0;
      }else{
        StringReplace(message, " \nBroken","");
        sinceAlerted_broken++;
      }
   }
   if (sinceAlerted_ideal != 0) {
      if (sinceAlerted_ideal > 5) {
        sinceAlerted_ideal = 0;
      }else{
        StringReplace(message, " \nIDEAL","");
        sinceAlerted_ideal++;
      }
   }
   if (sinceAlerted_extreme != 0) {
      if (sinceAlerted_extreme > 5) {
        sinceAlerted_extreme = 0;
      }else{
        StringReplace(message, " \n***atExtreme***","");
        sinceAlerted_extreme++;
      }
   }
}

void haveBroken() {
   if (Period() != PERIOD_M5) {
      return;
   }
   double upper = getValueByText("High_Low_Plus_UpperPrice");
   double lower = getValueByText("High_Low_Plus_LowerPrice");
   
   double open = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",2,0);
   double close = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",3,0);
   double low = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",1,0);
   double high = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",0,0);
   double leadingA = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,0); //一目均衡(先行スパンA)
	double leadingB = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,0); //一目均衡(先行スパンB)
   double entity_size = getEntitySize(open, close);
 
   int entity_type = getEntity(open,close);
   if (entity_type == 0) {
      return;
   }
   
   bool isAsc;
   if (entity_type == 1) {
      isAsc = true;
   }else if (entity_type == 2) {
      isAsc = false;
   }
   wasAscending = isAsc;

	//5分足の雲の位置
	int candle_position_five = getHeikenPosition(open,close,leadingA,leadingB);
	if (candle_position_five != 2 && candle_position_five != 3) {
	   //logs += " 5foot: at cloud";
	   //badCandlePos = true;
	}
	
	double open1 = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",2,0);
   double close1 = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",3,0);
   double leadingA1 = iIchimoku(Symbol(),PERIOD_M1,9,26,52,3,0); //一目均衡(先行スパンA)
	double leadingB1 = iIchimoku(Symbol(),PERIOD_M1,9,26,52,4,0); //一目均衡(先行スパンB)
   int candle_position_one = getHeikenPosition(open1,close1,leadingA1,leadingB1);
   
	if (candle_position_one != 2 && candle_position_one != 3) {
	   logs += " 1foot: at cloud";
	   badCandlePos = true;
	}
   
	double low1 = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",1,1);
   double high1 = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",0,1);
	//抵抗線を超えたか判定
   if (isAsc && high > upper && high1 <= upper) {
      broken = true;
   }else if(!isAsc && lower > low && low1 >= lower) {
      broken = true;
   }
   double bid = MarketInfo(Symbol(),MODE_BID);
   double at = (bid-low)/entity_size;
   if (bid > low) {
      if (at > 0.9 || at < 0.1) {
         message += " \nisTurningPoint(1)";
         logs += " isTurningPoint";
         isTurningPoint = true;
      }    
   }else if (bid > high) {
         message += " \nisTurningPoint(2)";
         logs += " isTurningPoint";
         isTurningPoint = true;
   }else if (bid < low) {
         message += " \nisTurningPoint(3)";
         logs += " isTurningPoint";
         isTurningPoint = true;
   }else {
         logs += " notTP="+at;
   }
   
   
   //抵抗線を超えそうか判定
   if (isAsc && high < upper && bid < upper && (high + entity_size) > upper && high1 <= upper) {
      willBreak = true;
   }else if(!isAsc && low > lower && bid > lower && (low - entity_size) < lower && low1 >= lower) {
      willBreak = true;
   }

   return;
   
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

bool hasAscended() {
   double bid = MarketInfo(Symbol(),MODE_BID);
    if (prev_bid < bid) {
         return true;
    } else {
         return false;
    }
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

/**
** current = MathAbs(bid - open)
*/
double getPositionWithinEntity(double size, double current) {
   return 100/size * current;
}

bool isGoodTrend() {
   double open = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",2,0);
   double close = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",3,0);
   double entity_size = getEntitySize(open, close);
   double open1 = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",2,1);
   double close1 = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",3,1);
   double entity_size1 = getEntitySize(open1, close1);
   logs += " size="+entity_size;
   csv += ",entity_size";
   csv += ","+entity_size;
   csv += ",prev_entity_size";
   csv += ","+entity_size1;
   int entity_type = getEntity(open,close);
   if (entity_type == 0) {
      //logs += " \n1foot: no entity type.";
      return false;
   }
   bool isAscOne;
   if (entity_type == 1) {
      isAscOne = true;
   }else if (entity_type == 2) {
      isAscOne = false;
   }

   isBig = isBig(isAscOne);
   //isExtreme = isAtExtreme(isAscOne);

   double leadingA = iIchimoku(Symbol(),PERIOD_M1,9,26,52,3,0); //一目均衡(先行スパンA)
	double leadingB = iIchimoku(Symbol(),PERIOD_M1,9,26,52,4,0); //一目均衡(先行スパンB)
	//1分足の雲の位置
	int candle_position_one = getHeikenPosition(open,close,leadingA,leadingB);
	if (candle_position_one != 2 && candle_position_one != 3) {
	   //logs += " \n1foot: at cloud";
	   return false;
	} 
	if ((isAscOne && candle_position_one != 2) || (!isAscOne && candle_position_one != 3)) {
		//logs += " \n1foot: trend and candle position no match.";
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
      //logs += " \n5foot: no entity type.";
      return false;
   }
	
	if (candle_position_five != 2 && candle_position_five != 3) {
	   //logs += " \n5foot: at cloud.";
	   return false;
	}
	
	double ema5 = iMA(Symbol(),PERIOD_M1,5,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(5)
   double ema20 = iMA(Symbol(),PERIOD_M1,20,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(20)
   double ema70 = iMA(Symbol(),PERIOD_M1,70,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(70)
   double ema200 = iMA(Symbol(),PERIOD_M1,200,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(200)
   
   if (candle_position_one == 2) {
      if (!(ema5 > ema20 && ema5 > ema70 && ema5 > ema200)) {
         //logs += " \nbad ema lineup on up cloud";
          return false;
      }
   }else{
      if (!(ema5 < ema20 && ema5 < ema70 && ema5 < ema200)) {
         //logs += " \nbad ema lineup on down cloud";
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

bool isBig (bool isAsc) {
   double low = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",1,0);
   double high = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",0,0);
   double pos;
   if (MathAbs(high-low) > BIG[getIndex()]) {
      message += " \nBIG";
      //logs += " \nBIG";
      if (isAsc){
            pos = getPositionWithinEntity(MathAbs(high-low),MathAbs(MarketInfo(Symbol(),MODE_BID) - low));
      }else{
            pos = getPositionWithinEntity(MathAbs(high-low),MathAbs(high - MarketInfo(Symbol(),MODE_BID)));
      }
      //logs += " \npos="+pos;
      //message += " \npos="+pos;
      return true;
   } else {
      //logs += " \nSMALL size="+MathAbs(high-low)+" smaller than "+BIG[getIndex()];
      return false;
   }
}

bool isAtExtreme(bool isAsc) {
   double low = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",1,0);
   double high = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",0,0);
   double bid = MarketInfo(Symbol(),MODE_BID);

   if (getEntitySize(high,low) > BIG[getIndex()]) {
      //logs += " extremely big";
      if (isAsc && bid > high){
            message += " \n***atExtreme***";
           // logs += " bid>high";
            return true;
      }else if (!isAsc && bid < low) {
           // logs += " bid<low";
            message += " \n***atExtreme***";
            return true;
      }
     // logs += " unequal bid="+bid+" high="+high+" low="+low;
      return false;
   } else {
      //logs += Symbol()+": notBig";
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
            //logs += " \nentity size too small at "+i+" before";
            return i;
         } 
         if (getEntity(open,close) != 1) {
            //logs += " \nasc but not asc at "+i+" before";
            return i;
         } 
         if (low < open) {
            //logs += " \nhas whisker at "+i+" before";
            return i;
         }
         
         if (ratio > 1) {
            //logs += " \ntop whisker too long at "+i+" before ratio="+ratio;
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
            //logs += " \nentity size too small at "+i+" before";
            return i;
         } 
         if (getEntity(open,close) != 2) {
            //logs += " \ndesc but not desc at "+i+" before";
            return i;
         } 
         if (high > open) {
            //logs += " \nhas whisker at "+i+" before";
            return i;
         } 
         
         if (ratio > 1) {
            //logs += " \nbottom whisker too long at "+i+" before ratio="+ratio;
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
   double min_size = IDEAL_MIN[getIndex()];
   double max_size = IDEAL_MAX[getIndex()];
   double size;
   double ratio;
   int exam_cnt = 6;
   int whiskerLength = 0;
   int whiskerCount = 0;
   int badSizes = 0;
   
   if (isAsc) {
      for (int i=0; i<exam_cnt; i++) {
         open = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",2,i);
         close = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",3,i);
         low = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",1,i);
         high = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",0,i);
         size = getEntitySize(open,close);
         ratio = (high-close)/size;
         if (size > max_size || size < min_size) {
            return -1;
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
   if ((whiskerLength/exam_cnt) < 0.35 && (whiskerCount/exam_cnt) < 0.35) {
//      message += " \nIDEAL";
//      logs += "\nIDEAL";
//      idealTrend = true;
   }else{
      //logs += "\nBad whisker num="+whiskerCount+" Bad whisker length num="+whiskerLength;
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

bool isCorrelated () {
   double bidSum = 0;
   double timeSum = 0;
   double max = 0;
   double min = 0;
   double current;
   double next;
   int count = 0;
   int pos_cnt = 0;
   int neg_cnt = 0;

   while(BIDS[count] != 0){
      count++;
      next = BIDS[count+1];
      current = BIDS[count];
      if (next != 0) {
         if (next > current) {
            pos_cnt++;
         } else if (next < current) {
            neg_cnt++;
         }
      }
   }
   logs += " posCnt="+pos_cnt+" negCnt="+neg_cnt;
   message += " \nposCnt="+pos_cnt+" \nnegCnt="+neg_cnt;
   
   //ティックが時間内に一回もなかった
   if (count == 0) {
      //logs += " \nno ticks";
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
   CC = covariance/(bidStd * timeStd);
   double roundedCC = CC;
   roundedCC = MathCeil(roundedCC * 100) * 1.0/100;
   logs += " R="+roundedCC;
   message += " \nR="+roundedCC;
   if (tick_cnt < 20) {
     // message += "\n WAIT!!!!";
   }
   message += "\nticks="+tick_cnt;
   previous_R = CC;
   if (MathAbs(CC) > rTol) {
      continuous_r_num++;
   }else{
      continuous_r_num = 0;
   }
   bidStd = bidStd/bidMean;
   bidStd = MathCeil(bidStd * 100000) * 1.0/100000;
   logs += " bidStd="+bidStd;
   message += " \nbidStd="+bidStd;
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

void setTicks(int timeDiff) {
   for (int i=0; i<60; i++) {
     if (timeDiff < i * 1000) {
      TICKS[i]++;
      return;
      }
   }
}

//秒間ティック数の標準偏差値　0に近いほど良い
void setStdTicksPerSecond() {
   double tickSum = 0;
   double tickDevSum = 0;
   for (int i=0; i<ArraySize(TICKS);i++) {
         tickSum += TICKS[i];
   }
   tickMean = tickSum/60;
   tickMean = MathCeil(tickMean * 100) * 1.0 /100;
   for (int i=0; i<ArraySize(TICKS);i++) {
       tickDevSum += MathPow((
         TICKS[i]-tickMean
       ),2);
   }
   double tickVariance = tickDevSum/60;
   tickStd = MathSqrt(tickVariance);
   tickStd = MathCeil(tickStd * 100) * 1.0 /100;
   csv += "tickMean";
   csv += ","+tickMean;
   csv += ","+"tickStd";
   csv += ","+tickStd;
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