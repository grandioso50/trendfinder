
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

bool alert_period = true;
int timeInterval = 60;
int tick_cnt = 0;
int prev_tick = 0;
int cnt_2 = 0;
int cnt_3 = 0;
int cnt_4 = 0;
int inBand = 0;
int ticks_in_secs = 0;
int ticks_to_exam = 0;
int bandInterval = 5;
int phase_after_strong = 0;
int large_entity_type = 0;
int entity_type = 0;
int entity_type_day = 0;
int prev_entity_type = 0;
int shortest_span = 60000;
int millisec_left = 0;
int candle_position_day = 0;
int big_alert_interval = 0;
int event_pt = 0;
int event_pt0 = 0;
int event_pt1 = 0;
int event_pt2 = 0;
int event_pt3 = 0;
int event_pt0_d = 0;
int event_pt1_d = 0;
int event_pt2_d = 0;
int event_pt3_d = 0;
int XL = 0;
int elapsed_since_xl = 0;
int elapsed = 0;
int bad_big = 0;
string reasons = "";
double BIDS[500];
double LOCALTIME[500];
double initialTime = GetTickCount();
double TIME[500];
double BIDS_2[500];
double BIDS_3[500];
double BIDS_4[500];
double TIME_2[500];
double TIME_3[500];
double TIME_4[500];
double LOCALTIME_2[500];
double LOCALTIME_3[500];
double LOCALTIME_4[500];
double BID_SUM[1200];
double TIME_SUM[1200];
double LOCALTIME_SUM[1200];
double ABRUPT_POS[500];
double ABRUPT_NEG[500];
double current_time = 0;
double current_bid = 0;
double last_entity_size = 0;
double current_open = 0;
double current_close = 0;
double alert_bid = 0;
double RECORD_BID[2500];
double RECORD_TIME[2500];
double upper = 0;
double prev_upper = 0;
double lower = 0;
double prev_lower = 0;
int is_ul_changed = 0;
double live_size_change = 0;
double live_pits[4];
double strength = 0;
int record_idx = 0;
int tick_idx = 0;
int ticks[10];
double last_two_sec_bid = 0;
//AUDJPY, AUDUSD, EURJPY, EURUSD, GBPJPY, NZDJPY, USDJPY
double MEAN[] = {0.0417450223664439,0.000332018131403119,0.0527167807799457,0.000411982524392215,0.0663341607698775,0.0372893966384425,0.0352369842692413};
double STD[] = {0.0141825157985687,0.000123181988689167,0.019949887948807,0.000177617192047747,0.0257662478856787,0.0119274401866431,0.0128039908008507};
double CLOUDMU[] = {0.167464810518175,0.0014047018129771,0.226817806603774,0.00192638392857143,0.290460643796992,0.15003317432784,0.140454959053685};
double CLOUDSIGMA[] = {0.103364118445929,0.000961762469045216,0.150409311904272,0.00143332509476982,0.199504083705912,0.0934747065395659,0.084657376380671};
double last_1H_z_score = 0;
double last_30m_z_score = 0;
double cloud_z_score = 0;
double size = 0;
double prev_full_size = 0;
double highestBarry = 0;
double lowestBarry = 0;
double highest12m = 0;
double lowest12m = 1000;
int time_highest12m = 0;
int time_lowest12m = 0;
int timestamp_highest12m = 0;
int timestamp_lowest12m = 0;
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
double ema5 = 0;
int time_highest0 = 0;
int time_lowest0 = 0;
int time_highest1 = 0;
int time_lowest1 = 0;
int time_highest2 = 0;
int time_lowest2 = 0;
int time_highest3 = 0;
int time_lowest3 = 0;
int time_highest4 = 0;
int time_lowest4 = 0;
int time_highest5 = 0;
int time_lowest5 = 0;
int time_highest6 = 0;
int time_lowest6 = 0;
int time_highest7 = 0;
int time_lowest7 = 0;
int time_highest8 = 0;
int time_lowest8 = 0;
int time_highest9 = 0;
int time_lowest9 = 0;
int time_highest10 = 0;
int time_lowest10 = 0;
int time_highest11 = 0;
int time_lowest11 = 0;
int timestamp_highest0 = 0;
int timestamp_lowest0 = 0;
int timestamp_highest1 = 0;
int timestamp_lowest1 = 0;
int timestamp_highest2 = 0;
int timestamp_lowest2 = 0;
int timestamp_highest3 = 0;
int timestamp_lowest3 = 0;
int timestamp_highest4 = 0;
int timestamp_lowest4 = 0;
int timestamp_highest5 = 0;
int timestamp_lowest5 = 0;
int timestamp_highest6 = 0;
int timestamp_lowest6 = 0;
int timestamp_highest7 = 0;
int timestamp_lowest7 = 0;
int timestamp_highest8 = 0;
int timestamp_lowest8 = 0;
int timestamp_highest9 = 0;
int timestamp_lowest9 = 0;
int timestamp_highest10 = 0;
int timestamp_lowest10 = 0;
int timestamp_highest11 = 0;
int timestamp_lowest11 = 0;
double amplitude = 0;
double abrupt_ratio = 0;
double mean_size_1H = 0;
double mean_size_30m = 0;
double live_z = 0;
double live_upper = 0;
double live_lower = 0;
double band_pos = 0;
double prev_cc_3m = 0;
double prev_leadingA5 = 0;
double prev_leadingB5 = 0;
double band_amplitude = 0;
double prev_cv = 0;
double hige15m = 0;
double higeday = 0;
double size_diff = 0;
double prev__prev_entity_type = 0;
double daily_mean = 0;
double daily_std = 0;
double imaginary_close = 0;
double tick_mean = 0;
string message = Symbol()+":highlow";
string last_event = "";
string csv = "";
string logs = "";
string cloud = "";
string ort = "";
string ort_5m = "";
string ort_day = "";
string hit_reverse = "";
string alert_time = "";
string alert_time2 = "";
string current_trend = "";
string phase_trend = "";
string wait = "";
string hit = "";
int alert_interval = 0;
int alert_interval2 = 0;
int alert_interval3 = 0;
int last_candle_position = 0;
int last_full_candle_posistion = 0;
int imaginary_pos = 0;
bool willBreak = false;
bool isNearResistance = false;
bool isNearEMA200 = false;
bool isNearEMA70 = false;
bool atEMA200 = false;
bool atEMA70 = false;
bool atEMA20 = false;
bool inCloud = false;
bool needRefresh = false;
bool live_inCloud = false;
bool band_alert = false;
bool band_asc = false;
bool done_examine = false;
bool measure_span = false;
bool large_alert = false;
bool next_round = false;
bool phase_init = false;
bool xl_exist = false;
bool big_alert = false;
int willFade = 0;
int potentialTrend = 0;
int live_entity_type = 0;
int serialnums = 0;
datetime current_alert = TimeCurrent();
datetime last_alert = TimeCurrent();
datetime current_alert2 = TimeCurrent();
datetime last_alert2 = TimeCurrent();
datetime first_launched = TimeCurrent();
datetime current = TimeCurrent();
datetime second_alert = TimeCurrent();
datetime last_strong = TimeCurrent();
datetime last_strong_end = TimeCurrent();
datetime large_alert_at = TimeCurrent();
datetime big_current_alert = TimeCurrent();
datetime big_last_alert = TimeCurrent();
string PAIRS[] = {"USDJPY","EURUSD","GBPJPY","EURJPY","AUDUSD","AUDJPY","NZDJPY"};
int DANGER_MIN[] = {0,5,10,15,20,25,30,35,40,45,50,55};
int SAFE_MIN[] = {4,9,14,19,24,29,34,39,44,49,54,59};
string danger_min = "";
bool has_danger_min = false;
int current_minute = 0;
double timesLargerInterval = 0;
int counter = 0;
int prev_high_idx = 0;
int prev_low_idx = 0;
int abrupt_idx = 0;
int abrupt_pos = 0;
int abrupt_neg = 0;
int period = 0;

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
   LOCALTIME[tick_cnt] = TimeLocal();

   if (big_alert) {
      current = TimeCurrent();
      alert_interval2 = (current - big_last_alert);
   if (alert_interval2 < 300) {
      //record data
      RECORD_BID[record_idx] = BIDS[tick_cnt];
      RECORD_TIME[record_idx] = TIME[tick_cnt];
      record_idx++;
    }else{
      band_alert = false;
      done_examine = true;
      big_alert = false;
    }
   }

   //今回の最高と最低を判断
   if (BIDS[tick_cnt] > highest0) {
      time_highest0 = TimeSeconds(TimeLocal());
      timestamp_highest0 = TimeLocal();
      highest0 = BIDS[tick_cnt];
   }
   if (BIDS[tick_cnt] < lowest0) {
      time_lowest0 = TimeSeconds(TimeLocal());
      timestamp_lowest0 = TimeLocal();
      lowest0 = BIDS[tick_cnt];
   }
   if (highest0 > highest12m) highest12m = highest0;
   if (lowest12m > lowest0) lowest12m = lowest0;
   if (highest0 > highest4m) highest4m = highest0;
   if (lowest4m > lowest0) lowest4m = lowest0;
   if (highest0 > highest2m) highest2m = highest0;
   if (lowest2m > lowest0) lowest2m = lowest0;

   if (measure_span) {
      //eval shortest span
      if (tick_cnt == 0) {
         next_round = true;
      }
      if (tick_cnt < 2) {
         millisec_left = 60000 - millisec_left;
      }else{
         if (((band_asc && BIDS[tick_cnt] > BIDS[tick_cnt - 1])|| (!band_asc && BIDS[tick_cnt] < BIDS[tick_cnt - 1]))
         && shortest_span > (TIME[tick_cnt] - TIME[tick_cnt-1])
         ) {
            shortest_span = TIME[tick_cnt] - TIME[tick_cnt-1];
         }
      }
      if (next_round && TIME[tick_cnt] > millisec_left) {
        //Alert(Symbol()+" span="+shortest_span);
        //slackprivate(Symbol()+" span="+shortest_span);
         shortest_span = 60000;
         next_round = false;
         measure_span = false;
      }
   }

   if (tick_cnt != 0 && TIME[tick_cnt] > 3000) {
      current_time = TIME[tick_cnt];
      current_bid = BIDS[tick_cnt];
      tick_idx = tick_cnt;
      ticks_in_secs = 0;
      while ((tick_idx - 1) != -1 && (current_time - TIME[tick_idx]) <= 3000) {
         last_two_sec_bid = BIDS[tick_idx];
         tick_idx--;
         ticks_in_secs++;
      }
      if (prev_leadingA5 > prev_leadingB5) {
         if (prev_leadingA5 > current_bid && current_bid > prev_leadingB5)
         {
            live_inCloud = true;
         }else{
            live_inCloud = false;
         }
      }else{
         if (prev_leadingA5 < current_bid && current_bid < prev_leadingB5)
         {
            live_inCloud = true;
         }else{
            live_inCloud = false;
         }
      }
   current_open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,0);
   current_close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,0);
   live_upper = getValueByText("High_Low_Plus_UpperPrice");
   live_lower = getValueByText("High_Low_Plus_LowerPrice");
   band_pos = getPosition(live_upper,live_lower,current_bid);
   live_z = getZscore(MEAN,STD,getEntitySize(current_open,current_bid));
   size_diff = (live_z - last_1H_z_score);

   imaginary_close = 0;
   if (current_open < current_close) {
      imaginary_close = current_close+(getEntitySize(current_open,current_close));
   }else{
      imaginary_close = current_close-(getEntitySize(current_open,current_close));
   }
   imaginary_pos = getHeikenPosition(current_open,imaginary_close,prev_leadingA5,prev_leadingB5);

   live_pits[0] = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,0);
   live_pits[1] = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,0);
   live_pits[2] = current_open;
   live_pits[3] = current_close;

   last_full_candle_posistion = getHeikenPosition(live_pits[ArrayMaximum(live_pits,WHOLE_ARRAY,0)],live_pits[ArrayMinimum(live_pits,WHOLE_ARRAY,0)],prev_leadingA5,prev_leadingB5);

   if (last_full_candle_posistion == 4 || last_full_candle_posistion == 5 || imaginary_pos == 4 || imaginary_pos == 5) {
      wait = " WAIT ";
   }else{
      wait = "";
   }

   if (size_diff > 3) {
      if (!large_alert) {
      /*
         Alert(Symbol()+": XL hit="+(prev_tick > 10 && (last_candle_position == 2 || last_candle_position == 3))
         +wait
         +" gyaku="+(
         (getPosition(live_upper,live_lower,current_close) < 1 && phase_after_strong == 0
         || last_full_candle_posistion == 7
         )
         +" closepos="+StringSubstr((getPosition(live_upper,live_lower,current_close)),0,4)
         +" candle="+last_candle_position
         +" tick="+prev_tick
         +" size="+size_diff
         );
         slackprivate(Symbol()+": XL *hit="+(prev_tick > 10 && (last_candle_position == 2 || last_candle_position == 3))
         +wait
         +" gyaku="+(
         (getPosition(live_upper,live_lower,current_close) < 1 && phase_after_strong == 0
         || last_full_candle_posistion == 7
         )
         +"* closepos="+StringSubstr((getPosition(live_upper,live_lower,current_close)),0,4)
         +" candle="+last_candle_position
         +" tick="+prev_tick
         +" size="+size_diff
         );
         */
         large_alert = true;
         phase_init = false;
         large_alert_at = TimeCurrent();
         large_entity_type = getEntity(iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,0),iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,0));
         if (large_entity_type == 1) XL = 1;
         if (large_entity_type == 2) XL = 2;
         //WindowScreenShot(TimeDay(TimeLocal())+"_"+TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal())+"_"+Symbol()+"_XL"+".gif", 640, 480);
         Print(Symbol()+"XL: zdiff="+StringSubstr((live_z - last_1H_z_score),0,4)+" last_candle_position="+last_candle_position+" prev_tick="+prev_tick);
      }
   }
   if (phase_after_strong > 0){
      if (large_entity_type == 1) {
         phase_trend = " phaseTrend=ASC";
      }else{
         phase_trend = " phaseTrend=DSC";
      }
   }else{
      phase_trend = "";
   }

      if (amplitude != 0) {
         abrupt_ratio = MathAbs((current_bid - last_two_sec_bid)/amplitude);
         abrupt_ratio = MathCeil(abrupt_ratio * 100) * 1.0/100;

         live_size_change = MathAbs((live_pits[ArrayMaximum(live_pits,WHOLE_ARRAY,0)] -live_pits[ArrayMinimum(live_pits,WHOLE_ARRAY,0)])/prev_full_size);
         //test
         /*
         if (abrupt_ratio > 1) {
            current_alert2 = TimeCurrent();
            alert_interval2 = (current_alert2 - last_alert2)/60;
            if (alert_interval2 > 0.8) {
             if (last_candle_position != 6 && !inCloud && prev_tick > 14) {
                 if (current_bid > last_two_sec_bid) {
                    ort = "ASC";
                    band_asc = true;
                    if (getEntity(current_open,current_close) == 2) {
                     hit_reverse = "YES";
                    } else {
                     hit_reverse = "NO";
                    }
                  }else{
                    ort = "DSC";
                    band_asc = false;
                    if (getEntity(current_open,current_close) == 1) {
                     hit_reverse = "YES";
                    } else {
                     hit_reverse = "NO";
                    }
                  }
               alert_time2 = TimeHour(TimeLocal())+"-"+TimeMinute(TimeLocal())+"-"+TimeSeconds(TimeLocal());

               Alert(
               Symbol()+":!"
               +" weak="+(live_size_change < 2)
               +" PHS="+phase_after_strong
               +" x="+StringSubstr(live_size_change,0,3)
               +phase_trend
               +" DLT="+StringSubstr((live_z - last_1H_z_score),0,4)+" POS="+StringSubstr(band_pos,0,4)
               +" TCK="+prev_tick+" ort="+ort+" incloud="+live_inCloud+" @"+alert_time2
               );
               slackprivate(
               Symbol()+":!"
               +" *weak="+(live_size_change < 2)
               +" PHS="+phase_after_strong
               +" x="+StringSubstr(live_size_change,0,3)
               +"*"+phase_trend
               +" DLT="+StringSubstr((live_z - last_1H_z_score),0,4)+" POS="+StringSubstr(band_pos,0,4)
               +" TCK="+prev_tick+" ort="+ort+" incloud="+live_inCloud+" @"+alert_time2
               );

               last_alert2 = current_alert2;
               band_alert = true;
               measure_span = true;
               band_amplitude = amplitude;
               alert_bid = current_bid;
               millisec_left = 60000 - TIME[tick_cnt];
               WindowScreenShot(TimeDay(TimeLocal())+"_"+TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal())+"_"+Symbol()+".gif", 640, 480);
             }else{
               Print(Symbol()+"BAD: bandpos="+StringSubstr(band_pos,0,4)+" candlepos="+last_full_candle_posistion
               +" incloud="+live_inCloud+" phase="+phase_after_strong+" tick="+prev_tick);
             }

             }
          }
          */
            //end test
         if (abrupt_ratio > 0.1 && last_candle_position != 6) {
             if (current_bid > last_two_sec_bid) {
                 ABRUPT_POS[abrupt_idx] = abrupt_ratio;
                 abrupt_pos++;
             }else{
                 ABRUPT_NEG[abrupt_idx] = abrupt_ratio;
                 abrupt_neg++;
             }
             abrupt_idx++;
         }
         //BIG logic
         if (abrupt_ratio > 0.6 && last_candle_position != 6) {
            big_current_alert = TimeCurrent();
            big_alert_interval = (big_current_alert - big_last_alert)/60;
            if (big_alert_interval > 4) {
            //Order alert
            live_entity_type = getEntity(current_open ,current_bid);
            if (live_entity_type == 1) {
               ort_5m = "UP";
            }else{
               ort_5m = "DW";
            }
            if (live_z - last_1H_z_score > 3 && prev_tick > 9) {
                  if (current_bid > last_two_sec_bid) {
                     ort = "ASC";
                  }else{
                     ort = "DSC";
                  }
                  if (
                  (live_entity_type == 1 && last_candle_position != 3) ||
                  (live_entity_type == 2 && last_candle_position != 2)
                  ) {
                  has_danger_min = false;
                  current_minute = TimeMinute(TimeLocal());
                  for (int i=0; i<ArraySize(DANGER_MIN); i++) {
                     if (DANGER_MIN[i] == current_minute) {
                        has_danger_min = true;
                     }
                  }
                  if (has_danger_min == true) {
                     danger_min = "NG";
                  }else{
                     danger_min = "OK";
                  }
                  alert_time = TimeHour(TimeLocal())+":"+TimeMinute(TimeLocal())+":"+TimeSeconds(TimeLocal());
                  Alert(Symbol()+"BIG: "
                  +" x="+timesLargerInterval
                  +" dng="+danger_min
                  +" EVT="+(event_pt0+event_pt1+event_pt2+event_pt3)
                  +" period="+period
                  +" tks="+tick_mean
                  +" ORT="+ort_5m
                  +" strength="+StringSubstr(strength,0,4)
                  +" pos="+last_candle_position
                  +" existXL="+(xl_exist && elapsed_since_xl < 6)
                  +" PHS="+phase_after_strong
                  +" BAD="+bad_big
                  +" ort="+ort
                  +" @"+alert_time
                  +" incloud="+live_inCloud);
                  slackprivate("*"+Symbol()+"BIG: "
                  +" EVT="+(event_pt0+event_pt1+event_pt2+event_pt3)
                  +" pos="+last_candle_position
                  +" period="+period
                  +" BAD="+bad_big
                  +" ORT="+ort_5m
                  +" hot="+(TimeHour(TimeLocal()) == 9 && Symbol() == "USDJPY" ? "NG" : "OK")
                  +"*");
                  big_last_alert = big_current_alert;
                  big_alert = true;
                  alert_time2 = TimeHour(TimeLocal())+"-"+TimeMinute(TimeLocal())+"-"+TimeSeconds(TimeLocal());
                  WindowScreenShot(TimeDay(TimeLocal())+"_"+TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal())+"_"+Symbol()+"_BIG"+".gif", 640, 480);
                  }
            }else{
               reasons = "";
               if (last_candle_position == 6) {
                  reasons += "CLOUD|";
               }else if (live_z - last_1H_z_score <= 3) {
                  reasons += "DIFF|";
               }else if (prev_tick <= 9) {
                  reasons += "TICK|";
               }else{
                  reasons += "ELSE|";
               }

               Print(Symbol()+"BADBIG: "+reasons+" zdiff="+StringSubstr((live_z - last_1H_z_score),0,4)+" live_entity_type="+live_entity_type+wait
               +" last_candle_position="+last_candle_position+" prev_tick="+prev_tick);
               bad_big++;
            }
            }
         }
      }
   }
   tick_cnt++;
  }

