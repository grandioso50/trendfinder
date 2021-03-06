#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string PAIRS[] = {"USDJPY","EURUSD","GBPJPY","EURJPY","AUDUSD","AUDJPY","NZDJPY"};
string BADDATES[] = {"2020.4.22 00:00"};
bool alert_period = false;
bool alert_ema200 = false;
int simple_counter = 0;

string logs = "";
string oceanic_aligned_at = "";
string alert_msg = "";
bool is_strong_ema = false;
bool initializing = true;
bool xl_alert = true;
bool trend_alert = false;
bool xl_alert2 = false;
bool daily_big_alert = false;
bool strong_trend_alert = false;
bool pair_signaling_alert = false;
bool daily_event_alert = false;
bool daily_uj_ema200_alert = false;
bool ema_aligned_alert = false;
double x0 = 0;
double x1 = 0;
int uj_phase = 0;
int eu_phase = 0;
int gj_phase = 0;
int ej_phase = 0;
int au_phase = 0;
int aj_phase = 0;
int nj_phase = 0;
int uj_phase_num = 1;
int eu_phase_num = 1;
int gj_phase_num = 1;
int ej_phase_num = 1;
int au_phase_num = 1;
int aj_phase_num = 1;
int nj_phase_num = 1;
int elapsed = 0;
int uj_phasein = 0;
int prev_uj_phase = 0;
int eu_phasein = 0;
int prev_eu_phase = 0;
int gj_phasein = 0;
int prev_gj_phase = 0;
int ej_phasein = 0;
int prev_ej_phase = 0;
int au_phasein = 0;
int prev_au_phase = 0;
int aj_phasein = 0;
int prev_aj_phase = 0;
int nj_phasein = 0;
int prev_nj_phase = 0;
int prev_paradigm = 0;
int total_highr_uj = 0;
datetime xl_alert_at = TimeCurrent();
datetime trend_alert_at = TimeCurrent();
datetime last_ema200_alert_at = TimeCurrent();
int uj_xl = 0;
int eu_xl = 0;
int gj_xl = 0;
int ej_xl = 0;
int au_xl = 0;
int aj_xl = 0;
int nj_xl = 0;
double uj_pips = 0;
double eu_pips = 0;
double gj_pips = 0;
double ej_pips = 0;
double au_pips = 0;
double aj_pips = 0;
double nj_pips = 0;
bool uj_big = false;
bool eu_big = false;
bool gj_big = false;
bool ej_big = false;
bool au_big = false;
bool aj_big = false;
bool nj_big = false;
bool ema200CrossAlert = false;
bool trendShiftAlert = false;
int asc = 0;
int dsc = 0;
int prev_asc = 0;
int prev_dsc = 0;
int last_fading_num = 0;
double prev_xl_ratio = 0;
datetime xl_time = TimeCurrent();
bool exist_xl = false;
int apex_num = 0;
int band_changed_num = 0;
int abrupt_num = 0;
int serial_num = 0;
double nine_to_ten_evt = 0;
int prev_hour = 0;
int hourly_cv = 0;
int daily_cv = 0;
int latest_evt[4];
double latest_evts;
double prev_dz[7];
datetime uj_walk = TimeCurrent();
datetime eu_walk = TimeCurrent();
datetime gj_walk = TimeCurrent();
datetime ej_walk = TimeCurrent();
datetime au_walk = TimeCurrent();
datetime aj_walk = TimeCurrent();
datetime nj_walk = TimeCurrent();

int OnInit()
  {
   EventSetTimer(60);
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
  }

