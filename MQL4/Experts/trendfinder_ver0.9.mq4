
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
double BIG[] = {0.05,0.0005,0.05,0.00005,0.05,0.05,0.05};
double ATLEAST[] = {0.01,0.0001,0.01,0.00001,0.01,0.01,0.01};
double max_std = 0;
double sizeRatio0 = 0;
double sizeRatio1 = 0;
double sizeRatio2 = 0;
double whereInBand = 0;
double volatility = 0;
double size = 0;
double sigma = 0;
double highestBarry = 0;
double lowestBarry = 0;
string message = Symbol()+": ";
string csv = "";
string logs = "";
int candleNum = 3;
int continuous_r_num = 0;
int orderNum = 0;
int reverseNum = 0;
int numOfGoodVol = 0;
int emaBrokenTrend = 0;
int a30asc = 0;
int a30dsc = 0;
int b30asc = 0;
int b30dsc = 0;
int asecs = 0;
int desecs = 0;
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
bool goodEMA5 = false;
bool tp = false;
bool inUpperLower = false;
bool isInflated = false;
bool isNearResistance = false;
bool isNearEMA200 = false;
bool isSerial = false;
bool isSerial1 = false;
bool isSerial5 = false;
bool hasBrokenEMA = false;
bool onceBrokenEMA = false;
bool atEMA200 = false;
bool isLarger = false;
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
   setStdTicksPerSecond();
   haveBroken();

   max_std = 0;
   //相関係数で判断
   double a30CC = getCorrelated(A_BIDS,A_TIME,"a30s");
   double b30CC = getCorrelated(B_BIDS,B_TIME,"b30s");
   getCorrelated(BIDS,TIME,"1m");
   bool willBet = false;
   int local_hour = TimeHour(TimeLocal());
  
   if (volatility < 0.2){
      numOfGoodVol++;
   }else{
      numOfGoodVol = 0;
   }
   
   double badWhiskerRatio = getMeanEntityRatio(12, PERIOD_M5);
   
   bool A = false;
   bool B = false;
   bool C = false;
   bool D = false;
   bool E = false;
   bool F = false;
   bool G = false;
   
   logs += " a30asc="+a30asc+" a30dsc="+a30dsc+" b30asc="+b30asc+" b30dsc="+b30dsc+" 1masc="+asecs+" 1mdsc="+desecs;
   
   if (isBig)logs += " isBig";
   if (tick_cnt <= 50)logs += " lowTick(N)="+tick_cnt;
   if (tickMean <= 0.7)logs += " lowTick(μ)="+tickMean;
   if (tickStd <= 0.7)logs += " lowTick(σ)="+tickStd;
   if (sizeRatio0 <= 0.3)logs += " largeWhisker="+sizeRatio0; 
   if (volatility >= 0.3)logs += " tooVolatile="+volatility;
   if (MathAbs(CC) <= 0.9)logs += " badR="+MathAbs(CC);
   if (badWhiskerRatio >= 0.66)logs += " vigorous="+badWhiskerRatio;
 
   
   if (isInflated) {
      message += " \ninflated";
      if (tick_cnt > 50 && atEMA200) {
         message += " \n@ema200";
               if (!isSmall && tick_cnt > 50 && tickMean > 0.7 && tickStd > 0.7 && sizeRatio0 > 0.3 && volatility < 0.3) {
               A = true;
         }
      }else if(!isSmall && tick_cnt > 50 && onceBrokenEMA) {
         message += " \ninflatedAfterBroken";
         D = true;
      }
   }
   
   if (hasBrokenEMA) {
      if (!onceBrokenEMA) {
         onceBrokenEMA = true;
      }
      if (!isSmall && tick_cnt > 50 && badWhiskerRatio < 0.66) {
         message += " \nema200Broken";
         B = true;
      }
   }
   
   if (onceBrokenEMA) {
      if (tick_cnt > 100 && tickMean > 0.9 && tickStd > 0.9 && MathAbs(CC) > 0.9 && badWhiskerRatio < 0.66) {
      message += " \nbrokenBefore";
      C = true;
      }
   }else{
      message += " \nnotBroken";
   }
   /*
   if (willBreak) {
      logs += " @resistance";
      if (tick_cnt > 50 && tickMean > 0.85 && tickStd > 0.75 && (MathAbs(CC) > 0.8 || MathAbs(a30CC) > 0.7) && sizeRatio0 > 0.3) {
      C = true;
      }
   }
   */
   if (isNearResistance) {
      message += " \n@barry";
      if (tick_cnt > 50 && tickMean > 0.7 && tickStd > 0.7) {
      E = true;
      }
   }

   if (isNearEMA200) {
      message += " \nnearEma200";
      if (tick_cnt > 50 && sizeRatio0 > 0.3) {
      F = true;
      }
   }
   /*
   if (isSerial1) {
      logs += " Serial@1foot";
   }
   if (isSerial5) {
      logs += " Serial@5foot";
   }
   */
   double roundedCC = CC;
   roundedCC = MathCeil(roundedCC * 100) * 1.0/100;
   double rounded30CC = a30CC;
   rounded30CC = MathCeil(rounded30CC * 100) * 1.0/100;
   b30CC = MathCeil(b30CC * 100) * 1.0/100;
   double roundedVol = volatility;
   roundedVol = MathCeil(roundedVol * 100) * 1.0/100;
   double roundedHigh = highestBarry;
   roundedHigh = MathCeil(roundedHigh * 100) * 1.0/100;
   double roundedLow = lowestBarry;
   roundedLow = MathCeil(roundedLow * 100) * 1.0/100;
   
   int hour = TimeHour(TimeLocal());
   int minute = TimeMinute(TimeLocal());
   int seconds = TimeSeconds(TimeLocal());
   string time = hour+":"+minute+":"+seconds;

   //logs += " tickCnt="+tick_cnt+" tickMean="+tickMean+" tickStd="+tickStd+" CC="+roundedCC+" a30CC="+rounded30CC+" b30CC="+b30CC+" volatility="+roundedVol+" last12Whisker="+badWhiskerRatio+" size="+size+" prevRatio="+sizeRatio1;
   logs += " last12Whisker="+badWhiskerRatio+" size="+size+" highestBarry="+roundedHigh+" lowestBarry="+roundedLow; 
   csv += "time,"+time+",tickCnt,"+tick_cnt+",tickMean,"+tickMean+",tickStd,"+tickStd+",CC,"+roundedCC+",a30CC,"+rounded30CC+" b30CC="+b30CC+",volatility,"+roundedVol+",last12Whisker,"+badWhiskerRatio+",size,"+size+",sigma,"+sigma;
   if    (
   A ||
   B ||
   C ||
   D ||
   E ||
   F
   ) {
      StringReplace(logs, " ","\n");
      message += logs;
      Alert(message);
      alertCnt++;
      AlertFlag = true;
      //slack(message);
      //if (!badCandlePos && isBig && sinceAlerted_big == 0) sinceAlerted_big++;
    }else{
      Print(logs);
      AlertFlag = false;
    }
   //exportData(Symbol());
   //WindowScreenShot(TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal())+"_"+Symbol()+".gif", 640, 480);
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
   isNearEMA200 = false;
   goodEMA5 = false;
   isSerial = false;
   isSerial1 = false;
   isSerial5 = false;
   hasBrokenEMA = false;
   isLarger = false;
   atEMA200 = false;
   sizeRatio0 = 0;
   sizeRatio1 = 0;
   sizeRatio2 = 0;
   whereInBand = 0;
   volatility = 0;
   size = 0;
   sigma = 0;
   a30asc = 0;
   a30dsc = 0;
   b30asc = 0;
   b30dsc = 0;
   asecs = 0;
   desecs = 0;
}

