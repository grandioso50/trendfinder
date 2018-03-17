
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

bool AlertFlag = false;
//ティックが順な閾値
double rTol = 0.7;
int timeInterval = 60;
int tick_cnt = 0;
int a_tick_cnt = 0;
int b_tick_cnt = 0;
int prev_tick_cnt = 0;
int sinceAlerted_big = 0;
int sinceAlerted_broken = 0;
int sinceAlerted_break = 0;
int sinceAlerted_ideal = 0;
int sinceAlerted_extreme = 0;
double BIDS[400];
double initialTime = GetTickCount();
double TIME[400];
double A_BIDS[400];
double A_TIME[400];
double B_BIDS[400];
double b_initialTime;
double B_TIME[400];
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
double BIG[] = {0.038,0.00038,0.038,0.00038,0.038,0.038,0.038};
double ATLEAST[] = {0.1,0.001,0.1,0.001,0.1,0.1,0.1};
double max_std = 0;
double sizeRatio0 = 0;
double sizeRatio1 = 0;
double whereInBand = 0;
string message = Symbol()+": ";
string csv = "";
string logs = "";
int candleNum = 3;
int continuous_r_num = 0;
int orderNum = 0;
int reverseNum = 0;
bool isBig = false;
bool isSmall = false;
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
bool atBorder = false;
bool goodEMA = false;
bool tp = false;
bool inUpperLower = false;
bool isInflated = false;
bool isNearResistance = false;
bool isNearEMA = false;
int ascend_num = 0;
int descend_num = 0;
int alertCnt = 0;

int OnInit()
  {
//--- create timer
   EventSetTimer(timeInterval);
      
//---
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
   EventKillTimer();
      
  }
void OnTick()
  {
   //1分刻み
   BIDS[tick_cnt] = MarketInfo(Symbol(),MODE_BID);
   TIME[tick_cnt] = GetTickCount() - initialTime;
  
   if (TIME[tick_cnt] < 30000) {
   //前半の30秒
      A_BIDS[a_tick_cnt] = MarketInfo(Symbol(),MODE_BID);
      A_TIME[a_tick_cnt] = GetTickCount() - initialTime;
      a_tick_cnt++;
   }else{
   //後半の30秒
      if (b_tick_cnt == 0) {
            b_initialTime = GetTickCount();
      }
      B_BIDS[b_tick_cnt] = MarketInfo(Symbol(),MODE_BID);
      B_TIME[b_tick_cnt] = GetTickCount() - b_initialTime;
      b_tick_cnt++;
   }
   
   setTicks(GetTickCount() - initialTime);
   tick_cnt++;
  }