void OnTimer()
  {
   logs = "";
   string filename = "";
   string val = "";
   int handle;
   double z[7];
   double z30[7];
   int serialelapsed[7];
   double hige[7];
   double ticks[7];
   int phase[7];
   int dtype[7];
   int dpos[7];
   double dz[7];
   double dcross[7];
   int xl[7];
   int potentialTrend[7];
   double atr[7];
   double larger[7];
   int fading[7];
   int band[7];
   int apex[7];
   int band_changed[7];
   double diff[7];
   int abrupt_12[7];
   int abrupt_val[7];
   int serial_candle[7];
   double abrupt_mu[7];
   double larger_d[7];
   int abrupt_pos[7];
   int abrupt_neg[7];
   double devent[7];
   double cc3m[7];
   int badbigs[7];
   int event5m[7];
   double covariance[7];
   double period[7];
   int isPeriodic[7];
   int hit1[7];
   int hit2[7];
   int big_after[7];
   double entity_changes[7];
   double ema5[7];
   double last3z[7];
   int good_walk[7];
   int daily_cross[7];
   int daily_converted[7];
   int big_alerted[7];
   int daily_phase[7];
   int paradigm[7];
   int lastEma200Surpassed[7];
   double last_15_r[7];
   double last_12_pips[7];
   double daily_size_r[7];

   if (elapsed >= 60) elapsed = 0;

   if (initializing) {
       slack("initializing monitor...");
       slackprivate("initializing private...");
       initializing = false;
   }

   int cnt = 0;
   for (int i=0; i<ArraySize(PAIRS); i++) {
      cnt = 0;
      filename = PAIRS[i]+".csv";
      handle = FileOpen(filename, FILE_CSV|FILE_READ|FILE_SHARE_READ, ',');
      while(!FileIsEnding(handle)){
         val = FileReadNumber(handle);
         switch (cnt) {
            case 0://z1H
            z[i] = StringToDouble(val);
            break;
            case 1://z30m
            z30[i] = StringToDouble(val);
            break;
            case 2://daily R Change
            daily_size_r[i] = StringToDouble(val);
            break;
            case 3://elaspedstrong
            serialelapsed[i] = StringToInteger(val);
            break;
            case 4://hige
            hige[i] = StringToDouble(val);
            break;
            case 5://tick_cnt
            ticks[i] = StringToDouble(val);
            break;
            case 6://phase
            phase[i] = StringToInteger(val);
            break;
            case 7://daily type
            dtype[i] = StringToInteger(val);
            break;
            case 8://daily pos
            dpos[i] = StringToInteger(val);
            break;
            case 9://daily z
            dz[i] = StringToDouble(val);
            break;
            case 10://daily cross
            dcross[i] = StringToDouble(val);
            break;
            case 11://xl cross
            xl[i] = StringToInteger(val);
            break;
            case 12://serial entity and different type comes after
            potentialTrend[i] = StringToInteger(val);
            break;
            case 13://atr
            atr[i] = StringToDouble(val);
            break;
            case 14://larger
            larger[i] = StringToDouble(val);
            break;
            case 15://fading
            fading[i] = StringToInteger(val);
            break;
            case 16://band
            band[i] = StringToInteger(val);
            break;
            case 17://apex
            apex[i] = StringToInteger(val);
            break;
            case 18://band changed
            band_changed[i] = StringToInteger(val);
            break;
            case 19://z-score diff
            diff[i] = StringToDouble(val);
            break;
            case 20://serial num
            serial_candle[i] = StringToInteger(val);
            break;
            case 21://abrupt mu
            abrupt_mu[i] = StringToDouble(val);
            break;
            case 22://larger day
            larger_d[i] = StringToDouble(val);
            break;
            case 23://abrupt pos
            abrupt_pos[i] = StringToInteger(val);
            break;
            case 24://abrupt neg
            abrupt_neg[i] = StringToInteger(val);
            break;
            case 25://daily event
            devent[i] = StringToInteger(val);
            break;
            case 26://3mcc
            cc3m[i] = StrToDouble(val);
            break;
            case 27://bad bigs
            badbigs[i] = StringToInteger(val);
            break;
            case 28://5m event
            event5m[i] = StringToInteger(val);
            break;
            case 29://covariance
            covariance[i] = StringToDouble(val);
            break;
            case 30://period
            period[i] = StringToDouble(val);
            break;
            case 31://isPeriodic
            isPeriodic[i] = StringToInteger(val);
            break;
            case 32://time
            hit1[i] = StringToInteger(val);
            break;
            case 33://time
            hit2[i] = StringToInteger(val);
            break;
            case 34://big after
            big_after[i] = StringToInteger(val);
            break;
            case 35://ema5
            ema5[i] = StringToDouble(val);
            break;
            case 36://last3z
            last3z[i] = StringToDouble(val);
            break;
            case 37://was walking
            good_walk[i] = StringToInteger(val);
            break;
            case 38://daily cross
            daily_cross[i] = StringToInteger(val);
            break;
            case 39://daily converted
            daily_converted[i] = StringToInteger(val);
            break;
            case 40://big alerted
            big_alerted[i] = StringToInteger(val);
            break;
            case 41://daily phase
            daily_phase[i] = StringToInteger(val);
            break;
            case 42://paradigm shift
            paradigm[i] = StringToInteger(val);
            break;
            case 43://last_ema200_surpassed
            lastEma200Surpassed[i] = StringToInteger(val);
            break;
            case 44://last 15r
            last_15_r[i] = StringToDouble(val);
            break;
            case 45://last 12 pips
            last_12_pips[i] = StringToDouble(val);
            break;
            default:
            break;
         }
         cnt++;
      }
      FileClose(handle);
   }

   if (good_walk[0] == 1) {
      uj_walk = TimeCurrent();
   }
   if (good_walk[1] == 1) {
      eu_walk = TimeCurrent();
   }
   if (good_walk[2] == 1) {
      gj_walk = TimeCurrent();
   }
   if (good_walk[3] == 1) {
      ej_walk = TimeCurrent();
   }
   if (good_walk[4] == 1) {
      au_walk = TimeCurrent();
   }
   if (good_walk[5] == 1) {
      aj_walk = TimeCurrent();
   }
   if (good_walk[6] == 1) {
      nj_walk = TimeCurrent();
   }
   int walk_cnt = countEqual(good_walk,1);
   if (walk_cnt > 0) {
      datetime walking_start = TimeCurrent();
      int walk_between = 0;
      int good_walk_cnt = 0;
      string walking_pairs = "";
      walk_between = (walking_start - uj_walk)/60;
      if (walk_between < 10) {
         walking_pairs += "USDJPY,";
         good_walk_cnt++;
      }
      walk_between = (walking_start - eu_walk)/60;
      if (walk_between < 10) {
         walking_pairs += "EURUSD,";
         good_walk_cnt++;
      }
      walk_between = (walking_start - gj_walk)/60;
      if (walk_between < 10) {
         walking_pairs += "GBPJPY,";
         good_walk_cnt++;
      }
      walk_between = (walking_start - ej_walk)/60;
      if (walk_between < 10) {
         walking_pairs += "EURJPY,";
         good_walk_cnt++;
      }
      walk_between = (walking_start - au_walk)/60;
      if (walk_between < 10) {
         walking_pairs += "AUDUSD,";
         good_walk_cnt++;
      }
      walk_between = (walking_start - aj_walk)/60;
      if (walk_between < 10) {
         walking_pairs += "AUDJPY,";
         good_walk_cnt++;
      }
      walk_between = (walking_start - nj_walk)/60;
      if (walk_between < 10) {
         walking_pairs += "NZDJPY,";
         good_walk_cnt++;
      }
      if (good_walk_cnt > 1) {
         //Alert("walkin pairs="+walking_pairs);
         //slackprivate("walkin pairs="+walking_pairs);
      }
   }


   int periodic_cnt = countEqual(isPeriodic,1);
   if (periodic_cnt > 0) {
      double peridic_sum = 0;
      if (isPeriodic[0] == 1) {
         peridic_sum += period[0];
      }
      if (isPeriodic[1] == 1){
         peridic_sum += period[1];
      }
      if (isPeriodic[2] == 1) {
         peridic_sum += period[2];
      }
      if (isPeriodic[3] == 1) {
         peridic_sum += period[3];
      }
      if (isPeriodic[4] == 1) {
         peridic_sum += period[4];
      }
      if (isPeriodic[5] == 1) {
         peridic_sum += period[5];
      }
      if (isPeriodic[6] == 1) {
         peridic_sum += period[6];
      }
      if (alert_period) {
            slackprivate("AVERAGE PRD: "+StringSubstr((peridic_sum/periodic_cnt),0,4)+" ALL:"+StringSubstr((mean(period,false,false,false)),0,4)+" EVTS="+(latest_evts/10000));
      }

   }

   double z30mu = mean(z30,true,false,false);
   logs += " z30="+StringSubstr(z30mu,0,5);

   double count[12];
   count[0] = 5;
   count[1] = 10;
   count[2] = 15;
   count[3] = 20;
   count[4] = 25;
   count[5] = 30;
   count[6] = 35;
   count[7] = 40;
   count[8] = 45;
   count[9] = 50;
   count[10] = 55;
   count[11] = 60;

   double period_mu = mean(period,false,false,false);

   string strong_elapsed =
   "USDJPY="+serialelapsed[0]+
   " EURUSD="+serialelapsed[1]+
   " GBPJPY="+serialelapsed[2]+
   " EURJPY="+serialelapsed[3]+
   " AUDUSD="+serialelapsed[4]+
   " AUDJPY="+serialelapsed[5]+
   " NZDJPY="+serialelapsed[6];
   
   if (elapsed > 15) {
      if (last_12_pips[0] > uj_pips) uj_pips =  last_12_pips[0];
      if (last_12_pips[1] > eu_pips) eu_pips =  last_12_pips[1];
      if (last_12_pips[2] > gj_pips) gj_pips =  last_12_pips[2];
      if (last_12_pips[3] > ej_pips) ej_pips =  last_12_pips[3];
      if (last_12_pips[4] > au_pips) au_pips =  last_12_pips[4];
      if (last_12_pips[5] > aj_pips) aj_pips =  last_12_pips[5];
      if (last_12_pips[6] > nj_pips) nj_pips =  last_12_pips[6];
   }
   
   string high_12_pips =
   "USDJPY="+uj_pips+
   " EURUSD="+eu_pips+
   " GBPJPY="+gj_pips+
   " EURJPY="+ej_pips+
   " AUDUSD="+au_pips+
   " AUDJPY="+aj_pips+
   " NZDJPY="+nj_pips;
   
   
   string last_ema200_surpassed_str =
   (lastEma200Surpassed[0] == 0 ? "" : "USDJPY="+lastEma200Surpassed[0])+
   (lastEma200Surpassed[1] == 0 ? "" :" EURUSD="+lastEma200Surpassed[1])+
   (lastEma200Surpassed[2] == 0 ? "" :" GBPJPY="+lastEma200Surpassed[2])+
   (lastEma200Surpassed[3] == 0 ? "" :" EURJPY="+lastEma200Surpassed[3])+
   (lastEma200Surpassed[4] == 0 ? "" :" AUDUSD="+lastEma200Surpassed[4])+
   (lastEma200Surpassed[5] == 0 ? "" :" AUDJPY="+lastEma200Surpassed[5])+
   (lastEma200Surpassed[6] == 0 ? "" :" NZDJPY="+lastEma200Surpassed[6]);
   int total_ema200_surpassed = sumInteger(lastEma200Surpassed);
   if (total_ema200_surpassed >= 1000) {
      if (!alert_ema200) {
         slackprivate("ema200 alert: "+last_ema200_surpassed_str);
         last_ema200_alert_at = TimeCurrent();
         alert_ema200 = true;
      }
   }else{   
      if (((TimeCurrent() - last_ema200_alert_at)/60) > 15) {
         alert_ema200 = false;
      }
   }

   string big_after_str =
   "USDJPY="+big_after[0]+
   " EURUSD="+big_after[1]+
   " GBPJPY="+big_after[2]+
   " EURJPY="+big_after[3]+
   " AUDUSD="+big_after[4]+
   " AUDJPY="+big_after[5]+
   " NZDJPY="+big_after[6];
   
   string paradigm_str =
   "USDJPY="+paradigm[0]+
   " EURUSD="+paradigm[1]+
   " GBPJPY="+paradigm[2]+
   " EURJPY="+paradigm[3]+
   " AUDUSD="+paradigm[4]+
   " AUDJPY="+paradigm[5]+
   " NZDJPY="+paradigm[6];
   int total_paradigm = sumInteger(paradigm);
   if (total_paradigm > 10) {
      paradigm_str = "*"+paradigm_str+"*";
   }
   if (total_paradigm > prev_paradigm) {
      string shift_pairs = "";
      shift_pairs += paradigm[0] > 0 ? "uj="+paradigm[0]+" " : "";
      shift_pairs += paradigm[1] > 0 ? "eu="+paradigm[1]+" "  : "";
      shift_pairs += paradigm[2] > 0 ? "gj="+paradigm[2]+" "  : "";
      shift_pairs += paradigm[3] > 0 ? "ej="+paradigm[3]+" "  : "";
      shift_pairs += paradigm[4] > 0 ? "au="+paradigm[4]+" "  : "";
      shift_pairs += paradigm[5] > 0 ? "aj="+paradigm[5]+" "  : "";
      shift_pairs += paradigm[6] > 0 ? "nj="+paradigm[6]+" "  : "";
      slackprivate("paradigm shift...pairs="+shift_pairs+" num="+total_paradigm);
   }
   prev_paradigm = total_paradigm;
   


   if (big_after[0] == 1) uj_big = true;
   if (big_after[1] == 1) eu_big = true;
   if (big_after[2] == 1) gj_big = true;
   if (big_after[3] == 1) ej_big = true;
   if (big_after[4] == 1) au_big = true;
   if (big_after[5] == 1) aj_big = true;
   if (big_after[6] == 1) nj_big = true;

  if (uj_big) {
      if (isStable(PAIRS[0])) {
         //slackprivate("stable uj");
         uj_big = false;
      }
   }
  if (eu_big) {
      if (isStable(PAIRS[1])) {
         //slackprivate("stable eu");
         eu_big = false;
      }
   }
  if (gj_big) {
      if (isStable(PAIRS[2])) {
         //slackprivate("stable gj");
         gj_big = false;
      }
   }
   if (ej_big) {
      if (isStable(PAIRS[3])) {
         //slackprivate("stable ej");
         ej_big = false;
      }
   }
   if (au_big) {
      if (isStable(PAIRS[4])) {
         //slackprivate("stable au");
         au_big = false;
      }
   }
   if (aj_big) {
      if (isStable(PAIRS[5])) {
         //slackprivate("stable aj");
         aj_big = false;
      }
   }
   if (nj_big) {
      if (isStable(PAIRS[6])) {
         //slackprivate("stable nj");
         nj_big = false;
      }
   }

   string larger_d_str =
   "USDJPY="+larger_d[0]+
   " EURUSD="+larger_d[1]+
   " GBPJPY="+larger_d[2]+
   " EURJPY="+larger_d[3]+
   " AUDUSD="+larger_d[4]+
   " AUDJPY="+larger_d[5]+
   " NZDJPY="+larger_d[6];

   string pos_str =
   "USDJPY="+abrupt_pos[0]+
   " EURUSD="+abrupt_pos[1]+
   " GBPJPY="+abrupt_pos[2]+
   " EURJPY="+abrupt_pos[3]+
   " AUDUSD="+abrupt_pos[4]+
   " AUDJPY="+abrupt_pos[5]+
   " NZDJPY="+abrupt_pos[6];

   string neg_str =
   "USDJPY="+abrupt_neg[0]+
   " EURUSD="+abrupt_neg[1]+
   " GBPJPY="+abrupt_neg[2]+
   " EURJPY="+abrupt_neg[3]+
   " AUDUSD="+abrupt_neg[4]+
   " AUDJPY="+abrupt_neg[5]+
   " NZDJPY="+abrupt_neg[6];

   string times_larger =
   "USDJPY="+larger[0]+
   " EURUSD="+larger[1]+
   " GBPJPY="+larger[2]+
   " EURJPY="+larger[3]+
   " AUDUSD="+larger[4]+
   " AUDJPY="+larger[5]+
   " NZDJPY="+larger[6];

   string atrs =
   "USDJPY="+StringSubstr(atr[0],0,6)+
   " EURUSD="+StringSubstr(atr[1],0,8)+
   " GBPJPY="+StringSubstr(atr[2],0,6)+
   " EURJPY="+StringSubstr(atr[3],0,6)+
   " AUDUSD="+StringSubstr(atr[4],0,8)+
   " AUDJPY="+StringSubstr(atr[5],0,6)+
   " NZDJPY="+StringSubstr(atr[6],0,6);
   
   string daily_size_r_str =
   "USDJPY="+StringSubstr(daily_size_r[0],0,4)+
   " EURUSD="+StringSubstr(daily_size_r[1],0,4)+
   " GBPJPY="+StringSubstr(daily_size_r[2],0,4)+
   " EURJPY="+StringSubstr(daily_size_r[3],0,4)+
   " AUDUSD="+StringSubstr(daily_size_r[4],0,4)+
   " AUDJPY="+StringSubstr(daily_size_r[5],0,4)+
   " NZDJPY="+StringSubstr(daily_size_r[6],0,4);

   string last3z_str =
   "USDJPY="+StringSubstr(last3z[0],0,4)+
   " EURUSD="+StringSubstr(last3z[1],0,4)+
   " GBPJPY="+StringSubstr(last3z[2],0,4)+
   " EURJPY="+StringSubstr(last3z[3],0,4)+
   " AUDUSD="+StringSubstr(last3z[4],0,4)+
   " AUDJPY="+StringSubstr(last3z[5],0,4)+
   " NZDJPY="+StringSubstr(last3z[6],0,4);
   int large_3d_cnt = countLargerOrEqual(last3z,1);
   if (large_3d_cnt > 0){
      last3z_str = "*"+last3z_str+"*";
   }


   string cc_str =
   "USDJPY="+StringSubstr(cc3m[0],0,4)+
   " EURUSD="+StringSubstr(cc3m[1],0,4)+
   " GBPJPY="+StringSubstr(cc3m[2],0,4)+
   " EURJPY="+StringSubstr(cc3m[3],0,4)+
   " AUDUSD="+StringSubstr(cc3m[4],0,4)+
   " AUDJPY="+StringSubstr(cc3m[5],0,4)+
   " NZDJPY="+StringSubstr(cc3m[6],0,4);

   string hige_total =
   "USDJPY="+StringSubstr(hige[0],0,4)+
   " EURUSD="+StringSubstr(hige[1],0,4)+
   " GBPJPY="+StringSubstr(hige[2],0,4)+
   " EURJPY="+StringSubstr(hige[3],0,4)+
   " AUDUSD="+StringSubstr(hige[4],0,4)+
   " AUDJPY="+StringSubstr(hige[5],0,4)+
   " NZDJPY="+StringSubstr(hige[6],0,4);

   string trend =
   "USDJPY="+howGood(dtype[0],dpos[0],dz[0],dcross[0])+
   " EURUSD="+howGood(dtype[1],dpos[1],dz[1],dcross[1])+
   " GBPJPY="+howGood(dtype[2],dpos[2],dz[2],dcross[2])+
   " EURJPY="+howGood(dtype[3],dpos[3],dz[3],dcross[3])+
   " AUDUSD="+howGood(dtype[4],dpos[4],dz[4],dcross[4])+
   " AUDJPY="+howGood(dtype[5],dpos[5],dz[5],dcross[5])+
   " NZDJPY="+howGood(dtype[6],dpos[6],dz[6],dcross[6]);
   
   string signal_str = hasSignal(0) == 1 ? "*STRONG*" : "week";

   string daily_z_str =
   "USDJPY="+dz[0]+
   " EURUSD="+dz[1]+
   " GBPJPY="+dz[2]+
   " EURJPY="+dz[3]+
   " AUDUSD="+dz[4]+
   " AUDJPY="+dz[5]+
   " NZDJPY="+dz[6];
   if (countLargerOrEqual(dz,0.8) > 0) daily_z_str = "*"+daily_z_str+"*";
   if (countLargerOrEqual(dz,2) > 0 && !daily_big_alert) {
      daily_big_alert = true;
      //slackprivate("DAILY BIG");
   }


   string minute5_event_str =
   "USDJPY="+event5m[0]+
   " EURUSD="+event5m[1]+
   " GBPJPY="+event5m[2]+
   " EURJPY="+event5m[3]+
   " AUDUSD="+event5m[4]+
   " AUDJPY="+event5m[5]+
   " NZDJPY="+event5m[6];

   string daily_event_str =
   "USDJPY="+devent[0]+
   " EURUSD="+devent[1]+
   " GBPJPY="+devent[2]+
   " EURJPY="+devent[3]+
   " AUDUSD="+devent[4]+
   " AUDJPY="+devent[5]+
   " NZDJPY="+devent[6];
   if (devent[0] + devent[1] + devent[2] + devent[3] + devent[4] + devent[5] + devent[6] > 250) {
       daily_event_str = "*"+daily_event_str+"*";
       if (!daily_event_alert) {
         slackprivate("_EVENT_");
         daily_event_alert = true;
       }
   }
   if (!daily_uj_ema200_alert) {
      if (devent[0] >= 200) {
         slackprivate("UJ event="+devent[0]);
         daily_uj_ema200_alert = true;
      }
   }

   string phase_str =
   "USDJPY="+phase[0]+
   " EURUSD="+phase[1]+
   " GBPJPY="+phase[2]+
   " EURJPY="+phase[3]+
   " AUDUSD="+phase[4]+
   " AUDJPY="+phase[5]+
   " NZDJPY="+phase[6];

   if (prev_uj_phase != phase[0] && phase[0] == 1) {
      uj_phasein++;
   }
   prev_uj_phase = phase[0];
   if (prev_eu_phase != phase[1] && phase[1] == 1) {
      eu_phasein++;
   }
   prev_eu_phase = phase[1];
   if (prev_gj_phase != phase[2] && phase[2] == 1) {
      gj_phasein++;
   }
   prev_gj_phase = phase[2];
   if (prev_ej_phase != phase[3] && phase[3] == 1) {
      ej_phasein++;
   }
   prev_ej_phase = phase[3];
   if (prev_au_phase != phase[4] && phase[4] == 1) {
      au_phasein++;
   }
   prev_au_phase = phase[4];
   if (prev_aj_phase != phase[5] && phase[5] == 1) {
      aj_phasein++;
   }
   prev_aj_phase = phase[5];
   if (prev_nj_phase != phase[6] && phase[6] == 1) {
      nj_phasein++;
   }
   prev_nj_phase = phase[6];

   string phasein_str =
   "USDJPY="+uj_phasein+
   " EURUSD="+eu_phasein+
   " GBPJPY="+gj_phasein+
   " EURJPY="+ej_phasein+
   " AUDUSD="+au_phasein+
   " AUDJPY="+aj_phasein+
   " NZDJPY="+nj_phasein;

   string xl_pair = "";
   if (xl[0] > 0) {
      if (xl[0] == 1) asc++;
      if (xl[0] == 2) dsc++;
      uj_xl++;
      exist_xl = true;
      xl_pair += "uj,";
   }
   if (xl[1] > 0) {
      if (xl[1] == 1) asc++;
      if (xl[1] == 2) dsc++;
      eu_xl++;
      exist_xl = true;
      xl_pair += "eu,";
   }
   if (xl[2] > 0) {
      if (xl[2] == 1) asc++;
      if (xl[2] == 2) dsc++;
      gj_xl++;
      exist_xl = true;
      xl_pair += "gj,";
   }
   if (xl[3] > 0) {
      if (xl[3] == 1) asc++;
      if (xl[3] == 2) dsc++;
      ej_xl++;
      exist_xl = true;
      xl_pair += "ej,";
   }
   if (xl[4] > 0) {
      if (xl[4] == 1) asc++;
      if (xl[4] == 2) dsc++;
      au_xl++;
      exist_xl = true;
      xl_pair += "au,";
   }
   if (xl[5] > 0) {
      if (xl[5] == 1) asc++;
      if (xl[5] == 2) dsc++;
      aj_xl++;
      exist_xl = true;
      xl_pair += "aj,";
   }
   if (xl[6] > 0) {
      if (xl[6] == 1) asc++;
      if (xl[6] == 2) dsc++;
      nj_xl++;
      exist_xl = true;
      xl_pair += "nj,";
   }
   if (exist_xl && !xl_alert2) {
      xl_time = TimeCurrent();
      //slackprivate("exist xl...pairs="+xl_pair);
      xl_alert2 = true;
   }
   int elapsed_since_xl = (TimeCurrent() - xl_time)/60;
   if (elapsed_since_xl > 30 && exist_xl) {
      exist_xl = false;
      xl_alert2 = false;
      //slackprivate("no more xl exists...");
   }
   if (prev_asc > prev_dsc) {
      if (dsc > prev_dsc) {
         //slack("converting to DSC");
      }
   }else{
      if (asc > prev_asc) {
         //slack("converting to ASC");
      }
   }

   int total_bad_bigs = badbigs[0]+badbigs[1]+badbigs[2]+badbigs[3]+badbigs[4]+badbigs[5]+badbigs[6];
   if (total_bad_bigs > 100) {
      //slackprivate("_BIG_ _ PAIRS_="+total_bad_bigs);
   }

   string aburpt_mu_str = "";
   aburpt_mu_str += abrupt_mu[0] != 0 ? " uj="+abrupt_mu[0]  : "";
   aburpt_mu_str += abrupt_mu[1] != 0 ? " eu="+abrupt_mu[1]  : "";
   aburpt_mu_str += abrupt_mu[2] != 0 ? " gj="+abrupt_mu[2]  : "";
   aburpt_mu_str += abrupt_mu[3] != 0 ? " ej="+abrupt_mu[3]  : "";
   aburpt_mu_str += abrupt_mu[4] != 0 ? " au="+abrupt_mu[4]  : "";
   aburpt_mu_str += abrupt_mu[5] != 0 ? " aj="+abrupt_mu[5]  : "";
   aburpt_mu_str += abrupt_mu[6] != 0 ? " nj="+abrupt_mu[6]  : "";
   if (aburpt_mu_str != "") {
       //slack("Abrupt mu="+aburpt_mu_str);
   }

   int fading_num = countEqual(fading,1);
   if (fading_num > 0 && fading_num > last_fading_num) {
       string fading_str = "";
       if (fading[0] == 1 && apex[0] > 1) {
         fading_str += band[0] == 1 ? " usdjpy "+diff[0] : "";
       }
       if (fading[1] == 1 && apex[1] > 1) {
         fading_str += band[1] == 1 ? " eurusd "+diff[1] : "";
       }
       if (fading[2] == 1 && apex[2] > 1) {
         fading_str += band[2] == 1 ? " gbpjpy "+diff[2] : "";
       }
       if (fading[3] == 1 && apex[3] > 1) {
         fading_str += band[3] == 1 ? " eurjpy "+diff[3] : "";
       }
       if (fading[4] == 1 && apex[4] > 1) {
         fading_str += band[4] == 1 ? " audusd "+diff[4] : "";
       }
       if (fading[5] == 1 && apex[5] > 1) {
         fading_str += band[5] == 1 ? " audjpy "+diff[5] : "";
       }
       if (fading[6] == 1 && apex[6] > 1) {
         fading_str += band[6] == 1 ? " nzdjpy "+diff[6] : "";
       }
       if (!exist_xl && fading_str != "") {
         //slackprivate(fading_str);
         //Alert(fading_str);
       }
   }
   last_fading_num = fading_num;

   prev_asc = asc;
   prev_dsc = dsc;

   string xl_str =
   "USDJPY="+uj_xl+
   " EURUSD="+eu_xl+
   " GBPJPY="+gj_xl+
   " EURJPY="+ej_xl+
   " AUDUSD="+au_xl+
   " AUDJPY="+aj_xl+
   " NZDJPY="+nj_xl;

   string serials_str =
   "USDJPY="+serialNum("USDJPY",PERIOD_D1,50,0)+
   " EURUSD="+serialNum("EURUSD",PERIOD_D1,50,0)+
   " GBPJPY="+serialNum("GBPJPY",PERIOD_D1,50,0)+
   " EURJPY="+serialNum("EURJPY",PERIOD_D1,50,0)+
   " AUDUSD="+serialNum("AUDUSD",PERIOD_D1,50,0)+
   " AUDJPY="+serialNum("AUDJPY",PERIOD_D1,50,0)+
   " NZDJPY="+serialNum("NZDJPY",PERIOD_D1,50,0);

   string daily_cross_str =
   "USDJPY="+(daily_cross[0] == 1 ? "y" : "-")+
   " EURUSD="+(daily_cross[1] == 1 ? "y" : "-")+
   " GBPJPY="+(daily_cross[2] == 1 ? "y" : "-")+
   " EURJPY="+(daily_cross[3] == 1 ? "y" : "-")+
   " AUDUSD="+(daily_cross[4] == 1 ? "y" : "-")+
   " AUDJPY="+(daily_cross[5] == 1 ? "y" : "-")+
   " NZDJPY="+(daily_cross[6] == 1 ? "y" : "-");
   if (countEqual(daily_cross,1) > 0) {
       daily_cross_str = "*"+daily_cross_str+"*";
   }

   string daily_converted_str =
   "USDJPY="+(daily_converted[0] == 1 ? "y" : "-")+
   " EURUSD="+(daily_converted[1] == 1 ? "y" : "-")+
   " GBPJPY="+(daily_converted[2] == 1 ? "y" : "-")+
   " EURJPY="+(daily_converted[3] == 1 ? "y" : "-")+
   " AUDUSD="+(daily_converted[4] == 1 ? "y" : "-")+
   " AUDJPY="+(daily_converted[5] == 1 ? "y" : "-")+
   " NZDJPY="+(daily_converted[6] == 1 ? "y" : "-");
   if (countEqual(daily_converted,1) > 0) {
       daily_converted_str = "*"+daily_converted_str+"*";
   }

   string daily_phase_str = "";
   daily_phase_str += "USDJPY=";
   if (daily_phase[0] == 3) {
       daily_phase_str += "3 ("+StringSubstr(getDailyZDiff("USDJPY"),0,4)+")";
   } else if(daily_phase[0] == 1) {
       daily_phase_str += "1 ("+StringSubstr(getHigeRatio("USDJPY"),0,4)+")";
   } else if(daily_phase[0] == 2) {
       daily_phase_str += "2";
   }
   daily_phase_str += " EURUSD=";
   if (daily_phase[1] == 3) {
       daily_phase_str += "3 ("+StringSubstr(getDailyZDiff("EURUSD"),0,4)+")";
   } else if(daily_phase[1] == 1) {
       daily_phase_str += "1 ("+StringSubstr(getHigeRatio("EURUSD"),0,4)+")";
   } else if(daily_phase[1] == 2) {
       daily_phase_str += "2";
   }
   daily_phase_str += " GBPJPY=";
   if (daily_phase[2] == 3) {
       daily_phase_str += "3 ("+StringSubstr(getDailyZDiff("GBPJPY"),0,4)+")";
   } else if(daily_phase[2] == 1) {
       daily_phase_str += "1 ("+StringSubstr(getHigeRatio("GBPJPY"),0,4)+")";
   } else if(daily_phase[2] == 2) {
       daily_phase_str += "2";
   }
   daily_phase_str += " EURJPY=";
   if (daily_phase[3] == 3) {
       daily_phase_str += "3 ("+StringSubstr(getDailyZDiff("EURJPY"),0,4)+")";
   } else if(daily_phase[3] == 1) {
       daily_phase_str += "1 ("+StringSubstr(getHigeRatio("EURJPY"),0,4)+")";
   } else if(daily_phase[3] == 2) {
       daily_phase_str += "2";
   }
   daily_phase_str += " AUDUSD=";
   if (daily_phase[4] == 3) {
       daily_phase_str += "3 ("+StringSubstr(getDailyZDiff("AUDUSD"),0,4)+")";
   } else if(daily_phase[4] == 1) {
       daily_phase_str += "1 ("+StringSubstr(getHigeRatio("AUDUSD"),0,4)+")";
   } else if(daily_phase[4] == 2) {
       daily_phase_str += "2";
   }
   daily_phase_str += " AUDJPY=";
   if (daily_phase[5] == 3) {
       daily_phase_str += "3 ("+StringSubstr(getDailyZDiff("AUDJPY"),0,4)+")";
   } else if(daily_phase[5] == 1) {
       daily_phase_str += "1 ("+StringSubstr(getHigeRatio("AUDJPY"),0,4)+")";
   } else if(daily_phase[5] == 2) {
       daily_phase_str += "2";
   }
   daily_phase_str += " NZDJPY=";
   if (daily_phase[6] == 3) {
       daily_phase_str += "3 ("+StringSubstr(getDailyZDiff("NZDJPY"),0,4)+")";
   } else if(daily_phase[6] == 1) {
       daily_phase_str += "1 ("+StringSubstr(getHigeRatio("NZDJPY"),0,4)+")";
   } else if(daily_phase[6] == 2) {
       daily_phase_str += "2";
   }
   /*
   if (sumInteger(daily_phase) > 1) {
       daily_phase_str = "*"+daily_phase_str+"*";
       if (sumInteger(daily_phase) > 5 && !pair_signaling_alert) {
         slackprivate("_CAUTIOUS_ _PHASE_");
         pair_signaling_alert = true;
       }
   }
   */

   string big_alerted_str = "";
   if (big_alerted[0] > 0) {
      big_alerted_str += " USDJPY="+(big_alerted[0] == 1 ? "O" : "R");
   }
   if (big_alerted[1] > 0) {
      big_alerted_str += " EURUSD="+(big_alerted[1] == 1 ? "O" : "R");
   }
   if (big_alerted[2] > 0) {
      big_alerted_str += " GBPJPY="+(big_alerted[2] == 1 ? "O" : "R");
   }
   if (big_alerted[3] > 0) {
      big_alerted_str += " EURJPY="+(big_alerted[3] == 1 ? "O" : "R");
   }
   if (big_alerted[4] > 0) {
      big_alerted_str += " AUDUSD="+(big_alerted[4] == 1 ? "O" : "R");
   }
   if (big_alerted[5] > 0) {
      big_alerted_str += " AUDJPY="+(big_alerted[5] == 1 ? "O" : "R");
   }
   if (big_alerted[6] > 0) {
      big_alerted_str += " NZDJPY="+(big_alerted[6] == 1 ? "O" : "R");
   }
   if (big_alerted_str != "") {
      big_alerted_str = "BIG RESULT: "+big_alerted_str;
      //slackprivate(big_alerted_str);
   }

   if (elapsed > 0) {
      string growing_str = "";
      double uj_dz_diff = difference(prev_dz[0],dz[0]);
      double eu_dz_diff = difference(prev_dz[1],dz[1]);
      double gj_dz_diff = difference(prev_dz[2],dz[2]);
      double ej_dz_diff = difference(prev_dz[3],dz[3]);
      double au_dz_diff = difference(prev_dz[4],dz[4]);
      double aj_dz_diff = difference(prev_dz[5],dz[5]);
      double nj_dz_diff = difference(prev_dz[6],dz[6]);
      if (uj_dz_diff > 0.2) growing_str += " USDJPY="+StringSubstr(uj_dz_diff,0,4);
      if (eu_dz_diff > 0.2) growing_str += " EURUSD="+StringSubstr(eu_dz_diff,0,4);
      if (gj_dz_diff > 0.2) growing_str += " GBPJPY="+StringSubstr(gj_dz_diff,0,4);
      if (ej_dz_diff > 0.2) growing_str += " EURJPY="+StringSubstr(ej_dz_diff,0,4);
      if (au_dz_diff > 0.2) growing_str += " AUDUSD="+StringSubstr(au_dz_diff,0,4);
      if (aj_dz_diff > 0.2) growing_str += " AUDJPY="+StringSubstr(aj_dz_diff,0,4);
      if (nj_dz_diff > 0.2) growing_str += " NZDJPY="+StringSubstr(nj_dz_diff,0,4);
      if (TimeHour(TimeLocal()) >= 10) {
         //if (growing_str != "") slack("ZD incr.."+growing_str);
      }
   }
   ArrayCopy(prev_dz,dz,0,0,WHOLE_ARRAY);

   int apexes = countEqual(apex,2) + countEqual(apex,3);
   if (apexes > 0) {
      apex_num++;
      //slack("total stable apexes="+apexes);
   }

   if (prev_hour != TimeHour(TimeLocal())) {
      hourly_cv = 0;
      prev_hour = TimeHour(TimeLocal());
   }
   hourly_cv += countLargerOrEqual(covariance,0.9);
   daily_cv += countLargerOrEqual(covariance,0.9);
   
   bool strongm5 = isEMAStrong("USDJPY",PERIOD_M5,0);
   bool strongm15 = isEMAStrong("USDJPY",PERIOD_M15,0);
   bool strongm30 = isEMAStrong("USDJPY",PERIOD_M30,0);
   bool strong1h = isEMAStrong("USDJPY",PERIOD_H1,0);
   string emas_str = "m5="+strongm5+" m15="+strongm15+" m30="+strongm30+" 1h="+strong1h;
   
   string ema_type_str = "";
   int ematype = emaType("USDJPY",PERIOD_D1,0);
   if (ematype == 1) {
      ema_type_str = "watch for downward signal";
   }else if (ematype == 2) {
      ema_type_str = "watch for upward signal";
   }else{
      ema_type_str = "no signal";
   }

    int sinceema200 = daysEMA200Crossed(Symbol(),PERIOD_D1,0,4);
    int sinceema200_before = daysEMA200Crossed(Symbol(),PERIOD_D1,1,4);
    /*
    if (!ema200CrossAlert && sinceema200_before == 0 && sinceema200 > 0) {
       slackprivate("strong trend could be appeared lastEMA200cross="+sinceema200);
       ema200CrossAlert = true;
    }
    */

   int phase_num = wavyPhasenum(Symbol(),PERIOD_D1,0,15);
   int phase_num_1 = wavyPhasenum(Symbol(),PERIOD_D1,1,15);
   /*
   if (!trendShiftAlert && phase_num > 2 && phase_num == phase_num_1) {
      slackprivate("strong trend could be appeared phase_num="+phase_num);
      trendShiftAlert = true;
   }
   */
   setPhase(last_15_r[0],0.6,uj_phase,uj_phase_num);
   setPhase(last_15_r[1],0.6,eu_phase,eu_phase_num);
   setPhase(last_15_r[2],0.6,gj_phase,gj_phase_num);
   setPhase(last_15_r[3],0.6,ej_phase,ej_phase_num);
   setPhase(last_15_r[4],0.6,au_phase,au_phase_num);
   setPhase(last_15_r[5],0.6,aj_phase,aj_phase_num);
   setPhase(last_15_r[6],0.6,nj_phase,nj_phase_num);
   if (last_15_r[0] > 0.6) {
      total_highr_uj++;
   }
   string r_phases_str =
   "USDJPY="+uj_phase_num+
   " EURUSD="+eu_phase_num+
   " GBPJPY="+gj_phase_num+
   " EURJPY="+ej_phase_num+
   " AUDUSD="+au_phase_num+
   " AUDJPY="+aj_phase_num+
   " NZDJPY="+nj_phase_num;
   Print("phase num="+r_phases_str);
   
   double d[4];
   d[0] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",0,0);
   d[1] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",1,0);
   d[2] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",2,0);
   d[3] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",3,0);
   int h = ArrayMaximum(d,WHOLE_ARRAY,0);
   int l = ArrayMinimum(d,WHOLE_ARRAY,0);
   double sizeday = MathAbs(d[h] - d[l]);
   double dailyZ = getDailyZ(Symbol(),sizeday,PERIOD_D1,31,0);

   string signal_today = signalScorer(0,BADDATES);
   if (signal_today != "") {
      signal_today = "*"+signal_today+"*";
   }
   string signal_yesterday = signalScorer(1,BADDATES);
   if (signal_yesterday != "") {
      signal_yesterday = "*"+signal_yesterday+"*";
   }
   if (isOceaniaStrong(0)) {
      oceanic_aligned_at = TimeToString(iTime(Symbol(),PERIOD_M5,0)+32400);
   }
   band_changed_num += countEqual(band_changed,1);
   datetime current = TimeCurrent();
   
   if (simple_counter > 0) {
      setMeanEstimate();
   }
   
   if (elapsed%15 == 0) {
       int seconds = TimeSeconds(TimeLocal());
       //slack("trend: "+trend);
       //slack("phase: "+phase_str);
       //slack("xls: "+xl_str);
       //slack("uj phases="+uj_phase_num);
       //slack("highUJR: "+total_highr_uj);
       slack("*mean prediction="+StringSubstr(x0,0,4)+" ~ "+StringSubstr(x1,0,4)+"*");
       slack("dailyZ: "+dailyZ);
       //slack("trd: "+ema_type_str);
       slack("evd: "+daily_event_str);
       //slack("pips:"+high_12_pips);
       //slack("ev5: "+minute5_event_str);
       //slack("xxx: "+larger_d_str);
       //slack("z-d: "+daily_z_str);
       //slack("zdm: "+StringSubstr(mean(dz,false,false,false),0,4));
       //slack("phase: "+daily_phase_str);
       //slack("shifts_after_ema200: "+last_ema200_surpassed_str);
       slack("serial: "+serials_str);
       slack("paradigm: "+paradigm_str);
       slack("dailyR: "+daily_size_r_str); 
       //slack("siganl today="+signal_today+" yesterday="+signal_yesterday);
       if (oceanic_aligned_at != "") {
         slack("strong oceania at: "+oceanic_aligned_at);
       }
       
       if (sinceema200 > 0) {
         slack("200: *daily UJ crossed ema200="+sinceema200+"*");
       }
       /*
       if (phase_num > 2) {
         slack("wav: *trending wave num="+phase_num+"*");
       }else{
         slack("wav: "+phase_num);
       }
       */
       //slack("ema: "+emas_str);
       //slack("jpy: "+signal_str);
       //slack("z-5: "+last3z_str);
       //slack("R3m: "+cc_str);
       //slack("pos: "+pos_str);
       //slack("neg: "+neg_str);
       //slack("hig: "+hige_total);
       //slack("x: "+times_larger);
       //slack("prd: "+StringSubstr(period_mu,0,4));
       double ratio = 0;
       if (asc > dsc) {
           ratio = asc - dsc;
       }else if(dsc > asc) {
           ratio = dsc - asc;
       }
       double ratio_delta = 0;
       if (prev_xl_ratio != 0) {
           ratio_delta =StringSubstr(ratio/prev_xl_ratio,0,4);
       }
       //9時台
       if (TimeHour(TimeLocal()) == 9) {
         nine_to_ten_evt += (double)sumInteger(event5m);
       }
       //slack("9-10 evts="+(nine_to_ten_evt/10000));
       //過去一時間
       latest_evt[3] = latest_evt[2];
       latest_evt[2] = latest_evt[1];
       latest_evt[1] = latest_evt[0];
       latest_evt[0] = sumInteger(event5m);
       latest_evts = (double)sumInteger(latest_evt);
       //slack("evts 9-10="+(nine_to_ten_evt/10000)+" latest="+(latest_evts/10000));
       //slack("houlyCV="+hourly_cv+" dailyCV="+daily_cv);
       //slack("at="+current+" asc="+asc+" dsc="+dsc);
       //slack("apexes="+apex_num+" band changed="+band_changed_num);
       apex_num = 0;
       prev_xl_ratio = ratio;
       //send daily change rate to local api
   }
   /*
   if (elapsed%5 == 0) {
       sendChange("USDJPY",dz[0]);
       sendChange("EURUSD",dz[1]);
       sendChange("GBPJPY",dz[2]);
       sendChange("EURJPY",dz[3]);
       sendChange("AUDUSD",dz[4]);
       sendChange("AUDJPY",dz[5]);
       sendChange("NZDJPY",dz[6]);
       sendChange("MEAN",StringSubstr(mean(dz,false,false,false),0,4));
       for (int i=0; i<ArraySize(PAIRS); i++) {
         filename = PAIRS[i]+"_BIDS.csv";
         if (FileIsExist(filename)) {
            FileDelete(filename);
         }
       }
   }
  */

   int xl_alert_interval = (current - xl_alert_at)/60;
   if (xl_alert_interval > 60 && xl_alert) {
      //slackprivate("60m since xl.");
      xl_alert = false;
   }
   int xl_num = countEqual(xl,1);
   if (xl_num > 0) {
      if (!xl_alert) {
         //slackprivate("60m-xl broken.");
      }
      exportData("XL","",true);
      xl_alert_at = TimeCurrent();
      xl_alert = true;
   }else{
      FileDelete("XL.csv");
   }
   int trend_alert_interval = (current - trend_alert_at)/60;
   if (trend_alert_interval > 5 && trend_alert) {
      trend_alert = false;
   }
   int serialnum = countEqual(potentialTrend,1);
   if (serialnum > 2) {
      if (!trend_alert) {
         //Alert("potential trendnum="+serialnum);
         //slack("potential trendnum="+serialnum);
      }
      trend_alert_at = TimeCurrent();
      trend_alert = true;
   }
   elapsed++;
   simple_counter++;
   logs += " evt[0]="+latest_evt[0]+" evt[1]="+latest_evt[1]+" evt[2]="+latest_evt[2]+" evt[3]="+latest_evt[3]+" sum="+latest_evts;
   Print(logs);
 }