void haveBroken() {
	
	double open1 = iCustom(Symbol(),PERIOD_M1,"HeikenAshi_DM",2,0);
   double close1 = iCustom(Symbol(),PERIOD_M1,"HeikenAshi_DM",3,0);
   double entity_size = getEntitySize(open1, close1);
   int entity_type = getEntity(open1,close1);
   bool asc = false;
   bool desc = false;
   double low = 0;
   double high = 0;
   double liveSize = 0;
   if (entity_type == 1) {
      low = iCustom(Symbol(),PERIOD_M1,"HeikenAshi_DM",0,0);
      high = iCustom(Symbol(),PERIOD_M1,"HeikenAshi_DM",1,0);
      asc = true;
   }else if (entity_type == 2) {
      low = iCustom(Symbol(),PERIOD_M1,"HeikenAshi_DM",1,0);
      high = iCustom(Symbol(),PERIOD_M1,"HeikenAshi_DM",0,0);
      desc = false;
   }
   double leadingA1 = iIchimoku(Symbol(),PERIOD_M1,9,26,52,3,0); //一目均衡(先行スパンA)
	double leadingB1 = iIchimoku(Symbol(),PERIOD_M1,9,26,52,4,0); //一目均衡(先行スパンB)
   int candle_position_one = getHeikenPosition(open1,close1,leadingA1,leadingB1);
   
	if (candle_position_one != 2 && candle_position_one != 3) {
	   badCandlePos = true;
	}
	
	double ema5 = iMA(Symbol(),PERIOD_M1,5,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(5)
   double ema20 = iMA(Symbol(),PERIOD_M1,20,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(20)
   double ema70 = iMA(Symbol(),PERIOD_M1,70,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(70)
   double ema200 = iMA(Symbol(),PERIOD_M1,200,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(200)
   
   if (candle_position_one == 2) {
      if (ema20 > ema70 && ema70 > ema200) {
         goodEMA = true;
         if (onceBrokenEMA) {
            onceBrokenEMA = false;
         }
      }
   }else if (candle_position_one == 3) {
      if (ema20 < ema70 && ema70 < ema200) {
         goodEMA = true;
         if (onceBrokenEMA) {
            onceBrokenEMA = false;
         }
      }
   }

   bool willExplode = false;
   double bid = MarketInfo(Symbol(),MODE_BID);
   double at = (bid-low)/entity_size;
   if (bid > low) {
      if (at > 0.9 || at < 0.1) {
         tp = true;
      }    
   }else if (bid > high) {
         tp = true;
   }else if (bid < low) {
         isTurningPoint = true;
         tp = true;
   }else {
   }
   
   if (Period() != PERIOD_M5) {
      return;
   }
   
   double upper = getValueByText("High_Low_Plus_UpperPrice");
   double lower = getValueByText("High_Low_Plus_LowerPrice");
   double omegaHigh = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",0,0);
   double omegaLow = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",1,0);
   if (highestBarry == 0 || lowestBarry == 0){
      updateOmega(60);
   }else{
      if(omegaHigh > highestBarry) highestBarry = omegaHigh;
      if(omegaLow < lowestBarry) lowestBarry = omegaLow;
   }
   double open5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,0);
   double close5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,0);
   double open51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,1);
   double close51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,1);
   double open52 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,2);
   double close52 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,2);
   int entity_type5 = getEntity(open5,close5);
   if (entity_type5 == 0) {
      return;
   }
   bool isAsc;
   double low5 = 0;
   double high5 = 0;
   if (entity_type5 == 1) {
      low5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,0);
      high5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,0);
      liveSize = bid - open5;
      isAsc = true;
   }else if (entity_type5 == 2) {
      low5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,0);
      high5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,0);
      liveSize = open5 - bid;
      isAsc = false;
   }
   
   int entity_type51 = getEntity(open51,close51);
   bool isAsc1;
   double low51 = 0;
   double high51 = 0;
   if (entity_type51 == 1) {
      low51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,1);
      high51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,1);
      isAsc1 = true;
   }else if (entity_type51 == 2) {
      low51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,1);
      high51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,1);
      isAsc1 = false;
   }
   int entity_type52 = getEntity(open52,close52);
   bool isAsc2;
   double low52 = 0;
   double high52 = 0;
   if (entity_type52 == 1) {
      low52 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,2);
      high52 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,2);
      isAsc2 = true;
   }else if (entity_type52 == 2) {
      low52 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,2);
      high52 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,2);
      isAsc2 = false;
   }
   double entity_size5 = getEntitySize(open5, close5);
   size = entity_size5;
   double entity_size51 = getEntitySize(open51, close51);
   double entity_size52 = getEntitySize(open52, close52);
   double size5 = MathAbs(high5 - low5);
   double size51 = MathAbs(high51 - low51);
   double size52 = MathAbs(high52 - low52);
   double leadingA5 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,0); //一目均衡(先行スパンA)
	double leadingB5 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,0); //一目均衡(先行スパンB)
   int candle_position_five = getHeikenPosition(open5,close5,leadingA5,leadingB5);
   //inflatedと連携するので前の実体の最低サイズを定義
   if (entity_size51 < ATLEAST[getIndex()]) {
      isSmall = true;
   }
   
   if (size > BIG[getIndex()]) {
      isBig = true;
   }
 
   //連続しているか
   if ((isAsc && isAsc1 && isAsc2)||(!isAsc && !isAsc1 && !isAsc2)){
      isSerial = true;
   }

   //抵抗線を超えたか判定
   if (isAsc && bid > upper && close51 <= upper) {
      willBreak = true;
   }else if(!isAsc && bid < lower && close51 >= lower) {
      willBreak = true;
   }
   
   //バリー抵抗線を超えたか判定
   if (isAsc && bid > highestBarry) {
      isNearResistance = true;
   }else if(!isAsc && bid < lowestBarry) {
      isNearResistance = true;
   }
   ema20 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(20)
   ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(70)
   ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(200)
   double ema200_1 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(200)
   
   if (candle_position_five == 2) {
      if (ema20 > ema70 && ema70 > ema200) {
         goodEMA5 = true;
      }
   }else if (candle_position_five == 3) {
      if (ema20 < ema70 && ema70 < ema200) {
         goodEMA5 = true;
      }
   }
   
   //EMA200を超えそうか判定
   if (isAsc && bid > ema200 && close51 <= ema200_1 && ema200 > ema70 && ema200 > ema20) {
      isNearEMA200 = true;
   }else if (!isAsc && bid < ema200 && close51 >= ema200_1 && ema200 < ema70 && ema200 < ema20) {
      isNearEMA200 = true;
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
   }
   sizeRatio0 = getEntityRatio(entity_size5,size5);
   sizeRatio1 = getEntityRatio(entity_size51,size51);
   sizeRatio2 = getEntityRatio(entity_size52,size52);
   
   double timesLarger = MathCeil((entity_size5/entity_size51) * 100) * 1.0/100;;
   
   if (entity_size5 > entity_size51 * 1.8 && isAsc == isAsc1) {
      isInflated = true;
   }
   if (entity_size5 > entity_size51 && isAsc == isAsc1) {
      isLarger = true;
   }
   logs += " ×"+timesLarger;
   isSerial1 = isSerial(PERIOD_M1);
   isSerial5 = isSerial(PERIOD_M15);
   
   if (isAsc && open5 < ema200 && ema200 < close5 ){
      atEMA200 = true;
   }else if(!isAsc && open5 > ema200 && ema200 > close5 ) {
      atEMA200 = true;
   }
   
   if (emaBrokenTrend == 1 && bid < ema200){
      onceBrokenEMA = false;
      emaBrokenTrend = 0;
   }else if (emaBrokenTrend == 2 && bid > ema200) {
      onceBrokenEMA = false;
      emaBrokenTrend = 0;
   }
   
   if (candle_position_five == 2 && isAsc1 && isAsc && open51 < ema200_1 && ema200_1 < close51 && ema200 < open5 && ema200 > ema70 && ema200 > ema20) {
      emaBrokenTrend = 1;
      hasBrokenEMA = true;
   }
   
   if (candle_position_five == 3 && !isAsc1 && !isAsc && open51 > ema200_1 && ema200_1 > close51 && ema200 > open5 && ema200 < ema70 && ema200 < ema20) {
      emaBrokenTrend = 2;
      hasBrokenEMA = true;
   }
   
   return;
   
}