void OnTimer()
  {

   if (done_examine) {
       string record = "";
       for (int i=0; i<record_idx-1;i++) {
          record += RECORD_TIME[i]+","+RECORD_BID[i]+"\r\n";
       }
       ArrayInitialize(RECORD_BID,0);
       ArrayInitialize(RECORD_TIME,0);
       done_examine = false;
       record_idx = 0;
       //exportData(Symbol()+"-"+alert_time2,record,true);
   }
   haveBroken();
   int cnt = 0;

   ArrayCopy(BID_SUM,BIDS,0,0,WHOLE_ARRAY);
   ArrayCopy(TIME_SUM,TIME,0,0,WHOLE_ARRAY);
   ArrayCopy(LOCALTIME_SUM,LOCALTIME,0,0,WHOLE_ARRAY);
   ArrayCopy(BID_SUM,BIDS_2,tick_cnt,0,WHOLE_ARRAY);
   ArrayCopy(TIME_SUM,TIME_2,tick_cnt,0,WHOLE_ARRAY);
   ArrayCopy(LOCALTIME_SUM,LOCALTIME_2,tick_cnt,0,WHOLE_ARRAY);
   ArrayCopy(BID_SUM,BIDS_3,tick_cnt+cnt_2,0,WHOLE_ARRAY);
   ArrayCopy(TIME_SUM,TIME_3,tick_cnt+cnt_2,0,WHOLE_ARRAY);
   ArrayCopy(LOCALTIME_SUM,LOCALTIME_3,tick_cnt+cnt_2,0,WHOLE_ARRAY);
   ArrayCopy(BID_SUM,BIDS_4,tick_cnt+cnt_2+cnt_3,0,WHOLE_ARRAY);
   ArrayCopy(TIME_SUM,TIME_4,tick_cnt+cnt_2+cnt_3,0,WHOLE_ARRAY);
   ArrayCopy(LOCALTIME_SUM,LOCALTIME_4,tick_cnt+cnt_2+cnt_3,0,WHOLE_ARRAY);
   
   int localtime_idx = 0;
   int initial_value = 0;
   while(LOCALTIME_SUM[localtime_idx] != 0 && localtime_idx+1 < ArraySize(LOCALTIME_SUM)){
      if (localtime_idx == 0) initial_value = LOCALTIME_SUM[localtime_idx];
      LOCALTIME_SUM[localtime_idx] = LOCALTIME_SUM[localtime_idx] - initial_value;
      localtime_idx++;
   }
   string bids_3m_csv = bidsToString(BID_SUM,LOCALTIME_SUM);
   //exportData(Symbol()+"-bids",bids_3m_csv,true);

   double covariance = MathAbs(getCorrelated(BIDS,TIME,"cc"));
   prev_cc_3m = getCorrelated(BID_SUM,TIME_SUM,"cc");
   prev_cv = getCorrelated(BID_SUM,TIME_SUM,"cv");

   mean_size_1H = meanEntitySize(12,1);
   mean_size_30m = meanEntitySize(6,1);
   last_1H_z_score = getZscore(MEAN,STD,mean_size_1H);
   last_30m_z_score = getZscore(MEAN,STD,mean_size_30m);

   int hour = TimeHour(TimeLocal());
   int minute = TimeMinute(TimeLocal());
   int seconds = TimeSeconds(TimeLocal());
   string time = hour+":"+minute+":"+seconds;
   /*
   if (seconds > 4) {
      if (!needRefresh) {
         int time_diff = (TimeCurrent() - first_launched)/60;
         logs += " NEEDREFRESH="+seconds+" elapsed="+time_diff;
         message += logs;
         Alert(message);
         slackprivate(message);
         needRefresh = true;
      }
      return;
   }
   */

   int isSerial15m = isSerial(PERIOD_M5,3,0,0);
   hige15m = getHigeRatio(3,PERIOD_M5,0);
   higeday = getHigeRatio(1,PERIOD_D1,0);
   //強いか判定
   if (isSerial15m == 1 && hige15m == 0) {
      last_strong = TimeCurrent();
   }

   //肥大化あとを判定
   int large_interval = (TimeCurrent() - large_alert_at)/60;
   double open5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,0);
   double close5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,0);
   double apex = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,0);
   double pos = getPosition(upper,lower,apex);
   double apex1 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,1);
   double apex2 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,2);
   double pos1 = getPosition(upper,lower,apex1);
   double pos2 = getPosition(upper,lower,apex2);

   if (!phase_init && large_alert && large_interval > 10) {
      double open51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,1);
      double close51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,1);
      double open52 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,2);
      double close52 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,2);
      int entity_type5 = getEntity(open5,close5);
      int entity_type51 = getEntity(open51,close51);
      int entity_type52 = getEntity(open52,close52);
      if ((large_entity_type == 1 && entity_type5 == 1 && entity_type51 == 1 && entity_type52 == 1) ||
         (large_entity_type == 2 && entity_type5 == 2 && entity_type51 == 2 && entity_type52 == 2)) {
         if (pos > 1.5 && pos1 > 1.5 && pos2 > 1.5) {
            phase_after_strong = 1;
            if (large_entity_type == 1) {
               //Alert(Symbol()+": phase start ASC");
               //slackprivate("*"+Symbol()+"*: phase start ASC");
            }else{
               //Alert(Symbol()+": phase start DSC");
               //slackprivate("*"+Symbol()+"*: phase start DSC");
            }
            phase_init = true;
         }
      }
   }

   double this_z = getZscore(MEAN,STD,getEntitySize(open5,MarketInfo(Symbol(),MODE_BID)));
   double this_diff = (this_z - last_1H_z_score);
   if (phase_after_strong == 0) {
      if (large_alert && large_interval > 20 && large_entity_type != prev_entity_type) {
         large_alert = false;
      }
   }
   if (phase_after_strong == 1) {
      if (large_entity_type != prev_entity_type && prev_entity_type == prev__prev_entity_type) {
            phase_after_strong = 2;
      }
   }
   if (phase_after_strong == 2) {
      if (large_entity_type == prev_entity_type && prev_entity_type == prev__prev_entity_type) {
         phase_after_strong = 3;
       }
   }
   if (phase_after_strong == 3) {
      if (large_entity_type != prev_entity_type && prev_entity_type == prev__prev_entity_type) {
         //Alert(Symbol()+": end of phase");
         //slackprivate(Symbol()+": end of phase");
         phase_after_strong = 0;
         last_strong_end = TimeCurrent();
         large_alert = false;
       }
   }
   int elapsed_strong = (TimeCurrent() - last_strong)/60;
   int elapsed_strong_end = 0;
   if (phase_after_strong == 3) {
      elapsed_strong_end = (TimeCurrent() - last_strong_end)/60;
   }else{
      elapsed_strong_end = 0;
   }

   if (FileIsExist("XL.csv")) {
      xl_exist = true;
   }
   if (xl_exist) {
      elapsed_since_xl++;
   }
   if (elapsed_since_xl > 5) {
      xl_exist = false;
      elapsed_since_xl = 0;
   }

   //update previous ticks
   int tick_sum = 0;
   for (int i=ArraySize(ticks)-1; i != 0; i--) {
      ticks[i] = ticks[i-1];
      tick_sum += ticks[i];
   }
   ticks[0] = prev_tick;
   tick_sum += ticks[0];
   tick_mean = StringSubstr(tick_sum/ArraySize(ticks),0,4);

   if (elapsed%10 == 0) {
      for (int i=0; i<ArraySize(SAFE_MIN); i++) {
         //if (SAFE_MIN[i] == current_minute) {
           // has_danger_min = true;
         //}
      }
   }

   //過去を走査して頂点を抽出
   bool running_min = false;
   current_minute = TimeMinute(TimeLocal());
   for (int i=0; i<ArraySize(DANGER_MIN); i++) {
      if (DANGER_MIN[i] == current_minute) {
         running_min = true;
      }
   }
   if (timestamp_highest12m > timestamp_lowest12m) {
      period = timestamp_highest12m - timestamp_lowest12m;
   }else{
      period = timestamp_lowest12m - timestamp_highest12m;
   }
   int stable_apex = 0;
   double abrupt_mean_ratio = 0;
   int isPeriodic = 0;
   string idx = "";
   int hittime1 = 0;
   int hittime2 = 0;
   if (running_min && counter >= 12) {
      //maxima minuma on 4 or 9 logic
      if(prev_tick > 9 && last_candle_position != 6) {
         stable_apex = 1;
         if (prev_high_idx == 9 || prev_low_idx == 9) {
            stable_apex++;
         }
         if (prev_high_idx == 4 || prev_low_idx == 4) {
            stable_apex++;
         }
         if (stable_apex > 1) {
            string hitat = "";
            string or = "";
            if (timestamp_highest12m > timestamp_lowest12m) {
               hitat = TimeToStr(timestamp_highest12m+period-60,TIME_MINUTES);
               or = TimeToStr(timestamp_highest12m+period-60+period,TIME_SECONDS);
               hittime1 = timestamp_highest12m+period-60;
               hittime2 = timestamp_highest12m+period-60+period;
            }else{
               hitat = TimeToStr(timestamp_lowest12m+period-60,TIME_MINUTES);
               or = TimeToStr(timestamp_lowest12m+period-60+period,TIME_SECONDS);
               hittime1 = timestamp_lowest12m+period-60;
               hittime2 = timestamp_lowest12m+period-60+period;
            }
            int period_sec = period % 60;
            string period_min_str = ((period - period_sec)/60)+":"+period_sec;
            if (prev_high_idx == 9) idx += hitat+"/"+or+",";
            if (prev_high_idx == 4) idx += hitat+"/"+or+",";
            if (prev_low_idx == 9) idx += hitat+"/"+or+",";
            if (prev_low_idx == 4) idx += hitat+"/"+or+",";
            isPeriodic = 1;
            string direction = "";
            if (ort_5m == "UP") {
               direction = ":arrow_up:";
            }else{
               direction = ":arrow_down:";
            }
            if (alert_period) {
               Alert(Symbol()+" hit@"+idx+" EVT="+(event_pt0+event_pt1+event_pt2+event_pt3)+" ort="+ort_5m+" pos="+last_candle_position+" period="+period);
               slackprivate(Symbol()+" hit@"+idx+" EVT="+(event_pt0+event_pt1+event_pt2+event_pt3)+" ort="+direction+" pos="+last_candle_position+" period="+period);         
            }
         }
      }
      //initialize
      double pos_mean = getGeometricMean(ABRUPT_POS);
      double neg_mean = getGeometricMean(ABRUPT_NEG);
      if (pos_mean > neg_mean) {
          neg_mean = neg_mean == 0 ? 1 : neg_mean;
          abrupt_mean_ratio = StringSubstr((pos_mean/neg_mean),0,4);
      }else{
          pos_mean = pos_mean == 0 ? 1 : pos_mean;
          abrupt_mean_ratio = StringSubstr((neg_mean/pos_mean),0,4);
      }
      ArrayInitialize(ABRUPT_POS,0);
      ArrayInitialize(ABRUPT_NEG,0);
      abrupt_pos = 0;
      abrupt_neg = 0;
      abrupt_idx = 0;
      counter = 0;
   }
   counter++;

   // bool trendy = false;
   // if (abrupt_pos > abrupt_neg) {
   //     trendy = abrupt_pos == 0 ? 1 : neg_size
   // }else{
   //
   // }
   
   double time_larger_5m = StringSubstr(getSizeChange(1,0,true,PERIOD_M5),0,4);
   double time_larger_5m_entity = StringSubstr(getSizeChange(1,0,false,PERIOD_M5),0,4);
   int min_after_big = (TimeCurrent() - big_last_alert)/60;

   string basis = "";
   basis += " last_alert="+big_last_alert;
   basis += " min_after_big="+min_after_big;
   basis += " 5mx="+time_larger_5m_entity;
   //basis += " dailyZ="+dailyZ;
   basis += " 3mCC="+prev_cc_3m;
   basis += " apex="+stable_apex;
   basis += " period="+period;
   basis += " high@"+time_highest12m;
   basis += " low@"+time_lowest12m;
   basis += " prev_high_idx="+prev_high_idx;
   basis += " prev_low_idx="+prev_low_idx;
   basis += " tickCnt="+tick_cnt;
   basis += " tickMu="+tick_mean;
   //basis += " strongElapsed="+elapsed_strong;
   basis += " hige="+StringSubstr(hige15m,0,4);
   basis += " phase="+phase_after_strong;
   basis += " bandpos="+StringSubstr(pos,0,4);
   basis += " diff="+StringSubstr(this_diff,0,4);
   basis += " EVT="+(event_pt0+event_pt1+event_pt2+event_pt3);
   basis += " strength="+StringSubstr(strength,0,4);
   basis += " event_pt0="+event_pt0;
   basis += " event_pt1="+event_pt1;
   basis += " event_pt2="+event_pt2;
   basis += " event_pt2="+event_pt3;
   basis += " candle="+last_candle_position;
   basis += " XL="+XL;
   basis += " xl_exist="+xl_exist;
   //basis += " z1H="+last_1H_z_score;
   //basis += " z30="+last_30m_z_score;
   basis += " zcloud="+cloud_z_score;

   //連続している相場の数
   serialnums = serialNum(Symbol(),14,0);

   logs += basis;
   string event = "";
   /*
   int usdserial[3];
   int jpyserial[4];
   usdserial[0] = serialNum(PAIRS[0],14,0);
   usdserial[1] = serialNum(PAIRS[1],14,0);
   jpyserial[0] = serialNum(PAIRS[2],14,0);
   jpyserial[1] = serialNum(PAIRS[3],14,0);
   usdserial[2] = serialNum(PAIRS[4],14,0);
   jpyserial[2] = serialNum(PAIRS[5],14,0);
   jpyserial[3] = serialNum(PAIRS[6],14,0);

   if (Symbol() == "EURUSD" || Symbol() == "AUDUSD" || Symbol() == "USDJPY") {
      int maxserialIdx = ArrayMaximum(usdserial,WHOLE_ARRAY,0);
      serialnums = usdserial[maxserialIdx];
   }else{
      int maxserialIdx = ArrayMaximum(jpyserial,WHOLE_ARRAY,0);
      serialnums = jpyserial[maxserialIdx];
   }
   */

   timesLargerInterval = StringSubstr(timesLarger(PERIOD_M5,14,0),0,4);

   if (atEMA200) {
       //logs += "@ema200";
       event +="@ema200";
   }

   if (isNearResistance) {
       //logs += "@barry|";
   }

   if (isNearEMA200) {
       //logs += "nearEma200";
       event +="@nearEma200";
   }
   if (atEMA70) {
       //logs += "@ema70";
       event +="@ema70";
   }
      if (atEMA20) {
         //logs += "@ema20";
         event +="@ema20";
      }
      if (atEMA20 && atEMA70) {
         //logs += "COMBO|";
      }
      if (isNearEMA70) {
         //logs += "nearEma70";
         event +="@nearEma70";
      }
      if (willBreak) {
         //logs += "@resistance|";
         event +="@resistance";
      }

   if (event == "") {
      last_event = "";
   }else{
      last_event = event;
   }

   int time_int = last_alert;
   string next_1H_clouds = getNextZClouds();

   prev_tick = tick_cnt;

   double crossity_day = crossity(PERIOD_D1,0);
   double pits_d[4];
   pits_d[0] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",0,0);
   pits_d[1] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",1,0);
   pits_d[2] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",2,0);
   pits_d[3] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",3,0);
   int highestPitIdx = ArrayMaximum(pits_d,WHOLE_ARRAY,0);
   int lowestPitIdx = ArrayMinimum(pits_d,WHOLE_ARRAY,0);
   double sizeday = MathAbs(pits_d[highestPitIdx] - pits_d[lowestPitIdx]);
   double dailyZ = getDailyZ(sizeday,PERIOD_D1,31);
   current_trend = howGood(entity_type_day,candle_position_day,dailyZ,crossity_day);

   double pits_5[4];
   pits_5[0] = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,1);
   pits_5[1] = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,1);
   pits_5[2] = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,1);
   pits_5[3] = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,1);
   highestPitIdx = ArrayMaximum(pits_5,WHOLE_ARRAY,0);
   lowestPitIdx = ArrayMinimum(pits_5,WHOLE_ARRAY,0);
   prev_full_size = MathAbs(pits_5[highestPitIdx] - pits_5[lowestPitIdx]);
   double atr = iATR(Symbol(),PERIOD_M5,14,0);

   //upper lowerが変わったか
   if (prev_lower != 0 && prev_upper != 0) {
      is_ul_changed = 0;
      if (upper != prev_upper || lower != prev_lower) {
         is_ul_changed = 1;
      }
   }

   double time_larger_d = StringSubstr(getSizeChange(1,0,false,PERIOD_D1),0,4);
   logs += " dailyZ="+dailyZ;

   csv = last_1H_z_score+","+last_30m_z_score+","+cloud_z_score+
   ","+next_1H_clouds+","+elapsed_strong+","+hige15m+","+tick_cnt+","+phase_after_strong+
   ","+entity_type_day+","+candle_position_day+","+dailyZ+","+crossity_day+","+XL+
   ","+potentialTrend+","+atr+","+timesLargerInterval+","+willFade+","+inBand+","+stable_apex+","+is_ul_changed+
   ","+StringSubstr(this_diff,0,4)+","+serialnums+","+abrupt_mean_ratio+","+time_larger_d+
   ","+abrupt_pos+","+abrupt_neg+","+event_pt0_d+","+prev_cc_3m+","+bad_big+
   ","+(event_pt0+event_pt1+event_pt2+event_pt3)+","+covariance+","+period+","+isPeriodic+","+hittime1+","+hittime2+
   ","+min_after_big+","+ema5;
   exportData(Symbol(),csv,true);
   Print(logs);
   deinitialize();
   elapsed++;
  }