void setPhase(double r, double threshold, int &phase, int &phasenum) {
   //phase 0=unstable
   //phase 1=stable
   if (phase == 0 && r > threshold) {
      phase = 1;
      return;
   }
   if (phase == 1 && r <= threshold) {
      phase = 0;
      phasenum++;
      return;
   }
   
}
void setMeanEstimate() {
   int cnt = 0;
   string filename = "mean_estimate.csv";
   if (!FileIsExist(filename)) {
      return;
   }
   int handle = FileOpen(filename, FILE_CSV|FILE_READ|FILE_SHARE_READ, ',');
   string val = "";
   while(!FileIsEnding(handle)){
      val = FileReadNumber(handle);
      switch (cnt) {
         case 0://x0
            x0 = StringToDouble(val);
         break;
         case 1://x1
            x1 = StringToDouble(val);
         break;
         default:
         break;
      }
         cnt++;
   }
   FileClose(handle);
   
   FileDelete(filename);
   
}

int paradigmDidShift (string symbol, int timeframe, int shift, int days, int minimum_serial) {
   int serialnum = serialNum(symbol,timeframe,days,shift+1);
   //minimum_serial未満の連続だったら終了
   if (serialnum < minimum_serial) return 0;
   
   if (getEntity(
      iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift),
      iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift)) !=
      getEntity(
      iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift+1),
      iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift+1))) {
      return serialnum;
   }
   return 0;
}
 