double getEntityRatio(double entitySize, double totalSize) {
   return MathCeil((entitySize/totalSize) * 100) * 1.0/100;
}

double getMeanEntityRatio(int count, int timeframe) {
   double ratioSum = 0;
   double open = 0;
   double close = 0;
   double high = 0;
   double low = 0;
   double entity_type = 0;
   double whisker_size = 0;
   for (int i=0; i<count;i++) {
      whisker_size = 0;
      open = iCustom(Symbol(),timeframe,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),timeframe,"HeikenAshi_DM",3,i);

      entity_type = getEntity(open,close);
      //上昇
      if (entity_type == 1) {
         low = iCustom(Symbol(),timeframe,"HeikenAshi_DM",0,i);
         high = iCustom(Symbol(),timeframe,"HeikenAshi_DM",1,i);
         if (open > low) {
            whisker_size += open-low;
         } 
         whisker_size += high - close;
         ratioSum += whisker_size/(high - low);
      }else if (entity_type == 2) {
         low = iCustom(Symbol(),timeframe,"HeikenAshi_DM",1,i);
         high = iCustom(Symbol(),timeframe,"HeikenAshi_DM",0,i);
         if (high > open) {
            whisker_size += high-open;
         }
         whisker_size += close - low;
         ratioSum += whisker_size/(high - low);
      }else{
         whisker_size += (high - open) + (close - low);
         ratioSum += whisker_size/(high - low);
         }
      
   }
   return MathCeil((ratioSum/count) * 100) * 1.0/100;
}

 void updateOmega (int count) {
   double omegaHigh = 0;
   double omegaLow = 0;
   
   for (int i=0; i<count;i++) {
      omegaHigh = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",0,i);
      omegaLow = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",1,i);
      if (highestBarry == 0 || omegaHigh > highestBarry) highestBarry = omegaHigh;
      if (lowestBarry == 0 || omegaLow < lowestBarry) lowestBarry = omegaLow;
   }
 }

 bool isSerial(int period) {
   int count = 9;
   double open = iCustom(Symbol(),period,"HeikenAshi_DM",2,count);
   double close = iCustom(Symbol(),period,"HeikenAshi_DM",3,count);
   int entity_type = getEntity(open,close);
   int prev_entity_type = getEntity(open,close);
   
   while (count != 0) {
      count--;
      open = iCustom(Symbol(),period,"HeikenAshi_DM",2,count);
      close = iCustom(Symbol(),period,"HeikenAshi_DM",3,count);
      entity_type = getEntity(open,close);
      if (entity_type != prev_entity_type) return false;
   }
   return true;

}

