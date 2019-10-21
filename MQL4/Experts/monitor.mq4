#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string PAIRS[] = {"USDJPY","EURUSD","GBPJPY","EURJPY","AUDUSD","AUDJPY","NZDJPY"};
bool alert_period = false;
string logs = "";
bool alert_by_cloud = true;
bool bad_cloud = false;
bool initializing = true;
bool xl_alert = true;
bool trend_alert = false;
bool xl_alert2 = false;
bool daily_big_alert = false;
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
datetime xl_alert_at = TimeCurrent();
datetime trend_alert_at = TimeCurrent();
int uj_xl = 0;
int eu_xl = 0;
int gj_xl = 0;
int ej_xl = 0;
int au_xl = 0;
int aj_xl = 0;
int nj_xl = 0;
bool uj_big = false;
bool eu_big = false;
bool gj_big = false;
bool ej_big = false;
bool au_big = false;
bool aj_big = false;
bool nj_big = false;
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
   double zcloud[7];
   double zcloud1[7];
   double zcloud2[7];
   double zcloud3[7];
   double zcloud4[7];
   double zcloud5[7];
   double zcloud6[7];
   double zcloud7[7];
   double zcloud8[7];
   double zcloud9[7];
   double zcloud10[7];
   double zcloud11[7];
   double zcloud12[7];
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

   if (elapsed >= 60) elapsed = 0;

   if (initializing) {
       slack("initializing...");
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
            case 2://cloud size
            zcloud[i] = StringToDouble(val);
            break;
            case 3:
            zcloud1[i] = StringToDouble(val);
            break;
            case 4:
            zcloud2[i] = StringToDouble(val);
            break;
            case 5:
            zcloud3[i] = StringToDouble(val);
            break;
            case 6:
            zcloud4[i] = StringToDouble(val);
            break;
            case 7:
            zcloud5[i] = StringToDouble(val);
            break;
            case 8:
            zcloud6[i] = StringToDouble(val);
            break;
            case 9:
            zcloud7[i] = StringToDouble(val);
            break;
            case 10:
            zcloud8[i] = StringToDouble(val);
            break;
            case 11:
            zcloud9[i] = StringToDouble(val);
            break;
            case 12:
            zcloud10[i] = StringToDouble(val);
            break;
            case 13:
            zcloud11[i] = StringToDouble(val);
            break;
            case 14:
            zcloud12[i] = StringToDouble(val);
            break;
            case 15://elaspedstrong
            serialelapsed[i] = StringToInteger(val);
            break;
            case 16://hige
            hige[i] = StringToDouble(val);
            break;
            case 17://tick_cnt
            ticks[i] = StringToDouble(val);
            break;
            case 18://phase
            phase[i] = StringToInteger(val);
            break;
            case 19://daily type
            dtype[i] = StringToInteger(val);
            break;
            case 20://daily pos
            dpos[i] = StringToInteger(val);
            break;
            case 21://daily z
            dz[i] = StringToDouble(val);
            break;
            case 22://daily cross
            dcross[i] = StringToDouble(val);
            break;
            case 23://xl cross
            xl[i] = StringToInteger(val);
            break;
            case 24://serial entity and different type comes after
            potentialTrend[i] = StringToInteger(val);
            break;
            case 25://atr
            atr[i] = StringToDouble(val);
            break;
            case 26://larger
            larger[i] = StringToDouble(val);
            break;
            case 27://fading
            fading[i] = StringToInteger(val);
            break;
            case 28://band
            band[i] = StringToInteger(val);
            break;
            case 29://apex
            apex[i] = StringToInteger(val);
            break;
            case 30://band changed
            band_changed[i] = StringToInteger(val);
            break;
            case 31://z-score diff
            diff[i] = StringToDouble(val);
            break;
            case 32://serial num
            serial_candle[i] = StringToInteger(val);
            break;
            case 33://abrupt mu
            abrupt_mu[i] = StringToDouble(val);
            break;
            case 34://larger day
            larger_d[i] = StringToDouble(val);
            break;
            case 35://abrupt pos
            abrupt_pos[i] = StringToInteger(val);
            break;
            case 36://abrupt neg
            abrupt_neg[i] = StringToInteger(val);
            break;
            case 37://daily event
            devent[i] = StringToInteger(val);
            break;
            case 38://3mcc
            cc3m[i] = StrToDouble(val);
            break;
            case 39://bad bigs
            badbigs[i] = StringToInteger(val);
            break;
            case 40://5m event
            event5m[i] = StringToInteger(val);
            break;
            case 41://covariance
            covariance[i] = StringToDouble(val);
            break;
            case 42://period
            period[i] = StringToDouble(val);
            break;
            case 43://isPeriodic
            isPeriodic[i] = StringToInteger(val);
            break;
            case 44://time
            hit1[i] = StringToInteger(val);
            break;
            case 45://time
            hit2[i] = StringToInteger(val);
            break;
            case 46://big after
            big_after[i] = StringToInteger(val);
            break;
            case 47://ema5
            ema5[i] = StringToDouble(val);
            break;
            case 48://last3z
            last3z[i] = StringToDouble(val);
            break;
            case 49://was walking
            good_walk[i] = StringToInteger(val);
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
   double cloudmu = mean(zcloud,true,false,false);
   logs += " cloud="+StringSubstr(cloudmu,0,5);

   double zcloudmu[12];
   zcloudmu[0] = mean(zcloud1,true,false,false);
   zcloudmu[1] = mean(zcloud2,true,false,false);
   zcloudmu[2] = mean(zcloud3,true,false,false);
   zcloudmu[3] = mean(zcloud4,true,false,false);
   zcloudmu[4] = mean(zcloud5,true,false,false);
   zcloudmu[5] = mean(zcloud6,true,false,false);
   zcloudmu[6] = mean(zcloud7,true,false,false);
   zcloudmu[7] = mean(zcloud8,true,false,false);
   zcloudmu[8] = mean(zcloud9,true,false,false);
   zcloudmu[9] = mean(zcloud10,true,false,false);
   zcloudmu[10] = mean(zcloud11,true,false,false);
   zcloudmu[11] = mean(zcloud12,true,false,false);
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

   string next_clouds =
   "5="+StringSubstr(zcloudmu[0],0,5)+
   " 10="+StringSubstr(zcloudmu[1],0,5)+
   " 15="+StringSubstr(zcloudmu[2],0,5)+
   " 20="+StringSubstr(zcloudmu[3],0,5)+
   " 25="+StringSubstr(zcloudmu[4],0,5)+
   " 30="+StringSubstr(zcloudmu[5],0,5)+
   " 35="+StringSubstr(zcloudmu[6],0,5)+
   " 40="+StringSubstr(zcloudmu[7],0,5)+
   " 45="+StringSubstr(zcloudmu[8],0,5)+
   " 50="+StringSubstr(zcloudmu[9],0,5)+
   " 55="+StringSubstr(zcloudmu[10],0,5)+
   " 60="+StringSubstr(zcloudmu[11],0,5);

   bool growing = cloudmu < -1 && (
   zcloudmu[0] > -1 ||
   zcloudmu[1] > -1 ||
   zcloudmu[2] > -1 ||
   zcloudmu[3] > -1 ||
   zcloudmu[4] > -1 ||
   zcloudmu[5] > -1
   );

   logs += " growing="+growing;

   if (growing || cloudmu > -1) {
     if (alert_by_cloud) {
      //slack("CLOUD GROWING size="+StringSubstr(cloudmu,0,4));
      //Alert("CLOUD GROWING size="+StringSubstr(cloudmu,0,4));
      alert_by_cloud = false;
      bad_cloud = true;
      }
   }else{
      alert_by_cloud = true;
      if (bad_cloud && cloudmu < -1) {
         //slack("END OF BADCLOUD size="+StringSubstr(cloudmu,0,4));
         //Alert("END OF BADCLOUD size="+StringSubstr(cloudmu,0,4));
         bad_cloud = false;
      }
   }
   
   double period_mu = mean(period,false,false,false);

   string strong_elapsed =
   "USDJPY="+serialelapsed[0]+
   " EURUSD="+serialelapsed[1]+
   " GBPJPY="+serialelapsed[2]+
   " EURJPY="+serialelapsed[3]+
   " AUDUSD="+serialelapsed[4]+
   " AUDJPY="+serialelapsed[5]+
   " NZDJPY="+serialelapsed[6];
   
   string big_after_str =
   "USDJPY="+big_after[0]+
   " EURUSD="+big_after[1]+
   " GBPJPY="+big_after[2]+
   " EURJPY="+big_after[3]+
   " AUDUSD="+big_after[4]+
   " AUDJPY="+big_after[5]+
   " NZDJPY="+big_after[6];

   
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
      slackprivate("DAILY BIG");
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
   if (devent[0] + devent[1] + devent[2] + devent[3] + devent[4] + devent[5] + devent[6] != 0) {
       daily_event_str = "*"+daily_event_str+"*";
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
      slackprivate("BIGS="+total_bad_bigs);
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
   "USDJPY="+serial_candle[0]+
   " EURUSD="+serial_candle[1]+
   " GBPJPY="+serial_candle[2]+
   " EURJPY="+serial_candle[3]+
   " AUDUSD="+serial_candle[4]+
   " AUDJPY="+serial_candle[5]+
   " NZDJPY="+serial_candle[6];
   
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
         if (growing_str != "") slackprivate("ZD incr.."+growing_str);
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

   band_changed_num += countEqual(band_changed,1);
   datetime current = TimeCurrent();
   if (elapsed%15 == 0) {
       int seconds = TimeSeconds(TimeLocal());
       //slack("at:"+seconds+" CLOUDS: "+next_clouds);
       //slack("trend: "+trend);
       //slack("phase: "+phase_str);
       //slack("xls: "+xl_str);
       slack("evd: "+daily_event_str);
       //slack("ev5: "+minute5_event_str);
       //slack("xxx: "+larger_d_str);
       slack("z-d: "+daily_z_str);
       slack("zdm: "+StringSubstr(mean(dz,false,false,false),0,4));
       //slack("z-5: "+last3z_str);
       //slack("R3m: "+cc_str);
       //slack("pos: "+pos_str);
       //slack("neg: "+neg_str);
       //slack("hig: "+hige_total);
       //slack("x: "+times_larger);
       slack("seq: "+serials_str);
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
       slack("evts 9-10="+(nine_to_ten_evt/10000)+" latest="+(latest_evts/10000));
       //slack("houlyCV="+hourly_cv+" dailyCV="+daily_cv);
       //slack("at="+current+" asc="+asc+" dsc="+dsc);
       //slack("apexes="+apex_num+" band changed="+band_changed_num);
       apex_num = 0;
       prev_xl_ratio = ratio;
       //send daily change rate to local api
   }

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
   logs += " evt[0]="+latest_evt[0]+" evt[1]="+latest_evt[1]+" evt[2]="+latest_evt[2]+" evt[3]="+latest_evt[3]+" sum="+latest_evts;
   Print(logs);
   //Print("CLOUDS: "+next_clouds);
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