double pipBreak(string symbol, int timeframe, int shift) {
   double high0 = iHigh(symbol,timeframe,shift);
   double low0 = iLow(symbol,timeframe,shift);
   double pips0 = PriceToPips(high0) - PriceToPips(low0);
   double high1 = iHigh(symbol,timeframe,shift+1);
   double low1 = iLow(symbol,timeframe,shift+1);
   double pips1 = PriceToPips(high1) - PriceToPips(low1);
   return pips0 - pips1;
 }
 
string signalScorer(int shift, string &last_vigorous_date[]) {
  string debug = "";
  int bars_diff;
  datetime shift_date = iTime(Symbol(),PERIOD_D1,shift);
   
  for (int i=0; i<ArraySize(last_vigorous_date); i++) {
   bars_diff = iBarShift(Symbol(),PERIOD_D1,StrToTime(last_vigorous_date[i])) - iBarShift(Symbol(),PERIOD_D1,shift_date);
      if (bars_diff > 0 && bars_diff < 2) {
         //debug += "closeToBad ";
         return debug;
      }
   } 
   
   bool is_pip_break = false;
   bool is_paradigm_shift = false;
   bool is_danger_serial = false;
   //pip break scorer
   
   int pairs_broken = 0;
   int break_pairs_threshold = 3;
   double break_threshold = 100;
   
   for (int i=0; i<ArraySize(PAIRS); i++) {
      if (pipBreak(PAIRS[i],PERIOD_D1,shift) > break_threshold) {
         pairs_broken++;
      }
   }
   if (pairs_broken > break_pairs_threshold) {
      //score pip break
      is_pip_break = true;
      
   }
   
   //paradigm scorer
   bool didShifted = false;
   int pairs_paradigm = 0;
   int shifted_within = 3;
   int paradigm_serial = 0;
   int paradigm_pairs_threshold = 1;
   int too_long_serial_threshold = 9;
   int long_serial_pairs = 0;
   double paradigm_serial_threshold = 6;
   
   for (int i=0; i<ArraySize(PAIRS); i++) {
      if (PAIRS[i] == "GBPJPY" || PAIRS[i] == "USDJPY") continue;
      didShifted = false;
      paradigm_serial = 0;
      
      for (int j=shift; j < shift+shifted_within; j++) {
        if (!didShifted) {
            paradigm_serial = paradigmDidShift(PAIRS[i],PERIOD_D1,j,14,paradigm_serial_threshold);
            if (paradigm_serial > 0) {
               didShifted = true;
            }
        }
      }
  
      if (didShifted) {
         pairs_paradigm++;
         if (paradigm_serial > too_long_serial_threshold) {
            long_serial_pairs++;
         }
      }
   }
   if (pairs_paradigm > paradigm_pairs_threshold) {
      int pairs_paradigm1 = 0;
      for (int i=0; i<ArraySize(PAIRS); i++) {
         if (PAIRS[i] == "GBPJPY" || PAIRS[i] == "USDJPY") continue;
         didShifted = false;
         paradigm_serial = 0;
      
      for (int j=shift+1; j < shift+shifted_within+1; j++) {
        if (!didShifted) {
            paradigm_serial = paradigmDidShift(PAIRS[i],PERIOD_D1,j,14,paradigm_serial_threshold);
            if (paradigm_serial > 0) {
               didShifted = true;
            }
        }
      }
      if (didShifted) {
         pairs_paradigm1++;
      }
    }
      if (pairs_paradigm1 <= paradigm_pairs_threshold && !(long_serial_pairs > 0)) {
         //score paradigm shift
         is_paradigm_shift = true;
      }
   }
   //serial scorer
   
   int total = 0;
   int serialnum = 0;
   int total_serial_threshold = 25;
   int maximum_total_threshold = 30;
   int minimum_serial = 5;
   
   for (int i=0; i<ArraySize(PAIRS); i++) {
     if (PAIRS[i] == "GBPJPY" || PAIRS[i] == "USDJPY") continue;
     serialnum = serialNum(PAIRS[i],PERIOD_D1,14,shift);
     if (serialnum > minimum_serial) {
         total += serialnum;
     }
   }
   if (total > total_serial_threshold && total < maximum_total_threshold) {
      //serial scorer
      is_danger_serial = true;  
   }

   //hige scorer
   double hige = higeSize(PERIOD_D1,shift);
   int pips = PriceToPips(iHigh("USDJPY",PERIOD_D1,shift)) - PriceToPips(iLow("USDJPY",PERIOD_D1,shift));
   if (is_pip_break) debug += "break ";
   if (is_paradigm_shift) debug += "paradigm ";
   if (is_danger_serial) debug += "serial ";
   if (hige > 15 && pips > 60) debug += " hige";
   return debug;
 }
 
 double higeSize(int timeframe,int shift) {
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
   double entity_size = MathAbs(open - close);
   return (hige_rev+hige_order)/entity_size;
}
 
 
bool isOceaniaStrong(int shift) {
   double ema5 = iMA("AUDJPY",PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,shift);
   double ema20 = iMA("AUDJPY",PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,shift);
   double ema70 = iMA("AUDJPY",PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,shift);
   double ema200 = iMA("AUDJPY",PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,shift);
   if (!((ema5 > ema20 && ema20 > ema70 && ema70 > ema200)||(ema5 < ema20 && ema20 < ema70 && ema70 < ema200))) {
      return false;
   }
   ema5 = iMA("NZDJPY",PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,shift);
   ema20 = iMA("NZDJPY",PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,shift);
   ema70 = iMA("NZDJPY",PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,shift);
   ema200 = iMA("NZDJPY",PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,shift);
   if (!((ema5 > ema20 && ema20 > ema70 && ema70 > ema200)||(ema5 < ema20 && ema20 < ema70 && ema70 < ema200))) {
      return false;
   }
   ema5 = iMA("AUDUSD",PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,shift);
   ema20 = iMA("AUDUSD",PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,shift);
   ema70 = iMA("AUDUSD",PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,shift);
   ema200 = iMA("AUDUSD",PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,shift);
   if (!((ema5 > ema20 && ema20 > ema70 && ema70 > ema200)||(ema5 < ema20 && ema20 < ema70 && ema70 < ema200))) {
      return false;
   }
   int before_aligned_count = 0;
   ema5 = iMA("AUDJPY",PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,shift+1);
   ema20 = iMA("AUDJPY",PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,shift+1);
   ema70 = iMA("AUDJPY",PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,shift+1);
   ema200 = iMA("AUDJPY",PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,shift+1);
   if (((ema5 > ema20 && ema20 > ema70 && ema70 > ema200)||(ema5 < ema20 && ema20 < ema70 && ema70 < ema200))) {
      before_aligned_count++;
   }
   ema5 = iMA("NZDJPY",PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,shift+1);
   ema20 = iMA("NZDJPY",PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,shift+1);
   ema70 = iMA("NZDJPY",PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,shift+1);
   ema200 = iMA("NZDJPY",PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,shift+1);
   if (((ema5 > ema20 && ema20 > ema70 && ema70 > ema200)||(ema5 < ema20 && ema20 < ema70 && ema70 < ema200))) {
      before_aligned_count++;
   }
   ema5 = iMA("AUDUSD",PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,shift+1);
   ema20 = iMA("AUDUSD",PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,shift+1);
   ema70 = iMA("AUDUSD",PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,shift+1);
   ema200 = iMA("AUDUSD",PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,shift+1);
   if (((ema5 > ema20 && ema20 > ema70 && ema70 > ema200)||(ema5 < ema20 && ema20 < ema70 && ema70 < ema200))) {
      before_aligned_count++;
   }
   if (before_aligned_count < 3) return true;
   else return false;
}
double PriceToPips(double price)
{
   double pips = 0;

   // 現在の通貨ペアの小数点以下の桁数を取得
   int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);

   // 3桁・5桁のFXブローカーの場合
   if(digits == 3 || digits == 5){
     pips = price * MathPow(10, digits) / 10;
   }
   // 2桁・4桁のFXブローカーの場合
   if(digits == 2 || digits == 4){
     pips = price * MathPow(10, digits);
   }
   // 少数点以下を１桁に丸める（目的によって桁数は変更する）
   pips = NormalizeDouble(pips, 1);

   return(pips);
}
 
 int wavyPhasenum (string symbol, int timeframe, int shift, int days) {
   int serialnums = serialNum(symbol,timeframe,days-1,shift+1);
   int minimum_serial = 3;

   //minimum_serial未満の連続だったら終了
   if (serialnums < minimum_serial) return 0;
   
   double pits_d[4];
   int highestPitIdx;
   int lowestPitIdx;
   double size;
   double z;
   double max = 0;
   int max_shift = shift;
   int candle_pos = getHeikenPosition(
   iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift),
   iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift),
   iIchimoku(symbol,timeframe,9,26,52,3,shift),
   iIchimoku(symbol,timeframe,9,26,52,4,shift)
   );
   int entity_type = getEntity(iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift),iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift));
   //雲の上なのに下降
   if (candle_pos == 2 && entity_type == 2) {
      return 0;
   }
   //雲の下なのに上昇
   if (candle_pos == 3 && entity_type == 1) {
      return 0;
   }
   for (int i=shift; i<=serialnums+shift; i++) {
      pits_d[0] = iCustom(symbol,timeframe,"HeikenAshi_DM",0,i);
      pits_d[1] = iCustom(symbol,timeframe,"HeikenAshi_DM",1,i);
      pits_d[2] = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i);
      pits_d[3] = iCustom(symbol,timeframe,"HeikenAshi_DM",3,i);

      highestPitIdx = ArrayMaximum(pits_d,WHOLE_ARRAY,0);
      lowestPitIdx = ArrayMinimum(pits_d,WHOLE_ARRAY,0);
      size = MathAbs(pits_d[highestPitIdx] - pits_d[lowestPitIdx]);
      if (size > max) {
         max = size;
         max_shift = i;
      }
   }
   int phase_cnt = 1;
   int paradigm_at = 0;
   int start_shift = max_shift;
   double d[4];
   d[0] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",0,max_shift);
   d[1] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",1,max_shift);
   d[2] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",2,max_shift);
   d[3] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",3,max_shift);
   int h = ArrayMaximum(d,WHOLE_ARRAY,0);
   int l = ArrayMinimum(d,WHOLE_ARRAY,0);
   double sizeday = MathAbs(d[h] - d[l]);
   double dailyZ = getDailyZ(symbol,sizeday,PERIOD_D1,31,max_shift);
   if (dailyZ < 2) return 0;
   while (paradigm_at != -1) {
      paradigm_at = decreasedAt(symbol,timeframe,start_shift,shift);
      if (paradigm_at != -1) {
         phase_cnt++;
         start_shift = paradigm_at;
      }
   }
   return phase_cnt;
}
int decreasedAt(string symbol,int timeframe,int starts, int ends) {
   double pits_d1[4];
   int highestPitIdx1;
   int lowestPitIdx1;
   double size1;
   double pits_d0[4];
   int highestPitIdx0;
   int lowestPitIdx0;
   double size0;
   for (int i=starts; i > ends; i--) {
      pits_d1[0] = iCustom(symbol,timeframe,"HeikenAshi_DM",0,i);
      pits_d1[1] = iCustom(symbol,timeframe,"HeikenAshi_DM",1,i);
      pits_d1[2] = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i);
      pits_d1[3] = iCustom(symbol,timeframe,"HeikenAshi_DM",3,i);
      highestPitIdx1 = ArrayMaximum(pits_d1,WHOLE_ARRAY,0);
      lowestPitIdx1 = ArrayMinimum(pits_d1,WHOLE_ARRAY,0);
      size1 = MathAbs(pits_d1[highestPitIdx1] - pits_d1[lowestPitIdx1]);
      pits_d0[0] = iCustom(symbol,timeframe,"HeikenAshi_DM",0,i-1);
      pits_d0[1] = iCustom(symbol,timeframe,"HeikenAshi_DM",1,i-1);
      pits_d0[2] = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i-1);
      pits_d0[3] = iCustom(symbol,timeframe,"HeikenAshi_DM",3,i-1);
      highestPitIdx0 = ArrayMaximum(pits_d0,WHOLE_ARRAY,0);
      lowestPitIdx0 = ArrayMinimum(pits_d0,WHOLE_ARRAY,0);
      size0 = MathAbs(pits_d0[highestPitIdx0] - pits_d0[lowestPitIdx0]);
      //大きくなった
      if (size0 > size1) {
         return i-1;
      }
   }
   return -1;
}
 int serialNum(string symbol,int period, int count, int shift) {
   double open = iCustom(symbol,period,"HeikenAshi_DM",2,shift);
   double close = iCustom(symbol,period,"HeikenAshi_DM",3,shift);
   int entity_type = getEntity(open,close);
   int prev_entity_type = entity_type;
   int serial_num = 1;
   for (int i=0; i<count;i++) {
      open = iCustom(symbol,period,"HeikenAshi_DM",2,i+shift+1);
      close = iCustom(symbol,period,"HeikenAshi_DM",3,i+shift+1);
      entity_type = getEntity(open,close);
      if (entity_type != prev_entity_type) return serial_num;
      serial_num++;
      prev_entity_type = entity_type;
   }
   return serial_num;
}
/**
* 0=nothing
* 1=up trend
* 2=dwn trend
**/
int heikenLikely(string symbol, int timeframe) {
   int examine_dates = 52;
   double leadingA;
   double leadingB;
   double open;
   double close;
   double upnum = 0;
   double dwnnum = 0;
   int candle_pos = 0;
   for (int i=0; i < examine_dates; i++) {
      open = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i);
      close = iCustom(symbol,timeframe,"HeikenAshi_DM",3,i);
      leadingA = iIchimoku(symbol,timeframe,9,26,52,3,i); //一目均衡(先行スパンA)
      leadingB = iIchimoku(symbol,timeframe,9,26,52,4,i); //一目均衡(先行スパンB)
      candle_pos = getHeikenPosition(open,close,leadingA,leadingB);
      if (candle_pos == 2) {
         upnum++;
      }else if(candle_pos == 3) {
         dwnnum++;
      }
   }
   double upratio = upnum/examine_dates;
   double dwnratio = dwnnum/examine_dates;
   if (upratio > 0.5) {
      return 1;
   }
   if (dwnratio > 0.5) {
      return 2;
   }
   return 0;
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
int daysEMA200Crossed (string symbol, int timeframe, int shift, int within) {
   int days_crossed = 0;
   bool crossed = false;
   double open_0 = iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift);
   double close_0 = iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift);
   int entitytype_0 = getEntity(open_0,close_0);
   double open_1;
   double close_1;
   int entitytype_1;
   
   for (int i=within+shift; i >= shift; i--){
      if (days_crossed == 0) {
         crossed = isEMA200Crossed(symbol,timeframe,i,within);
         if (crossed) {
            open_1 = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i);
            close_1 = iCustom(symbol,timeframe,"HeikenAshi_DM",3,i);
            entitytype_1 = getEntity(open_1,close_1);
            days_crossed = i - shift + 1;
         }
      }
   }
   
   if (days_crossed > 0 && entitytype_0 != entitytype_1 && !isCross(symbol,timeframe,shift)) {
      return 0;
   }
   return days_crossed;
}
bool isCross(string symbol,int timeframe, int shift) {
   double open = iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift);
   double close = iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift);
   int entity_type = getEntity(open, close);
   double high = 0;
   double low = 0;
   double hige_rev = 0;
   double hige_order = 0;
   if (entity_type == 1) {
      low = iCustom(symbol,timeframe,"HeikenAshi_DM",0,shift);
      high = iCustom(symbol,timeframe,"HeikenAshi_DM",1,shift);
      hige_rev = open - low;
      hige_order = high - close;
   }else if (entity_type == 2) {
      low = iCustom(symbol,timeframe,"HeikenAshi_DM",1,shift);
      high = iCustom(symbol,timeframe,"HeikenAshi_DM",0,shift);
      hige_rev = high - open;
      hige_order = close - low;
   }
   if (hige_rev != 0 && hige_order != 0) return true;
   return false;
}
bool isEMA200Crossed (string symbol, int timeframe, int shift, int within) {
   double open = iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift);
   double close = iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift);
   double ema200 = iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,shift);
   int ematype = emaType(symbol,timeframe,shift);
   int heiken = heikenLikely(symbol,timeframe);
   int entitytype = getEntity(open,close);
   //雲上昇で下降じゃないやつは無視
   if (heiken == 1 && entitytype != 2) return false;
   //雲下降で上昇じゃないやつは無視
   if (heiken == 2 && entitytype != 1) return false;
   if (ematype == 1) {
      if (open < ema200 && ema200 > close) {
         return false;
      }
   }else if (ematype == 2) {
      if (open > ema200 && ema200 > close) {
         return false;
      }
   }
   for (int i=shift+within; i >= shift; i--) {
      open = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i);
      close = iCustom(symbol,timeframe,"HeikenAshi_DM",3,i);
      ema200 = iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,i);
      if (ematype == 1) {
         if (open > close){
            if (open > ema200 && ema200 > close) {
               return true;
            }
         }
      }else if (ematype == 2) {
         if (open < close) {
            if (open < ema200 && ema200 < close) {
               return true;
            }
         }
      }
   }
   return false;
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