double getValueByText(string objectName) {
   if(ObjectType(objectName)==OBJ_TEXT || ObjectType(objectName)==OBJ_LABEL){
      return StrToDouble(ObjectDescription(objectName));
   }
   return 0;
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
   double volProduct = 0;
   double max = 0;
   double min = 0;
   double current;
   double next;
   int count = 0;
   int max_asc = 0;
   int max_desc = 0;
   int num_ascs = 0;
   int num_descs = 0;
   bool was_asc = false;
   bool was_desc = false;
   int pos_cnt = 0;
   int neg_cnt = 0;
   double VOL[400];

   while(bids[count] != 0){
      next = bids[count+1];
      current = bids[count];
       if (next != 0) {
          if (next > current) {
            if (num_descs > max_desc) {
              max_desc = num_descs;
            }
            num_descs = 0;
            was_asc = true;
            was_desc = false;
            if (was_asc) {
               num_ascs++;
             }
          } else if (next < current) {
            if (num_ascs > max_asc) {
              max_asc = num_ascs;
            }
            num_ascs = 0;
             was_asc = false;
             was_desc = true;
             if (was_desc) {
                num_descs++;
              }
          }
       }
      count++;
      if (bids[count] == 0) {
         if (max_asc == 0 || num_ascs > max_asc)max_asc = num_ascs;
         if (max_desc == 0 || num_descs > max_desc)max_desc = num_descs;
      }
   }
   if (prefix == "a30s") {
      a30asc = max_asc;
      a30dsc = max_desc;
   }else if(prefix == "b30s") {
      b30asc = max_asc;
      b30dsc = max_desc;
   }else{
      asecs = max_asc;
      desecs = max_desc;
   }
      
   //ティックが時間内に一回もなかった
   if (count == 0) {
      return 0;
   }
   for (int i=0; i<count; i++) {
      bidSum += bids[i];
      timeSum += times[i];
      if (volProduct == 0) {
         volProduct = VOL[i];
      }else if (VOL[i] != 0){
         volProduct *= VOL[i];
      }
   }
   double bidMean = bidSum/count;
   double timeMean = timeSum/count;
   double power = 1.0/(count*1.0);
   double volMean = MathPow(MathAbs(volProduct),power);
   double bidDevSum = 0;
   double timeDevSum = 0;
   double volDevSum = 0;
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
       volDevSum += MathPow((
         VOL[i]-volMean
       ),2);
       
       productSum += (bids[i]-bidMean) * (times[i]-timeMean);
   }
   
   double bidVariance = bidDevSum/count;
   double timeVariance = timeDevSum/count;
   double covariance = productSum/count;
   double volVariance = volDevSum/count;
   double bidStd = MathSqrt(bidVariance);
   double timeStd = MathSqrt(timeVariance);
   double volStd = MathSqrt(volVariance);
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
   
   volatility = volStd;

   previous_R = CC;
   if (MathAbs(CC) > rTol) {
      continuous_r_num++;
   }else{
      continuous_r_num = 0;
   }
   bidStd = bidStd/bidMean;
   bidStd = MathCeil(bidStd * 100000) * 1.0/100000;
   sigma = bidStd;
   
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