void deinitialize(){
   ArrayInitialize(BID_SUM,0);
   ArrayInitialize(TIME_SUM,0);
   ArrayInitialize(LOCALTIME_SUM,0);
   ArrayInitialize(BIDS_4,0);
   ArrayInitialize(TIME_4,0);
   ArrayInitialize(LOCALTIME_4,0);
   int cnt = 0;
   while(TIME_3[cnt] != 0) {
      TIME_3[cnt] = TIME_3[cnt] + 60000;
      cnt++;
   }
   ArrayCopy(BIDS_4,BIDS_3,0,0,WHOLE_ARRAY);
   ArrayCopy(TIME_4,TIME_3,0,0,WHOLE_ARRAY);
   ArrayCopy(LOCALTIME_4,LOCALTIME_3,0,0,WHOLE_ARRAY);
   ArrayInitialize(BIDS_3,0);
   ArrayInitialize(TIME_3,0);
   ArrayInitialize(LOCALTIME_3,0);
   cnt = 0;
   while(TIME_2[cnt] != 0) {
      TIME_2[cnt] = TIME_2[cnt] + 60000;
      cnt++;
   }
   ArrayCopy(BIDS_3,BIDS_2,0,0,WHOLE_ARRAY);
   ArrayCopy(TIME_3,TIME_2,0,0,WHOLE_ARRAY);
   ArrayCopy(LOCALTIME_3,LOCALTIME_2,0,0,WHOLE_ARRAY);
   ArrayInitialize(BIDS_2,0);
   ArrayInitialize(TIME_2,0);
   ArrayInitialize(LOCALTIME_2,0);
   cnt = 0;
   while(TIME[cnt] != 0) {
      TIME[cnt] = TIME[cnt] + 60000;
      cnt++;
   }
   ArrayCopy(BIDS_2,BIDS,0,0,WHOLE_ARRAY);
   ArrayCopy(TIME_2,TIME,0,0,WHOLE_ARRAY);
   ArrayCopy(LOCALTIME_2,LOCALTIME,0,0,WHOLE_ARRAY);
   ArrayInitialize(BIDS,0);
   ArrayInitialize(TIME,0);
   ArrayInitialize(LOCALTIME,0);
   cnt_4 = cnt_3;
   cnt_3 = cnt_2;
   cnt_2 = tick_cnt;
   tick_cnt = 0;
   initialTime = GetTickCount();
   message = Symbol()+":";
   csv = "";
   logs = "";
   willBreak = false;
   isNearResistance = false;
   isNearEMA200 = false;
   isNearEMA70 = false;
   atEMA200 = false;
   atEMA70 = false;
   atEMA20 = false;
   inCloud = false;
   size = 0;
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
   time_highest11 = time_highest10;
   time_lowest11 = time_lowest10;
   time_highest10 = time_highest9;
   time_lowest10 = time_lowest9;
   time_highest9 = time_highest8;
   time_lowest9 = time_lowest8;
   time_highest8 = time_highest7;
   time_lowest8 = time_lowest7;
   time_highest7 = time_highest6;
   time_lowest7 = time_lowest6;
   time_highest6 = time_highest5;
   time_lowest6 = time_lowest5;
   time_highest5 = time_highest4;
   time_lowest5 = time_lowest4;
   time_highest4 = time_highest3;
   time_lowest4 = time_lowest3;
   time_highest3 = time_highest2;
   time_lowest3 = time_lowest2;
   time_highest2 = time_highest1;
   time_lowest2 = time_lowest1;
   time_highest1 = time_highest0;
   time_lowest1 = time_lowest0;
   
   timestamp_highest11 = timestamp_highest10;
   timestamp_lowest11 = timestamp_lowest10;
   timestamp_highest10 = timestamp_highest9;
   timestamp_lowest10 = timestamp_lowest9;
   timestamp_highest9 = timestamp_highest8;
   timestamp_lowest9 = timestamp_lowest8;
   timestamp_highest8 = timestamp_highest7;
   timestamp_lowest8 = timestamp_lowest7;
   timestamp_highest7 = timestamp_highest6;
   timestamp_lowest7 = timestamp_lowest6;
   timestamp_highest6 = timestamp_highest5;
   timestamp_lowest6 = timestamp_lowest5;
   timestamp_highest5 = timestamp_highest4;
   timestamp_lowest5 = timestamp_lowest4;
   timestamp_highest4 = timestamp_highest3;
   timestamp_lowest4 = timestamp_lowest3;
   timestamp_highest3 = timestamp_highest2;
   timestamp_lowest3 = timestamp_lowest2;
   timestamp_highest2 = timestamp_highest1;
   timestamp_lowest2 = timestamp_lowest1;
   timestamp_highest1 = timestamp_highest0;
   timestamp_lowest1 = timestamp_lowest0;
   
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
   prev_high_idx = maxHighest11idx;
   highest12m = last11highest[maxHighest11idx];
   double time_last11highest[11];
   time_last11highest[0] = time_highest11;
   time_last11highest[1] = time_highest10;
   time_last11highest[2] = time_highest9;
   time_last11highest[3] = time_highest8;
   time_last11highest[4] = time_highest7;
   time_last11highest[5] = time_highest6;
   time_last11highest[6] = time_highest5;
   time_last11highest[7] = time_highest4;
   time_last11highest[8] = time_highest3;
   time_last11highest[9] = time_highest2;
   time_last11highest[10] = time_highest1;
   time_highest12m = time_last11highest[maxHighest11idx];
   double timestamp_last11highest[11];
   timestamp_last11highest[0] = timestamp_highest11;
   timestamp_last11highest[1] = timestamp_highest10;
   timestamp_last11highest[2] = timestamp_highest9;
   timestamp_last11highest[3] = timestamp_highest8;
   timestamp_last11highest[4] = timestamp_highest7;
   timestamp_last11highest[5] = timestamp_highest6;
   timestamp_last11highest[6] = timestamp_highest5;
   timestamp_last11highest[7] = timestamp_highest4;
   timestamp_last11highest[8] = timestamp_highest3;
   timestamp_last11highest[9] = timestamp_highest2;
   timestamp_last11highest[10] = timestamp_highest1;
   timestamp_highest12m = timestamp_last11highest[maxHighest11idx];
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
   prev_low_idx = maxLowest11idx;
   lowest12m = last11lowest[maxLowest11idx];
   double time_last11lowest[11];
   time_last11lowest[0] = time_lowest11;
   time_last11lowest[1] = time_lowest10;
   time_last11lowest[2] = time_lowest9;
   time_last11lowest[3] = time_lowest8;
   time_last11lowest[4] = time_lowest7;
   time_last11lowest[5] = time_lowest6;
   time_last11lowest[6] = time_lowest5;
   time_last11lowest[7] = time_lowest4;
   time_last11lowest[8] = time_lowest3;
   time_last11lowest[9] = time_lowest2;
   time_last11lowest[10] = time_lowest1;
   time_lowest12m = time_last11lowest[maxLowest11idx];
   double timestamp_last11lowest[11];
   timestamp_last11lowest[0] = timestamp_lowest11;
   timestamp_last11lowest[1] = timestamp_lowest10;
   timestamp_last11lowest[2] = timestamp_lowest9;
   timestamp_last11lowest[3] = timestamp_lowest8;
   timestamp_last11lowest[4] = timestamp_lowest7;
   timestamp_last11lowest[5] = timestamp_lowest6;
   timestamp_last11lowest[6] = timestamp_lowest5;
   timestamp_last11lowest[7] = timestamp_lowest4;
   timestamp_last11lowest[8] = timestamp_lowest3;
   timestamp_last11lowest[9] = timestamp_lowest2;
   timestamp_last11lowest[10] = timestamp_lowest1;
   timestamp_lowest12m = timestamp_last11lowest[maxLowest11idx];
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
   amplitude = MathAbs(highest4m - lowest4m);
   //過去2
   highest2m = highest1;
   lowest2m = lowest1;

   current_time = 0;
   current_bid = 0;
   tick_idx = 0;
   last_two_sec_bid = 0;
   ticks_in_secs = 0;
   ticks_to_exam = 0;
   abrupt_ratio = 0;
   size_diff = 0;
   prev_upper = upper;
   prev_lower = lower;
   upper = 0;
   lower = 0;
   XL = 0;
   bad_big = 0;
}

