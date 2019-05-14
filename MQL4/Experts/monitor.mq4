#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string PAIRS[] = {"USDJPY","EURUSD","GBPJPY","EURJPY","AUDUSD","AUDJPY","NZDJPY"};
string logs = "";
bool alert_by_cloud = true;
bool bad_cloud = false;
bool initializing = true;
bool xl_alert = true;
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
int uj_xl = 0;
int eu_xl = 0;
int gj_xl = 0;
int ej_xl = 0;
int au_xl = 0;
int aj_xl = 0;
int nj_xl = 0;
int asc = 0;
int dsc = 0;
int prev_asc = 0;
int prev_dsc = 0;

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
            default:
            break;
         }
         cnt++;
      }
      FileClose(handle);
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
   
   string strong_elapsed =
   "USDJPY="+serialelapsed[0]+
   " EURUSD="+serialelapsed[1]+
   " GBPJPY="+serialelapsed[2]+
   " EURJPY="+serialelapsed[3]+
   " AUDUSD="+serialelapsed[4]+
   " AUDJPY="+serialelapsed[5]+
   " NZDJPY="+serialelapsed[6];
   
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
   
   if (xl[0] > 0) {
      if (xl[0] == 1) asc++;
      if (xl[0] == 2) dsc++;
      uj_xl++;
   }
   if (xl[1] > 0) {
      if (xl[1] == 1) asc++;
      if (xl[1] == 2) dsc++;
      eu_xl++;
   }
   if (xl[2] > 0) {
      if (xl[2] == 1) asc++;
      if (xl[2] == 2) dsc++;
      gj_xl++;
   }
   if (xl[3] > 0) {
      if (xl[3] == 1) asc++;
      if (xl[3] == 2) dsc++;
      ej_xl++;
   }
   if (xl[4] > 0) {
      if (xl[4] == 1) asc++;
      if (xl[4] == 2) dsc++;
      au_xl++;
   }
   if (xl[5] > 0) {
      if (xl[5] == 1) asc++;
      if (xl[5] == 2) dsc++;
      aj_xl++;
   }
   if (xl[6] > 0) {
      if (xl[6] == 1) asc++;
      if (xl[6] == 2) dsc++;
      nj_xl++;
   }
   if (prev_asc > prev_dsc) {
      if (dsc > prev_dsc) {
         slackprivate("converting to DSC");
      }
   }else{
      if (asc > prev_asc) {
         slackprivate("converting to ASC");
      }
   }
   
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

   if (elapsed%15 == 0) {
       int seconds = TimeSeconds(TimeLocal());
       slack("at:"+seconds+" CLOUDS: "+next_clouds);
       slack("trend: "+trend);
       //slack("phase: "+phase_str);
       //slack("xls: "+xl_str);
       //slack("hige: "+hige_total);
       slack("asc="+asc+" dsc="+dsc);
   }
   
   if (elapsed%5 == 0) {
       string cc = correlation();
       //slack("at:"+seconds+" CLOUDS: "+next_clouds);
       //slack(cc);
       //Print(cc);
       for (int i=0; i<ArraySize(PAIRS); i++) {
         filename = PAIRS[i]+"_BIDS.csv";
         if (FileIsExist(filename)) {
            FileDelete(filename);
         }
       }
   }
   datetime current = TimeCurrent();
   int xl_alert_interval = (current - xl_alert_at)/60;
   if (xl_alert_interval > 60 && xl_alert) {
      slackprivate("60m since xl.");
      xl_alert = false;
   }
   int xl_num = countEqual(xl,1);
   if (xl_num > 0) {
      if (!xl_alert) {
         slackprivate("60m-xl broken.");
      }
      exportData("XL","",true);
      xl_alert_at = TimeCurrent();
      xl_alert = true;
   }else{
      FileDelete("XL.csv");
   }
   elapsed++;
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