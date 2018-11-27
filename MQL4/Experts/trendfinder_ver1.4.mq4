
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

bool AlertFlag = false;
//ティックが順な閾値
double rTol = 0.7;
double mean_period = 0;
int timeInterval = 60;
int tick_cnt = 0;
int a_tick_cnt = 0;
int b_tick_cnt = 0;
int c_tick_cnt = 0;
int prev_tick_cnt = 1;
int sinceAlerted_big = 0;
int sinceAlerted_broken = 0;
int sinceAlerted_break = 0;
int sinceAlerted_ideal = 0;
int sinceAlerted_extreme = 0;
int continuous_type_num = 1;
int eval_minute = 4;
int cnt_1 = 0;
int cnt_2 = 0;
int cnt_3 = 0;
double positives = 0;
double negatives = 0;
int deltaCnt = 0;
double BIDS[400];
double initialTime = GetTickCount();
double TIME[400];
double BID_DELTA[400];
double A_BIDS[400];
double A_TIME[400];
double B_BIDS[400];
double b_initialTime;
double B_TIME[400];
double C_BIDS[400];
double c_initialTime;
double C_TIME[400];
double BIDS_2[400];
double BIDS_3[400];
double TIME_2[400];
double TIME_3[400];
double BID_SUM[1200];
double TIME_SUM[1200];
double TICKS[60];
double TICKS30[30];
double TICKS15[15];
double MINUTE[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60};
double SECOND_30[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30};
double SECOND_15[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
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
double IDEAL_MAX[] = {0.11,0.0011,0.11,0.0011,0.11,0.11,0.11};
double BIG[] = {0.048,0.00048,0.048,0.000048,0.048,0.048,0.048};
double GIGANT[] = {0.08,0.0008,0.08,0.00008,0.08,0.08,0.08};
double ATLEAST[] = {0.003,0.00003,0.003,0.000003,0.003,0.003,0.003};
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
double highest12m = 0;
double lowest12m = 1000;
double highest4m = 0;
double lowest4m = 1000;
double highest2m = 0;
double lowest2m = 1000;
double highest0 = 0;
double lowest0 = 1000;
double highest1 = 0;
double lowest1 = 0;
double highest2 = 0;
double lowest2 = 0;
double highest3 = 0;
double lowest3 = 0;
double highest4 = 0;
double lowest4 = 0;
double highest5 = 0;
double lowest5 = 0;
double highest6 = 0;
double lowest6 = 0;
double highest7 = 0;
double lowest7 = 0;
double highest8 = 0;
double lowest8 = 0;
double highest9 = 0;
double lowest9 = 0;
double highest10 = 0;
double lowest10 = 0;
double highest11 = 0;
double lowest11 = 0;
double timesLarger = 0;
double t1m = 0;
double delta2mRatio = 0;
double ema2070Distance = 0;
string message = Symbol()+":highlow";
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
bool isNearEMA70 = false;
bool isSerial = false;
bool isSerial1 = false;
bool isSerial5 = false;
bool hasBrokenEMA = false;
bool onceBrokenEMA = false;
bool atEMA200 = false;
bool weakEMA200 = false;
bool strongEMA200 = false;
bool atEMA70 = false;
bool atEMA20 = false;
bool isLarger = false;
bool inCloud = false;
bool wasEMA70 = false;
bool idealBig = false;
bool ascending = false;
bool descending = false;
bool strongEMA = false;
bool crossEMA = false;
bool outermost = false;
bool needRefresh = false;
bool willBreakBarry = false;
bool isGigantic = false;
bool aroundCloud = false;
int ascend_num = 0;
int descend_num = 0;
int alertCnt = 0;
datetime last_alert = TimeCurrent();
datetime first_launched = TimeCurrent();
datetime last_combo = TimeCurrent();

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
   
   //今回の最高と最低を判断
   if (BIDS[tick_cnt] > highest0) highest0 = BIDS[tick_cnt];
   if (BIDS[tick_cnt] < lowest0) lowest0 = BIDS[tick_cnt];
   if (highest0 > highest12m) highest12m = highest0;
   if (lowest12m > lowest0) lowest12m = lowest0;
   if (highest0 > highest4m) highest4m = highest0;
   if (lowest4m > lowest0) lowest4m = lowest0;
   if (highest0 > highest2m) highest2m = highest0;
   if (lowest2m > lowest0) lowest2m = lowest0;
  
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
      if (TIME[tick_cnt] > 44000) {
         if (c_tick_cnt == 0) {
            c_initialTime = GetTickCount();
         }
         C_BIDS[c_tick_cnt] = MarketInfo(Symbol(),MODE_BID);
         C_TIME[c_tick_cnt] = GetTickCount() - c_initialTime;
         c_tick_cnt++;
      }
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
   double CC_15s = getCorrelated(C_BIDS,C_TIME,"15s");
   ArrayCopy(BID_SUM,BIDS,0,0,WHOLE_ARRAY);
   ArrayCopy(TIME_SUM,TIME,0,0,WHOLE_ARRAY);
   ArrayCopy(BID_SUM,BIDS_2,cnt_1,0,WHOLE_ARRAY);
   ArrayCopy(TIME_SUM,TIME_2,cnt_1,0,WHOLE_ARRAY);
   ArrayCopy(BID_SUM,BIDS_3,cnt_1+cnt_2,0,WHOLE_ARRAY);
   ArrayCopy(TIME_SUM,TIME_3,cnt_1+cnt_3,0,WHOLE_ARRAY);
   double posRate = 0;
   double negRate = 0;

   double CC_3m = getCorrelated(BID_SUM,TIME_SUM,"3m");
   double ticks60 = getCorrelated(TICKS,MINUTE,"");
   double ticks30 = getCorrelated(TICKS30,SECOND_30,"");
   double ticks15 = getCorrelated(TICKS15,SECOND_15,"");
   getCorrelated(BIDS,TIME,"1m");
   bool is_increasing = false;
   if (CC>0) {
      is_increasing = true;
   }
   double sig_level = 1.19;
   setBidDelta(BIDS);
   int rejected = testT(BID_DELTA,sig_level,is_increasing,"1m");
   bool has_rejected = false;
   if (rejected == 1) {
      has_rejected = true;
   }
   
   double momentum = 0;
   if (mean_period != 0) {
      momentum = MathCeil((10000/mean_period) * 100) * 1.0 /100;
   }
   bool willBet = false;
   int local_hour = TimeHour(TimeLocal());
  
   if (volatility < 0.2){
      numOfGoodVol++;
   }else{
      numOfGoodVol = 0;
   }
   
   double hige1H = getHigeRatio(12, PERIOD_M5);
   hige1H = MathCeil(hige1H * 100) * 1.0/100;
   double hige30 = getHigeRatio(6, PERIOD_M5);
   hige30 = MathCeil(hige30 * 100) * 1.0/100;
   double hige15 = getHigeRatio(3, PERIOD_M5);
   hige15 = MathCeil(hige15 * 100) * 1.0/100;
   
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
   bool K = false;
   bool L = false;
   bool M = false;
   bool N = false;
   bool O = false;
   bool P = false;
   bool Q = false;
   bool R = false;
   bool S = false;
   bool T = true;
   bool Z = false;
   
   int hour = TimeHour(TimeLocal());
   int minute = TimeMinute(TimeLocal());
   int seconds = TimeSeconds(TimeLocal());
   string time = hour+":"+minute+":"+seconds;
   
   if (seconds > 4) {
      if (!needRefresh) {
         int time_diff = (TimeCurrent() - first_launched)/60;
         logs += " NEEDREFRESH="+seconds+" elapsed="+time_diff;
         message += logs;
         Alert(message);
         slack(message);
         needRefresh = true;
      }
      return;
   }
   
   int min_tick = 0;
   if (9 <= hour && hour <= 15){
      min_tick = 25;
   }else{
      min_tick = 49;
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
   
   double tckChange = 0;
   tckChange = (double)tick_cnt/(double)prev_tick_cnt;
   tckChange = MathCeil(tckChange * 100) * 1.0/100;
      double roundedCC = CC;
   roundedCC = MathCeil(roundedCC * 100) * 1.0/100;
   double rounded30CCA = MathCeil(a30CC * 100) * 1.0/100;
   b30CC = MathCeil(b30CC * 100) * 1.0/100;
   double rounded30CCB = MathCeil(b30CC * 100) * 1.0/100;
   double rounded3mCC = MathCeil(CC_3m * 100) * 1.0/100;
   double rounded15sCC = MathCeil(CC_15s * 100) * 1.0/100;
   double roundedVol = volatility;
   roundedVol = MathCeil(roundedVol * 100) * 1.0/100;
   double roundedHigh = highestBarry;
   roundedHigh = MathCeil(roundedHigh * 100) * 1.0/100;
   double roundedLow = lowestBarry;
   roundedLow = MathCeil(roundedLow * 100) * 1.0/100;
   double rounded60tickCC = MathCeil(ticks60 * 100) * 1.0/100;
   double rounded30tickCC = MathCeil(ticks30 * 100) * 1.0/100;
   double rounded15tickCC = MathCeil(ticks15 * 100) * 1.0/100;
   
   //過去12分間内での現BIDの位置（％）
   double pos12m = getPosition(highest12m, lowest12m);
   //過去4分間内での現BIDの位置（％）
   double pos4m = getPosition(highest4m, lowest4m);
   //過去2分間内での現BIDの位置（％）
   double pos2m = getPosition(highest2m, lowest2m);
   
   int signal_cnt = 0;

   string basis = " TYPE:";
   
   if (hige15 < 0.21 && hige30 < 0.21 && hige1H < 0.21) {
      //logs += "TESTHIGE";
      N = true;  
   }
   
   if (strongEMA) {
      if (t1m > 2 && idealBig && hige1H < 0.1 && hige30 < 0.05 && hige15 < 0.01 && pos12m > 0.9 && pos4m > 0.9 && pos2m > 0.9 
      && MathAbs(rounded15sCC) > 0.9 && delta2mRatio < 0.15 && MathAbs(rounded15tickCC) < 0.5
      && tick_cnt > min_tick && tick_cnt < 105 && meanChange > 0.9 && stdChange > 0.9 && tckChange > 0.8
      && momentum > 15 && MathAbs(CC) > 0.85 && MathAbs(rounded30CCA) > 0.85 
      && MathAbs(rounded30CCB) > 0.85  && MathAbs(rounded3mCC) > 0.85
      ){
         basis += " *EMA(JUN)* ";
         R = true;
      }else{
         if (isNearResistance) {
            basis += " *EMA(GYAKU)* ";
         }else{
            basis += " *EMA(JUN2)* ";
         }
         Q = true;
      }
   }
   
   else if(goodEMA5){
     // basis += "goodEMA";
      //if (ascending) basis += "(U)";
      //if (descending)basis += "(D)";
   }
   
   if (willBreakBarry) {
      basis += " BARRY";
      Q = true;
   if (hige1H < 0.2 && hige30 < 0.01 && hige15 < 0.01 && pos4m > 0.8 && pos2m > 0.8
      && tick_cnt > min_tick && tick_cnt < 105 && meanChange > 0.9 && stdChange > 0.9 && tckChange > 0.8
      && momentum > 10 && MathAbs(rounded3mCC) > 0.9
      ){
        basis += "(NEXT4or9) ";
      }
   }

   if(weakEMA200 && !inCloud) {
      basis += "hige(JUN)";
      if (MathAbs(t1m) >= 2) basis += "+strong";
      R = true;
   }
   
   if(strongEMA200 && hige15 < 0.21 && hige30 < 0.21 && hige15 < 0.21 && !inCloud){
      basis += "close(JUN)";
      //if (MathAbs(t1m) >= 2) basis += "+strong";
      R = true;
   }
   
   if(atEMA20 && atEMA70 && !inCloud){
      int combo_time_diff = (TimeCurrent() - last_combo)/60;
      if (combo_time_diff < 30) {
         basis += " combo_elasped="+combo_time_diff;
      }
      last_combo = TimeCurrent();
      basis += " *combo(JUN)* ";
      //if (MathAbs(t1m) >= 2) basis += "+strong";
      R = true;
   }
   /*
   if(crossEMA){
      basis += "cross";
      if (MathAbs(t1m) >= 2){
         basis += "(1m->JUN)";
      }else{
         basis += "(GYAKU)";
      }
      //Q = true;
   }
   */
   if(N && !Q && MathAbs(t1m) >= 2 && outermost && !inCloud && !aroundCloud){
      basis += " *trend(GYAKU)* ";
      Q = true;
   }
   
   if (basis == "TYPE:"){
      basis += "NOTHING";
      Z = true;
   }
   
   if (ascending) basis += "(ASC)";
   if (descending)basis += "(DESC)";
   int time_diff = (TimeCurrent() - last_alert)/60;
   basis += " elapsed:"+time_diff+" ";
   
   logs += basis;
   
   if (isInflated) {
      if (atEMA200) {
          logs += "@ema200";
          signal_cnt++;
         if (!inCloud && isBig && tick_cnt > min_tick && tickMean > 0.4 && tickStd > 0.6 && sizeRatio0 > 0.3 && volatility < 0.3) {
            A = true;
         }
      }
      if(onceBrokenEMA) {
         logs += "inflatedAfterBroken|";
         if (!inCloud && isBig && tick_cnt > min_tick) {
                     B = true;
         }
      }
      
      if (isNearResistance) {
         logs += "@barry|";
         if (!inCloud && isBig && tick_cnt > min_tick && tickMean > 0.7 && tickStd > 0.7) {
            C = true;
         }
      }
      
      if (isNearEMA200) {
         logs += "nearEma200";
         if (!inCloud && isBig && tick_cnt > min_tick && sizeRatio0 > 0.3) {
            D = true;
            if (wasEMA70) {
               logs += "@super|";
               J = true;
            }
         }
      }
      if (atEMA70) {
         logs += "@ema70";
         signal_cnt++;
         if (!inCloud && isBig && tick_cnt > min_tick && tickMean > 0.7 && tickStd > 0.7 && sizeRatio0 > 0.3 && volatility < 0.3) {
            E = true;
            wasEMA70 = true;
         }else{
            wasEMA70 = false;
         }
      }else{
            wasEMA70 = false;
      }
      if (atEMA20) {
         logs += "@ema20";
         signal_cnt++;
         /*
         if (!inCloud && isBig && tick_cnt > min_tick && tickMean > 0.7 && tickStd > 0.7 && sizeRatio0 > 0.3 && volatility < 0.3) {
            M = true;
         }
         */
      }
      if (atEMA20 && atEMA70) {
         logs += "COMBO|";
      }
      if (isNearEMA70) {
         logs += "nearEma70";
         if (!inCloud && isBig && tick_cnt > min_tick && sizeRatio0 > 0.3) {
            F = true;
         }
      }
      if (willBreak) {
         logs += "@resistance|";
         /*
         if (!inCloud && isBig && tick_cnt > min_tick && sizeRatio0 > 0.3) {
            G = true;
         }
         */
      }

   }
   if (hasBrokenEMA) {
      if (!onceBrokenEMA) {
         onceBrokenEMA = true;
      }
   }
   
   if (tick_cnt < 105 && tick_cnt > 49 && meanChange > 0.85 && stdChange > 0.7 && momentum > 8 && (MathAbs(rounded15tickCC) < 0.2 || MathAbs(rounded60tickCC) < 0.2 || MathAbs(rounded30tickCC) < 0.2) && MathAbs(rounded15sCC) > 0.2) {
      if (pos12m > 0.9 && pos4m > 0.9 && pos2m > 0.9 && has_rejected && delta2mRatio < 0.21 && MathAbs(CC) > 0.89 && (MathAbs(rounded30CCA) > 0.89 || MathAbs(rounded30CCB) > 0.89) && MathAbs(rounded30CCA) > 0.6 && MathAbs(rounded30CCB) > 0.6 && MathAbs(rounded3mCC) > 0.8 && MathAbs(rounded15sCC) > 0.8) {
         logs += "STRONGP|";
         P = true;
      }else if(delta2mRatio < 0.13 && pos12m > 0.7 && MathAbs(CC) > 0.75 && (MathAbs(rounded30CCA) > 0.8 || MathAbs(rounded30CCB) > 0.8) && MathAbs(rounded30CCA) > 0.2 && MathAbs(rounded30CCB) > 0.2 && MathAbs(rounded3mCC) > 0.3) {
         logs += "OKSTRONGP|";
         P = true;
      }
   }
   if (
   hige1H < 0.25 && hige30 < 0.2 && hige15 < 0.15 
   && pos12m > 0.89 && pos4m > 0.84 && pos2m > 0.79 
   && delta2mRatio < 0.4 && tick_cnt > min_tick && tick_cnt < 150 
   && meanChange > 0.99 && stdChange > 0.75 && tckChange > 0.75 && momentum > 8
   ) {
      logs += " MAYBEGOOD";
      P = true;
   }
   if (N && !P){
      logs += " RECONSIDER-REVERSE-CONDITION|";
   }
   if (
      hige1H < 0.25 && hige30 < 0.45 && hige15 < 0.4
      && pos12m > 0.59 && pos4m > 0.59 && pos2m > 0.59 
      && delta2mRatio < 0.2 && tick_cnt > min_tick && tick_cnt < 150 
      && meanChange > 0.8 && stdChange > 0.8 && tckChange > 0.8 && momentum > 8
   ) {
      logs += " MAYBEGOODTREND";
      S = true;
   }
   
   if (N && !S){
      logs += " RECONSIDER-ORDER-CONDITION|";
   }

   if (goodEMA5) {
      logs += "goodEMA|";
      if (strongEMA) logs += "STRONG|";
      O = true;
   }
   if (crossEMA) {
      logs += "CROSSED|";
   }
   if (MathAbs(rounded15sCC) > 0.9) {
      logs += "steep|";
   }
   if (idealBig) {
      logs += "idealBig|";
   }
   if (isBig) {
      logs += "BIG|";
   }
   if (isGigantic) {
      logs += "GIGANT|";
   }
   logs += " emaD="+ema2070Distance;
   logs += " x"+timesLarger;
   logs += " hige1H="+hige1H+" hige30m="+hige30+" hige15m="+hige15;
   logs += " pos12="+pos12m+" pos4="+pos4m+" pos2="+pos2m+" 15R="+rounded15sCC+" t="+t1m+" rejectNull="+has_rejected;
   logs += " deltaRatio="+delta2mRatio;
   logs += " tckR="+rounded60tickCC+" tck30R="+rounded30tickCC+" tck15R="+rounded15tickCC;
   logs += " tickCnt="+tick_cnt+" size="+size+" mu2/mu1="+meanChange+" std2/std1="+stdChange+" tck2/tck1="+tckChange;
   logs += " momentum="+momentum+" R="+roundedCC+" aR="+rounded30CCA+" bR="+rounded30CCB+" 3R="+rounded3mCC;
   
   /*
   csv += time+","+timesLarger+","+hige1H+","+hige30+","+hige15+","+pos12m+","+pos4m+","+pos2m+","+rounded15sCC
   +","+t1m+","+has_rejected+","+delta2mRatio+","+rounded60tickCC+","+rounded30tickCC+","+rounded15tickCC
   +","+tick_cnt+","+size+","+meanChange+","+stdChange+","+tckChange+","+momentum+","+roundedCC+","+rounded30CCA+","+rounded30CCB+","+rounded3mCC;
   */
   
   if    (
   (P && Q) ||
   (R && S)
   ) {
      StringReplace(logs, " ","\n");
      message += logs;
      Alert(message);
      alertCnt++;
      slack(message);
      last_alert = TimeCurrent();

    }else{
      Print(logs);
    }
   //exportData(Symbol());
   //WindowScreenShot(TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal())+"_"+Symbol()+".gif", 640, 480);
   deinitialize();
  }
//+------------------------------------------------------------------+

void deinitialize(){
   prev_tick_cnt = tick_cnt;
   if (prev_tick_cnt == 0) prev_tick_cnt = 1;
   tick_cnt = 0;
   a_tick_cnt = 0;
   b_tick_cnt = 0;
   c_tick_cnt = 0;
   ArrayInitialize(BIDS,0);
   ArrayInitialize(TIME,0);
   ArrayInitialize(BID_DELTA,0);
   ArrayInitialize(TICKS,0);
   ArrayInitialize(TICKS30,0);
   ArrayInitialize(TICKS15,0);
   ArrayInitialize(A_BIDS,0);
   ArrayInitialize(A_TIME,0);
   ArrayInitialize(B_BIDS,0);
   ArrayInitialize(B_TIME,0);
   ArrayInitialize(C_BIDS,0);
   ArrayInitialize(C_TIME,0);
   ArrayInitialize(BID_SUM,0);
   ArrayInitialize(TIME_SUM,0);
   ArrayInitialize(BIDS_3,0);
   ArrayInitialize(TIME_3,0);
   ArrayCopy(BIDS_3,BIDS_2,0,0,WHOLE_ARRAY);
   ArrayCopy(TIME_3,TIME_2,0,0,WHOLE_ARRAY);
   ArrayInitialize(BIDS_2,0);
   ArrayInitialize(TIME_2,0);
   ArrayCopy(BIDS_2,BIDS,0,0,WHOLE_ARRAY);
   ArrayCopy(TIME_2,TIME,0,0,WHOLE_ARRAY);
   cnt_2 = cnt_1;
   initialTime = GetTickCount();
   message = Symbol()+":";
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
   atEMA20 = false;
   inCloud = false;
   idealBig = false;
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
   highest11 = highest10;
   lowest11 = lowest10;
   highest10 = highest9;
   lowest10 = lowest9;
   highest9 = highest8;
   lowest9 = lowest8;
   highest8 = highest7;
   lowest8 = lowest7;
   highest7 = highest6;
   lowest7 = lowest6;
   highest6 = highest5;
   lowest6 = lowest5;
   highest5 = highest4;
   lowest5 = lowest4;
   highest4 = highest3;
   lowest4 = lowest3;
   highest3 = highest2;
   lowest3 = lowest2;
   highest2 = highest1;
   lowest2 = lowest1;
   highest1 = highest0;
   lowest1 = lowest0;
   highest0 = 0;
   lowest0 = 1000;
   //過去11
   double last11highest[11];
   last11highest[0] = highest11;
   last11highest[1] = highest10;
   last11highest[2] = highest9;
   last11highest[3] = highest8;
   last11highest[4] = highest7;
   last11highest[5] = highest6;
   last11highest[6] = highest5;
   last11highest[7] = highest4;
   last11highest[8] = highest3;
   last11highest[9] = highest2;
   last11highest[10] = highest1;
   int  maxHighest11idx = ArrayMaximum(last11highest,WHOLE_ARRAY,0);
   highest12m = last11highest[maxHighest11idx];
   double last11lowest[11];
   last11lowest[0] = lowest11;
   last11lowest[1] = lowest10;
   last11lowest[2] = lowest9;
   last11lowest[3] = lowest8;
   last11lowest[4] = lowest7;
   last11lowest[5] = lowest6;
   last11lowest[6] = lowest5;
   last11lowest[7] = lowest4;
   last11lowest[8] = lowest3;
   last11lowest[9] = lowest2;
   last11lowest[10] = lowest1;
   int  maxLowest11idx = ArrayMinimum(last11lowest,WHOLE_ARRAY,0);
   lowest12m = last11lowest[maxLowest11idx];
   //過去4
   double last3highest[3];
   last3highest[0] = highest3;
   last3highest[1] = highest2;
   last3highest[2] = highest1;
   int  maxHighest3idx = ArrayMaximum(last3highest,WHOLE_ARRAY,0);
   highest4m = last3highest[maxHighest3idx];
   double last3lowest[3];
   last3lowest[0] = lowest3;
   last3lowest[1] = lowest2;
   last3lowest[2] = lowest1;
   
   int  maxLowest3idx = ArrayMinimum(last3lowest,WHOLE_ARRAY,0);
   lowest4m = last3lowest[maxLowest3idx];
   //過去2
   highest2m = highest1;
   lowest2m = lowest1;
   
   timesLarger = 0;
   continuous_type_num = 1;
   tickMean30a = 0;
   tickStd30a = 0;
   tickMean30b = 0;
   tickStd30b = 0;
   mean_period = 0;
   t1m = 0;
   positives = 0;
   negatives = 0;
   deltaCnt = 0;
   delta2mRatio = 0;
   ascending = false;
   descending = false;
   strongEMA = false;
   crossEMA = false;
   weakEMA200 = false;
   strongEMA200 = false;
   outermost = false;
   willBreakBarry = false;
   isGigantic = false;
   aroundCloud = false;
   ema2070Distance = 0;
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
   ema2070Distance = MathAbs(MathAbs(ema70-ema20)/MathAbs(upper-lower));
   ema2070Distance = MathCeil(ema2070Distance * 100) * 1.0/100;
   double omegaHigh = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",0,0);
   double omegaLow = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",1,0);
   double omegaHigh1 = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",0,1);
   double omegaLow1 = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",1,1);
   double omegaHigh2 = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",0,2);
   double omegaLow2 = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",1,2);
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
      ascending = true;
      isAsc = true;
   }else if (entity_type5 == 2) {
      low5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,0);
      high5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,0);
      liveSize = open5 - bid;
      descending = true;
      isAsc = false;
   }
   
   if (candle_position_one == 2) {
      if (ema20 > ema70 && ema70 > ema200 && isAsc) {
         goodEMA = true;
         if (onceBrokenEMA) {
            onceBrokenEMA = false;
         }
      }
   }else if (candle_position_one == 3) {
      if (ema20 < ema70 && ema70 < ema200 && !isAsc) {
         goodEMA = true;
         if (onceBrokenEMA) {
            onceBrokenEMA = false;
         }
      }
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
	double leadingA5_1 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,1); //一目均衡(先行スパンA)
	double leadingB5_1 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,1); //一目均衡(先行スパンB)
	double leadingA5_2 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,2); //一目均衡(先行スパンA)
	double leadingB5_2 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,2); //一目均衡(先行スパンB)
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
   int candle_position_five_1 = getHeikenPosition(open51,close51,leadingA5_1,leadingB5_1);
   int candle_position_five_2 = getHeikenPosition(open52,close52,leadingA5_2,leadingB5_2);
   //inflatedと連携するので前の実体の最低サイズを定義
   if (entity_size51 < ATLEAST[getIndex()]) {
      isSmall = true;
   }
   
   if (size > BIG[getIndex()]) {
      isBig = true;
   }
   if (size > IDEAL_MAX[getIndex()]){
      idealBig = true;
   }
   if (size > GIGANT[getIndex()]) {
      isGigantic = true;
   }
 
   //連続しているか
   if ((isAsc && isAsc1 && isAsc2)||(!isAsc && !isAsc1 && !isAsc2)){
      isSerial = true;
   }

   //抵抗線を超えたか判定
   if (isAsc && bid > upper && upper > close51) {
      willBreak = true;
   }else if(!isAsc && bid < lower && lower < close51) {
      willBreak = true;
   }else{
      //logs += " !WillBreak";
   }
   
   //バリー抵抗線を超えたか判定
   if (isAsc && bid > highestBarry && highestBarry > close51) {
      isNearResistance = true;
   }else if(!isAsc && bid < lowestBarry && lowestBarry < close51) {
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
   double ema20_1 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(20)s
   ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(70)
   double ema70_1 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(200)
   ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(200)
   double ema200_1 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(200)
   
   
   if (candle_position_five == 2) {
      if (ema5 > ema20 && ema20 > ema70 && ema70 > ema200) {
         if (isAsc) {
            goodEMA5 = true;
            if (bid > highestBarry)strongEMA = true;
         }
      }
      if (!(candle_position_five_1 == candle_position_five_2 == 2)) {
         aroundCloud = true;
      }
   }else if (candle_position_five == 3) {
      if (ema5 < ema20 && ema20 < ema70 && ema70 < ema200) {
         if (!isAsc){
            goodEMA5 = true;
            if (bid < lowestBarry)strongEMA = true;
         } 
      }
       if (!(candle_position_five_1 == candle_position_five_2 == 3)) {
         aroundCloud = true;
      }
   }
   
   if (bid > ema70 && bid > ema200 && open5 < ema20 && ema5 < ema20 && ema20 > ema70 && ema70 > ema200) {
      if (!isAsc) {
         crossEMA = true;
      }
   }
   if (bid < ema70 && bid < ema200 && open5 > ema20 && ema5 > ema20 && ema20 < ema70 && ema70 < ema200) {
      if (isAsc) {
         crossEMA = true;
      }
   }
   
   //EMA70を超えそうか判定
   if (isAsc && bid > ema70 && close51 <= ema70_1 && ema200 > ema70 && ema70 > ema20) {
      isNearEMA70 = true;
   }else if (!isAsc && bid < ema70 && close51 >= ema70_1 && ema200 < ema70 && ema70 < ema20) {
      isNearEMA70 = true;
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
   
   timesLarger = MathCeil((entity_size5/entity_size51) * 100) * 1.0/100;
   
   double live_size = getEntitySize(open1, bid);
   if (entity_size5 >= live_size) {
      live_size = entity_size5;
   }
   if (live_size > entity_size51 * 0.9 && isAsc == isAsc1) {
      isInflated = true;
   }
   if (entity_size5 > entity_size51 && isAsc == isAsc1) {
      isLarger = true;
   }

   isSerial1 = isSerial(PERIOD_M1,4);
   isSerial5 = isSerial(PERIOD_M5,4);
   
   if (ema5 < ema200 && ema20 < ema200 && ema70 < ema200 && isAsc && close5 < ema200 && (ema200 < bid || ema200 < high5) && close51 <= ema200_1){
      weakEMA200 = true;
   }else if(ema5 > ema200 && ema20 > ema200 && ema70 > ema200 && !isAsc && close5 > ema200 && (ema200 > bid || ema200 > low5) && close51 >= ema200_1) {
      weakEMA200 = true;
   }
   if (ema5 < ema200 && ema20 < ema200 && ema70 < ema200 && isAsc && bid > ema200 && close5 > ema200 && (ema200 < bid || ema200 < high5) && close51 <= ema200_1){
      strongEMA200 = true;
   }else if(ema5 > ema200 && ema20 > ema200 && ema70 > ema200 && !isAsc && bid < ema200 && close5 < ema200 && (ema200 > bid || ema200 > low5) && close51 >= ema200_1) {
      strongEMA200 = true;
   }
   if (candle_position_five == 2) {
      if (bid > ema20 && bid > ema70 && bid > ema200 && low51 > ema20 && low51 > ema70 && low51 > ema200 && open5 > ema20 && open5 > ema70 && open5 > ema200 && ema5 > ema20 && ema5 > ema70 && ema5 > ema200) {
         outermost = true;
      }
      
   }else if (candle_position_five == 3) {
      if (bid < ema20 && bid < ema70 && bid < ema200 && low51 < ema20 && low51 < ema70 && low51 < ema200 && open5 < ema20 && open5 < ema70 && open5 < ema200 && ema5 < ema20 && ema5 < ema70 && ema5 < ema200) {
         outermost = true;
      }
   }
   
   //バリー抵抗線を超えそうか判定
   if (isAsc && candle_position_five == 2 && bid > ema20 && bid > ema70 && bid > ema200 && omegaHigh == omegaHigh1 == omegaHigh2 && high5 < omegaHigh && high51 < omegaHigh1 && high52 < omegaHigh2) {
      willBreakBarry = true;
   }else if(!isAsc && candle_position_five == 3 && bid < ema20 && bid < ema70 && bid < ema200 && omegaLow == omegaLow1 == omegaLow2 && low5 > omegaLow && low51 > omegaLow1 && low52 > omegaLow2) {
      willBreakBarry = true;
   }else{
      //logs += " !@barry";
   }
   
   if (isAsc && open5 < ema200 && ema200 < close5 ){
      atEMA200 = true;
   }else if(!isAsc && open5 > ema200 && ema200 > close5 ) {
      atEMA200 = true;
   }
   
   if (isAsc && open5 < ema20 && ema20 < close5 ){
      atEMA20 = true;
   }else if(!isAsc && open5 > ema20 && ema20 > close5 ) {
      atEMA20 = true;
   }
   if (isAsc && open5 < ema70 && ema70 < close5 ){
      atEMA70 = true;
   }else if(!isAsc && open5 > ema70 && ema70 > close5 ) {
      atEMA70 = true;
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

double getHigeRatio(int count, int timeframe) {
   double ratioProduct = 0;
   double ratio = 0;
   double open = 0;
   double close = 0;
   int entity_type = 0;
   double high = 0;
   double low = 0;
   double hige = 0;
   double body = 0;
   int counted = 0;

   for (int i=0; i<count;i++) {
      open = iCustom(Symbol(),timeframe,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),timeframe,"HeikenAshi_DM",3,i);
      entity_type = getEntity(open, close);
      if (entity_type == 1) {
         low = iCustom(Symbol(),timeframe,"HeikenAshi_DM",0,i);
         high = iCustom(Symbol(),timeframe,"HeikenAshi_DM",1,i);
         hige = open - low;
      }else if (entity_type == 2) {
         low = iCustom(Symbol(),timeframe,"HeikenAshi_DM",1,i);
         high = iCustom(Symbol(),timeframe,"HeikenAshi_DM",0,i);
         hige = high - open;
      }

      body = high - low;
      ratio = hige/body;
      if (ratio == 0) continue;;
 
      if (ratioProduct == 0) {
         ratioProduct = ratio;
      }else{
         ratioProduct *= ratio;
      }
      counted++;
 
      
   }
   if (counted == 0) counted = 1;
   return MathPow(ratioProduct,(1.0/(double)counted));
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

 bool isSerial(int period, int count) {
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

   while(bids[count] != 0 && count+1 < ArraySize(bids)){
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
   cnt_1 = count;
   if (prefix == "a30s") {
      a30asc = max_asc;
      a30dsc = max_desc;
   }else if(prefix == "b30s") {
      b30asc = max_asc;
      b30dsc = max_desc;
   }else if(prefix == "1m"){
      asecs = max_asc;
      desecs = max_desc;
   }
   
   //ティックが時間内に一回もなかった
   if (count == 0) {
      return 0;
   }
   
   double last_5_period = 0;
   double period_cnt = 0;
   
   for (int i=0; i<count; i++) {
      bidSum += bids[i];
      timeSum += times[i];
      if (volProduct == 0) {
         volProduct = VOL[i];
      }else if (VOL[i] != 0){
         volProduct *= VOL[i];
      }
      if (i > count - 6 && i != 0) {
         last_5_period += times[i] - times[i-1];
         period_cnt++;
      }
   }
   if (period_cnt != 0) {
      mean_period = last_5_period/period_cnt;
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

//0は棄却
int testT (double &delta[],double sig_level,bool is_increasing,string prefix) {
   double deltaSum = 0;
   int count = 0;
   double maxDelta = 0;

   while(delta[count] != 0){
      deltaSum += delta[count];
      if (maxDelta < MathAbs(delta[count])) maxDelta = delta[count];
      count++;
   }
   //ティックが時間内に一回もなかった
   if (count == 0 || count-1 == 0) {
      return 0;
   }
   double deltaMean = deltaSum/count;
   double deltaDevSum = 0;
   
   delta2mRatio = MathCeil((MathAbs(maxDelta)/MathAbs(highest0 - lowest0)) * 100) * 1.0/100;

   for (int i=0; i<count; i++) {
       deltaDevSum += MathPow((
         delta[i]-deltaMean
       ),2);
   }
   
   double deltaVariance = deltaDevSum/(count-1);
   if (deltaVariance == 0) {
      return 0;
   }
   //母平均は差がないことを主張するため０とする
   double t = deltaMean/MathSqrt(deltaVariance/count);
   double roundedT = MathCeil(t * 100) * 1.0/100;
   
   if (prefix == "1m"){
      t1m = roundedT;
   }
   
   if (is_increasing) {
      if (roundedT > sig_level) {
         return 1;
      }else{
         return 0;
      }
   }
   
   if (roundedT < sig_level * -1) {
      return 1;
   }
   return 0;
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
   double tickDevSum30a = 0;
   double tickSum30b = 0;
   double tickDevSum30b = 0;
   for (int i=0; i<ArraySize(TICKS);i++) {
         TICKS[i]++;
         tickSum += TICKS[i];
         if (i <= 29) {
            tickSum30a += TICKS[i];
         }else{
            tickSum30b += TICKS[i];
            TICKS30[i-30] = TICKS[i];

            if (i > 44) {
               TICKS15[i-45] = TICKS[i];
            } 
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

void setBidDelta(double &bids[]) {
   int count = 0;
   double delta = 0;
   while(bids[count] != 0 && count+1 < ArraySize(bids)){
      if (count != 0) {
         delta = bids[count]-bids[count-1];
         BID_DELTA[count-1] = delta;
      }
      count++;
   }
   deltaCnt = count;
}

double getPosition(double highest, double lowest) {
    double pos = 0;
    if (highest > lowest) {
    double delta = highest - lowest;
    double half = delta/2;
    double current = MarketInfo(Symbol(),MODE_BID);
    if (current > (half+lowest)) {
        if (delta != 0) pos = MathAbs(current - lowest)/delta;
        }else{
            if (delta != 0) pos = MathAbs(highest - current)/delta;
        }
        pos = MathCeil(pos * 100) * 1.0 /100;
    }
    return pos;
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