string correlation() {
   string filenames = "";
   string vals = "";
   int handler;
   double usdjpy[2500];
   double eurusd[2500];
   double gbpjpy[2500];
   double eurjpy[2500];
   double audusd[2500];
   double audjpy[2500];
   double nzdjpy[2500];
   int cnt = 0;
   for (int i=0; i<ArraySize(PAIRS); i++) {
      cnt = 0;
      filenames = PAIRS[i]+"_BIDS.csv";
      handler = FileOpen(filenames, FILE_CSV|FILE_READ|FILE_SHARE_READ, ',');
      while(!FileIsEnding(handler)){
         vals = FileReadNumber(handler);
         switch (i) {
            case 0://USDJPY
            usdjpy[cnt] = StringToDouble(vals);
            break;
            case 1://EURUSD
            eurusd[cnt] = StringToDouble(vals);
            break;
            case 2://GBPJPY
            gbpjpy[cnt] = StringToDouble(vals);
            break;
            case 3://EURJPY
            eurjpy[cnt] = StringToDouble(vals);
            break;
            case 4://AUDUSD
            audusd[cnt] = StringToDouble(vals);
            break;
            case 5://AUDJPY
            audjpy[cnt] = StringToDouble(vals);
            break;
            case 6://NZDJPY
            nzdjpy[cnt] = StringToDouble(vals);
            break;
            default:
            break;
          }
         cnt++;
         }
      FileClose(handler);
   }
   double usdjpy_eurjpy = getCorrelated(usdjpy,eurjpy);
   double usdjpy_eurusd = getCorrelated(usdjpy,eurusd);
   double usdjpy_gbpjpy = getCorrelated(usdjpy,gbpjpy);
   double usdjpy_audjpy = getCorrelated(usdjpy,audjpy);
   double usdjpy_audusd = getCorrelated(usdjpy,audusd);
   double usdjpy_nzdjpy = getCorrelated(usdjpy,nzdjpy);
   double eurjpy_eurusd = getCorrelated(eurjpy,eurusd);
   double eurjpy_gbpjpy = getCorrelated(eurjpy,gbpjpy);
   double eurjpy_audjpy = getCorrelated(eurjpy,audjpy);
   double eurjpy_audusd = getCorrelated(eurjpy,audusd);
   double eurjpy_nzdjpy = getCorrelated(eurjpy,nzdjpy);
   double eurusd_gbpjpy = getCorrelated(eurusd,gbpjpy);
   double eurusd_audjpy = getCorrelated(eurusd,audjpy);
   double eurusd_audusd = getCorrelated(eurusd,audusd);
   double eurusd_nzdjpy = getCorrelated(eurusd,nzdjpy);
   double gbpjpy_audjpy = getCorrelated(gbpjpy,audjpy);
   double gbpjpy_audusd = getCorrelated(gbpjpy,audusd);
   double gbpjpy_nzdjpy = getCorrelated(gbpjpy,nzdjpy);
   double audjpy_audusd = getCorrelated(audjpy,audusd);
   double audjpy_nzdjpy = getCorrelated(audjpy,nzdjpy);
   double audusd_nzdjpy = getCorrelated(audusd,nzdjpy);
   string cc_str = "CC: "+
   " usdjpy_eurjpy="+StringSubstr(usdjpy_eurjpy,0,4)+
   " usdjpy_eurusd="+StringSubstr(usdjpy_eurusd,0,4)+
   " usdjpy_gbpjpy="+StringSubstr(usdjpy_gbpjpy,0,4)+
   " usdjpy_audjpy="+StringSubstr(usdjpy_audjpy,0,4)+
   " usdjpy_audusd="+StringSubstr(usdjpy_audusd,0,4)+
   " usdjpy_nzdjpy="+StringSubstr(usdjpy_nzdjpy,0,4)+
   " eurjpy_eurusd="+StringSubstr(eurjpy_eurusd,0,4)+
   " eurjpy_gbpjpy="+StringSubstr(eurjpy_gbpjpy,0,4)+
   " eurjpy_audjpy="+StringSubstr(eurjpy_audjpy,0,4)+
   " eurjpy_audusd="+StringSubstr(eurjpy_audusd,0,4)+
   " eurjpy_nzdjpy="+StringSubstr(eurjpy_nzdjpy,0,4)+
   " eurusd_gbpjpy="+StringSubstr(eurusd_gbpjpy,0,4)+
   " eurusd_audjpy="+StringSubstr(eurusd_audjpy,0,4)+
   " eurusd_audusd="+StringSubstr(eurusd_audusd,0,4)+
   " eurusd_nzdjpy="+StringSubstr(eurusd_nzdjpy,0,4)+
   " gbpjpy_audjpy="+StringSubstr(gbpjpy_audjpy,0,4)+
   " gbpjpy_audusd="+StringSubstr(gbpjpy_audusd,0,4)+
   " gbpjpy_nzdjpy="+StringSubstr(gbpjpy_nzdjpy,0,4)+
   " audjpy_audusd="+StringSubstr(audjpy_audusd,0,4)+
   " audjpy_nzdjpy="+StringSubstr(audjpy_nzdjpy,0,4)+
   " audusd_nzdjpy="+StringSubstr(audusd_nzdjpy,0,4);
   return cc_str;
}

