#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string PAIRS[] = {"USDJPY","EURUSD","GBPJPY","EURJPY","AUDUSD","AUDJPY","NZDJPY"};
string logs = "";
string goodpairs = "";
bool will_alert = true;
bool alert_by_pos = true;
bool alert_by_trend = true;
bool alert_by_future = true;
bool alert_by_size = true;
bool alert_by_cloud = true;
bool alert_by_apex = true;
bool alert_by_std = true;
bool alert_by_tickdelta = true;
bool alert_by_band = true;
bool alert_by_incloud = true;
bool walking = false;
bool trend = false;
bool expanded = false;
bool bad_cloud = false;
bool band = false;
bool incloud = false;
double prev_3mR = 0;
int last_alert = 0;
int elapsed = 0;

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
   goodpairs = "";
   string filename = "";
   string val = "";
   int handle;
   double z[7];
   double z30[7];
   double zcloud[7];
   double zcloudfuture[7];
   double R3m[7];
   int candlepos[7];
   int inband[7];

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
            case 3://candle position
            candlepos[i] = StringToDouble(val);
            break;
            case 4://inBand
            inband[i] = StringToInteger(val);
            break;
            case 5://futurecloud size
            zcloudfuture[i] = StringToDouble(val);
            break;
            case 6://3mR
            R3m[i] = StringToDouble(val);
            break;
            default:
            break;
         }
         cnt++;
      }
      FileClose(handle);
   }

   //bool isGoodCandlePos = stableCandlePos("pos",candlepos,5);
   bool isInCloud = inCloud("incloud",candlepos,1);
   bool isGoodBand = stableBand("band",inband,6);
   double r3mmu = mean("3mR",R3m,false,true,true);
   int posnum = posnum(R3m);
   int negnum = negnum(R3m);
   logs += " pos="+posnum+" neg="+negnum;
   mean("3mRA",R3m,false,false,true);
   double z30mu = mean("z30",z30,true,false,false);
   double cloudmu = mean("zcloud",zcloud,true,false,false);
   double futurecloudmu = mean("zcloud-future",zcloudfuture,true,false,false);
/*
    if (isInCloud && cloudmu > -1) {
      if (alert_by_incloud) {
         slackprivate("IN CLOUD");
         Alert("IN CLOUD");
         alert_by_incloud = false;
      }
      incloud = true;
   }else{
      if (incloud) {
         slackprivate("OUT OF CLOUD");
         Alert("OUT OF CLOUD");
      }
      incloud = false;
      alert_by_incloud = true;
   }
   
   if (futurecloudmu < -1 ) {
      if (alert_by_future) {
      int hour = (TimeHour(TimeLocal()))+1;
      int minute = TimeMinute(TimeLocal());
      string time = hour+":"+minute;
      slackprivate("CLOUD SHRINKS AT="+time+" size="+StringSubstr(futurecloudmu,0,4));
      Alert("CLOUD SHRINKS AT="+time+" size="+StringSubstr(futurecloudmu,0,4));
      alert_by_future = false;
      }
   }else{
      alert_by_future = true;
   }
   
     */
   if (cloudmu > -1 ) {
     if (alert_by_cloud) {
      slack("BADCLOUD size="+StringSubstr(cloudmu,0,4)+" goneIn1H="+(futurecloudmu < -1));
      Alert("BADCLOUD size="+StringSubstr(cloudmu,0,4)+" goneIn1H="+(futurecloudmu < -1));
      alert_by_cloud = false;
      bad_cloud = true;
      }
     if (elapsed == 60) {
      slack("stillBad size="+StringSubstr(cloudmu,0,4)+" goneIn1H="+(futurecloudmu < -1));
      Alert("stillBad size="+StringSubstr(cloudmu,0,4)+" goneIn1H="+(futurecloudmu < -1));
      elapsed = 0;
     }
     elapsed++;
   }else{
      alert_by_cloud = true;
      if (bad_cloud) {
         slack("END OF BADCLOUD size="+StringSubstr(cloudmu,0,4));
         Alert("END OF BADCLOUD size="+StringSubstr(cloudmu,0,4));
         bad_cloud = false;
      }
   }
 
   /*
   if (cloudmu < -1 && (posnum > 5 || negnum > 5) && r3mmu > 0.8) {
     if (alert_by_trend) {
      slack("TESTTREND R="+StringSubstr(r3mmu,0,4));
      Alert("TESTTREND R="+StringSubstr(r3mmu,0,4));
      alert_by_trend = false;
      }
   }else{
      alert_by_trend = true;
   }
     */
   Print(logs);
  }



int timeIterator(int &time[]) {
   int current = TimeCurrent();
   int elapsed = 10;
   int stopper = ArraySize(time)+1;
   for (int i=0; i<ArraySize(time);i++) {
      elapsed = current - time[i];
      //1分以内
      if (elapsed < 60){
         return i;
      }
   }
   return stopper;
}

bool stableCandlePos(string prefix, int &pos[], int minimum) {
   int num = 0;
   for (int i=0; i<ArraySize(pos);i++) {
      if (pos[i] == 2 || pos[i] == 3){
         num++;
      }
   }
   logs += " posnum="+num+" min="+minimum;
   if (num > minimum)return(true);
   else return(false);
}

bool inCloud(string prefix, int &pos[], int minimum) {
   int num = 0;
   for (int i=0; i<ArraySize(pos);i++) {
      if (pos[i] != 2 && pos[i] != 3){
         num++;
      }
   }
   logs += " atcloudnum="+num+" min="+minimum;
   if (num > minimum)return(true);
   else return(false);
}

bool stableBand(string prefix, int &band[], int minimum) {
   int num = 0;
   for (int i=0; i<ArraySize(band);i++) {
      if (band[i] == 1){
         num++;
      }
   }
   logs += " bandnum="+num+" min="+minimum;
   if (num > minimum)return(true);
   else return(false);
}