void OnTimer()
  {
   logs += " alertCnt="+alertCnt;
   setStdTicksPerSecond();
   haveBroken();

  // message += " \ntickMean="+tickMean+" \ntickStd="+tickStd;
  // logs += " tickMean="+tickMean+" tickStd="+tickStd;
   max_std = 0;
   //相関係数で判断
   double a30CC = getCorrelated(A_BIDS,A_TIME,"a30s");
   double b30CC = getCorrelated(B_BIDS,B_TIME,"b30s");
   getCorrelated(BIDS,TIME,"1m");
   bool willBet = false;
   int local_hour = TimeHour(TimeLocal());
  
   controlAlerts();
   bool A = false;
   bool B = false;
   bool C = false;
   bool D = false;
   bool E = false;
   bool F = false;
   bool G = false;
   if ((tick_cnt > 50 && willBreak && tickMean > 1 && tickStd > 0.9 && MathAbs(CC) > 0.8 && MathAbs(a30CC) > 0.7 && MathAbs(b30CC) > 0.7 && sizeRatio0 > 0.3)) {
      A = true;
      logs += " 'A' ";
      message += " \nGood 30s correlation";
   }
   if ((!isSmall && tick_cnt > 115 && tickMean > 1 && tickStd > 0.9 && MathAbs(CC) > 0.8 && sizeRatio0 > 0.3)) {
      B = true;
      logs += " 'B' ";
      message += " \nGood strongly stable";
   }
   if ((!isSmall && tick_cnt > 50 && isBig && goodEMA && tickMean > 0.7 && MathAbs(CC) > 0.8 && sizeRatio0 > 0.3)) {
      C = true;
      logs += " 'C' ";
      message += " \nbig and nice EMA";
   }
   if (!isSmall && tick_cnt > 50 && tickMean > 0.7 && MathAbs(CC) > 0.8 && inUpperLower && whereInBand > 0.8 && sizeRatio0 > 0.3) {
      D = true;
      logs += " 'D' ";
      message += " \nnear upper or lower";
   }
   /*
   if ((!isSmall && tick_cnt > 50 && isInflated && sizeRatio0 > 0.3)) {
      E = true;
      message += " \ninflated";
   }
   */
   if ((!isSmall && tick_cnt > 50 && tickMean > 0.7 && MathAbs(CC) > 0.8 && isNearResistance && sizeRatio0 > 0.3)) {
      F = true;
      logs += " 'F' ";
      message += " \nnearBarry";
   }
   if ((!isSmall && tick_cnt > 50 && tickMean > 0.7 && MathAbs(CC) > 0.8 && isNearEMA && sizeRatio0 > 0.3)) {
      G = true;
      logs += " 'G' ";
      message += " \nnear ema200";
   }
   double roundedCC = CC;
   roundedCC = MathCeil(roundedCC * 100) * 1.0/100;
   logs += " tickCnt="+tick_cnt+" tickMean="+tickMean+" tickStd="+tickStd+" CC="+roundedCC;
   if    (
   A || 
   B || 
   C ||
   D || 
   F ||
   G
   ) {
      if (G){
         slack(message);
      }
      Alert(message);
      alertCnt++;
      AlertFlag = true;
      if (!badCandlePos && isBig && sinceAlerted_big == 0) sinceAlerted_big++;
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
   a_tick_cnt = 0;
   b_tick_cnt = 0;
   ArrayInitialize(BIDS,0);
   ArrayInitialize(TIME,0);
   ArrayInitialize(TICKS,0);
   ArrayInitialize(A_BIDS,0);
   ArrayInitialize(A_TIME,0);
   ArrayInitialize(B_BIDS,0);
   ArrayInitialize(B_TIME,0);
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
   tp = false;
   goodEMA = false;
   atBorder = false;
   isSmall = false;
   inUpperLower = false;
   isInflated = false;
   isNearResistance = false;
   isNearEMA = false;
   sizeRatio0 = 0;
   sizeRatio1 = 0;
   whereInBand = 0;
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
	
	double open1 = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",2,0);
   double close1 = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",3,0);
   double entity_size = getEntitySize(open1, close1);
   int entity_type = getEntity(open1,close1);
   bool asc = false;
   bool desc = false;
   if (entity_type == 1) {
      asc = true;
   }else if (entity_type == 2) {
      desc = false;
   }
   double leadingA1 = iIchimoku(Symbol(),PERIOD_M1,9,26,52,3,0); //一目均衡(先行スパンA)
	double leadingB1 = iIchimoku(Symbol(),PERIOD_M1,9,26,52,4,0); //一目均衡(先行スパンB)
   int candle_position_one = getHeikenPosition(open1,close1,leadingA1,leadingB1);
   
	if (candle_position_one != 2 && candle_position_one != 3) {
	  // logs += " 1foot: at cloud";
	   badCandlePos = true;
	}
	
	double ema5 = iMA(Symbol(),PERIOD_M1,5,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(5)
   double ema20 = iMA(Symbol(),PERIOD_M1,20,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(20)
   double ema70 = iMA(Symbol(),PERIOD_M1,70,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(70)
   double ema200 = iMA(Symbol(),PERIOD_M1,200,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(200)
   
   if (candle_position_one == 2) {
      if (ema20 > ema70 && ema70 > ema200) {
         //logs += " goodEMA";
         goodEMA = true;
      }
   }else if (candle_position_one == 3) {
      if (ema20 < ema70 && ema70 < ema200) {
         //logs += " goodEMA";
         goodEMA = true;
      }
   }
   
   double low = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",1,0);
   double high = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",0,0);
   //一足前
   double low1 = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",1,1);
   double high1 = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",0,1);
   bool willExplode = false;
   if (MathAbs(high-low) > BIG[getIndex()]) {
      //logs += " BIG";
      //message += " \nBIG";
      isBig = true;
   }
   double bid = MarketInfo(Symbol(),MODE_BID);
   double at = (bid-low)/entity_size;
   if (bid > low) {
      if (at > 0.9 || at < 0.1) {
        // message += " \nisTurningPoint(1)";
        // logs += " isTurningPoint(1)";
         tp = true;
      }    
   }else if (bid > high) {
        // message += " \nisTurningPoint(2)";
        // logs += " isTurningPoint(2)";
         tp = true;
   }else if (bid < low) {
        // message += " \nisTurningPoint(3)";
        // logs += " isTurningPoint(3)";
         isTurningPoint = true;
         tp = true;
   }else {
         //logs += " notTP="+at;
   }
   
   if (Period() != PERIOD_M5) {
      return;
   }
   
   double upper = getValueByText("High_Low_Plus_UpperPrice");
   double lower = getValueByText("High_Low_Plus_LowerPrice");
   double omegaHigh = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",0,0);
   double omegaLow = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",1,0);
   double open5 = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",2,0);
   double close5 = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",3,0);
   double open51 = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",2,1);
   double close51 = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",3,1);
   double low5 = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",1,0);
   double high5 = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",0,0);
   double low51 = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",1,1);
   double high51 = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",0,1);
   double entity_size5 = getEntitySize(open5, close5);
   double entity_size51 = getEntitySize(open51, close51);
   double size5 = MathAbs(high5 - low5);
   double size51 = MathAbs(high51 - low51);
   
   if (size5 < ATLEAST[getIndex()] && size51 < ATLEAST[getIndex()]) {
     // logs += " minSizeNotMet="+size5;
     // message += " \nminSizeNotMet="+size5;
      isSmall = true;
   }else{
     // message += " \nminSizeMet"+size5;
     // logs += " minSizeMet="+size5;
   }
 
   int entity_type5 = getEntity(open5,close5);
   if (entity_type5 == 0) {
      return;
   }
   bool isAsc;
   if (entity_type5 == 1) {
      isAsc = true;
   }else if (entity_type5 == 2) {
      isAsc = false;
   }
   
   int entity_type51 = getEntity(open51,close51);
   bool isAsc1;
   if (entity_type51 == 1) {
      isAsc1 = true;
   }else if (entity_type51 == 2) {
      isAsc1 = false;
   }

   //抵抗線を超えそうか判定
   if (isAsc && high5 < upper && bid < upper && (high5 + entity_size5) > upper && high51 <= upper) {
      willBreak = true;
   }else if(!isAsc && low5 > lower && bid > lower && (low5 - entity_size5) < lower && low51 >= lower) {
      willBreak = true;
   }
   
   //バリー抵抗線を超えそうか判定
   if (isAsc && high5 < omegaHigh && bid < omegaHigh && (high5 + entity_size5) > omegaHigh && high51 <= omegaHigh) {
      isNearResistance = true;
   }else if(!isAsc && low5 > omegaLow && bid > omegaLow && (low5 - entity_size5) < omegaLow && low51 >= omegaLow) {
      isNearResistance = true;
   }
   ema20 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(20)
   ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(70)
   ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(200)
   
   //EMA200を超えそうか判定
   if (isAsc && bid < ema200 && ema200 < (high5 + entity_size5) && high51 <= ema200 && ema200 > ema70 && ema200 > ema20 && close5 >= ema200) {
      logs += " near EMA200(asc)";
      isNearEMA = true;
   }else if (!isAsc && bid > ema200 && ema200 > (low5 - entity_size5) && low51 >= ema200 && ema200 < ema70 && ema200 < ema20 && close5 <= ema200) {
      logs += " near EMA200(desc)";
      isNearEMA = true;
   }
   
   if (bid < upper && bid > lower) {
      inUpperLower = true;
      //upperからの中間地点
      double halfway = upper - (MathAbs(upper - lower))/2;
      if (bid > halfway) {
         whereInBand = (bid - halfway)/(upper - halfway);
      }else{
         whereInBand = (halfway - bid)/(halfway - lower);
      }
      whereInBand = MathCeil(whereInBand * 100) * 1.0/100;
      logs += " posInBand="+whereInBand;
      message += " \nposInBand="+whereInBand;
   }
   sizeRatio0 = entity_size5/size5;
   sizeRatio0 = MathCeil(sizeRatio0 * 100) * 1.0/100;
   sizeRatio1 = entity_size51/size51;
   sizeRatio1 = MathCeil(sizeRatio1 * 100) * 1.0/100;
   logs += " whiskerRatio0="+sizeRatio0;
   logs += " whiskerRatio1="+sizeRatio1;
   message += " \nwhiskerRatio0="+sizeRatio0;
   message += " \nwhiskerRatio1="+sizeRatio1;
   if (entity_size5 > entity_size51 * 2 && isAsc == isAsc1) {
      isInflated = true;
   }
   return;
   
}

double getWhiskerSize (bool isAsc, int index) {
   double open = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",2,index);
   double close = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",3,index);
   double low = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",1,index);
   double high = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",0,index);
   double whiskerSize = 0;
   
   if (isAsc) {
      whiskerSize += high - close;
      if (open > low){
         whiskerSize += open - low;
      }    
   }else{
      whiskerSize += close - low;
      if (high > open) {
         whiskerSize += high - open;
      }
   }
   return whiskerSize;
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

double getCorrelated (double &bids[],double &times[],string prefix) {
   double bidSum = 0;
   double timeSum = 0;
   double max = 0;
   double min = 0;
   double current;
   double next;
   int count = 0;
   int pos_cnt = 0;
   int neg_cnt = 0;

   while(bids[count] != 0){
      count++;
      next = bids[count+1];
      current = bids[count];
      if (next != 0) {
         if (next > current) {
            pos_cnt++;
         } else if (next < current) {
            neg_cnt++;
         }
      }
   }
   
   //ティックが時間内に一回もなかった
   if (count == 0) {
      return 0;
   }
   
   for (int i=0; i<count; i++) {
      bidSum += bids[i];
      timeSum += times[i];
   }
   double bidMean = bidSum/count;
   double timeMean = timeSum/count;
   double bidDevSum = 0;
   double timeDevSum = 0;
   double productSum = 0;
   
   for (int i=0; i<count; i++) {
       updateMaxStd(MathPow((
         bids[i]-bidMean
       ),2));
       bidDevSum += MathPow((
         bids[i]-bidMean
       ),2);
       timeDevSum += MathPow((
         times[i]-timeMean
       ),2);
       productSum += (bids[i]-bidMean) * (times[i]-timeMean);
   }
   
   double bidVariance = bidDevSum/count;
   double timeVariance = timeDevSum/count;
   double covariance = productSum/count;
   double bidStd = MathSqrt(bidVariance);
   double timeStd = MathSqrt(timeVariance);
   double slope = 0;
   if (timeStd != 0) {
      slope = covariance/timeStd;
   }
   
   if ((bidStd * timeStd) == 0) {
      return 0;
   }
   CC = covariance/(bidStd * timeStd);
   double roundedCC = CC;
   roundedCC = MathCeil(roundedCC * 100) * 1.0/100;
   //logs += " "+prefix+"_R="+roundedCC;
   //message += " \n"+prefix+"_R="+roundedCC;
   previous_R = CC;
   if (MathAbs(CC) > rTol) {
      continuous_r_num++;
   }else{
      continuous_r_num = 0;
   }
   bidStd = bidStd/bidMean;
   bidStd = MathCeil(bidStd * 100000) * 1.0/100000;
   double ratio = MathAbs(pos_cnt - neg_cnt);
   return CC;
 
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