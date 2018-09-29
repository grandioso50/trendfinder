
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
int continuous_type_num = 1;
int eval_minute = 4;
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
double tickMean30a;
double tickStd30a;
double tickMean30b;
double tickStd30b;
double prev_bid = 0;
double previous_R = 0;
double CC = 0;
//AUDJPY, AUDUSD, EURJPY, EURUSD, GBPJPY, NZDJPY, USDJPY
double MIN[] = {0.005,0.00004,0.01,0.00004,0.01,0.005,0.002};
double IDEAL_MIN[] = {0.005,0.00005,0.005,0.00005,0.005,0.005,0.15};
double IDEAL_MAX[] = {0.01,0.0001,0.01,0.0001,0.01,0.01,0.1};
double BIG[] = {0.048,0.00048,0.048,0.000048,0.048,0.048,0.048};
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
double highest = 0;
double lowest = 1000;
double highest0 = 0;
double lowest0 = 1000;
double highest1 = 0;
double lowest1 = 0;
double highest2 = 0;
double lowest2 = 0;
double highest3 = 0;
double lowest3 = 0;
double timesLarger = 0;
string message = Symbol()+": ";
string csv = "";
string logs = "";
string prev_cause = "";
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
bool beforeInflate = false;
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
bool isNearEMA70 = false;
bool isSerial = false;
bool isSerial1 = false;
bool isSerial5 = false;
bool hasBrokenEMA = false;
bool onceBrokenEMA = false;
bool atEMA200 = false;
bool atEMA70 = false;
bool isLarger = false;
bool was5term = false;
bool inCloud = false;
bool wasEMA70 = false;
bool atEMA200_1 = false;
bool nearEMA200_1 = false;
bool atEMA70_1 = false;
bool nearEMA70_1 = false;
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
   
   if (highest != 0 && lowest != 0 && (BIDS[tick_cnt] > highest || BIDS[tick_cnt] < lowest)) {
      if(!AlertFlag && beforeInflate && !was5term){
         //Alert(Symbol()+" watch out...cause="+prev_cause);
         AlertFlag = true;
      }
   }
   
   //今回の最高と最低を判断
   if (BIDS[tick_cnt] > highest0) highest0 = BIDS[tick_cnt];
   if (BIDS[tick_cnt] < lowest0) lowest0 = BIDS[tick_cnt];
   if (highest0 > highest) highest = highest0;
   if (lowest > lowest0) lowest = lowest0;
  
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
   bool H = false;
   bool I = false;
   bool J = false;
   bool T = true;
   
   int hour = TimeHour(TimeLocal());
   int minute = TimeMinute(TimeLocal());
   int seconds = TimeSeconds(TimeLocal());
   string time = hour+":"+minute+":"+seconds;
   
   int min_tick = 0;
   if (9 <= hour && hour <= 15){
      min_tick = 29;
   }else{
      min_tick = 49;
   }
   
   
   //logs += " a30asc="+a30asc+" a30dsc="+a30dsc+" b30asc="+b30asc+" b30dsc="+b30dsc;
   //logs += " avg30="+(a30asc+a30dsc+b30asc+b30dsc)/4;
  /* 
   if (isBig)logs += " isBig";
   
   if (tick_cnt <= min_tick)logs += " badtick_cnt(N)="+tick_cnt;
   if (tickMean <= 0.7)logs += " badtickMean(μ)="+tickMean;
   if (tickStd <= 0.7)logs += " badtickStd(σ)="+tickStd;
   if (sizeRatio0 <= 0.3)logs += " badsizeRatio0="+sizeRatio0; 
   if (volatility >= 0.3)logs += " badvolatility="+volatility;
   if (MathAbs(CC) <= 0.890)logs += " badR="+MathAbs(CC);
   if (badWhiskerRatio >= 0.66)logs += " badWhiskerRatio="+badWhiskerRatio;
      if (isBig)logs += " isBig";
   */   
   //logs += " ticks="+tick_cnt;
   //logs += " μ="+tickMean;
   //logs += " σ="+tickStd;
   //logs += " entityR="+sizeRatio0; 
   //logs += " rough="+volatility;
   //logs += " R="+MathAbs(CC);
   //logs += " vigorous="+badWhiskerRatio;
   
   if (!isSmall && tick_cnt > min_tick && sizeRatio0 > 0.3 && isInflated){
      if (atEMA200)
      {
      prev_cause = "atEMA200";
      beforeInflate = true;
      }
      else if(isNearResistance)
            {
            prev_cause = "isNearResistance";
      beforeInflate = true;
      }
      else if(isNearEMA200)
            {
            prev_cause = "isNearEMA200";
      beforeInflate = true;
      }
      else if(atEMA70)
            {
            prev_cause = "atEMA70";
      beforeInflate = true;
      }
      else if(isNearEMA70)
            {
            prev_cause = "isNearEMA70";
      beforeInflate = true;
      }
      else if(willBreak)
            {
            prev_cause = "willBreak";
      beforeInflate = true;
      }

   }else{
      beforeInflate = false;
      prev_cause = "";
   }
 
   
   if (isInflated) {
      //logs += " inflated";
      if (goodEMA5 && isSerial5) {
         logs += ",strong";
      }
      if (!inCloud && timesLarger > 1.5 && isBig && tick_cnt > 75 && tickMean > 1 && tickStd > 1 && MathAbs(CC) > 0.88 && badWhiskerRatio < 0.66) {
         logs += ",isTrend";
         I = true;
      }
      if (atEMA200) {
          logs += ",@ema200";
         if (atEMA200_1){
            logs += "(2nd)";
         }else{
            logs += "(1st)";
         }
         if (!inCloud && isBig && tick_cnt > min_tick && tickMean > 0.7 && tickStd > 0.7 && sizeRatio0 > 0.3 && volatility < 0.3) {
            A = true;
         }
      }
      if(onceBrokenEMA) {
         logs += ",inflatedAfterBroken";
         if (!inCloud && isBig && tick_cnt > min_tick) {
                     B = true;
         }
      }
      /*
      if (isNearResistance) {
         logs += " @barry";
         if (!inCloud && isBig && tick_cnt > min_tick && tickMean > 0.7 && tickStd > 0.7) {
            C = true;
         }
      }
      */
      if (isNearEMA200) {
         logs += ",nearEma200";
         if (nearEMA200_1){
            logs += "(2nd)";
         }else{
            logs += "(1st)";
         }
         if (!inCloud && isBig && tick_cnt > min_tick && sizeRatio0 > 0.3) {
            D = true;
            if (wasEMA70) {
               logs += ",@super";
               J = true;
            }
         }
      }
      if (atEMA70) {
         logs += ",@ema70";
         if (atEMA70_1){
            logs += "(2nd)";
         }else{
            logs += "(1st)";
         }
         if (!inCloud && isBig && tick_cnt > min_tick && tickMean > 0.7 && tickStd > 0.7 && sizeRatio0 > 0.3 && volatility < 0.3) {
            E = true;
            wasEMA70 = true;
         }else{
            wasEMA70 = false;
         }
      }else{
            wasEMA70 = false;
      }
      if (isNearEMA70) {
         logs += ",nearEma70";
         if (nearEMA70_1){
            logs += "(2nd)";
         }else{
            logs += "(1st)";
         }
         if (!inCloud && isBig && tick_cnt > min_tick && sizeRatio0 > 0.3) {
            F = true;
         }
      }
      if (willBreak) {
         logs += ",@resistance";
         if (!inCloud && isBig && tick_cnt > min_tick && sizeRatio0 > 0.3) {
            G = true;
         }
      }
   }else{
      logs += " x";
   }
   if (hasBrokenEMA) {
      if (!onceBrokenEMA) {
         onceBrokenEMA = true;
      }
   }


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
   
   double pos = 0;
   if (highest > lowest) {
      double delta = highest - lowest;
      double half = delta/2;
      double current = MarketInfo(Symbol(),MODE_BID);
      if (current > half) {
         if (delta != 0) pos = MathAbs(current - lowest)/delta;
      }else{
         if (delta != 0) pos = MathAbs(current - highest)/delta;
      }
      pos = MathCeil(pos * 100) * 1.0 /100;
   }
   
   
   if (minute == 4 || minute == 9 || minute == 14 || minute == 19 || minute == 24 || minute == 29 || minute == 34 || minute == 39
   || minute == 44 || minute == 49 || minute == 54 || minute == 59){
      was5term = false;
   }else{
      was5term = false;
   }
   double meanChange = 0;
   if (tickMean30a != 0) {
      meanChange = tickMean30b/tickMean30a;
   }
   meanChange = MathCeil(meanChange * 100) * 1.0/100;
   double stdChange = 0;
   if (tickStd30a != 0) {
      stdChange = tickStd30b/tickStd30a;
   }
   stdChange = MathCeil(stdChange * 100) * 1.0/100;

   logs += " μ2/μ1="+meanChange+" std2/std1="+stdChange+" μ1="+tickMean30a+" μ2="+tickMean30b+" std1="+tickStd30a+" std2="+tickStd30b;
   //logs += " avgHige="+badWhiskerRatio+" size="+size; 
   //csv += "time,"+time+",tickCnt,"+tick_cnt+",tickMean,"+tickMean+",tickStd,"+tickStd+",CC,"+roundedCC+",a30CC,"+rounded30CC+" b30CC="+b30CC+",volatility,"+roundedVol+",last12Whisker,"+badWhiskerRatio+",size,"+size+",sigma,"+sigma;
   if    (
   A ||
   B ||
   C ||
   D ||
   E ||
   F ||
   G ||
   H ||
   I ||
   J
   ) {
      StringReplace(logs, " ","\n");
      message += logs;
      Alert(message);
      alertCnt++;
      slack(message);
      //if (!badCandlePos && isBig && sinceAlerted_big == 0) sinceAlerted_big++;
    }else{
      if (isInflated) {
         if (inCloud) logs += " inCloud";
         if (!isBig) logs += " small="+size;
         if (tick_cnt <= min_tick) logs += " tick="+tick_cnt;
         if (tickMean <= 0.7) logs += " tickMean="+tickMean;
         if (tickStd <= 0.7) logs += " tickStd="+tickStd;
         if (sizeRatio0 <= 0.3) logs += " sizeRatio0="+sizeRatio0;
         if (volatility >= 0.3) logs += " volatility="+volatility;
      }
      Print(logs);
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
   isNearEMA70 = false;
   goodEMA5 = false;
   isSerial = false;
   isSerial1 = false;
   isSerial5 = false;
   hasBrokenEMA = false;
   isLarger = false;
   atEMA200 = false;
   atEMA70 = false;
   inCloud = false;
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
   highest3 = highest2;
   lowest3 = lowest2;
   highest2 = highest1;
   lowest2 = lowest1;
   highest1 = highest0;
   lowest1 = lowest0;
   highest0 = 0;
   lowest0 = 1000;
   if (highest3 > highest2 && highest3 > highest1) highest = highest3;
   if (highest2 > highest3 && highest2 > highest1) highest = highest2;
   if (highest1 > highest3 && highest1 > highest2) highest = highest1;
   if (lowest3 < lowest2 && lowest3 < lowest1) lowest = lowest3;
   if (lowest2 < lowest3 && lowest2 < lowest1) lowest = lowest2;
   if (lowest1 < lowest3 && lowest1 < lowest2) lowest = lowest1;
   //Print("highest2="+highest);
   //Print("lowest2="+lowest);
   AlertFlag = false;
   timesLarger = 0;
   continuous_type_num = 1;
   tickMean30a = 0;
   tickStd30a = 0;
   tickMean30b = 0;
   tickStd30b = 0;
   atEMA200_1 = false;
   nearEMA200_1 = false;
   atEMA70_1 = false;
   nearEMA70_1 = false;
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
	if (leadingA5 > leadingB5) {
	   if (leadingA5 > bid && bid > leadingB5)
	   {
	   	//logs += " inCloud";
	      inCloud = true;
	   }
	}else{
	   if (leadingA5 < bid && bid < leadingB5)
	   {
	   	//logs += " inCloud";
	      inCloud = true;
	   }
	}
   int candle_position_five = getHeikenPosition(open5,close5,leadingA5,leadingB5);
   //inflatedと連携するので前の実体の最低サイズを定義
   if (entity_size51 < ATLEAST[getIndex()]) {
      isSmall = true;
   }
   
   if (size > BIG[getIndex()]) {
      isBig = true;
   }else{
      //logs += " !isBig";
   }
 
   //連続しているか
   if ((isAsc && isAsc1 && isAsc2)||(!isAsc && !isAsc1 && !isAsc2)){
      isSerial = true;
   }

   //抵抗線を超えたか判定
   if (isAsc && bid > upper && upper > high51) {
      willBreak = true;
   }else if(!isAsc && bid < lower && lower < low51) {
      willBreak = true;
   }else{
      //logs += " !WillBreak";
   }
   
   //バリー抵抗線を超えたか判定
   if (isAsc && bid > highestBarry && highestBarry > high51) {
      isNearResistance = true;
   }else if(!isAsc && bid < lowestBarry && lowestBarry < low51) {
      isNearResistance = true;
   }else{
      //logs += " !@barry";
   }
   ema5 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(5)
   double ema5_1 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(5)
   double ema5_2 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,2); //指数移動平均(5)
   double ema5_3 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,3); //指数移動平均(5)
   double ema5_4 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,4); //指数移動平均(5)
   ema20 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(20)
   ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(70)
   double ema70_1 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(200)
   ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(200)
   double ema200_1 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(200)
   
   if (candle_position_five == 2) {
      if (ema5 > ema20 && ema5_1 > ema20 && ema5_2 > ema20 && ema5_3 > ema20 && ema5_4 > ema20 && ema20 > ema70 && ema70 > ema200) {
         goodEMA5 = true;
      }
   }else if (candle_position_five == 3) {
      if (ema5 < ema20 && ema5_1 < ema20 && ema5_2 < ema20 && ema5_3 < ema20 && ema5_4 < ema20 && ema20 < ema70 && ema70 < ema200) {
         goodEMA5 = true;
      }
   }
   
   //EMA70を超えそうか判定
   if (isAsc && bid > ema70 && close51 <= ema70_1 && ema200 > ema70 && ema70 > ema20) {
      isNearEMA70 = true;
      if (high51 > ema70_1) {
         nearEMA70_1 = true;
      }
   }else if (!isAsc && bid < ema70 && close51 >= ema70_1 && ema200 < ema70 && ema70 < ema20) {
      isNearEMA70 = true;
      if (low51 < ema70_1) {
         nearEMA70_1 = true;
      }
   }else{
      //logs += " !NearEMA70";
   }
   
   //EMA200を超えそうか判定
   if (isAsc && bid > ema200 && close51 <= ema200_1 && ema200 > ema70 && ema200 > ema20) {
      isNearEMA200 = true;
      if (high51 > ema200_1) {
         nearEMA200_1 = true;
      }
   }else if (!isAsc && bid < ema200 && close51 >= ema200_1 && ema200 < ema70 && ema200 < ema20) {
      isNearEMA200 = true;
      if (low51 < ema200_1) {
         nearEMA200_1 = true;
      }
   }else{
      //logs += " !NearEMA200";
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
   
   timesLarger = MathCeil((entity_size5/entity_size51) * 100) * 1.0/100;
   
   double live_size = getEntitySize(open1, bid);
   if (entity_size5 >= live_size) {
      live_size = entity_size5;
   }
   if (live_size > entity_size51 * 0.9 && isAsc == isAsc1) {
      isInflated = true;
   }else{
      logs += " timesLarger="+MathCeil((live_size/entity_size51) * 100) * 1.0/100;
   }
   if (entity_size5 > entity_size51 && isAsc == isAsc1) {
      isLarger = true;
   }
   //logs += " ×"+timesLarger;
   isSerial1 = isSerial(PERIOD_M1);
   isSerial5 = isSerial(PERIOD_M5);
   
   if (isAsc && open5 < ema200 && ema200 < close5 ){
      atEMA200 = true;
      if (high51 > ema200_1) {
         atEMA200_1 = true;
      }
   }else if(!isAsc && open5 > ema200 && ema200 > close5 ) {
      atEMA200 = true;
      if (low51 < ema200_1) {
         atEMA200_1 = true;
      }
   }else{
      //logs += " !@EMA200";
   }
   
   if (isAsc && open5 < ema70 && ema70 < close5 ){
      atEMA70 = true;
      if (high51 > ema70_1) {
         atEMA70_1 = true;
      }
   }else if(!isAsc && open5 > ema70 && ema70 > close5 ) {
      atEMA70 = true;
      if (low51 < ema70_1) {
         atEMA70_1 = true;
      }
   }else{
      //logs += " !@EMA70";
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
   int prev_type = -1;
   bool will_count = true;
   for (int i=0; i<count;i++) {
      whisker_size = 0;
      open = iCustom(Symbol(),timeframe,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),timeframe,"HeikenAshi_DM",3,i);

      entity_type = getEntity(open,close);
      if (will_count) {
         if (prev_type == -1) {
            prev_type = entity_type;
         }else if(prev_type == entity_type){
            continuous_type_num++;
         }else{
            will_count = false;
         }
         prev_type = entity_type;
      }

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
   int count = 8;
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
   double tickSum30a = 0;
   double tickSum30b = 0;
   double tickDevSum30a = 0;
   double tickDevSum30b = 0;
   for (int i=0; i<ArraySize(TICKS);i++) {
         tickSum += TICKS[i];
         if (i <= 30) {
            tickSum30a += TICKS[i];
         }else{
            tickSum30b += TICKS[i];
         }
   }
   tickMean = tickSum/60;
   tickMean = MathCeil(tickMean * 100) * 1.0 /100;
   tickMean30a = tickSum30a/30;
   tickMean30a = MathCeil(tickMean30a * 100) * 1.0 /100;
   tickMean30b = tickSum30b/30;
   tickMean30b = MathCeil(tickMean30b * 100) * 1.0 /100;
   for (int i=0; i<ArraySize(TICKS);i++) {
       tickDevSum += MathPow((
         TICKS[i]-tickMean
       ),2);
       if (i <= 30) {
         tickDevSum30a += MathPow((
         TICKS[i]-tickMean30a
         ),2);
       }else{
         tickDevSum30b += MathPow((
         TICKS[i]-tickMean30b
         ),2);
       }
   }
   double tickVariance = tickDevSum/60;
   tickStd = MathSqrt(tickVariance);
   tickStd = MathCeil(tickStd * 100) * 1.0 /100;
   double tickVariance30a = tickDevSum30a/30;
   tickStd30a = MathSqrt(tickVariance30a);
   tickStd30a = MathCeil(tickStd30a * 100) * 1.0 /100;
   double tickVariance30b = tickDevSum30b/30;
   tickStd30b = MathSqrt(tickVariance30b);
   tickStd30b = MathCeil(tickStd30b * 100) * 1.0 /100;
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