bool stableNegative(string prefix, int &negatives[], int minimum) {
   int num = 0;
   for (int i=0; i<ArraySize(negatives);i++) {
      if (negatives[i] == 1){
         num++;
      }
   }
   logs += " negnum="+num+" min="+minimum;
   if (num > minimum)return(true);
   else return(false);
}

bool stableEMA(string prefix, int &ema[], int minimum) {
   int num = 0;
   for (int i=0; i<ArraySize(ema);i++) {
      if (ema[i] == 1){
         num++;
      }
   }
   //logs += " ema="+num+" min="+minimum;
   if (num > minimum)return(true);
   else return(false);
}

int posnum(double &R[]) {
   int num = 0;
   for (int i=0; i<ArraySize(R);i++) {
      if (R[i] > 0){
         num++;
      }
   }
   return num;
}

int negnum(double &R[]) {
   int num = 0;
   for (int i=0; i<ArraySize(R);i++) {
      if (R[i] < 0){
         num++;
      }
   }
   return num;
}

double mean(string prefix, double &data[], bool ignoremax, bool ignoremin, bool abs) {
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
   logs += " mu-"+prefix+"="+StringSubstr(mean,0,5);
   return mean;
}

//0:"USDJPY" 1:"EURUSD" 2:"GBPJPY" 3:"EURJPY" 4:"AUDUSD" 5:"AUDJPY" 6:"NZDJPY"};
bool stableAlong(string prefix, int &along[], double threshold, int minimum) {
   int num = 0;

   //logs += " "+prefix+":";
   if (along[1] > threshold || along[3] > threshold) {
      if (-1 == StringFind(goodpairs,"EURUSD",0)) goodpairs += "EURUSD/";
      if (-1 == StringFind(goodpairs,"EURJPY",0)) goodpairs += "EURJPY/";
      num++;
   }
   if (along[1] > threshold || along[0] > threshold) {
      if (-1 == StringFind(goodpairs,"EURUSD",0)) goodpairs += "EURUSD/";
      if (-1 == StringFind(goodpairs,"USDJPY",0)) goodpairs += "USDJPY/";
      num++;
   }
   if (along[4] > threshold || along[1] > threshold) {
      if (-1 == StringFind(goodpairs,"EURUSD",0)) goodpairs += "EURUSD/";
      if (-1 == StringFind(goodpairs,"AUDUSD",0)) goodpairs += "AUDUSD/";
      num++;
   }
   if (along[4] > threshold || along[0] > threshold) {
      if (-1 == StringFind(goodpairs,"USDJPY",0)) goodpairs += "USDJPY/";
      if (-1 == StringFind(goodpairs,"AUDUSD",0)) goodpairs += "AUDUSD/";
      num++;
   }
   if (along[2] > threshold || along[3] > threshold) {
      if (-1 == StringFind(goodpairs,"GBPJPY",0)) goodpairs += "GBPJPY/";
      if (-1 == StringFind(goodpairs,"EURJPY",0)) goodpairs += "EURJPY/";
      num++;
   }
   if (along[5] > threshold || along[6] > threshold) {
      if (-1 == StringFind(goodpairs,"NZDJPY",0)) goodpairs += "NZDJPY/";
      if (-1 == StringFind(goodpairs,"AUDJPY",0)) goodpairs += "AUDJPY/";
      num++;
   }
   logs += " "+prefix+"num="+num+" min="+minimum;
   if (num > minimum)return(true);
   else return(false);
}

bool hasAllPairs() {
   string missing = "";
   if (-1 == StringFind(goodpairs,"USDJPY",0)) missing += "USDJPY/";
   if (-1 == StringFind(goodpairs,"EURUSD",0)) missing += "EURUSD/";
   if (-1 == StringFind(goodpairs,"GBPJPY",0)) missing += "GBPJPY/";
   if (-1 == StringFind(goodpairs,"EURJPY",0)) missing += "EURJPY/";
   if (-1 == StringFind(goodpairs,"AUDUSD",0)) missing += "AUDUSD/";
   if (-1 == StringFind(goodpairs,"AUDJPY",0)) missing += "AUDJPY/";
   if (-1 == StringFind(goodpairs,"NZDJPY",0)) missing += "NZDJPY/";

   if (missing == "") {
      return(true);
   }else{
      //logs += " missing:"+missing;
      return(false);
   }

}
//0:"USDJPY" 1:"EURUSD" 2:"GBPJPY" 3:"EURJPY" 4:"AUDUSD" 5:"AUDJPY" 6:"NZDJPY"};
bool stableBandType(int &bandType[], int minimum) {
   int num = 0;
   for (int i=0; i<ArraySize(bandType);i++) {
      if (bandType[i] > 0){
         num++;
      }
   }
   logs += " bandtypenum="+num+" min="+minimum;
   if (num > minimum)return(true);
   else return(false);
}
//0:"USDJPY" 1:"EURUSD" 2:"GBPJPY" 3:"EURJPY" 4:"AUDUSD" 5:"AUDJPY" 6:"NZDJPY"};
bool stableZ(string prefix, double &z[],double threshold,int minimum) {
   int num = 0;
   for (int i=0; i<ArraySize(z);i++) {
      if (z[i] < threshold){
         num++;
      }
   }
   //logs += " "+prefix+"="+num+" min="+minimum;;
   if (num > minimum)return(true);
   else return(false);
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
   string str= "&payload="+"{\"text\":\""+text+"\"}";

   StringToCharArray( str, post );
   WebR = WebRequest( "POST", URL, cookie, NULL, timeout, post, 0, FTPdata, headers );
   return(WebR);
}