void haveBroken() {
   double bid = MarketInfo(Symbol(),MODE_BID);

   if (Period() != PERIOD_M5) {
      return;
   }

   upper = getValueByText("High_Low_Plus_UpperPrice");
   lower = getValueByText("High_Low_Plus_LowerPrice");
   inBand = inBand(upper,lower,1);
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
   double opend = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",2,0);
   double closed = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",3,0);
   double open51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,1);
   double close51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,1);
   double opend1 = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",2,1);
   double closed1 = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",3,1);
   double open52 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,2);
   double close52 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,2);
   double opend2 = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",2,2);
   double closed2 = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",3,2);
   double open53 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,3);
   double close53 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,3);
   double opend3 = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",2,3);
   double closed3 = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",3,3);
   int entity_type5 = getEntity(open5,close5);
   entity_type = entity_type5;
   entity_type_day = getEntity(opend,closed);
   bool isAscd;
   if (entity_type_day == 1) {
      ort_day = "ASC";
      isAscd = true;
   }else{
      ort_day = "DSC";
      isAscd = false;
   }
   if (entity_type5 == 0) {
      return;
   }
   bool isAsc;
   double low5 = 0;
   double high5 = 0;
   if (entity_type5 == 1) {
      low5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,0);
      high5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,0);
      isAsc = true;
      ort_5m = "UP";
   }else if (entity_type5 == 2) {
      low5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,0);
      high5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,0);
      isAsc = false;
      ort_5m = "DOWN";
   }


   int entity_type51 = getEntity(open51,close51);
   prev_entity_type = entity_type51;
   prev__prev_entity_type = getEntity(open52,close52);
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
   last_entity_size = entity_size5;
   size = entity_size5;
   double entity_size51 = getEntitySize(open51, close51);
   double entity_size52 = getEntitySize(open52, close52);
   double size5 = MathAbs(high5 - low5);
   double size51 = MathAbs(high51 - low51);
   double size52 = MathAbs(high52 - low52);
   double leadingA5 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,0); //一目均衡(先行スパンA)
   double leadingB5 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,0); //一目均衡(先行スパンB)
   double leadingAd = iIchimoku(Symbol(),PERIOD_D1,9,26,52,3,0); //一目均衡(先行スパンA)
   double leadingBd = iIchimoku(Symbol(),PERIOD_D1,9,26,52,4,0); //一目均衡(先行スパンB)
   prev_leadingA5 = leadingA5;
   prev_leadingB5 = leadingB5;
   cloud_z_score = getZscore(CLOUDMU,CLOUDSIGMA,MathAbs(leadingA5-leadingB5));
   cloud_z_score = MathCeil(cloud_z_score * 100) * 1.0/100;

   double leadingA5_1 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,1); //一目均衡(先行スパンA)
   double leadingB5_1 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,1); //一目均衡(先行スパンB)
   double leadingA5_2 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,2); //一目均衡(先行スパンA)
   double leadingB5_2 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,2); //一目均衡(先行スパンB)
	if (leadingA5 > leadingB5) {
	   if (leadingA5 > bid && bid > leadingB5)
	   {
	   	//logs += " inCloud";
	      inCloud = true;
	      cloud = "in";
	   }
	}else{
	   if (leadingA5 < bid && bid < leadingB5)
	   {
	   	//logs += " inCloud";
	      inCloud = true;
	      cloud = "in";
	   }
	}
   last_candle_position = getHeikenPosition(open5,close5,leadingA5,leadingB5);
   candle_position_day = getHeikenPosition(opend,closed,leadingAd,leadingBd);

   bool barry_in_cloud = false;
   /*
   if (leadingA5 > leadingB5) {
      if ((leadingA5 > omegaHigh && omegaHigh > leadingB5) || (leadingA5 > omegaLow && omegaLow > leadingB5)) {
         barry_in_cloud = true;
      }
   }else{
      if ((leadingB5 > omegaHigh && omegaHigh > leadingA5) || (leadingB5 > omegaLow && omegaLow > leadingA5)) {
         barry_in_cloud = true;
      }
   }
   */

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
   }

   if (isAsc && last_candle_position == 2 && bid > omegaHigh && close51 > omegaHigh && open51 < omegaHigh && !barry_in_cloud) {
       willFade = 1;
   }else if(!isAsc && last_candle_position == 3 && bid < omegaLow && close51 < omegaLow && open51 > omegaLow && !barry_in_cloud) {
       willFade = 1;
   }else {
       willFade = 0;
   }


   ema5 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(5)
   double ema5_1 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(5)
   double ema5_2 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,2); //指数移動平均(5)
   double ema5_3 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,3); //指数移動平均(5)
   double ema5_4 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,4); //指数移動平均(5)

   double ema5d = iMA(Symbol(),PERIOD_D1,5,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(5)
   double ema5d_1 = iMA(Symbol(),PERIOD_D1,5,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(5)
   double ema5d_2 = iMA(Symbol(),PERIOD_D1,5,0,MODE_EMA,PRICE_CLOSE,2); //指数移動平均(5)
   double ema5d_3 = iMA(Symbol(),PERIOD_D1,5,0,MODE_EMA,PRICE_CLOSE,3); //指数移動平均(5)
   double ema5d_4 = iMA(Symbol(),PERIOD_D1,5,0,MODE_EMA,PRICE_CLOSE,4); //指数移動平均(5)

   double ema20 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(20)
   double ema20_1 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(20)
   double ema20_2 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,2); //指数移動平均(20)
   double ema20_3 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,3); //指数移動平均(20)
   double ema20_4 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,4); //指数移動平均(20)

   double ema20d = iMA(Symbol(),PERIOD_D1,20,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(20)
   double ema20d_1 = iMA(Symbol(),PERIOD_D1,20,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(20)
   double ema20d_2 = iMA(Symbol(),PERIOD_D1,20,0,MODE_EMA,PRICE_CLOSE,2); //指数移動平均(20)
   double ema20d_3 = iMA(Symbol(),PERIOD_D1,20,0,MODE_EMA,PRICE_CLOSE,3); //指数移動平均(20)
   double ema20d_4 = iMA(Symbol(),PERIOD_D1,20,0,MODE_EMA,PRICE_CLOSE,4); //指数移動平均(20)

   double ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(70)
   double ema70_1 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(70)
   double ema70_2 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,2); //指数移動平均(70)
   double ema70_3 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,3); //指数移動平均(70)
   double ema70_4 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,4); //指数移動平均(70)

   double ema70d = iMA(Symbol(),PERIOD_D1,70,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(70)
   double ema70d_1 = iMA(Symbol(),PERIOD_D1,70,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(70)
   double ema70d_2 = iMA(Symbol(),PERIOD_D1,70,0,MODE_EMA,PRICE_CLOSE,2); //指数移動平均(70)
   double ema70d_3 = iMA(Symbol(),PERIOD_D1,70,0,MODE_EMA,PRICE_CLOSE,3); //指数移動平均(70)
   double ema70d_4 = iMA(Symbol(),PERIOD_D1,70,0,MODE_EMA,PRICE_CLOSE,4); //指数移動平均(70)

   double ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(200)
   double ema200_1 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(200)
   double ema200_2 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,2); //指数移動平均(200)
   double ema200_3 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,3); //指数移動平均(200)
   double ema200_4 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,4); //指数移動平均(200)

   double ema200d = iMA(Symbol(),PERIOD_D1,200,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(200)
   double ema200d_1 = iMA(Symbol(),PERIOD_D1,200,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(200)
   double ema200d_2 = iMA(Symbol(),PERIOD_D1,200,0,MODE_EMA,PRICE_CLOSE,2); //指数移動平均(200)
   double ema200d_3 = iMA(Symbol(),PERIOD_D1,200,0,MODE_EMA,PRICE_CLOSE,3); //指数移動平均(200)
   double ema200d_4 = iMA(Symbol(),PERIOD_D1,200,0,MODE_EMA,PRICE_CLOSE,4); //指数移動平均(200)

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

   strength = 0;
   int candle_position_five = getHeikenPosition(open5,close5,leadingA5,leadingB5);
   if (candle_position_five == 2) {
      if (ema5 > ema20 && ema20 > ema70 && ema70 > ema200) {
         if (isAsc) {
            strength = MathAbs(ema70 - ema20)/entity_size5;
         }
      }
   }else if (candle_position_five == 3) {
      if (ema5 < ema20 && ema20 < ema70 && ema70 < ema200) {
         if (!isAsc){
            strength = MathAbs(ema70 - ema20)/entity_size5;
         }
      }
   }

   //強い順の兆しを判定
   potentialTrend = 0;
   bool serial4 = isSerial(PERIOD_M5,5,entity_type5,2);
   if (serial4) {
      serial4 = (entity_type5 == 2 && candle_position_five == 3) || (entity_type5 == 1 && candle_position_five == 2);
   }
   if (serial4 && (entity_type5 != entity_type51 && entity_type51 != entity_type52)) potentialTrend = 1;

   event_pt0 = 0;
   event_pt1 = 0;
   event_pt2 = 0;
   event_pt3 = 0;

   event_pt0_d = 0;
   event_pt1_d = 0;
   event_pt2_d = 0;
   event_pt3_d = 0;

   //daily candle position
   if (candle_position_day != 2 && candle_position_day != 3 && candle_position_day != 6) {
       event_pt0_d += 0x32;
   }

   if (isAsc && open5 < ema200 && ema200 < close5 ){
      event_pt0 += 0x7530;
      atEMA200 = true;
   }else if(!isAsc && open5 > ema200 && ema200 > close5 ) {
      event_pt0 += 0x7530;
      atEMA200 = true;
   }
   //daily ema200 cross
   if (isAscd && opend < ema200d && ema200d < closed ){
      event_pt0_d += 0x1e;
   }else if(!isAscd && opend > ema200d && ema200d > closed ) {
      event_pt0_d += 0x1e;
   }


   if (isAsc && open5 < ema20 && ema20 < close5 ){
      event_pt0 += 0x2710;
      atEMA20 = true;
   }else if(!isAsc && open5 > ema20 && ema20 > close5 ) {
      event_pt0 += 0x2710;
      atEMA20 = true;
   }
   if (isAsc && open5 < ema70 && ema70 < close5 ){
      event_pt0 += 0x4e20;
      atEMA70 = true;
   }else if(!isAsc && open5 > ema70 && ema70 > close5 ) {
      event_pt0 += 0x4e20;
      atEMA70 = true;
   }
   //daily ema20 cross
   if (isAscd && opend < ema20d && ema20d < closed ){
      event_pt0_d += 0xa;
   }else if(!isAscd && opend > ema20d && ema20d > closed ) {
      event_pt0_d += 0xa;
   }
   //daily ema70 cross
   if (isAscd && opend < ema70d && ema70d < closed ){
      event_pt0_d += 0x14;
   }else if(!isAscd && opend > ema70d && ema70d > closed ) {
      event_pt0_d += 0x14;
   }


   if (atEMA20 && atEMA70) {
      if (isAsc) {
         if (high5 < ema200 && (high5 + entity_size5) > ema200) {
            //logs += " SPCombo";
            //WindowScreenShot(TimeDay(TimeLocal())+"_"+TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal())+"_"+Symbol()+"_SP"+".gif", 640, 480);
         }
      }else{
         if (low5 > ema200 && (low5 - entity_size5) < ema200) {
            //logs += " SPCombo";
            //WindowScreenShot(TimeDay(TimeLocal())+"_"+TimeHour(TimeLocal())+"_"+TimeMinute(TimeLocal())+"_"+TimeSeconds(TimeLocal())+"_"+Symbol()+"_SP"+".gif", 640, 480);
         }
      }
   }

   //d0
   //daily ema5 ema20 cross
   if (ema5d_1 < ema20d_1) {
      if (ema5d > ema20d) {
         event_pt0_d += 0x1;
      }
   }else{
      if (ema5d < ema20d) {
         event_pt0_d += 0x1;
      }
   }
   //daily ema5 ema70 cross
   if (ema5d_1 < ema70d_1) {
      if (ema5d > ema70d) {
         event_pt0_d += 0x2;
      }
   }else{
      if (ema5d < ema70d) {
         event_pt0_d += 0x2;
      }
   }
   //daily ema5 ema200 cross
   if (ema5d_1 < ema200d_1) {
      if (ema5d > ema200d) {
         event_pt0_d += 0x3;
      }
   }else{
      if (ema5d < ema200d) {
         event_pt0_d += 0x3;
      }
   }
   //daily ema20 ema70 cross
   if (ema20d_1 < ema70d_1) {
      if (ema20d > ema70d) {
         event_pt0_d += 0x4;
      }
   }else{
      if (ema20d < ema70d) {
         event_pt0_d += 0x4;
      }
   }
   //daily ema70 ema200 cross
   if (ema70d_1 < ema200d_1) {
      if (ema70d > ema200d) {
         event_pt0_d += 0x6;
      }
   }else{
      if (ema70d < ema200d) {
         event_pt0_d += 0x6;
      }
   }
   //daily ema20 ema200 cross
   if (ema20d_1 < ema200d_1) {
      if (ema20d > ema200d) {
         event_pt0_d += 0x5;
      }
   }else{
      if (ema20d < ema200d) {
         event_pt0_d += 0x5;
      }
   }

   //0
   if (ema5_1 < ema20_1) {
      if (ema5 > ema20) {
         //logs += " Xema20_0";
         event_pt0 += 0x3e8;
      }
   }else{
      if (ema5 < ema20) {
         //logs += " Xema20_0";
         event_pt0 += 0x3e8;
      }
   }
   if (ema5_1 < ema70_1) {
      if (ema5 > ema70) {
         //logs += " Xema70_0";
         event_pt0 += 0x7d0;
      }
   }else{
      if (ema5 < ema70) {
         //logs += " Xema70_0";
         event_pt0 += 0x7d0;
      }
   }
   if (ema5_1 < ema200_1) {
      if (ema5 > ema200) {
         //logs += " Xema200_0";
         event_pt0 += 0xbb8;
      }
   }else{
      if (ema5 < ema200) {
         //logs += " Xema200_0";
         event_pt0 += 0xbb8;
      }
   }
   if (ema20_1 < ema70_1) {
      if (ema20 > ema70) {
         //logs += " Xema2070_0";
         event_pt0 += 0xfa0;
      }
   }else{
      if (ema20 < ema70) {
         //logs += " Xema2070_0";
         event_pt0 += 0xfa0;
      }
   }
   if (ema70_1 < ema200_1) {
      if (ema70 > ema200) {
         //logs += " Xema70200_0";
         event_pt0 += 0x1770;
      }
   }else{
      if (ema70 < ema200) {
         //logs += " Xema70200_0";
         event_pt0 += 0x1770;
      }
   }
   if (ema20_1 < ema200_1) {
      if (ema20 > ema200) {
         //logs += " Xema20200_0";
         event_pt0 += 0x1388;
      }
   }else{
      if (ema20 < ema200) {
         //logs += " Xema70200_0";
         event_pt0 += 0x1388;
      }
   }
   //1
   if (ema5_2 < ema20_2) {
      if (ema5_1 > ema20_1) {
         //logs += " Xema20_1";
         event_pt1 += 0x64;
      }
   }else{
      if (ema5_1 < ema20_1) {
         //logs += " Xema20_1";
         event_pt1 += 0x64;
      }
   }
   if (ema5_2 < ema70_2) {
      if (ema5_1 > ema70_1) {
         //logs += " Xema70_1";
         event_pt1 += 0xc8;
      }
   }else{
      if (ema5_1 < ema70_1) {
         //logs += " Xema70_1";
         event_pt1 += 0xc8;
      }
   }
   if (ema5_2 < ema200_2) {
      if (ema5_1 > ema200_1) {
         //logs += " Xema200_1";
         event_pt1 += 0x12c;
      }
   }else{
      if (ema5_1 < ema200_1) {
         //logs += " Xema200_1";
         event_pt1 += 0x12c;
      }
   }
   if (ema20_2 < ema70_2) {
      if (ema20_1 > ema70_1) {
         //logs += " Xema2070_1";
         event_pt1 += 0x190;
      }
   }else{
      if (ema20_1 < ema70_1) {
         //logs += " Xema2070_1";
         event_pt1 += 0x190;
      }
   }
   if (ema70_2 < ema200_2) {
      if (ema70_1 > ema200_1) {
         //logs += " Xema70200_1";
         event_pt1 += 0x258;
      }
   }else{
      if (ema70_1 < ema200_1) {
         //logs += " Xema70200_1";
         event_pt1 += 0x258;
      }
   }
   if (ema20_2 < ema200_2) {
      if (ema20_1 > ema200_1) {
         //logs += " Xema20200_1";
         event_pt1 += 0x1f4;
      }
   }else{
      if (ema20_1 < ema200_1) {
         //logs += " Xema20200_1";
         event_pt1 += 0x1f4;
      }
   }

   //2
   if (ema5_3 < ema20_3) {
      if (ema5_2 > ema20_2) {
         //logs += " Xema20_2";
         event_pt2 += 0xa;
      }
   }else{
      if (ema5_2 < ema20_2) {
         //logs += " Xema20_2";
         event_pt2 += 0xa;
      }
   }
   if (ema5_3 < ema70_3) {
      if (ema5_2 > ema70_2) {
         //logs += " Xema70_2";
         event_pt2 += 0x14;
      }
   }else{
      if (ema5_2 < ema70_2) {
         //logs += " Xema70_2";
         event_pt2 += 0x14;
      }
   }
   if (ema5_3 < ema200_3) {
      if (ema5_2 > ema200_2) {
         //logs += " Xema200_2";
         event_pt2 += 0x1e;
      }
   }else{
      if (ema5_2 < ema200_2) {
         //logs += " Xema200_2";
         event_pt2 += 0x1e;
      }
   }
   if (ema20_3 < ema70_3) {
      if (ema20_2 > ema70_2) {
         //logs += " Xema2070_2";
         event_pt2 += 0x28;
      }
   }else{
      if (ema20_2 < ema70_2) {
         //logs += " Xema2070_2";
         event_pt2 += 0x28;
      }
   }
   if (ema70_3 < ema200_3) {
      if (ema70_2 > ema200_2) {
         //logs += " Xema70200_2";
         event_pt2 += 0x3c;
      }
   }else{
      if (ema70_2 < ema200_2) {
         //logs += " Xema70200_2";
         event_pt2 += 0x3c;
      }
   }
   if (ema20_3 < ema200_3) {
      if (ema20_2 > ema200_2) {
         //logs += " Xema20200_2";
         event_pt2 += 0x32;
      }
   }else{
      if (ema20_2 < ema200_2) {
         //logs += " Xema70200_2";
         event_pt2 += 0x32;
      }
   }

   //3
   if (ema5_4 < ema20_4) {
      if (ema5_3 > ema20_3) {
         //logs += " Xema20_3";
         event_pt3 += 0x1;
      }
   }else{
      if (ema5_3 < ema20_3) {
         //logs += " Xema20_3";
         event_pt3 += 0x1;
      }
   }
   if (ema5_4 < ema70_4) {
      if (ema5_3 > ema70_3) {
         //logs += " Xema70_3";
         event_pt3 += 0x2;
      }
   }else{
      if (ema5_3 < ema70_3) {
         //logs += " Xema70_3";
         event_pt3 += 0x2;
      }
   }
   if (ema5_4 < ema200_4) {
      if (ema5_3 > ema200_3) {
         //logs += " Xema200_3";
         event_pt3 += 0x3;
      }
   }else{
      if (ema5_3 < ema200_3) {
         //logs += " Xema200_3";
         event_pt3 += 0x3;
      }
   }
   if (ema20_4 < ema70_4) {
      if (ema20_3 > ema70_3) {
         //logs += " Xema2070_3";
         event_pt3 += 0x4;
      }
   }else{
      if (ema20_3 < ema70_3) {
         //logs += " Xema2070_3";
         event_pt3 += 0x4;
      }
   }
   if (ema70_4 < ema200_4) {
      if (ema70_3 > ema200_3) {
         //logs += " Xema70200_3";
         event_pt3 += 0x6;
      }
   }else{
      if (ema70_3 < ema200_3) {
         //logs += " Xema70200_3";
         event_pt3 += 0x6;
      }
   }
   if (ema20_4 < ema200_4) {
      if (ema20_3 > ema200_3) {
         //logs += " Xema20200_3";
         event_pt3 += 0x5;
      }
   }else{
      if (ema20_3 < ema200_3) {
         //logs += " Xema20200_3";
         event_pt3 += 0x5;
      }
   }
   return;

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

double meanEntitySize(int interval, int idx) {
   double close = 0;
   double open = 0;
   double size = 0;
   double sum = 0;

   for (int i=0+idx; i<interval+idx; i++) {
      close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,i);
      open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,i);
      size = MathAbs(open-close);
      sum += size;
   }
   return sum/interval;
 }

 double getZscore(double &mu[], double &sigma[], double sample) {
   double mean = mu[getIndex()];
   double std = sigma[getIndex()];
   return MathCeil(((sample - mean)/std) * 100) * 1.0/100;
 }