double mean(double &data[], bool ignoremax, bool ignoremin, bool abs) {
   double sum = 0;
   int count = 0;
   int maxidx = ArrayMaximum(data,WHOLE_ARRAY,0);
   int minidx = ArrayMinimum(data,WHOLE_ARRAY,0);
   for (int i=0; i<ArraySize(data);i++) {
      if(abs) sum += MathAbs(data[i]);
      else sum += data[i];
      count++;
   }
   if (ignoremax) {
      if (abs) sum -= MathAbs(data[maxidx]);
      else sum -= data[maxidx];
      count--;
   }
   if (ignoremin) {
      if (abs) sum -= MathAbs(data[minidx]);
      else sum -= data[minidx];
      count--;
   }
   double mean = sum/count;
   return mean;
}

int countEqual(int &data[],int assert) {
   int count = 0;
   for (int i=0; i<ArraySize(data);i++) {
      if(data[i] == assert) count++;
   }
   return count;
}

int countLargerOrEqual(double &data[],double assert) {
   int count = 0;
   for (int i=0; i<ArraySize(data);i++) {
      if(data[i] >= assert) count++;
   }
   return count;
}

int countLargerOrEqual(int &data[],int assert) {
   int count = 0;
   for (int i=0; i<ArraySize(data);i++) {
      if(data[i] >= assert) count++;
   }
   return count;
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

int sumInteger(int &sample[]) {
   int sum = 0;
   for (int i=0; i<ArraySize(sample); i++) {
      sum += sample[i];
   }
   return sum;
}

double getCorrelated (double &bids[],double &times[]) {
   double bidSum = 0;
   double timeSum = 0;
   double volProduct = 0;
   int count = 0;
   double VOL[2500];

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
   return CC;

}

double difference(double prev, double current) {
   if (prev >= current) {
      return 0;
   }else{
      return MathAbs(current - prev);
   }
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
 int sendEMA(string pair, double value) {
   int WebR;
   string URL = "http://localhost/ema";
   int timeout = 5000;
   string cookie = NULL,headers;
   char post[],FTPdata[];
   string str= "&pair="+pair+"&ema="+value;

   StringToCharArray( str, post );
   WebR = WebRequest( "POST", URL, cookie, NULL, timeout, post, 0, FTPdata, headers );
   return(WebR);
}

 int sendChange(string pair, double value) {
   int WebR;
   string URL = "http://localhost/transit";
   int timeout = 5000;
   string cookie = NULL,headers;
   char post[],FTPdata[];
   string str= "&pair="+pair+"&change="+value;

   StringToCharArray( str, post );
   WebR = WebRequest( "POST", URL, cookie, NULL, timeout, post, 0, FTPdata, headers );
   return(WebR);
}

double getSizeChange(int before, int after, bool fullsize, int period, string symbol) {
   double entity[4];
   double entity1[4];
   double open1 = iCustom(symbol,period,"HeikenAshi_DM",2,before);
   double close1 = iCustom(symbol,period,"HeikenAshi_DM",3,before);
   double open2 = iCustom(symbol,period,"HeikenAshi_DM",2,after);
   double close2 = iCustom(symbol,period,"HeikenAshi_DM",3,after);
   if (fullsize) {
      double low2 = iCustom(symbol,period,"HeikenAshi_DM",0,after);
      double high2 = iCustom(symbol,period,"HeikenAshi_DM",1,after);
      entity[0] = open2;
      entity[1] = close2;
      entity[2] = low2;
      entity[3] = high2;
      int highestIdx = ArrayMaximum(entity,WHOLE_ARRAY,0);
      double highest = entity[highestIdx];
      int lowestIdx = ArrayMinimum(entity,WHOLE_ARRAY,0);
      double lowest = entity[lowestIdx];

      double low1 = iCustom(symbol,period,"HeikenAshi_DM",0,before);
      double high1 = iCustom(symbol,period,"HeikenAshi_DM",1,before);
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

double getDailyZDiff (string symbol) {
    int threshold = 1;
    double pits_d[4];
    pits_d[0] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",0,0);
    pits_d[1] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",1,0);
    pits_d[2] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",2,0);
    pits_d[3] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",3,0);
    int highestPitIdx = ArrayMaximum(pits_d,WHOLE_ARRAY,0);
    int lowestPitIdx = ArrayMinimum(pits_d,WHOLE_ARRAY,0);
    double sizeday = MathAbs(pits_d[highestPitIdx] - pits_d[lowestPitIdx]);
    double dailyZ = getDailyZ(symbol,sizeday,PERIOD_D1,31,0);
    pits_d[0] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",0,1);
    pits_d[1] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",1,1);
    pits_d[2] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",2,1);
    pits_d[3] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",3,1);
    highestPitIdx = ArrayMaximum(pits_d,WHOLE_ARRAY,0);
    lowestPitIdx = ArrayMinimum(pits_d,WHOLE_ARRAY,0);
    sizeday = MathAbs(pits_d[highestPitIdx] - pits_d[lowestPitIdx]);
    double last_dailyZ = getDailyZ(symbol,sizeday,PERIOD_D1,31,1);
    return MathAbs(dailyZ - last_dailyZ);
}

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

double getHigeRatio (string symbol) {
    double open = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",2,0);
    double close = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",3,0);
    int entity_type = getEntity(open, close);
    double high = 0;
    double low = 0;
    double hige_rev = 0;
    double hige_order = 0;
    if (entity_type == 1) {
       low = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",0,0);
       high = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",1,0);
       hige_rev = open - low;
       hige_order = high - close;
    }else if (entity_type == 2) {
       low = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",1,0);
       high = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",0,0);
       hige_rev = high - open;
       hige_order = close - low;
    }
    if (hige_order != 0) return hige_rev/hige_order;
    return 0;
}

double getDailyZ(string symbol, double sample, int timeshift, int count, int shift) {
   double sum = 0;
   double devsum = 0;
   double pits[4];
   int highestIdx = 0;
   int lowestIdx = 0;

   for (int i=0+shift; i<count+shift; i++) {
      pits[0] = iCustom(symbol,timeshift,"HeikenAshi_DM",0,i);
      pits[1] = iCustom(symbol,timeshift,"HeikenAshi_DM",1,i);
      pits[2] = iCustom(symbol,timeshift,"HeikenAshi_DM",2,i);
      pits[3] = iCustom(symbol,timeshift,"HeikenAshi_DM",3,i);
      highestIdx = ArrayMaximum(pits,WHOLE_ARRAY,0);
      lowestIdx = ArrayMinimum(pits,WHOLE_ARRAY,0);
      sum += MathAbs(pits[highestIdx] - pits[lowestIdx]);
   }

   double daily_mean = sum/count;
   for (int i=0; i<count; i++) {
      pits[0] = iCustom(symbol,timeshift,"HeikenAshi_DM",0,i);
      pits[1] = iCustom(symbol,timeshift,"HeikenAshi_DM",1,i);
      pits[2] = iCustom(symbol,timeshift,"HeikenAshi_DM",2,i);
      pits[3] = iCustom(symbol,timeshift,"HeikenAshi_DM",3,i);
      highestIdx = ArrayMaximum(pits,WHOLE_ARRAY,0);
      lowestIdx = ArrayMinimum(pits,WHOLE_ARRAY,0);
      devsum += MathPow((
         (MathAbs(pits[highestIdx] - pits[lowestIdx]))-daily_mean
       ),2);
   }
   double variance = devsum/count;
   double daily_std = MathSqrt(variance);
   return MathCeil(((sample - daily_mean)/daily_std) * 100) * 1.0/100;
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

bool isStable(string symbol) {
   int change0 = (int)getSizeChange(1,0,false,PERIOD_M5,symbol);
   int change1 = (int)getSizeChange(2,1,false,PERIOD_M5,symbol);
   int change2 = (int)getSizeChange(3,2,false,PERIOD_M5,symbol);
      if (change0 == 1 && change1 == 1 && change2 == 1) {
         return true;
      }
   return false;
}

/**
* 0=no trend
* 1=upward
* 2=downward
**/
int emaType(string symbol, int timeframe, int shift) {
   double ema20 = iMA(symbol,timeframe,20,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(20)
   double ema70 = iMA(symbol,timeframe,70,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(70)
   double ema200 = iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,shift);//指数移動平均(200)
   if (ema20 > ema70 && ema70 > ema200) {
      return 1;
   }else if (ema20 < ema70 && ema70 < ema200) {
      return 2;
   }
   return 0;
}

bool isEMAStrong(string symbol, int timeframe, int shift) {
   double ema5 = iMA(symbol,timeframe,5,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(5);
   double ema20 = iMA(symbol,timeframe,20,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(20)
   double ema70 = iMA(symbol,timeframe,70,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(70)
   double ema200 = iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,shift);//指数移動平均(200)
   bool strong = false;
   if (ema5 > ema20 && ema20 > ema70 && ema70 > ema200) {
      strong = true;
   }else if (ema5 < ema20 && ema20 < ema70 && ema70 < ema200) {
      strong = true;
   }
   if (strong) return true;
   return false;
}

int hasSignal(int shift) {
   int weight = 0;
   int weight_u = 0;
   double threshold = 0.4;
   string text = "";
   if (isCorrelated("AUDJPY","NZDJPY",shift,threshold) == 1) {
      text += "a/n,";
      weight++;
   }
   if (isCorrelated("AUDJPY","USDJPY",shift,threshold) == 1) {
      text += "a/u,";
      weight++;
      weight_u++;
   }
   if (isCorrelated("AUDJPY","EURJPY",shift,threshold) == 1) {
      text += "a/e,";
      weight++;
   }
   if (isCorrelated("AUDJPY","GBPJPY",shift,threshold) == 1) {
      text += "a/g,";
      weight++;
   }
   if (isCorrelated("USDJPY","NZDJPY",shift,threshold) == 1) {
      text += "u/n,";
      weight++;
      weight_u++;
   }
   if (isCorrelated("USDJPY","EURJPY",shift,threshold) == 1) {
      text += "u/e,";
      weight++;
      weight_u++;
   }
   if (isCorrelated("USDJPY","GBPJPY",shift,threshold) == 1) {
      text += "u/g,";
      weight++;
      weight_u++;
   }
   if (isCorrelated("EURJPY","NZDJPY",shift,threshold) == 1) {
      text += "e/n,";
      weight++;
   }
   if (isCorrelated("EURJPY","GBPJPY",shift,threshold) == 1) {
      text += "e/g,";
      weight++;
   }
   if (isCorrelated("GBPJPY","NZDJPY",shift,threshold) == 1) {
      text += "g/n,";
      weight++;
   }
   
   if (weight < 6) {
      return 0;
   }
   
   if (weight_u < 3) {
      return 0;
   }
   
   string ema_pairs = "";
   
   int ema_strength = 0;
   if (isEMAStrong("AUDJPY",PERIOD_M5,shift)) {
      ema_pairs += "aud,";
      ema_strength++;
   }
   if (isEMAStrong("NZDJPY",PERIOD_M5,shift)) {
      ema_pairs += "nzd,";
      ema_strength++;
   }
   if (isEMAStrong("USDJPY",PERIOD_M5,shift)) {
      ema_pairs += "usd,";
      ema_strength++;
   }
   if (isEMAStrong("EURJPY",PERIOD_M5,shift)) {
      ema_pairs += "eur,";
      ema_strength++;
   }
   if (isEMAStrong("GBPJPY",PERIOD_M5,shift)) {
      ema_pairs += "gbp,";
      ema_strength++;
   }
   
   if (ema_strength < 4) return 0;
   
   if (!strong_trend_alert) {
      //slackprivate("possible trend StrongCCnum="+weight+"/10 alignedEMAnum="+ema_strength+"/5");
      strong_trend_alert = true;
   }
   return 1;
   
   
}

bool isCorrelated(string symbol1, string symbol2, int shift, double threshold) {
   int count = 30;
   
   double ema5_1[30];
   double ema20_1[30];
   double ema70_1[30];
   double ema200_1[30];
   double ema5_2[30];
   double ema20_2[30];
   double ema70_2[30];
   double ema200_2[30];

   int counter = 0;
   for (int i=count+shift; i > shift; i--) {
      ema5_1[counter] = iMA(symbol1,PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,i);
      ema20_1[counter] = iMA(symbol1,PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,i);
      ema70_1[counter] = iMA(symbol1,PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,i);
      ema200_1[counter] = iMA(symbol1,PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,i);
      ema5_2[counter] = iMA(symbol2,PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,i);
      ema20_2[counter] = iMA(symbol2,PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,i);
      ema70_2[counter] = iMA(symbol2,PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,i);
      ema200_2[counter] = iMA(symbol2,PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,i);
      counter++;
   }
   
   if (getCorrelated(ema5_1,ema5_2) > threshold &&
   getCorrelated(ema20_1,ema20_2) > threshold &&
   getCorrelated(ema70_1,ema70_2) > threshold &&
   getCorrelated(ema200_1,ema200_2) > threshold
   ) {
      return true;
   }
   return false;
}


/**
 * 次の日強さ取得取得
 */
void isBadday(){
   int uj = serialNum("USDJPY",PERIOD_D1,50,0);
   int eu = serialNum("EURUSD",PERIOD_D1,50,0);
   int gj = serialNum("GBPJPY",PERIOD_D1,50,0);
   int ej = serialNum("EURJPY",PERIOD_D1,50,0);
   int au = serialNum("AUDUSD",PERIOD_D1,50,0);
   int aj = serialNum("AUDJPY",PERIOD_D1,50,0);
   int nj = serialNum("NZDJPY",PERIOD_D1,50,0);
   
   Print("uj="+uj+" eu="+eu+" gj="+gj+" ej="+ej+" au="+au+" aj="+aj+" nj="+nj);
   
   int WebR;
   string URL = "http://192.168.11.69:8000/api/predict";
   int timeout = 5000;
   string cookie = NULL,headers;
   char post[],result[];
   string str= "&uj="+uj+"&eu="+eu+"&gj="+gj+"&ej="+ej+"&au="+au+"&aj="+aj+"&nj="+nj;

   StringToCharArray( str, post );
   WebR = WebRequest( "GET", URL, cookie, NULL, timeout, post, 0, result, headers );
   if(WebR == -1)
     {
      //Print("Error in WebRequest. Error code  =",GetLastError());
      MessageBox("Add the address '"+URL+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
        string json = CharArrayToString(result);
        Print(json);
     }
}