double getDailyZ(double sample, int timeshift, int count) {
   if (daily_std != 0 && daily_mean != 0) {
      return MathCeil(((sample - daily_mean)/daily_std) * 100) * 1.0/100;
   }
   double sum = 0;
   double devsum = 0;
   double pits[4];
   int highestIdx = 0;
   int lowestIdx = 0;

   for (int i=0; i<count; i++) {
      pits[0] = iCustom(Symbol(),timeshift,"HeikenAshi_DM",0,i);
      pits[1] = iCustom(Symbol(),timeshift,"HeikenAshi_DM",1,i);
      pits[2] = iCustom(Symbol(),timeshift,"HeikenAshi_DM",2,i);
      pits[3] = iCustom(Symbol(),timeshift,"HeikenAshi_DM",3,i);
      highestIdx = ArrayMaximum(pits,WHOLE_ARRAY,0);
      lowestIdx = ArrayMinimum(pits,WHOLE_ARRAY,0);
      sum += MathAbs(pits[highestIdx] - pits[lowestIdx]);
   }

   daily_mean = sum/count;
   for (int i=0; i<count; i++) {
      pits[0] = iCustom(Symbol(),timeshift,"HeikenAshi_DM",0,i);
      pits[1] = iCustom(Symbol(),timeshift,"HeikenAshi_DM",1,i);
      pits[2] = iCustom(Symbol(),timeshift,"HeikenAshi_DM",2,i);
      pits[3] = iCustom(Symbol(),timeshift,"HeikenAshi_DM",3,i);
      highestIdx = ArrayMaximum(pits,WHOLE_ARRAY,0);
      lowestIdx = ArrayMinimum(pits,WHOLE_ARRAY,0);
      devsum += MathPow((
         (MathAbs(pits[highestIdx] - pits[lowestIdx]))-daily_mean
       ),2);
   }
   double variance = devsum/count;
   daily_std = MathSqrt(variance);
   return MathCeil(((sample - daily_mean)/daily_std) * 100) * 1.0/100;
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

string howGood(int type, int pos, double z, double cross) {
   string cloudflg = "";
   if (pos != 2 && pos != 3) {
      cloudflg = "(cloud)";
   }
   if (z < -1) {
      if (type == 1) return "tiny-asc"+cloudflg;
      if (type == 2) return "tiny-dsc"+cloudflg;
   }
   if (cross < 0.3) {
      if (type == 1) return "stable-asc"+cloudflg;
      if (type == 2) return "stable-dsc"+cloudflg;
   }

   if (type == 1) return "vig-asc"+cloudflg;
   if (type == 2) return "vig-dsc"+cloudflg;
   return "HUH?";

}

double getCorrelated (double &bids[],double &times[],string want) {
   double bidSum = 0;
   double timeSum = 0;
   double volProduct = 0;
   int count = 0;
   double VOL[1200];

   while(bids[count] != 0 && count+1 < ArraySize(bids)){
      count++;
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

   if ((bidStd * timeStd) == 0) {
      return 0;
   }
   double CC = covariance/(bidStd * timeStd);
   double slope = 0;
   if (timeStd != 0) {
      slope = covariance/timeStd;
   }
   if (want == "cv") return bidStd/bidMean;
   if (want == "slope") return slope;
   if (want == "cc") return CC;
   return CC;

}

double getGeometricMean (double &sample[]) {
   double product = 0;
   int count = 0;

   while(sample[count] != 0 && count+1 < ArraySize(sample)){
      count++;
   }
   //一回もなかった
   if (count == 0) {
      return 0;
   }

   for (int i=0; i<count; i++) {
      if (product == 0) {
         product = sample[i];
      }else if (sample[i] != 0){
         product *= sample[i];
      }
   }
   double power = 1.0/(count*1.0);
   return MathPow(MathAbs(product),power);
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
		if (open > leading_a && open > leading_b && close > leading_a && close >leading_b) {
			return 2; //雲の上
		}
		if (close < leading_a && close < leading_b && open < leading_a && open  < leading_b) {
			return 3; //雲の下
		}
      if (close > leading_a && close > leading_b && open < leading_a && open  < leading_b) {
			return 7; //雲が間
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
		if (close > leading_a && close >leading_b && open > leading_a && open > leading_b) {
			return 2; //雲の上
		}
		if (open < leading_a && open < leading_b && close < leading_a && close < leading_b) {
			return 3; //雲の下
		}
		if (close < leading_a && close < leading_b && open > leading_a && open  > leading_b) {
			return 7; //雲が間
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

double getPosition(double highest, double lowest, double target) {
    double pos = 0;
    if (highest > lowest) {
    double delta = highest - lowest;
    double half = delta/2;
    if (target > (half+lowest)) {
        if (delta != 0) pos = MathAbs(target - lowest)/delta;
    }else{
        if (delta != 0) pos = MathAbs(highest - target)/delta;
    }
        pos = MathCeil(pos * 100) * 1.0 /100;
    }
    return pos;
}

string getNextZClouds() {
    string csv = "";
    double leadingA = 0;
    double leadingB = 0;
    double z = 0;
    for (int i=-1; i>-13; i--) {
        leadingA = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,i); //一目均衡(先行スパンA)
        leadingB = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,i); //一目均衡(先行スパンB)
        z = getZscore(CLOUDMU,CLOUDSIGMA,MathAbs(leadingA-leadingB));
        csv += (MathCeil(z * 100) * 1.0/100);
        if (i != -12) {
            csv += ",";
        }
    }
    return csv;
}

  int inBand(double top_band, double bottom_band, int count) {
    double open = 0;
    double close = 0;

    for (int i=0; i<count; i++) {
      open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,i);
      if (close > top_band) {
         return 0;
      }
      if (open > top_band) {
         return 0;
      }
      if (open < bottom_band) {
         return 0;
      }
      if (close < bottom_band) {
         return 0;
      }
    }
    return 1;
 }

double getHigeRatio(int count, int timeframe, int shift) {
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

   for (int i=0+shift; i<count+shift;i++) {
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

double crossity(int timeframe, int shift) {
   double open = iCustom(Symbol(),timeframe,"HeikenAshi_DM",2,shift);
   double close = iCustom(Symbol(),timeframe,"HeikenAshi_DM",3,shift);
   int entity_type = getEntity(open, close);
   double high = 0;
   double low = 0;
   double hige_rev = 0;
   double hige_order = 0;
   if (entity_type == 1) {
      low = iCustom(Symbol(),timeframe,"HeikenAshi_DM",0,shift);
      high = iCustom(Symbol(),timeframe,"HeikenAshi_DM",1,shift);
      hige_rev = open - low;
      hige_order = high - close;
   }else if (entity_type == 2) {
      low = iCustom(Symbol(),timeframe,"HeikenAshi_DM",1,shift);
      high = iCustom(Symbol(),timeframe,"HeikenAshi_DM",0,shift);
      hige_rev = high - open;
      hige_order = close - low;
   }
   return 0;
   //return MathCeil((hige_rev/hige_order) * 100) * 1.0 /100;
}

/**
* type 0: any 1:asc 2:desc
*/
 bool isSerial(int period, int count, int type, int shift) {
   double open = iCustom(Symbol(),period,"HeikenAshi_DM",2,shift+count);
   double close = iCustom(Symbol(),period,"HeikenAshi_DM",3,shift+count);
   int entity_type = getEntity(open,close);
   int prev_entity_type = entity_type;

   while (shift - count != shift) {
      count--;
      open = iCustom(Symbol(),period,"HeikenAshi_DM",2,shift+count);
      close = iCustom(Symbol(),period,"HeikenAshi_DM",3,shift+count);
      entity_type = getEntity(open,close);
      if (type == 1 && entity_type != 1) return false;
      if (type == 2 && entity_type != 2) return false;
   }
   return true;
}

 int serialNum(int period, int count, int shift) {
   double open = iCustom(Symbol(),period,"HeikenAshi_DM",2,shift);
   double close = iCustom(Symbol(),period,"HeikenAshi_DM",3,shift);
   int entity_type = getEntity(open,close);
   int prev_entity_type = entity_type;
   int serial_num = 1;
   for (int i=0; i<count;i++) {
      open = iCustom(Symbol(),period,"HeikenAshi_DM",2,i+shift+1);
      close = iCustom(Symbol(),period,"HeikenAshi_DM",3,i+shift+1);
      entity_type = getEntity(open,close);
      if (entity_type != prev_entity_type) return serial_num;
      serial_num++;
      prev_entity_type = entity_type;
   }
   return serial_num;
}

double timesLarger(int period, int count, int shift) {
   double open = iCustom(Symbol(),period,"HeikenAshi_DM",2,shift);
   double close = iCustom(Symbol(),period,"HeikenAshi_DM",3,shift);
   int entity_type = 0;
   double pos_size = 0;
   double neg_size = 0;
   for (int i=0; i<count;i++) {
      open = iCustom(Symbol(),period,"HeikenAshi_DM",2,i+shift+1);
      close = iCustom(Symbol(),period,"HeikenAshi_DM",3,i+shift+1);
      entity_type = getEntity(open,close);
      if (entity_type == 1) {
         pos_size += getEntitySize(open,close);
      }else{
         neg_size += getEntitySize(open,close);
      }
   }
   if (pos_size > neg_size) {
      neg_size = neg_size == 0 ? 1 : neg_size;
      return pos_size/neg_size;
   }else{
      pos_size = pos_size == 0 ? 1 : pos_size;
      return neg_size/pos_size;
   }
}

string bidsToString (double &bids[],double &times[]) {
   string bid_string = "\n";
   int count = 0;
   
   while(bids[count] != 0 && count+1 < ArraySize(bids)){
      bid_string += times[count]+","+bids[count]+"\n";
      count++;
   }
   return bid_string;
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

int slackprivate(string text)
{

   int WebR;
   string URL = "https://hooks.slack.com/services/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";
   int timeout = 5000;
   string cookie = NULL,headers;
   char post[],FTPdata[];
   string str= "&payload="+"{\"text\":\""+text+"\",\"mrkdwn\":true}";

   StringToCharArray( str, post );
   WebR = WebRequest( "POST", URL, cookie, NULL, timeout, post, 0, FTPdata, headers );
   return(WebR);
}

double getSizeChange(int before, int after, bool fullsize, int period) {
   double entity[4];
   double entity1[4];
   double open1 = iCustom(Symbol(),period,"HeikenAshi_DM",2,before);
   double close1 = iCustom(Symbol(),period,"HeikenAshi_DM",3,before);
   double open2 = iCustom(Symbol(),period,"HeikenAshi_DM",2,after);
   double close2 = iCustom(Symbol(),period,"HeikenAshi_DM",3,after);
   if (fullsize) {
      double low2 = iCustom(Symbol(),period,"HeikenAshi_DM",0,after);
      double high2 = iCustom(Symbol(),period,"HeikenAshi_DM",1,after);
      entity[0] = open2;
      entity[1] = close2;
      entity[2] = low2;
      entity[3] = high2;
      int highestIdx = ArrayMaximum(entity,WHOLE_ARRAY,0);
      double highest = entity[highestIdx];
      int lowestIdx = ArrayMinimum(entity,WHOLE_ARRAY,0);
      double lowest = entity[lowestIdx];
      
      double low1 = iCustom(Symbol(),period,"HeikenAshi_DM",0,before);
      double high1 = iCustom(Symbol(),period,"HeikenAshi_DM",1,before);
      entity1[0] = open1;
      entity1[1] = close1;
      entity1[2] = low1;
      entity1[3] = high1;
      int highestIdx1 = ArrayMaximum(entity1,WHOLE_ARRAY,0);
      double highest1 = entity1[highestIdx1];
      int lowestIdx1 = ArrayMinimum(entity1,WHOLE_ARRAY,0);
      double lowest1 = entity1[lowestIdx1]; 
      return getEntitySize(highest,lowest)/getEntitySize(highest1,lowest1);
   }
   return getEntitySize(open2,close2)/getEntitySize(open1,close1);
}

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
