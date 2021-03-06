#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

double BIG[] = {0.048,0.00048,0.048,0.000048,0.048,0.048,0.048};
string PAIRS[] = {"USDJPY","EURUSD","GBPJPY","EURJPY","AUDUSD","AUDJPY","NZDJPY"};
double MEAN[] = {0.0417450223664439,0.000332018131403119,0.0527167807799457,0.000411982524392215,0.0663341607698775,0.0372893966384425,0.0352369842692413};
double STD[] = {0.0141825157985687,0.000123181988689167,0.019949887948807,0.000177617192047747,0.0257662478856787,0.0119274401866431,0.0128039908008507};
string logs = "";
double daily_mean = 0;
double daily_std = 0;
void OnStart()
  {
   double open5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,0);
   double close5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,0);
   double open51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,2);
   double close51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,2);
   double leadingA = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,3); //一目均衡(先行スパンA)
	double leadingB = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,3); //一目均衡(先行スパンB)
   double upper = getValueByText("High_Low_Plus_UpperPrice");
   double lower = getValueByText("High_Low_Plus_LowerPrice");
   //Alert(getPosition(getValueByText("High_Low_Plus_UpperPrice"),getValueByText("High_Low_Plus_LowerPrice"),MarketInfo(Symbol(),MODE_BID)));
   //getPosition(upper,lower,MarketInfo(Symbol(),MODE_BID))
   int current_minute = TimeMinute(TimeLocal());
   int DANGER_MIN[] = {1,6,11,16,21,26,31,36,41,46,51,56};
   string text[] = {"18:40/18:45:00&"};
   //monitor();
   double pits_d[4];
   int current = 4;
   pits_d[0] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",0,current);
   pits_d[1] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",1,current);
   pits_d[2] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",2,current);
   pits_d[3] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",3,current);
   //Print("mean="+((pits_d[0]+pits_d[1]+pits_d[2]+pits_d[3])/4));
   int highestPitIdx = ArrayMaximum(pits_d,WHOLE_ARRAY,0);
   int lowestPitIdx = ArrayMinimum(pits_d,WHOLE_ARRAY,0);
   double sizeday = MathAbs(pits_d[highestPitIdx] - pits_d[lowestPitIdx]);
   string csv = "";
   double open;
   double close;
   double size;
   double mean;
   double sigma;
   double zscore;
   double target_z;
   double total_z;
   //ShellExecuteW(NULL,"open","C:\Users\Kiyoshi\Desktop\batch\minute.bat",NULL,NULL,1);

   /*
   for (int j=0; j<ArraySize(PAIRS); j++) {
    zscore = 0;
    for (int i=4+3; i > 4; i--) {
      open = iCustom(PAIRS[j],PERIOD_M5,"HeikenAshi_DM",2,i);
      close = iCustom(PAIRS[j],PERIOD_M5,"HeikenAshi_DM",3,i);
      size = getEntitySize(open,close);
      mean = getMeanEntity(PAIRS[j],PERIOD_M5,30,i);
      sigma = getStdEntity(mean,PAIRS[j],PERIOD_M5,30,i);
      zscore += getZ(mean,sigma,size);
     }
     if (Symbol() == PAIRS[j]) {
          target_z = zscore/3;
     }
     total_z += zscore/3;
   }
   Print("shift="+target_shift+" this="+StringSubstr(target_z,0,6)+" total="+StringSubstr(total_z/7,0,6));
   */
   //Print(TimeToString(iTime(Symbol(),PERIOD_D1,48)));
   //Print(isEMA200Signal(Symbol(),PERIOD_M5,shift));
   int signal = 0;
   datetime signal_time;
   datetime local;
   int hour = 0;
   /*
   for (int i=5000; i < 10000; i++) {
      hour = TimeHour(iTime(Symbol(),PERIOD_M5,i) + + 60 * 60 * 9);
      if (!(hour >= 8 && hour <= 12)) continue;
      signal = isEMA200Signal(Symbol(),PERIOD_M5,i,false);
      if (signal > 0 && signal < 1000) {
         signal_time = iTime(Symbol(),PERIOD_M5,i);
         local = signal_time + 60 * 60 * 9;
         Print("local="+TimeToString(local)+" ema signal at="+TimeToString(signal_time)+" signal="+signal);
      }
      
   }
   */
   
   /*
   for (int i=shift+2500; i >= shift; i--) {
      hasSignal(i);
   }
   */
   //testSignal();
   
   //Print(isFactorial(Symbol(),10,shift));
   //automata(Symbol(),true);
   //collectPastEntity("USDJPY",PERIOD_D1,1,12);

   string phase = "";
   int daily_phase[7];
   /*
   for (int i=52; i >= 0; i--) {
      phase = "";
      daily_phase[0] = getDailyPhase(PAIRS[0],i);
      daily_phase[1] = getDailyPhase(PAIRS[1],i);
      daily_phase[2] = getDailyPhase(PAIRS[2],i);
      daily_phase[3] = getDailyPhase(PAIRS[3],i);
      daily_phase[4] = getDailyPhase(PAIRS[4],i);
      daily_phase[5] = getDailyPhase(PAIRS[5],i);
      daily_phase[6] = getDailyPhase(PAIRS[6],i);
      phase += "USDJPY="+daily_phase[0];
      phase += " EURUSD="+daily_phase[1];
      phase += " GBPJPY="+daily_phase[2];
      phase += " EURJPY="+daily_phase[3];
      phase += " AUDUSD="+daily_phase[4];
      phase += " AUDJPY="+daily_phase[5];
      phase += " NZDJPY="+daily_phase[6];
      Print(TimeToString(iTime(Symbol(),PERIOD_D1,i))+" sum="+sumInteger(daily_phase)+" "+phase);
   }

   */
   
   //string TIMES[] = {"2020.4.9 16:48","2020.4.9 10:30","2020.4.9 9:01","2020.4.8 11:58","2020.4.8 9:42","2020.4.8 9:33","2020.4.7 11:44","2020.4.7 8:56","2020.4.6 18:29","2020.4.3 15:27","2020.4.3 9:14","2020.4.2 15:08","2020.4.2 14:59","2020.4.2 14:30","2020.4.2 11:57","2020.4.1 12:34","2020.4.1 10:51","2020.4.1 10:18","2020.4.1 9:35","2020.3.31 13:28","2020.3.31 12:03","2020.3.30 23:35","2020.3.30 20:10","2020.3.30 12:18"};
   //string TIMES[] = {"2020.4.9 8:13","2020.4.8 13:14","2020.4.7 10:45","2020.4.6 20:04","2020.4.6 16:29","2020.4.6 15:58","2020.4.6 15:52","2020.4.6 14:52","2020.4.6 14:46","2020.4.6 13:39","2020.4.6 9:03","2020.4.6 8:57","2020.4.3 10:17","2020.4.2 14:11","2020.4.2 10:36","2020.4.2 9:24","2020.4.2 8:53","2020.4.1 11:11","2020.3.31 19:18","2020.3.31 11:06","2020.3.31 9:50","2020.3.30 21:48","2020.3.30 15:50","2020.3.30 11:19"};
   int in_cloud_num = 0;
   string time = "";
   string BADDATES[] = {};
   
   //collectOHLC(Symbol(),PERIOD_D1,1,2218,"ohlc-");
   //collectFeature2(PERIOD_D1,0,2218,"feature-");
   //collectFibo(PERIOD_D1,1,2318,"");
   //Print(leadingMomentum(Symbol(), PERIOD_D1, 0));
   //slack("test");
   //slackprivate("test");
   //SendNotification("test");
   //testPips(Symbol(),TIMES);
   
   //Print(paradigmShift(Symbol(),PERIOD_D1,0,14));
      /*
   for (int i=170; i >= 0; i--) {
      d[0] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",0,i);
      d[1] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",1,i);
      d[2] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",2,i);
      d[3] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",3,i);
      h = ArrayMaximum(d,WHOLE_ARRAY,0);
      l = ArrayMinimum(d,WHOLE_ARRAY,0);
      sizeday = MathAbs(d[h] - d[l]);
      daily_z = getDailyZ("USDJPY",sizeday,PERIOD_D1,31,i);
      Print("i="+i+" "+TimeToString(iTime(Symbol(),PERIOD_D1,i))+" z="+daily_z);
   }
   

   for (int i=5760; i >= 0; i--) {
      open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,i);
      type = getEntity(open,close);
      extreme_distance = lastExtreme(close,type,Symbol(),PERIOD_CURRENT,i);
      //Print(TimeToString(iTime(Symbol(),PERIOD_M5,i))+" distance="+extreme_distance);
   }
   */
  }
  
double getMACDZAt (string symbol, int timeframe, int shift, int count) {
   double sample = MathAbs(iMACD(symbol,timeframe,12,26,9,PRICE_CLOSE,0,shift));
   double sum;
   double x;
   
   for (int i=shift; i<count+shift; i++) {
      x = MathAbs(iMACD(symbol,timeframe,12,26,9,PRICE_CLOSE,0,i));
      sum += x;
   }
   
   double mean = sum/count;
   double dev_sum;
   for (i=shift; i<count+shift; i++) {
      x = MathAbs(iMACD(symbol,timeframe,12,26,9,PRICE_CLOSE,0,i));
      dev_sum += MathPow((
         x-mean
       ),2);
   }
   double variance = dev_sum/count;
   double std = MathSqrt(variance);
   return getZ(mean, std, sample);
}
  
int getStochasticCross (string symbol, int timeframe, int shift) {
   double Stoc_Level_UPPER = 82;
   double Stoc_Level_LOWER = 20;
   double Stoc_MAIN0 = iStochastic(symbol,timeframe,5,3,3,MODE_EMA,1,MODE_MAIN,shift);
   double Stoc_SIGNAL0 = iStochastic(symbol,timeframe,5,3,3,MODE_EMA,1,MODE_SIGNAL,shift);
   double Stoc_MAIN1 = iStochastic(symbol,timeframe,5,3,3,MODE_EMA,1,MODE_MAIN,shift+1);
   double Stoc_SIGNAL1 = iStochastic(symbol,timeframe,5,3,3,MODE_EMA,1,MODE_SIGNAL,shift+1);
   
   //ストキャスが20以下でゴールデンクロス
   if (Stoc_MAIN1 < Stoc_Level_LOWER) {
      if (Stoc_MAIN1 > Stoc_SIGNAL1) {
         if (Stoc_MAIN0 <= Stoc_SIGNAL0) {
            return 2;
         }
      } else {
         if (Stoc_MAIN0 >= Stoc_SIGNAL0) {
            return 2;
         }
      }
   }

   //ストキャスが80以上でデッドクロス
   if (Stoc_MAIN1 > Stoc_Level_UPPER) {
      if (Stoc_MAIN1 < Stoc_SIGNAL1) {
         if (Stoc_MAIN0 >= Stoc_SIGNAL0) {
            return 3;
         }
      } else {
         if (Stoc_MAIN0 <= Stoc_SIGNAL0) {
            return 3;
         }
      }
   }
   
   if (Stoc_MAIN1 <= Stoc_Level_UPPER && Stoc_MAIN1 >= Stoc_Level_LOWER) {
      // クロス
      if (Stoc_MAIN0 > Stoc_SIGNAL0 && Stoc_MAIN1 <= Stoc_SIGNAL1) {
         return 1;
      }
   
      // クロス
      if (Stoc_MAIN0 < Stoc_SIGNAL0 && Stoc_MAIN1 >= Stoc_SIGNAL1) {
         return 1;
      }
   }
   
   return 0;
}

void collectFeature2(int timeframe, int shift, int days, string prefix) {
   datetime time;
   string time_str = "";
   string data = "";
   string symbol_data = "";
   
   int stoc = 0;
   double macdz0 = 0;
   int macdz_period = 26;
   int days_uj = 0;
   int days_eu = 0;
   int days_gj = 0;
   int days_ej = 0;
   int days_au = 0;
   int days_aj = 0;
   int days_nj = 0;
   double macdz_uj = 0;
   double macdz_eu = 0;
   double macdz_gj = 0;
   double macdz_ej = 0;
   double macdz_au = 0;
   double macdz_aj = 0;
   double macdz_nj = 0;
   int serial = 0;
   
   for (int i=days+shift; i >= shift; i--) {
      time = iTime("USDJPY",timeframe,i) + 60 * 60 * 9;
      time_str = TimeYear(time)+"-"+TimeMonth(time)+"-"+TimeDay(time);
      symbol_data = time_str;  
      
      for (int j=0; j<ArraySize(PAIRS); j++) {
         stoc = getStochasticCross(PAIRS[j], timeframe, i);
         if (stoc > 0) {
            switch (j) {
               case 0:
                  days_uj = 0;
                  macdz_uj = getMACDZAt(PAIRS[j], timeframe, i, macdz_period);
               break;
               case 1:
                  days_eu = 0;
                  macdz_eu = getMACDZAt(PAIRS[j], timeframe, i, macdz_period);
               break;
               case 2:
                  days_gj = 0;
                  macdz_gj = getMACDZAt(PAIRS[j], timeframe, i, macdz_period);
               break;
               case 3:
                  days_ej = 0;
                  macdz_ej = getMACDZAt(PAIRS[j], timeframe, i, macdz_period);
               break;
               case 4:
                  days_au = 0;
                  macdz_au = getMACDZAt(PAIRS[j], timeframe, i, macdz_period);
               break;
               case 5:
                  days_aj = 0;
                  macdz_aj = getMACDZAt(PAIRS[j], timeframe, i, macdz_period);
               break;
               case 6:
                  days_nj = 0;
                  macdz_nj = getMACDZAt(PAIRS[j], timeframe, i, macdz_period);
               break;
            }
               
         }else{
            // パラダイムシフトしてない通常かつ土日じゃない
            if (TimeDayOfWeek(time) != 0 || TimeDayOfWeek(time) != 6) {
               switch (j) {
                  case 0:
                     days_uj++;
                  break;
                  case 1:
                     days_eu++;
                  break;
                  case 2:
                     days_gj++;
                  break;
                  case 3:
                     days_ej++;
                  break;
                  case 4:
                     days_au++;
                  break;
                  case 5:
                     days_aj++;
                  break;
                  case 6:
                     days_nj++;
                  break;
               }
            }
         }
         // 今のMACD
         macdz0 = getMACDZAt(PAIRS[j], timeframe, i, macdz_period);
         // 連続数
         serial = serialNum(PAIRS[j],timeframe,50,i);
         
         
         // パラダイムシフト経過日+直近パラダイムシフトのMACD
         switch (j) {
            case 0:
               symbol_data += ","+days_uj+","+macdz_uj+","+macdz0+","+serial;
            break;
            case 1:
               symbol_data += ","+days_eu+","+macdz_eu+","+macdz0+","+serial;
            break;
            case 2:
               symbol_data += ","+days_gj+","+macdz_gj+","+macdz0+","+serial;
            break;
            case 3:
               symbol_data += ","+days_ej+","+macdz_ej+","+macdz0+","+serial;
            break;
            case 4:
               symbol_data += ","+days_au+","+macdz_au+","+macdz0+","+serial;
            break;
            case 5:
               symbol_data += ","+days_aj+","+macdz_aj+","+macdz0+","+serial;
            break;
            case 6:
               symbol_data += ","+days_nj+","+macdz_nj+","+macdz0+","+serial;
            break;
            }

      }
      
       data += symbol_data+"\n";
   }
   //Print(data);
   exportData(prefix+"sampling-feature2-"+days+"days",data,true);
}
double leadingMomentum(string symbol, int timeframe, int shift) {    
   double open = 0;
   double close = 0;
   double size = 0;
   int count = 0;
   
   int periods = 5;
   int serial = serialNum(symbol,timeframe,periods,shift);
   if (serial < periods) {
      periods = serial;
   }
   double y[5];
   double x[5];
   
   for (int i=shift; i < shift+periods; i++) {
      open = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i);
      close = iCustom(symbol,timeframe,"HeikenAshi_DM",3,i);
      size = getEntitySize(open,close);
      y[count] = size;
      x[count] = 5 - count;
      count++;
   }
      
   return getCorrelated(y, x);

}
int outCloudSince(string symbol, int timeframe, int shift) {
   int candle_pos = getHeikenPosition(
   iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift),
   iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift),
   iIchimoku(symbol,timeframe,9,26,52,3,shift),
   iIchimoku(symbol,timeframe,9,26,52,4,shift)
   );

   //Print("time="+(TimeToStr(iTime(Symbol(),PERIOD_D1,shift) + 32400))+" pos="+candle_pos);
   if (candle_pos != 4 && candle_pos != 5) return 0;
   
   int max_in_clouds = 20;
   int in_cloud_num = 0;
   int out_cloud_num = 0;
   int pos = 0;
   for (int i=shift+1; i <= shift+1+max_in_clouds; i++) {
      if (out_cloud_num < 2) {
         pos = getHeikenPosition(
         iCustom(symbol,timeframe,"HeikenAshi_DM",2,i),
         iCustom(symbol,timeframe,"HeikenAshi_DM",3,i),
         iIchimoku(symbol,timeframe,9,26,52,3,i),
         iIchimoku(symbol,timeframe,9,26,52,4,i)
         );
         if (pos != 6) {
            out_cloud_num++;
         }else{
            in_cloud_num++;
         }
      }
   }
   
   return in_cloud_num;
}
double getLast15R(string pair) {
   int cnt = 0;
   string filename = pair+"_r.csv";
   if (!FileIsExist(filename)) {
      return 0;
   }
   int handle = FileOpen(filename, FILE_CSV|FILE_READ|FILE_SHARE_READ, ',');
   string val = "";
   double r;
   while(!FileIsEnding(handle)){
      val = FileReadNumber(handle);
      switch (cnt) {
         case 0://z1H
            r = StringToDouble(val);
         break;
         default:
         break;
      }
         cnt++;
   }
   FileClose(handle);
   return r;
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
 
 //+------------------------------------------------------------------+
//| 価格をpipsに換算する関数
//+------------------------------------------------------------------+
double PriceToPips(double price, string symbol)
{
   double pips = 0;

   // 現在の通貨ペアの小数点以下の桁数を取得
   int digits = (int)MarketInfo(symbol, MODE_DIGITS);

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
 double getHighLowDiff(string symbol, int shift, int minutes) {
      double entity[4];
      double highest = 0;
      double lowest = 1000;
      double current_highest = 0;
      double current_lowest = 0;
      for (int i=shift; i<minutes+shift; i++) {
         entity[0] = iCustom(symbol,PERIOD_M1,"HeikenAshi_DM",2,i);
         entity[1] = iCustom(symbol,PERIOD_M1,"HeikenAshi_DM",3,i);
         entity[2] = iCustom(symbol,PERIOD_M1,"HeikenAshi_DM",0,i);
         entity[3] = iCustom(symbol,PERIOD_M1,"HeikenAshi_DM",1,i);
         current_highest = entity[ArrayMaximum(entity,WHOLE_ARRAY,0)];
         current_lowest = entity[ArrayMinimum(entity,WHOLE_ARRAY,0)];
         if (current_highest > highest) highest = current_highest;
         if (current_lowest < lowest) lowest = current_lowest;
      }
      return PriceToPips(highest, symbol) - PriceToPips(lowest, symbol);
 }
 int isEMA200Signal (string symbol, int timeframe, int shift, bool debug) {
      if (debug)Print("start at="+TimeToString(iTime(Symbol(),timeframe,shift)));
      double open = iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift);
      double close = iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift);
      double ema5 = iMA(symbol,timeframe,5,0,MODE_EMA,PRICE_CLOSE,shift);
      double ema20 = iMA(symbol,timeframe,20,0,MODE_EMA,PRICE_CLOSE,shift);
      double ema70 = iMA(symbol,timeframe,70,0,MODE_EMA,PRICE_CLOSE,shift);
      double ema200 = iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,shift);
      int current_type = getEntity(open,close);
      
      if (current_type == 1) {
         if (!(ema20 > ema70)) return 0;
      }else if (current_type == 2) {
         if (!(ema20 < ema70)) return 0;
      }
      
      //200-70の相対幅
      double relative_200_size = MathAbs(ema200 - ema70)/MathAbs(ema70 - ema20);
      if (debug) Print("relative_200_size="+relative_200_size);
      //小さい相場は無視
      if (relative_200_size < 2.5) {   
         return 0;
      }
      
      //過去2時間ずっとema20とema70がema200を超えていない判定
      bool is_20_70_stable = true;
      for (int i=shift; i<shift+14;i++) {
         ema20 = iMA(symbol,timeframe,20,0,MODE_EMA,PRICE_CLOSE,i);
         ema70 = iMA(symbol,timeframe,70,0,MODE_EMA,PRICE_CLOSE,i);
         ema200 = iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,i);
         if (current_type == 1) {
            if (is_20_70_stable && !(ema200 > ema70 && ema200 > ema20)) {
               if (debug)Print("incr badema at="+TimeToString(iTime(Symbol(),timeframe,i)));
               is_20_70_stable = false;
            }
         }else if (current_type == 2) {
            if (is_20_70_stable && !(ema200 < ema70 && ema200 < ema20)) {
               if (debug)Print("decr badema at="+TimeToString(iTime(Symbol(),timeframe,i)));
               is_20_70_stable = false;
            }
         }
      }
      if (debug)Print("is_20_70_stable="+is_20_70_stable);
      if (!is_20_70_stable) {
         return 0;
      }
      
      int latest = 3;
      bool ema200_surpassed = false;
      //ema200を既に抜けたか判定
      if (current_type == 1 && ema5 > ema200) ema200_surpassed = true;
      if (current_type == 2 && ema5 < ema200) ema200_surpassed = true;
      
      if (debug)Print("ema200_surpassed="+ema200_surpassed);

      //既にema200超えた後
      if (ema200_surpassed) {
         bool ema200_lately_crossed = false;
         int ema200_crossed_shift = 0;
         for (i=shift; i<shift+latest;i++) {
            //直近でema200抜け判定
            if (!ema200_lately_crossed) {
               if (current_type == 1) {
                  //上昇の時ema5がema200より下
                  if (iMA(symbol,timeframe,5,0,MODE_EMA,PRICE_CLOSE,i) < iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,i)) {
                     ema200_lately_crossed = true;
                     ema200_crossed_shift = i;
                  }
               }else if(current_type == 2) {
                  //下降の時ema5がema200より上
                  if (iMA(symbol,timeframe,5,0,MODE_EMA,PRICE_CLOSE,i) > iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,i)) {
                     ema200_lately_crossed = true;
                     ema200_crossed_shift = i;
                  }
               }
            }
         }
         
         bool has_ema200_crossed = false;
         int ema200cross_before_index = 0;
         if (ema200_lately_crossed){
            for (i=ema200_crossed_shift; i<ema200_crossed_shift+18;i++) {
               if (current_type == 1) {
                  if (iMA(symbol,timeframe,5,0,MODE_EMA,PRICE_CLOSE,i) > iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,i)) {
                     has_ema200_crossed = true;
                     ema200cross_before_index = i;
                  }
               }else if (current_type == 2) {
                  if (iMA(symbol,timeframe,5,0,MODE_EMA,PRICE_CLOSE,i) < iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,i)) {
                     has_ema200_crossed = true;
                     ema200cross_before_index = i;
                  }
               }
            }
         }else{
            //直近3以内に抜けていない
            if (debug)Print("ema not surpassed recently");
            return 0;
         }
         
         //ema200抜けする前にも18(1時間30分）以内に抜けていたらアウト
         if (has_ema200_crossed) {
            if (debug)Print("ema crossed before at="+TimeToString(iTime(Symbol(),timeframe,ema200_crossed_shift)));
            return 0;
         }
         
         for (i=ema200_crossed_shift; i<ema200_crossed_shift+5760;i++) {
            ema20 = iMA(symbol,timeframe,20,0,MODE_EMA,PRICE_CLOSE,i);
            ema70 = iMA(symbol,timeframe,70,0,MODE_EMA,PRICE_CLOSE,i);
            ema200 = iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,i);
            if (current_type == 1) {
               if (!(ema200 > ema70 && ema200 > ema20)) {
                     return (i - shift);
               }
             }else if (current_type == 2) {
               if (!(ema200 < ema70 && ema200 < ema20)) {
                     return (i - shift);
               }
             }
          }
         if (debug)Print("crossed_idx="+ema200_crossed_shift+" ema200 surpassed at="+TimeToString(iTime(Symbol(),timeframe,ema200_crossed_shift)));
         //ema200を3足以内に抜けた
         return 1;
      }else{
         //まだema200抜けていない 過去抜けた数をカウント
         int type;
         int surpassed_cnt =0;
         for (i=shift+1; i<shift+24+1;i++) {
            open = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i);
            close = iCustom(symbol,timeframe,"HeikenAshi_DM",3,i);
            type = getEntity(open,close);
            ema200 = iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,i);
            if (type == current_type) {
               if (current_type == 1) {
                  if (close > ema200) {
                     if (debug)Print("incr surpassed at="+TimeToString(iTime(Symbol(),timeframe,i)));
                     surpassed_cnt++;
                  }
               }else if (current_type == 2) {
                  if (close < ema200) {
                     if (debug)Print("decr surpassed at="+TimeToString(iTime(Symbol(),timeframe,i)));
                     surpassed_cnt++;
                  }
               }
            }
          }
          for (i=shift; i<shift+5760;i++) {
            ema20 = iMA(symbol,timeframe,20,0,MODE_EMA,PRICE_CLOSE,i);
            ema70 = iMA(symbol,timeframe,70,0,MODE_EMA,PRICE_CLOSE,i);
            ema200 = iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,i);
            if (current_type == 1) {
               if (!(ema200 > ema70 && ema200 > ema20)) {
                     return i;
               }
             }else if (current_type == 2) {
               if (!(ema200 < ema70 && ema200 < ema20)) {
                     return i;
               }
             }
          }
          if (!(surpassed_cnt > 0 && 3 > surpassed_cnt)) {
            if (debug)Print("surpassed_cnt="+surpassed_cnt);
            return 0;
          }
          return 2;
      }
      return 0;

      
 }
 void findSimilarAnyTime(string symbol, int timeframe1, int timeframe2, int starts, double threshold) {
      double open = iCustom(symbol,timeframe1,"HeikenAshi_DM",2,starts);
      double close = iCustom(symbol,timeframe1,"HeikenAshi_DM",3,starts);
      double ema5 = iMA(symbol,timeframe1,5,0,MODE_EMA,PRICE_CLOSE,starts);
      double ema20 = iMA(symbol,timeframe1,20,0,MODE_EMA,PRICE_CLOSE,starts);
      double ema70 = iMA(symbol,timeframe1,70,0,MODE_EMA,PRICE_CLOSE,starts);
      double ema200 = iMA(symbol,timeframe1,200,0,MODE_EMA,PRICE_CLOSE,starts);
      double leadingA = iIchimoku(symbol,timeframe1,9,26,52,3,starts);
	   double leadingB = iIchimoku(symbol,timeframe1,9,26,52,4,starts);
	   double naught[8];
	   //定義
      naught[0] = open;
      naught[1] = close;
      naught[2] = ema5;
      naught[3] = ema20;
      naught[4] = ema70;
      naught[5] = ema200;
      naught[6] = leadingA;
      naught[7] = leadingB;
      int highestIdx = ArrayMaximum(naught,WHOLE_ARRAY,0);
      //大きい順
      int phase[8];
      phase[0] = highestIdx;
      naught[highestIdx] = 0;
      highestIdx = ArrayMaximum(naught,WHOLE_ARRAY,0);
      phase[1] = highestIdx;
      naught[highestIdx] = 0;
      highestIdx = ArrayMaximum(naught,WHOLE_ARRAY,0);
      phase[2] = highestIdx;
      naught[highestIdx] = 0;
      highestIdx = ArrayMaximum(naught,WHOLE_ARRAY,0);
      phase[3] = highestIdx;
      naught[highestIdx] = 0;
      highestIdx = ArrayMaximum(naught,WHOLE_ARRAY,0);
      phase[4] = highestIdx;
      naught[highestIdx] = 0;
      highestIdx = ArrayMaximum(naught,WHOLE_ARRAY,0);
      phase[5] = highestIdx;
      naught[highestIdx] = 0;
      highestIdx = ArrayMaximum(naught,WHOLE_ARRAY,0);
      phase[6] = highestIdx;
      naught[highestIdx] = 0;
      highestIdx = ArrayMaximum(naught,WHOLE_ARRAY,0);
      phase[7] = highestIdx;
      
      double open_1 = iCustom(symbol,timeframe1,"HeikenAshi_DM",2,starts);
      double close_1 = iCustom(symbol,timeframe1,"HeikenAshi_DM",3,starts);
      double ema5_1 = iMA(symbol,timeframe1,5,0,MODE_EMA,PRICE_CLOSE,starts);
      double ema20_1 = iMA(symbol,timeframe1,20,0,MODE_EMA,PRICE_CLOSE,starts);
      double ema70_1 = iMA(symbol,timeframe1,70,0,MODE_EMA,PRICE_CLOSE,starts);
      double ema200_1 = iMA(symbol,timeframe1,200,0,MODE_EMA,PRICE_CLOSE,starts);
      double leadingA_1 = iIchimoku(symbol,timeframe1,9,26,52,3,starts);
	   double leadingB_1 = iIchimoku(symbol,timeframe1,9,26,52,4,starts);
	   double target[8];

      //大きい順
      int phase_1[8];

      for (int i=starts+1; i < 2100; i++) {
         open_1 = iCustom(symbol,timeframe2,"HeikenAshi_DM",2,i);
         close_1 = iCustom(symbol,timeframe2,"HeikenAshi_DM",3,i);
         ema5_1 = iMA(symbol,timeframe2,5,0,MODE_EMA,PRICE_CLOSE,i);
         ema20_1 = iMA(symbol,timeframe2,20,0,MODE_EMA,PRICE_CLOSE,i);
         ema70_1 = iMA(symbol,timeframe2,70,0,MODE_EMA,PRICE_CLOSE,i);
         ema200_1 = iMA(symbol,timeframe2,200,0,MODE_EMA,PRICE_CLOSE,i);
         leadingA_1 = iIchimoku(symbol,timeframe2,9,26,52,3,i);
	      leadingB_1 = iIchimoku(symbol,timeframe2,9,26,52,4,i);
	      //定義
         target[0] = open_1;
         target[1] = close_1;
         target[2] = ema5_1;
         target[3] = ema20_1;
         target[4] = ema70_1;
         target[5] = ema200_1;
         target[6] = leadingA_1;
         target[7] = leadingB_1;
         highestIdx = ArrayMaximum(target,WHOLE_ARRAY,0);
         phase_1[0] = highestIdx;
         target[highestIdx] = 0;
         highestIdx = ArrayMaximum(target,WHOLE_ARRAY,0);
         phase_1[1] = highestIdx;
         target[highestIdx] = 0;
         highestIdx = ArrayMaximum(target,WHOLE_ARRAY,0);
         phase_1[2] = highestIdx;
         target[highestIdx] = 0;
         highestIdx = ArrayMaximum(target,WHOLE_ARRAY,0);
         phase_1[3] = highestIdx;
         target[highestIdx] = 0;
         highestIdx = ArrayMaximum(target,WHOLE_ARRAY,0);
         phase_1[4] = highestIdx;
         target[highestIdx] = 0;
         highestIdx = ArrayMaximum(target,WHOLE_ARRAY,0);
         phase_1[5] = highestIdx;
         target[highestIdx] = 0;
         highestIdx = ArrayMaximum(target,WHOLE_ARRAY,0);
         phase_1[6] = highestIdx;
         target[highestIdx] = 0;
         highestIdx = ArrayMaximum(target,WHOLE_ARRAY,0);
         phase_1[7] = highestIdx;
         if (phase[0] == phase_1[0] && phase[1] == phase_1[1] && phase[2] == phase_1[2] && phase[3] == phase_1[3] && 
         phase[4] == phase_1[4] && phase[5] == phase_1[5] && phase[6] == phase_1[6] && phase[7] == phase_1[7]) {
            //Print(TimeToString(iTime(symbol,timeframe2,i)));
            WindowScreenShot(TimeYear(iTime(symbol,timeframe2,i))+"_"+TimeMonth(iTime(symbol,timeframe2,i))+"_"+TimeDay(iTime(symbol,timeframe2,i))+"_REG"+".gif", 640, 480,i+26);
         }
      }
 }
 double getDynamicZ(string symbol, int timeframe, int shift, int days) {
   double sum = 0;
   int cnt = 0;
   for (int i=1+shift; i<days+shift+1; i++) {
      sum += getEntitySize(iCustom(symbol,timeframe,"HeikenAshi_DM",2,i),iCustom(symbol,timeframe,"HeikenAshi_DM",3,i));
      cnt++;
   }
   double mean = sum/cnt;
   double deviations = 0;
   for (i=1+shift; i<days+shift+1; i++) {
      deviations += MathPow((
         getEntitySize(iCustom(symbol,timeframe,"HeikenAshi_DM",2,i),iCustom(symbol,timeframe,"HeikenAshi_DM",3,i))-mean
       ),2);
   }
   double variance = deviations/cnt;
   double std = MathSqrt(variance);
   double sample = getEntitySize(iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift),iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift));
   return MathCeil(((sample - mean)/std) * 100) * 1.0/100;
 }

 int serialNumAllowSingle(string symbol,int period, int count, int shift) {
   double open = iCustom(symbol,period,"HeikenAshi_DM",2,shift);
   double close = iCustom(symbol,period,"HeikenAshi_DM",3,shift);
   int entity_type = getEntity(open,close);
   int fwd_entity_type2;
   int fwd_entity_type1;
   int serial_num = 1;
   //過去に走査する
   for (int i=0; i<count;i++) {
      open = iCustom(symbol,period,"HeikenAshi_DM",2,i+shift);
      close = iCustom(symbol,period,"HeikenAshi_DM",3,i+shift);
      entity_type = getEntity(open,close);
      fwd_entity_type1 = getEntity(
      iCustom(symbol,period,"HeikenAshi_DM",2,i+shift+1),
      iCustom(symbol,period,"HeikenAshi_DM",3,i+shift+1));
      fwd_entity_type2 = getEntity(
      iCustom(symbol,period,"HeikenAshi_DM",2,i+shift+2),
      iCustom(symbol,period,"HeikenAshi_DM",3,i+shift+2));
      if (i==0 && entity_type != fwd_entity_type1 && entity_type != fwd_entity_type2) {
         return serial_num;
      }else if (entity_type == fwd_entity_type1){
         serial_num++;
         continue;
      }else if (entity_type != fwd_entity_type1 && entity_type == fwd_entity_type2) {
         serial_num++;
         i++;
         continue;
      }else{
         return serial_num;
      }
   }
   return serial_num;
}

int paradigmShift (string symbol, int timeframe, int shift, int days) {
   int serialnum_igr_cross = serialNumAllowSingle(symbol,timeframe,days-1,shift+1);
   int minimum_serial = 3;
   //minimum_serial未満の連続だったら終了
   if (serialnum_igr_cross < minimum_serial) return 0;
   
   bool isCross200 = false;
   double ema200 = 0;
   double open = 0;
   double close = 0;
   for (int i=shift; i<shift+minimum_serial;i++) {
      ema200 = iMA(Symbol(),timeframe,200,0,MODE_EMA,PRICE_CLOSE,i);
      open = iCustom(Symbol(),timeframe,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),timeframe,"HeikenAshi_DM",3,i);
      if (!isCross200) {
         if (open > close) {
            if (open > ema200 && ema200 > close) isCross200 = true;
         }else{
            if (close > ema200 && ema200 > open) isCross200 = true;
         }
      }
   }
   
   double total_cross_num = 0;
   for (i=shift; i<shift+serialnum_igr_cross;i++) {
      if(isCross(symbol,timeframe,i) == true)total_cross_num++;
   }
   //直近でema200超えがなくかつ半分以上十字だったらだめ
   if (isCross200 && total_cross_num >= serialnum_igr_cross/2) return 0;
   
   if (getEntity(
      iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift),
      iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift)) !=
      getEntity(
      iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift+1),
      iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift+1))) {
      return serialnum_igr_cross;
   }
   return 0;
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
   double pips0 = PriceToPips(high0,symbol) - PriceToPips(low0,symbol);
   double high1 = iHigh(symbol,timeframe,shift+1);
   double low1 = iLow(symbol,timeframe,shift+1);
   double pips1 = PriceToPips(high1,symbol) - PriceToPips(low1,symbol);
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
   
   for (i=0; i<ArraySize(PAIRS); i++) {
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
   
   for ( i=0; i<ArraySize(PAIRS); i++) {
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
      for (i=0; i<ArraySize(PAIRS); i++) {
         if (PAIRS[i] == "GBPJPY" || PAIRS[i] == "USDJPY") continue;
         didShifted = false;
         paradigm_serial = 0;
      
      for (j=shift+1; j < shift+shifted_within+1; j++) {
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
   
   for (i=0; i<ArraySize(PAIRS); i++) {
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
   int pips = PriceToPips(iHigh("USDJPY",PERIOD_D1,shift),"USDJPY") - PriceToPips(iLow("USDJPY",PERIOD_D1,shift),"USDJPY");
   if (is_pip_break) debug += "break ";
   if (is_paradigm_shift) debug += "paradigm ";
   if (is_danger_serial) debug += "serial ";
   if (hige > 15 && pips > 60) debug += " hige";
   return debug;
 }
 
 int lastExtreme (double current_extreme, int entity_type, string symbol, int timeframe, int shift) {
       //Print(current_extreme+" "+entity_type+" "+symbol+" "+timeframe+" "+shift);
      //20日
      for (int i=shift+1; i<=shift+5760+1; i++) {
         if (entity_type == 1) {
            if (iCustom(symbol,timeframe,"HeikenAshi_DM",3,i) > current_extreme) return i;
         }else{
            //Print("i="+i+" close="+iCustom(symbol,timeframe,"HeikenAshi_DM",3,i));
            if (iCustom(symbol,timeframe,"HeikenAshi_DM",3,i) < current_extreme) return i;
         }
      }
      return shift+5760+1;
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
         Print("max_shift="+max_shift+" dailyZ="+dailyZ);
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
void findSimilar (string symbol, int timeframe, double threshold) {
   double R = 0;
   for (int i=1; i < 2100; i++) {
      R = euclideanR(symbol,timeframe,0,i);
      if (R > threshold) {
        WindowScreenShot(TimeYear(iTime(symbol,timeframe,i))+"_"+TimeMonth(iTime(symbol,timeframe,i))+"_"+TimeDay(iTime(symbol,timeframe,i))+"_REG"+".gif", 640, 480,i+26);
      }
   }
}

double euclideanR(string symbol, int timeframe, int shift_source, int shift_target) {
    double low0 = iCustom(symbol,timeframe,"HeikenAshi_DM",0,shift_source);
    double high0 = iCustom(symbol,timeframe,"HeikenAshi_DM",1,shift_source);
    double open0 = iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift_source);
    double close0 = iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift_source);
    double ema5_0 = iMA(symbol,timeframe,5,0,MODE_EMA,PRICE_CLOSE,shift_source);
    double ema20_0 = iMA(symbol,timeframe,20,0,MODE_EMA,PRICE_CLOSE,shift_source);
    double ema70_0 = iMA(symbol,timeframe,70,0,MODE_EMA,PRICE_CLOSE,shift_source);
    double ema200_0 = iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,shift_source);
    double leadingA_0 = iIchimoku(symbol,timeframe,9,26,52,3,shift_source);
    double leadingB_0 = iIchimoku(symbol,timeframe,9,26,52,4,shift_source);
    double low1 = iCustom(symbol,timeframe,"HeikenAshi_DM",0,shift_target);
    double high1 = iCustom(symbol,timeframe,"HeikenAshi_DM",1,shift_target);
    double open1 = iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift_target);
    double close1 = iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift_target);
    double ema5_1 = iMA(symbol,timeframe,5,0,MODE_EMA,PRICE_CLOSE,shift_target);
    double ema20_1 = iMA(symbol,timeframe,20,0,MODE_EMA,PRICE_CLOSE,shift_target);
    double ema70_1 = iMA(symbol,timeframe,70,0,MODE_EMA,PRICE_CLOSE,shift_target);
    double ema200_1 = iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,shift_target);
    double leadingA_1 = iIchimoku(symbol,timeframe,9,26,52,3,shift_target);
    double leadingB_1 = iIchimoku(symbol,timeframe,9,26,52,4,shift_target);
	
	double sample0[10];
	sample0[0] = low0;
    sample0[1] = high0;
    sample0[2] = open0;
    sample0[3] = close0;
    sample0[4] = ema5_0;
    sample0[5] = ema20_0;
    sample0[6] = ema70_0;
    sample0[7] = ema200_0;
    sample0[8] = leadingA_0;
    sample0[9] = leadingB_0;
    int minidx0 = ArrayMinimum(sample0,WHOLE_ARRAY,0);
    double min0 = sample0[minidx0];
    sample0[0] = sample0[0] - min0;
    sample0[1] = sample0[1] - min0;
    sample0[2] = sample0[2] - min0;
    sample0[3] = sample0[3] - min0;
    sample0[4] = sample0[4] - min0;
    sample0[5] = sample0[5] - min0;
    sample0[6] = sample0[6] - min0;
    sample0[7] = sample0[7] - min0;
    sample0[8] = sample0[8] - min0;
    sample0[9] = sample0[9] - min0;
	double sample1[10];
    sample1[0] = low1;
    sample1[1] = high1;
    sample1[2] = open1;
    sample1[3] = close1;
    sample1[4] = ema5_1;
    sample1[5] = ema20_1;
    sample1[6] = ema70_1;
    sample1[7] = ema200_1;
    sample1[8] = leadingA_1;
    sample1[9] = leadingB_1;
    int minidx1 = ArrayMinimum(sample1,WHOLE_ARRAY,0);
    double min1 = sample1[minidx1];
    sample1[0] = sample1[0] - min1;
    sample1[1] = sample1[1] - min1;
    sample1[2] = sample1[2] - min1;
    sample1[3] = sample1[3] - min1;
    sample1[4] = sample1[4] - min1;
    sample1[5] = sample1[5] - min1;
    sample1[6] = sample1[6] - min1;
    sample1[7] = sample1[7] - min1;
    sample1[8] = sample1[8] - min1;
    sample1[9] = sample1[9] - min1;

    double sum = 0;
    sum += getSquareDiff(sample0[0],sample1[0]);
    sum += getSquareDiff(sample0[1],sample1[1]);
    sum += getSquareDiff(sample0[2],sample1[2]);
    sum += getSquareDiff(sample0[3],sample1[3]);
    sum += getSquareDiff(sample0[4],sample1[4]);
    sum += getSquareDiff(sample0[5],sample1[5]);
    sum += getSquareDiff(sample0[6],sample1[6]);
    sum += getSquareDiff(sample0[7],sample1[7]);
    sum += getSquareDiff(sample0[8],sample1[8]);
    sum += getSquareDiff(sample0[9],sample1[9]);

    double d = MathSqrt(sum);
    return 1/(d+1);
   
}
double getSquareDiff(double val1, double val2){
   return MathPow((
         val1-val2
       ),2);
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

int sumInteger(int &sample[]) {
   int sum = 0;
   for (int i=0; i<ArraySize(sample); i++) {
      sum += sample[i];
   }
   return sum;
}

void testPips (string symbol, string &time[]) {
   int shift = 0;
   double pip5 = 0;
   double pip15 = 0;
   double pip30 = 0; 
   double pip60 = 0;

   string result = "";
   for (int i=0; i < ArraySize(time); i++) {
      shift = iBarShift(symbol,PERIOD_M1,StrToTime(time[i])-32400);
      
      pip5 = getHighLowDiff(symbol,shift,5);
      pip15 = getHighLowDiff(symbol,shift,15);
      pip30 = getHighLowDiff(symbol,shift,30);
      pip60 = getHighLowDiff(symbol,shift,60);
      Print("i="+i+" pip5="+pip5+" shift="+shift+" symbol="+symbol+" time="+time[i]+" strtotime="+(StrToTime(time[i])-32400));
      result += time[i]+","+pip5+","+pip15+","+pip30+","+pip60+"\n";
   }
   exportData(symbol+"-pips",result,true);
}

void testEMAwasStrong () {
   string TIMES[] = {"2020.1.31 12:39","2020.1.31 12:24","2020.1.30 18:56","2020.1.30 18:24","2020.1.30 17:19","2020.1.30 17:14","2020.1.30 16:06","2020.1.30 11:42","2020.1.30 11:23","2020.1.30 10:09","2020.1.29 18:10","2020.1.29 17:06","2020.1.29 16:45","2020.1.29 16:44","2020.1.29 16:10","2020.1.29 9:41","2020.1.29 9:30","2020.1.28 17:28","2020.1.28 17:04","2020.1.28 11:02","2020.1.28 9:58","2020.1.28 9:54","2020.1.25 23:22","2020.1.25 23:15","2020.1.25 22:29","2020.1.25 20:56","2020.1.25 18:00","2020.1.25 16:20","2020.1.25 13:46","2020.1.25 11:09","2020.1.24 18:56","2020.1.24 17:30","2020.1.24 10:51","2020.1.24 8:59","2020.1.23 14:16","2020.1.23 11:02","2020.1.23 9:30","2020.1.23 8:32","2020.1.22 23:59","2020.1.22 21:05","2020.1.22 20:17","2020.1.22 20:05","2020.1.22 18:15","2020.1.22 11:51","2020.1.22 10:13","2020.1.22 9:42","2020.1.21 22:17","2020.1.21 22:15","2020.1.21 22:11","2020.1.21 20:13","2020.1.21 20:08","2020.1.21 17:16","2020.1.21 11:35","2020.1.21 10:54","2020.1.21 10:16","2020.1.21 10:11","2020.1.17 18:30","2020.1.17 18:19","2020.1.17 15:32","2020.1.17 11:16","2020.1.17 11:00","2020.1.17 10:35","2020.1.16 17:31","2020.1.15 8:53","2020.1.15 8:48","2020.1.15 8:41","2020.1.15 8:35","2020.1.15 8:33","2020.1.14 10:44","2020.1.14 10:28","2020.1.14 9:55","2020.1.14 9:12","2020.1.14 9:02","2020.1.13 18:04","2020.1.13 17:21","2020.1.13 16:24","2020.1.13 16:06","2020.1.13 9:24","2020.1.10 20:01","2020.1.10 17:35","2020.1.10 15:01","2020.1.10 9:30","2020.1.9 21:26","2020.1.9 18:39","2020.1.9 18:10","2020.1.9 16:49","2020.1.9 16:43","2020.1.9 15:05","2020.1.9 14:51","2020.1.9 10:41","2020.1.8 23:31","2020.1.8 21:45","2020.1.8 20:21","2020.1.8 17:29","2020.1.8 17:13","2020.1.8 17:03","2020.1.8 16:41","2020.1.8 16:30","2020.1.8 16:09","2020.1.8 16:04","2020.1.8 11:38","2020.1.8 10:43","2020.1.8 9:14","2020.1.8 9:10","2020.1.8 8:39","2020.1.8 8:32","2020.1.8 8:22","2020.1.8 8:17","2020.1.7 17:29","2020.1.7 16:27","2020.1.7 15:01","2020.1.7 14:56","2020.1.7 8:34","2020.1.7 8:29","2020.1.6 20:09","2020.1.6 17:41","2020.1.6 16:30","2020.1.6 16:27","2020.1.6 15:12","2020.1.3 19:39","2020.1.3 17:44","2020.1.3 16:48","2020.1.3 16:32","2020.1.3 16:23","2020.1.3 16:20","2020.1.3 16:18","2020.1.3 14:14","2020.1.3 13:54","2020.1.3 12:31","2020.1.3 12:17","2020.1.3 11:47","2020.1.3 10:58","2020.1.3 10:50","2020.1.3 10:40","2020.1.3 9:07","2019.12.30 13:07","2019.12.30 12:21","2019.12.30 11:48","2019.12.30 11:34","2019.12.30 9:54","2019.12.27 16:34","2019.12.27 15:40","2019.12.27 10:55","2019.12.27 9:07","2019.12.21 12:14","2019.12.21 0:32","2019.12.20 22:56","2019.12.20 22:30","2019.12.20 22:07","2019.12.20 16:07","2019.12.20 13:51","2019.12.20 10:36","2019.12.20 0:06","2019.12.19 23:54","2019.12.19 22:54","2019.12.19 22:44","2019.12.19 22:17","2019.12.19 21:44","2019.12.19 20:59","2019.12.19 20:24","2019.12.19 16:40","2019.12.19 9:37","2019.12.19 9:30","2019.12.18 18:30","2019.12.18 15:59","2019.12.18 11:23","2019.12.18 11:18","2019.12.18 10:47","2019.12.18 10:43","2019.12.18 9:06","2019.12.17 17:25","2019.12.17 17:17","2019.12.17 17:12","2019.12.17 17:08","2019.12.17 10:52","2019.12.17 8:31","2019.12.16 18:29","2019.12.16 17:51","2019.12.16 15:59","2019.12.16 15:48","2019.12.16 13:19","2019.12.16 11:00","2019.12.13 17:20","2019.12.13 16:26","2019.12.13 15:27","2019.12.13 12:48","2019.12.13 9:25","2019.12.13 0:14","2019.12.13 0:11","2019.12.13 0:03","2019.12.13 0:00","2019.12.12 22:40","2019.12.12 22:34","2019.12.12 21:44","2019.12.12 20:00","2019.12.12 18:59","2019.12.12 18:17","2019.12.12 10:59","2019.12.12 10:44","2019.12.12 9:02","2019.12.11 17:09","2019.12.11 10:35","2019.12.11 10:30","2019.12.11 9:39","2019.12.11 9:03","2019.12.11 9:02","2019.12.10 23:38","2019.12.10 22:32","2019.12.10 21:53","2019.12.10 21:50","2019.12.10 20:27","2019.12.10 18:29","2019.12.10 18:27","2019.12.10 18:00","2019.12.10 17:26","2019.12.9 22:26","2019.12.9 15:31","2019.12.9 15:21","2019.12.9 10:06","2019.12.7 0:43","2019.12.7 0:15","2019.12.6 23:59","2019.12.6 23:53","2019.12.6 22:30","2019.12.6 17:29","2019.12.6 15:01","2019.12.5 16:15","2019.12.5 11:55","2019.12.5 11:49","2019.12.5 10:44","2019.12.5 9:30","2019.12.5 9:28","2019.12.5 8:20","2019.12.5 8:12","2019.12.4 22:38","2019.12.4 21:27","2019.12.4 20:53","2019.12.4 18:06","2019.12.4 16:29","2019.12.4 16:09","2019.12.4 11:58","2019.12.4 10:00","2019.12.4 9:12","2019.12.3 23:48","2019.12.3 21:44","2019.12.3 21:08","2019.12.3 19:29","2019.12.3 19:21","2019.12.3 19:10","2019.12.3 16:47","2019.12.3 16:23","2019.12.3 12:30","2019.12.3 0:00","2019.12.2 22:00","2019.12.2 20:37","2019.12.2 17:34","2019.12.2 9:16","2019.11.30 1:33","2019.11.30 1:30","2019.11.30 0:49","2019.11.29 23:04","2019.11.29 22:23","2019.11.29 22:13","2019.11.29 20:36","2019.11.29 18:37","2019.11.29 0:19","2019.11.29 0:10","2019.11.28 15:15","2019.11.28 9:30","2019.11.28 8:15","2019.11.26 17:13","2019.11.26 17:04","2019.11.26 13:43","2019.11.26 10:46","2019.11.26 8:25","2019.11.25 22:25","2019.11.22 18:10","2019.11.22 18:08","2019.11.22 18:00","2019.11.22 17:30","2019.11.22 17:08","2019.11.21 16:07","2019.11.21 14:39","2019.11.21 10:47","2019.11.21 9:58","2019.11.21 8:55","2019.11.20 16:11","2019.11.20 10:29","2019.11.20 10:21","2019.11.20 10:17","2019.11.19 9:46","2019.11.19 9:39","2019.11.19 9:30","2019.11.19 9:18","2019.11.19 9:12","2019.11.18 22:19","2019.11.18 19:07","2019.11.18 17:13","2019.11.18 16:16","2019.11.15 9:43","2019.11.15 9:40","2019.11.15 9:37","2019.11.14 18:10","2019.11.14 16:18","2019.11.14 14:54","2019.11.14 13:04","2019.11.14 11:00","2019.11.14 9:43","2019.11.14 9:30","2019.11.13 19:13","2019.11.13 19:03","2019.11.13 18:56","2019.11.13 18:40","2019.11.13 18:29","2019.11.13 18:19","2019.11.13 18:09","2019.11.13 18:03","2019.11.13 15:36","2019.11.13 9:44","2019.11.12 17:08","2019.11.12 12:36","2019.11.12 12:31","2019.11.12 11:24","2019.11.12 11:14","2019.11.12 11:00","2019.11.11 23:53","2019.11.11 21:44","2019.11.11 21:13","2019.11.11 21:08","2019.11.11 18:09","2019.11.11 18:01","2019.11.11 16:32","2019.11.11 15:21","2019.11.11 15:13","2019.11.11 11:58","2019.11.11 9:58","2019.11.9 1:19","2019.11.8 23:58","2019.11.8 21:22","2019.11.8 19:54","2019.11.8 10:03","2019.11.7 22:31","2019.11.7 21:30","2019.11.7 16:50","2019.11.7 16:20","2019.11.7 12:08","2019.11.7 10:49","2019.11.6 23:38","2019.11.6 15:41","2019.11.6 15:29","2019.11.6 9:07","2019.11.6 9:03","2019.11.6 0:09","2019.11.6 0:00","2019.11.5 23:39","2019.11.5 23:22","2019.11.5 22:39","2019.11.5 12:45","2019.11.5 12:33","2019.11.5 8:34","2019.11.4 21:39","2019.11.4 19:31","2019.11.1 18:10","2019.11.1 10:53","2019.11.1 10:45","2019.11.1 9:54","2019.10.31 23:20","2019.10.31 22:42","2019.10.31 22:34","2019.10.31 19:59","2019.10.31 18:05","2019.10.31 16:12","2019.10.31 12:32","2019.10.31 10:59","2019.10.31 10:30","2019.10.31 10:00","2019.10.31 9:00","2019.10.29 23:15","2019.10.29 17:19","2019.10.29 17:15","2019.10.29 16:56","2019.10.28 21:48","2019.10.28 20:36","2019.10.28 20:06","2019.10.28 16:53","2019.10.28 9:34","2019.10.25 22:47","2019.10.25 21:49","2019.10.25 21:38","2019.10.24 21:38","2019.10.24 20:44","2019.10.24 19:33","2019.10.24 17:00","2019.10.24 16:15","2019.10.24 16:01","2019.10.24 15:59","2019.10.23 23:58","2019.10.23 23:45","2019.10.23 19:02","2019.10.23 17:48","2019.10.23 16:05","2019.10.23 11:44","2019.10.23 10:52","2019.10.23 10:35","2019.10.23 9:05","2019.10.22 19:53","2019.10.22 17:23","2019.10.22 16:03","2019.10.22 9:17","2019.10.21 17:17","2019.10.21 17:10","2019.10.21 15:35","2019.10.21 15:22","2019.10.21 15:07","2019.10.18 14:55","2019.10.18 11:08","2019.10.18 11:00","2019.10.17 16:13","2019.10.17 14:47","2019.10.17 9:43","2019.10.17 9:30","2019.10.16 10:19","2019.10.16 9:41","2019.10.16 9:36","2019.10.16 9:01","2019.10.15 19:49","2019.10.15 17:00","2019.10.15 16:54","2019.10.15 16:32","2019.10.15 15:37","2019.10.15 9:02","2019.10.14 20:05","2019.10.14 18:20","2019.10.14 16:52","2019.10.14 15:54","2019.10.14 15:51","2019.10.14 15:32","2019.10.14 11:38","2019.10.14 10:15","2019.10.14 9:53","2019.10.14 9:37","2019.10.14 9:33","2019.10.14 9:19","2019.10.14 9:00","2019.10.12 1:31","2019.10.12 1:15","2019.10.12 1:02","2019.10.12 0:10","2019.10.11 23:56","2019.10.11 20:16","2019.10.11 19:08","2019.10.11 19:05","2019.10.11 17:39","2019.10.11 17:32","2019.10.11 15:00","2019.10.11 13:47","2019.10.11 13:38"};
   datetime date0;
   int shift5 = 0;
   int shift15 = 0;
   int shift30 = 0;
   int shift1h = 0;
   bool strongm5 = false;
   bool strongm15 = false; 
   bool strongm30 = false;
   bool strong1h = false;
   string result = "";
   for (int i=0; i < ArraySize(TIMES); i++) {
      shift5 = iBarShift("USDJPY",PERIOD_M5,StrToTime(TIMES[i])-32400);
      shift15 = iBarShift("USDJPY",PERIOD_M15,StrToTime(TIMES[i])-32400);
      shift30 = iBarShift("USDJPY",PERIOD_M30,StrToTime(TIMES[i])-32400);
      shift1h = iBarShift("USDJPY",PERIOD_H1,StrToTime(TIMES[i])-32400);
      
      strongm5 = isEMAStrong("USDJPY",PERIOD_M5,shift5);
      strongm15 = isEMAStrong("USDJPY",PERIOD_M15,shift15);
      strongm30 = isEMAStrong("USDJPY",PERIOD_M30,shift30);
      strong1h = isEMAStrong("USDJPY",PERIOD_H1,shift1h);
      result += strongm5+","+strongm15+","+strongm30+","+strong1h+"\n";
   }
   exportData("ema-",result,true);
}
  
/**
* 1=ascending
* 2=descending
* 0=nothing
**/
int isTrending (string symbol,int shift, int days) {
   int candle_pos = 0;
   double open;
   double close;
   double leadingA;
   double leadingB;
   for (int i=shift+1; i < shift+days+1; i++) {
      if (!isEMAStrong(symbol,PERIOD_M5,i)) return 0;
      open = iCustom(symbol,PERIOD_M5,"HeikenAshi_DM",2,i);
      close = iCustom(symbol,PERIOD_M5,"HeikenAshi_DM",3,i);
      leadingA = iIchimoku(symbol,PERIOD_M5,9,26,52,3,i); //一目均衡(先行スパンA)
      leadingB = iIchimoku(symbol,PERIOD_M5,9,26,52,4,i); //一目均衡(先行スパンB)
      candle_pos = getHeikenPosition(open,close,leadingA,leadingB);
      if (candle_pos == 2) {
         if (getEntity(open,close) != 1) return 0;
      }else if(candle_pos == 3) {
         if (getEntity(open,close) != 2) return 0;
      }else{
         return 0;
      }
   }
   int serialnums = serialNum(symbol,PERIOD_M5,10,shift+1);
   if (serialnums < days) return 0;
   
   if (candle_pos == 2) return 1;
   return 2;
}
void automata(string pair, bool isHigh) {
   int WebR;
   string URL = "http://localhost:8080/bid";
   int timeout = 5000;
   string cookie = NULL,headers;
   char post[],FTPdata[];
   string str= "{\"pair\":\""+pair+"\",\"isHigh\":\""+isHigh+"\}";

   StringToCharArray( str, post );
   WebR = WebRequest( "POST", URL, cookie, NULL, timeout, post, 0, FTPdata, headers );
   Print(WebR);
   return(WebR);
}

void collectFeature(int timeframe, int shift, int days, string prefix) {
   datetime time;
   string time_str = "";
   string data = "";
   string symbol_data = "";
   int isEMA70 = 0;
   int isEMA200 = 0;
   int nth_cycle = 0;
   int serial_num = 0;
   double current_size = 0;
   double aggr_size = 0;
   
   double ema70 = 0;
   double ema200 = 0;
   double open = 0;
   double close = 0;
   double high = 0;
   double low = 0;
   double high_0 = 0;
   double low_0 = 0;
   int entity = 0;
   
   for (int i=shift; i <= shift+days; i++) {
      time = iTime("USDJPY",timeframe,i) + 60 * 60 * 9;
      time_str = TimeYear(time)+"-"+TimeMonth(time)+"-"+TimeDay(time);
      symbol_data = time_str;
      for (int j=0; j<ArraySize(PAIRS); j++) {
         ema70 = iMA(PAIRS[j],timeframe,70,0,MODE_EMA,PRICE_CLOSE,i);
         ema200 = iMA(PAIRS[j],timeframe,200,0,MODE_EMA,PRICE_CLOSE,i);
         open = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",2,i);
         close = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",3,i);
      
         isEMA70 = 0;
         if (open > close){
            if (open > ema70 && ema70 > close) {
               isEMA70 = 1;
            }
         }else{
            if (open < ema70 && ema70 < close) {
               isEMA70 = 1;
            }
         }
         isEMA200 = 0;
         if (open > close){
            if (open > ema200 && ema200 > close) {
               isEMA200 = 1;
            }
         }else{
            if (open < ema200 && ema200 < close) {
               isEMA200 = 1;
            }
         }
         
         high = iHigh(PAIRS[j],timeframe,i);
         low = iLow(PAIRS[j],timeframe,i);
         current_size = high - low;
         
         serial_num = serialNum(PAIRS[j],timeframe,20,i);
         high_0 = iHigh(PAIRS[j],timeframe,i+serial_num-1);
         low_0 = iLow(PAIRS[j],timeframe,i+serial_num-1);
         // 上昇
         if (open < close){
            aggr_size = high - low_0;
         }else{
            // 下降
            aggr_size = high_0 - low;
         }

         
         symbol_data += ","+isEMA70+","+isEMA200+","+current_size+","+serial_num+","+aggr_size;
         

         
      }
       data += symbol_data+"\n";
   }
   //Print(data);
   exportData(prefix+"sampling-feature-"+days+"days",data,true);
}

void collectFibo(int timeframe, int shift, int days, string prefix) {
   datetime time;
   string time_str = "";
   string data = "";
   string symbol_data = "";

   double close = 0;
   double highest = 0;
   double lowest = 0;
   int is_paradigm = 0;
   double fibo0 = 0;
   //23.6
   double fibo23 = 0;
   //38.2
   double fibo38 = 0;
   //50
   double fibo50 = 0;
   //61.8
   double fibo61 = 0;
   //100
   double fibo100 = 0;
   double pos = 0;
   
   int type = 0;
   int n_type = 0;
   int high_low_check_period = 45;
   
   string fibos = "";
   
   for (int i=shift; i <= shift+days; i++) {
      time = iTime("USDJPY",timeframe,i) + 60 * 60 * 9;
      time_str = TimeYear(time)+"-"+TimeMonth(time)+"-"+TimeDay(time);
      symbol_data = "";
      for (int j=0; j<ArraySize(PAIRS); j++) {;
         close = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",3,i);
         type = getEntity(iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",2,i), iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",3,i));
         n_type = getEntity(iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",2,i-1), iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",3,i-1));
      
         if (type != n_type) {
            is_paradigm = 1;
         }else{
            is_paradigm = 0;
         }
         
         fibo100 = highest(PAIRS[j],timeframe,i,high_low_check_period);
         fibo0 = lowest(PAIRS[j],timeframe,i,high_low_check_period);
         fibo23 = ((fibo100 - fibo0) * 0.236) + fibo0;
         fibo38 = ((fibo100 - fibo0) * 0.382) + fibo0;
         fibo50 = ((fibo100 - fibo0) * 0.5) + fibo0;
         fibo61 = ((fibo100 - fibo0) * 0.618) + fibo0;
         
         if (fibo0 < close && close < fibo23) {
            if (type == 1) {
               fibos = "0,1,0,0,0,0";
            } else {
               fibos = "1,0,0,0,0,0";
            }
         } else if (fibo23 < close && close < fibo38) {
            if (type == 1) {
               fibos = "0,0,1,0,0,0";
            } else {
               fibos = "0,1,0,0,0,0";
            }
         } else if (fibo38 < close && close < fibo50) {
            if (type == 1) {
               fibos = "0,0,0,1,0,0";
            } else {
               fibos = "0,0,1,0,0,0";
            }
         } else if (fibo50 < close && close < fibo61) {
            if (type == 1) {
               fibos = "0,0,0,0,1,0";
            } else {
               fibos = "0,0,0,1,0,0";
            }
         } else if (fibo61 < close && close < fibo100) {
            if (type == 1) {
               fibos = "0,0,0,0,0,1";
            } else {
               fibos = "0,0,0,0,1,0";
            }
         } else {
            fibos = "0,0,0,0,0,0";
         }
         
         pos = (close -  fibo0) / (fibo100 - fibo0);
         
         symbol_data += time_str + "," + PAIRS[j] + ","+ fibos + ","+pos + "," + is_paradigm+"\n";
         
      }
       data += symbol_data;
   }
   //Print(data);
   exportData(prefix+"sampling-fibo-"+days+"days",data,true);
}

double highest (string symbol, int timeframe, int shift, int days) {
   double highest = 0;
   double current_hi = 0;
   int idx = 0;
   double pits[4];
   
   for (int i=shift; i <= shift+days; i++) {
      pits[0] = iCustom(symbol,timeframe,"HeikenAshi_DM",0,i);
      pits[1] = iCustom(symbol,timeframe,"HeikenAshi_DM",1,i);
      pits[2] = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i);
      pits[3] = iCustom(symbol,timeframe,"HeikenAshi_DM",3,i);
      idx = ArrayMaximum(pits,WHOLE_ARRAY,0);
      current_hi = pits[idx];
      if (current_hi > highest) {
         highest = current_hi;
      }
   }
   return highest;
}

double lowest (string symbol, int timeframe, int shift, int days) {
   double lowest = 1000;
   double current_lo = 0;
   int idx = 0;
   double pits[4];
   
   for (int i=shift; i <= shift+days; i++) {
      pits[0] = iCustom(symbol,timeframe,"HeikenAshi_DM",0,i);
      pits[1] = iCustom(symbol,timeframe,"HeikenAshi_DM",1,i);
      pits[2] = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i);
      pits[3] = iCustom(symbol,timeframe,"HeikenAshi_DM",3,i);
      idx = ArrayMinimum(pits,WHOLE_ARRAY,0);
      current_lo = pits[idx];
      if (current_lo < lowest) {
         lowest = current_lo;
      }
   }
   return lowest;
}

void collectOHLC(string symbol, int timeframe, int shift, int days, string prefix) {
   double close = 0;
   double open = 0;
   double high = 0;
   double low = 0;
   double n_close = 0;
   double n_open = 0;
   double n_high = 0;
   double n_low = 0;
   datetime time;
   string time_str = "";
   string data = "";
   string symbol_data = "";
   int is_hige = 0;
   int is_paradigm = 0;
   int type = 0;
   int n_type = 0;
   double hige_rev = 0;
   double hige_order = 0;
   double n_hige_rev = 0;
   double n_hige_order = 0;
   int serial = 0;
   
   double r = 0;
   
   for (int i=shift; i <= shift+days; i++) {
      time = iTime(symbol,timeframe,i) + 60 * 60 * 9;
      time_str = TimeYear(time)+"-"+TimeMonth(time)+"-"+TimeDay(time);
      symbol_data = "";
      for (int j=0; j<ArraySize(PAIRS); j++) {
         open = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",2,i);
         close = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",3,i);
         type = getEntity(open, close);

         if (type == 1) {
            low = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",0,i);
            high = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",1,i);
            hige_rev = open - low;
            hige_order = high - close;
         }else if (type == 2) {
            low = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",1,i);
            high = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",0,i);
            hige_rev = high - open;
            hige_order = close - low;
         }
      
         n_open = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",2,i-1);
         n_close = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",3,i-1);
         n_type = getEntity(n_open, n_close);
      
         if (n_type == 1) {
            n_low = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",0,i-1);
            n_high = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",1,i-1);
            n_hige_rev = n_open - n_low;
            n_hige_order = n_high - n_close;
         }else if (n_type == 2) {
            n_low = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",1,i-1);
            n_high = iCustom(PAIRS[j],timeframe,"HeikenAshi_DM",0,i-1);
            n_hige_rev = n_high - n_open;
            n_hige_order = n_close - n_low;
         }

         if (type != n_type) {
            is_paradigm = 1;
         }else{
            is_paradigm = 0;
         }
      
         if (n_hige_rev != 0 && n_hige_order != 0) {
            is_hige = 1;
         }else{
            is_hige = 0;
         }
         
         serial = serialNum(PAIRS[j],timeframe,50,i);
      
         r = leadingMomentum(PAIRS[j], timeframe, i);
         //Print(time_str+","+delta+","+ent_per_total+","+high_low_hige);
         //data += time_str+","+MathAbs(open-close)+","+hige_rev+","+hige_order+","+is_paradigm+","+is_hige+"\n";

  
         symbol_data += time_str+","+PAIRS[j]+","+open+","+close+","+high+","+low+","+serial+","+r+","+MathAbs(open-close)+","+is_paradigm+"\n";
         
      }
       data += symbol_data;
   }
   
   exportData(prefix+"sampling-data-"+days+"days",data,true);
}

void collectPastEntity(string symbol, int timeframe, int shift, int days, string prefix) {
   double close = 0;
   double open = 0;
   string data = "";
   
   for (int i=shift; i <= shift+days; i++) {
      Print(i);
      open = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i);
      close = iCustom(symbol,timeframe,"HeikenAshi_DM",3,i);
      data += iTime(symbol,timeframe,i)+","+getEntitySize(open,close)+"\r\n";
   }
   exportData(prefix,data,true);
}
int surpassedSince(int shift, int timeframe, int min_nontouching, int days) {
    double ema200 = 0;
    double close = 0;
    
    for (int i=shift; i < shift+days; i++) {
      ema200 = iMA(Symbol(),timeframe,200,0,MODE_EMA,PRICE_CLOSE,i);
      close = iCustom(Symbol(),timeframe,"HeikenAshi_DM",3,i);
      Print("at i="+i+" is crossing="+(ema200 > close));
    }
   /**
   int ema_converted = ema200Surpass(0,timeframe,12);
   if (ema_converted > 0) {
     int since_last_converted = (TimeCurrent() - last_ema_converted)/60;
     if (since_last_converted > 5) {
      //slackprivate(Symbol()+" is touching ema200 since="+ema_converted);
      last_ema_converted = TimeCurrent();
      ema_convert = true;
     }
   }
   */
}
void testSignal() {
   string start_date = "2019.10.12 00:00";
   datetime date0 = StrToTime(start_date);
   string date0_str = "";
   int counter = 0;
   int shift = 0;
   
   while (counter < 20000) {
      counter++;
      if (TimeDayOfWeek(date0) == 6) {
         date0_str = TimeToStr(date0,TIME_DATE)+" 00:00";
         date0 = StrToTime(date0_str) + (86400 * 2);
      }
      shift = iBarShift(Symbol(),PERIOD_M5,date0);
      if (hasSignal(shift) == 1) {
         date0_str = TimeToStr(date0,TIME_DATE)+" 00:00";
         date0 = StrToTime(date0_str) + 86400;
      }else{
         date0 = date0 + 300;
      }
   }
}

bool isFactorial(string symbol, int count, int shift) {
   double ema20_0 = 0;
   double ema70_0 = 0;
   double ema20_1 = 0;
   double ema70_1 = 0;
   double diff_0 = 0;
   double diff_1 = 0;
   
   for (int i=count+shift; i >= shift; i--) {
      ema20_0 = iMA(symbol,PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,i);
      ema70_0 = iMA(symbol,PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,i);
      ema20_1 = iMA(symbol,PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,i+1);
      ema70_1 = iMA(symbol,PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,i+1);
      if (ema20_0 > ema70_0) {
         diff_0 = ema20_0 - ema70_0;
         diff_1 = ema20_1 - ema70_1;
      }else{
         diff_0 = ema70_0 - ema20_0;
         diff_1 = ema70_1 - ema20_1;
      }
      Print("i="+i+" diff_0="+diff_0+" diff_1="+diff_1+" rate="+(diff_0/diff_1));
   }
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
   
   string ema5csv = "";
   string ema20csv = "";
   string ema70csv = "";
   string ema200csv = "";
   
   for (i=0; i<ArraySize(ema5_1); i++) {
      ema5csv += ema5_1[i]+",";
      ema20csv += ema20_1[i]+",";
      ema70csv += ema70_1[i]+",";
      ema200csv += ema200_1[i]+",";
   }
   /*
   Print("ema5cc="+getCorrelated(ema5_1,ema5_2));
   Print("ema20cc="+getCorrelated(ema20_1,ema20_2));
   Print("ema70cc="+getCorrelated(ema70_1,ema70_2));
   Print("ema200cc="+getCorrelated(ema200_1,ema200_2));
   */
   
   if (getCorrelated(ema5_1,ema5_2) > threshold &&
   getCorrelated(ema20_1,ema20_2) > threshold &&
   getCorrelated(ema70_1,ema70_2) > threshold &&
   getCorrelated(ema200_1,ema200_2) > threshold
   ) {
      return true;
   }
   return false;
}


int getEventScore (string symbol, int timeframe, int shift) {
    int serial_days = 3;
    int serialnums = serialNum(symbol,timeframe,serial_days-1,shift);
    if (serialnums != serial_days) return 0;
    
    double open = 0;
    double open1 = 0;
    double close = 0;
    int type = getEntityType(symbol,timeframe,shift);
    bool is_trending = true;
    for (int i=shift; i < shift+serial_days; i++) {
      open = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i);
      open1 = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i+1);
      if (is_trending) {
         if (type == 1) {
            if (open < open1) is_trending = false;
         }else{
            if (open > open1) is_trending = false;
         }
      }
    }
    
    if (!is_trending) return 0;
    
    bool ema200_crossed = false;
    bool ema70_crossed = false;
    bool ema20_crossed = false;
    
    int examine_days = 3;
    double ema20 = 0;
    double ema70 = 0;
    double ema200 = 0;

    for (i=shift; i < shift+examine_days; i++) {
      ema20 = iMA(symbol,timeframe,20,0,MODE_EMA,PRICE_CLOSE,i);
      ema70 = iMA(symbol,timeframe,70,0,MODE_EMA,PRICE_CLOSE,i);
      ema200 = iMA(symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,i);
      open = iCustom(symbol,timeframe,"HeikenAshi_DM",2,i);
      close = iCustom(symbol,timeframe,"HeikenAshi_DM",3,i);
      if (!ema20_crossed) {
         if (open > close){
            if (open > ema20 && ema20 > close) {
               ema20_crossed = true;
            }
         }else{
            if (open < ema20 && ema20 < close) {
               ema20_crossed = true;
            }
         }
      }
      if (!ema70_crossed) {
         if (open > close){
            if (open > ema70 && ema70 > close) {
               ema70_crossed = true;
            }
         }else{
            if (open < ema70 && ema70 < close) {
               ema70_crossed = true;
            }
         }
      }
      if (!ema200_crossed) {
         if (open > close){
            if (open > ema200 && ema200 > close) {
               ema200_crossed = true;
            }
         }else{
            if (open < ema200 && ema200 < close) {
               ema200_crossed = true;
            }
         }
      }
    }
    int event_points = 0;
    if (ema20_crossed) event_points += 20;
    if (ema70_crossed) event_points += 70;
    if (ema200_crossed) event_points += 200;
    return event_points;
}

int getDailyPhase(string symbol,int shift) {
    int phase = 0;
    int conversion_examine_dates = 3;
    //if converting

    bool crossed_before = false;
    for (int i=1+shift; i < shift+1+conversion_examine_dates; i++) {
        if (!crossed_before) {
            crossed_before = isCross(symbol,PERIOD_D1,i);
        }
    }
    bool crossed_today = isCross(symbol,PERIOD_D1,shift);
    int serialnums = serialNum(symbol,PERIOD_D1,conversion_examine_dates-1,shift+1);
    //daily converted or cross state
    if (crossed_today && !crossed_before && serialnums == conversion_examine_dates) {
        return 1;
    }
    
    //if converting within 3 days
    bool converted_before = false;
    for (i=shift; i < shift+conversion_examine_dates; i++) {
        if (!converted_before) {
            if (getEntityType(symbol,PERIOD_D1,i) != getEntityType(symbol,PERIOD_D1,i+1)) {
               converted_before = serialNum(symbol,PERIOD_D1,10,i+1) > 9;
            }
        }
    }
    if (converted_before) return 2;
    //if become large
    int threshold = 1;
    double pits_d[4];
    pits_d[0] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",0,0+shift);
    pits_d[1] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",1,0+shift);
    pits_d[2] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",2,0+shift);
    pits_d[3] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",3,0+shift);
    int highestPitIdx = ArrayMaximum(pits_d,WHOLE_ARRAY,0);
    int lowestPitIdx = ArrayMinimum(pits_d,WHOLE_ARRAY,0);
    double sizeday = MathAbs(pits_d[highestPitIdx] - pits_d[lowestPitIdx]);
    double dailyZ = getDailyZ(symbol,sizeday,PERIOD_D1,31,0+shift);
    pits_d[0] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",0,1+shift);
    pits_d[1] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",1,1+shift);
    pits_d[2] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",2,1+shift);
    pits_d[3] = iCustom(symbol,PERIOD_D1,"HeikenAshi_DM",3,1+shift);
    highestPitIdx = ArrayMaximum(pits_d,WHOLE_ARRAY,0);
    lowestPitIdx = ArrayMinimum(pits_d,WHOLE_ARRAY,0);
    sizeday = MathAbs(pits_d[highestPitIdx] - pits_d[lowestPitIdx]);
    double last_dailyZ = getDailyZ(symbol,sizeday,PERIOD_D1,31,1+shift);
    if (last_dailyZ < dailyZ) {
       double diff = MathAbs(dailyZ - last_dailyZ);
       if (diff > threshold) {
           return 3;
       }
    }
    return 0;

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
   
   string target_time = TimeToStr(iTime(Symbol(),PERIOD_M5,shift) + 32400);
   
   Print("time="+(target_time));
   //Print("time="+(target_time)+" correlated pairs="+text+" emas="+ema_pairs); 
   //Print("possible trend StrongCCnum="+weight+"/10 alignedEMAnum="+ema_strength+"/5");;

   return 1;
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

void testHaruto() {
   string logs = "";
   double open;
   double close;
   double ema3;
   double ema60;
   double RSI;
   bool isAsc;
   //for test
   int count = 64;
   double total_signal = 0;
   double wins = 0;
   double open_after;
   double close_after;
   double high_after;
   double low_after;
   bool isAsc_after;
   
   //test
   for (int i=0; i < count;i++) {
      ema3 = iMA(Symbol(),PERIOD_M1,3,0,MODE_EMA,PRICE_CLOSE,i); //指数移動平均(3)
      ema60 = iMA(Symbol(),PERIOD_M1,60,0,MODE_EMA,PRICE_CLOSE,i); //指数移動平均(60)
      open = iOpen(Symbol(),PERIOD_M1,i);
      close = iClose(Symbol(),PERIOD_M1,i);
      RSI = iRSI(Symbol(),PERIOD_M1,5,PRICE_CLOSE,i+1);
      isAsc = close > open;
      
      //test codes
      open_after = iOpen(Symbol(),PERIOD_M1,i-1);
      close_after = iClose(Symbol(),PERIOD_M1,i-1);
      high_after = iHigh(Symbol(),PERIOD_M1,i-1);
      low_after = iLow(Symbol(),PERIOD_M1,i-1);
      isAsc_after = close_after > open_after;

      if (ema3 > ema60) {
         //is candle not touching MA3
         if (open > ema3 && close > ema3) {
            if (!isAsc) {
               if (RSI > 70) {
                  //test
                  total_signal++;
                  if (open_after < open) {
                     logs += "W"+i+",";
                     wins++;
                  }else{
                     logs += "L"+i+",";
                  }
               }
            }
         }
      }else if (ema3 < ema60) {
         //is candle not touching MA3
         if (open < ema3 && close < ema3) {
            if (isAsc) {
               if (RSI < 30) {
                  total_signal++;
                  if (open_after > open) {
                     logs += "W"+i+",";
                     wins++;
                  }else{
                     logs += "L"+i+",";
                  }
               }
            }
         }
      }
   }
   Print(logs);
   Print("total signal="+total_signal+" wins="+wins+" odds="+StringSubstr((wins/total_signal),0,4));

}

bool isWalking(int shift) {
   double ema200 = 0;
   double ema70 = 0;
   double ema20 = 0;
   double ema5 = 0;
   double last3z = getLast3Z(shift,true);
   double min = 0.99995;
   double max = 1.00005;
   double goodZ = -1;
   bool walking20 = true;
   bool walking70 = true;
   bool walking200 = true;
   for (int i=2+shift; i >= shift; i--) {
      ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,i); //指数移動平均(20)
      ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,i); //指数移動平均(20)
      ema20 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,i); //指数移動平均(20)
      ema5 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,i); //指数移動平均(5)
      if (walking20) {
         if (max < ema5/ema20 || ema5/ema20 < min) walking20 = false;
      }
      if (walking70) {
         if (max < ema5/ema70 || ema5/ema70 < min) walking70 = false;
      }
      if (walking200) {
         if (max < ema5/ema200 || ema5/ema200 < min) walking200 = false;
      }
      Print("at "+i+" 3z="+StringSubstr(last3z,0,4)+" ema20="+StringSubstr(ema5/ema20,0,8)+" ema70="+StringSubstr(ema5/ema70,0,8)+" ema200="+StringSubstr(ema5/ema200,0,8));
   }
   if (walking20){
      Print("walking @20");
      if (last3z <= goodZ) return true;
   }
   if (walking70){
      Print("walking @70");
      if (last3z <= goodZ) return true;
   }
   if (walking200){
      Print("walking @200");
      if (last3z <= goodZ) return true;
   }
   return false;
}
double getLast3Z(int shift, bool include_self = false) {
   double this_open;
   double this_close;
   double this_size;
   double this_mean;
   double this_sigma;
   double last_3_z = 0;
   int adjuster = include_self ? -1 : 0;
   for (int i=shift+3+adjuster; i > shift+adjuster; i--) {
     this_open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,i);
     this_close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,i);
     this_size = getEntitySize(this_open,this_close);
     this_mean = getMeanEntity(Symbol(),PERIOD_M5,30,i);
     this_sigma = getStdEntity(this_mean,Symbol(),PERIOD_M5,30,i);
     last_3_z += getZ(this_mean,this_sigma,this_size);
   }
   last_3_z = last_3_z/3;
   return last_3_z;
}
int emaConversion(int shift) {
   int start_shift = shift;
   int threshold = 10;
   double ema5 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,shift+1); //指数移動平均(5);
   double ema20 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,shift+1); //指数移動平均(20)
   double ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,shift+1); //指数移動平均(70)
   double ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,shift+1);//指数移動平均(200)
   bool strong = false;
   bool up = false;
   bool dwn = false;
   if (ema5 > ema20 && ema20 > ema70 && ema70 > ema200) {
      strong = true;
      up = true;
   }else if (ema5 < ema20 && ema20 < ema70 && ema70 < ema200) {
      strong = true;
      dwn = true;
   }
   if (!strong) return 0;
   int num = 0;
   shift += 1;
   while (strong) {
      ema5 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(5);
      ema20 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(20)
      ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(70)
      ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,shift);//指数移動平均(200)
      if (ema5 > ema20 && ema20 > ema70 && ema70 > ema200) {
         strong = true;
      }else if (ema5 < ema20 && ema20 < ema70 && ema70 < ema200) {
         strong = true;
      }else{
         strong = false;
      }
      if (!strong) break;
      num++;
      shift += 1;
    }
   if (num < threshold) return 0;
   double bid = MarketInfo(Symbol(),MODE_BID);
   ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,start_shift); //指数移動平均(20)
   if (up && bid < ema200) {
      return num;
   }else if (dwn && bid > ema200) {
      return num;
   }
   return 0;
 }

int ema200Surpass(int shift, int timeframe, int threshold) {
   int start_shift = shift;
   double ema5 = iMA(Symbol(),timeframe,5,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(5);
   double ema20 = iMA(Symbol(),timeframe,20,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(20)
   double ema70 = iMA(Symbol(),timeframe,70,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(70)
   double ema200 = iMA(Symbol(),timeframe,200,0,MODE_EMA,PRICE_CLOSE,shift);//指数移動平均(200)
   double bid = MarketInfo(Symbol(),MODE_BID);
   double close = iCustom(Symbol(),timeframe,"HeikenAshi_DM",3,shift);
   bool strong = false;
   bool up = false;
   bool dwn = false;
   if (close > ema200 && ema5 > ema200 && ema20 > ema200 && ema70 > ema200) {
      strong = true;
      up = true;
   }else if (close < ema200 && ema5 < ema200 && ema20 < ema200 && ema70 < ema200) {
      strong = true;
      dwn = true;
   }
   if (!strong) return 0;
   int num = 0;
   shift += 1;
   while (strong) {
      ema5 = iMA(Symbol(),timeframe,5,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(5);
      ema20 = iMA(Symbol(),timeframe,20,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(20)
      ema70 = iMA(Symbol(),timeframe,70,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(70)
      ema200 = iMA(Symbol(),timeframe,200,0,MODE_EMA,PRICE_CLOSE,shift);//指数移動平均(200)
      if (ema5 > ema200 && ema20 > ema200 && ema70 > ema200) {
         strong = true;
      }else if (ema5 < ema200 && ema20 < ema200 && ema70 < ema200) {
         strong = true;
      }else{
         strong = false;
      }
      if (!strong) break;
      num++;
      shift += 1;
    }
   if (num < threshold) return 0;
   ema200 = iMA(Symbol(),timeframe,200,0,MODE_EMA,PRICE_CLOSE,start_shift); //指数移動平均(20)
   if (up && bid < ema200) {
      return num;
   }else if (dwn && bid > ema200) {
      return num;
   }
   return 0;
 }
 string getMinuteCSV (double &bids[],double &times[]) {
   string bid_string = "";
   int count = 0;
   int new_count = 0;
   double last_time = 0;
   int padding = 0;
   bool added = false;

   //1秒後とのサンプリング　なかったら前のと同じ
   while(bids[count] != 0 && count+1 < ArraySize(bids)){
      if (count == 0) {
         new_count++;
         bid_string += (new_count)+","+bids[count];
         bid_string += "\n";
      }else{
         //前回と1秒以上あいた時
         if (times[count]-last_time > 1000) {
            padding = MathFloor((times[count]-last_time)/1000);
            //秒数分だけ前ので代用
            for (int i=0; i < padding; i++) {
               bid_string += new_count+","+bids[count-1];
               bid_string += "\n";
               new_count++;
            }
            added = false;
         }else{
            //1秒以内の時
            added = true;
         }
         if (!added) {
            bid_string += new_count+","+bids[count];
            bid_string += "\n";
            added = true;
         }
      }
      last_time = times[count];
      new_count++;
      count++;
   }
   return bid_string;
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

int sendChange(double value) {
   int WebR;
   string URL = "http://localhost/transit";
   int timeout = 5000;
   string cookie = NULL,headers;
   char post[],FTPdata[];
   string str= "&pair="+Symbol()+"&change="+value;

   StringToCharArray( str, post );
   WebR = WebRequest( "POST", URL, cookie, NULL, timeout, post, 0, FTPdata, headers );
   return(WebR);
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
      return pos_size/neg_size;
   }else{
      return neg_size/pos_size;
   }
}

string monitor() {
   string filename = "";
   string val = "";
   int handle;
   double usdjpy[2500];
   double eurusd[2500];
   double gbpjpy[2500];
   double eurjpy[2500];
   double audusd[2500];
   double audjpy[2500];
   double nzdjpy[2500];
   logs = "";
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
   string idx[7];
   int cnt = 0;
   for (int i=0; i<ArraySize(PAIRS); i++) {
      cnt = 0;
      filename = PAIRS[i]+"-cp.csv";
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
            Print(PAIRS[i]+": period="+period[i]);
            break;
            case 43://isPeriodic
            isPeriodic[i] = StringToInteger(val);
            break;
            case 44://time
            Print(PAIRS[i]+": idx="+FileReadString(handle));
            idx[i] = FileReadString(handle);
            default:
            break;
         }
         cnt++;
      }
      FileClose(handle);
   }
   return;
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
   return MathCeil((hige_rev/hige_order) * 100) * 1.0 /100;
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

double getHigeRatio(int count, int timeframe, int shift, string which) {
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
         if (which == "reverse") hige = open - low;
         if (which == "order") hige = high - close;
      }else if (entity_type == 2) {
         low = iCustom(Symbol(),timeframe,"HeikenAshi_DM",1,i);
         high = iCustom(Symbol(),timeframe,"HeikenAshi_DM",0,i);
         if (which == "reverse") hige = high - open;
         if (which == "order") hige = close - low;
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
      Print("now shift="+(shift+count)+" type="+entity_type);
      if (type == 1 && entity_type != 1) return false;
      if (type == 2 && entity_type != 2) return false;
   }
   return true;
}

int serialNumEA(int period, int count, int shift) {
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

double getCorrelated (double &bids[],double &times[]) {
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

   for (i=0; i<count; i++) {
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
int inTwist(int target, int rounds) {
   double leadingA1 = 0;
   double leadingB1 = 0;
   double leadingA2 = 0;
   double leadingB2 = 0;
   for (int i=0+target; i<rounds+target; i++) {
      leadingA1 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,i);
      leadingB1 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,i);
      leadingA2 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,i+1);
      leadingB2 = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,i+1);
      if (leadingA2 > leadingB2 && leadingB1 > leadingA1) {
         return 1;
      }
      if (leadingA2 < leadingB2 && leadingB1 < leadingA1) {
         return 1;
      }
   }
   return 0;
}

double naturalLog(double ce, double x) {
   return ce * MathPow(2.718281828459,-x);
}

void sizeChangeAt(int count, double z_threshold) {
   string msg = "";
   int shift = 0;
   double sizechange = 0;
   double open = 0;
   double close = 0;
   double high = 0;
   double low = 0;
   double leadingA = 0;
   double leadingB = 0;
   double z = 0;
   double z2 = 0;
   int candle_position = 0;
   int entity_type = 0;
   double mean = 0;
   double multiplyby = 0;
   double entity[4];
   int highestIdx = 0;
   int lowestIdx = 0;
   double highest = 0;
   double lowest = 0;

   for (int i=0; i<count; i++) {
      sizechange = getSizeChange(i+1,i,true,PERIOD_M5,Symbol());
      open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,i);
      low = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,i);
      high = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,i);
      leadingA = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,i); //一目均衡(先行スパンA)
      leadingB = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,i); //一目均衡(先行スパンB)
      entity[0] = open;
      entity[1] = close;
      entity[2] = low;
      entity[3] = high;
      highestIdx = ArrayMaximum(entity,WHOLE_ARRAY,0);
      highest = entity[highestIdx];
      lowestIdx = ArrayMinimum(entity,WHOLE_ARRAY,0);
      lowest = entity[lowestIdx];
      candle_position = getHeikenPosition(open,close,leadingA,leadingB);
      entity_type = getEntity(open ,close);
      mean = meanEntitySize(12,i+1);
      //last30m
      z = getZscore(MEAN,STD,mean);
      //now
      z2 = getZscore(MEAN,STD,getEntitySize(open,close));
      multiplyby = naturalLog(1.5,z);
      if (candle_position != 6) {
         if (z2 - z > 3 && ((entity_type == 1 && candle_position != 3)||(entity_type == 2 && candle_position != 2))) {
         msg += "\n"+TimeToString(iTime(Symbol(),PERIOD_M5,i))+" change="+sizechange
         +" x"+multiplyby+" before="+z+" after="+z2+" diff="+(z2-z)
         +" type="+entity_type+" pos="+candle_position;
         }
      }
   }
   Alert(msg);
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

double getDailyZ(string symbol,double sample, int timeshift, int count, int initial) {
   if (daily_std != 0 && daily_mean != 0) {
      return MathCeil(((sample - daily_mean)/daily_std) * 100) * 1.0/100;
   }
   double sum = 0;
   double devsum = 0;
   double pits[4];
   int highestIdx = 0;
   int lowestIdx = 0;

   for (int i=0+initial; i<count+initial; i++) {
      pits[0] = iCustom(symbol,timeshift,"HeikenAshi_DM",0,i);
      pits[1] = iCustom(symbol,timeshift,"HeikenAshi_DM",1,i);
      pits[2] = iCustom(symbol,timeshift,"HeikenAshi_DM",2,i);
      pits[3] = iCustom(symbol,timeshift,"HeikenAshi_DM",3,i);
      highestIdx = ArrayMaximum(pits,WHOLE_ARRAY,0);
      lowestIdx = ArrayMinimum(pits,WHOLE_ARRAY,0);
      sum += MathAbs(pits[highestIdx] - pits[lowestIdx]);
   }

   daily_mean = sum/count;
   for (i=0; i<count; i++) {
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
   daily_std = MathSqrt(variance);
   return MathCeil(((sample - daily_mean)/daily_std) * 100) * 1.0/100;
 }

double getStds(int start_idx, int count, int timeshift) {
   double open = 0;
   double close= 0;
   double size = 0;
   double mean = 0;
   double sum = 0;
   double devsum = 0;

   for (int i=0+start_idx; i<(count+start_idx); i++) {
      open = iCustom(Symbol(),timeshift,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),timeshift,"HeikenAshi_DM",3,i);
      size = getEntitySize(open,close);
      sum += size;
   }

   mean = sum/count;
   for (i=0+start_idx; i<(count+start_idx); i++) {
      open = iCustom(Symbol(),timeshift,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),timeshift,"HeikenAshi_DM",3,i);
      size = getEntitySize(open,close);
      devsum += MathPow((
         size-mean
       ),2);
   }
   double variance = devsum/count;
   double std = MathSqrt(variance);
   double cv = std/mean;
   return MathCeil(cv * 100) * 1.0 /100;
}

double getPOSNEGRatio(int start_idx, int count) {
   double open = 0;
   double close= 0;
   double size = 0;
   double possum = 0;
   double negsum = 0;
   int pos_cnt = 0;
   int neg_cnt = 0;

   for (int i=0+start_idx; i<(count+start_idx); i++) {
      open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,i);
      size = getEntitySize(open,close);
      if(close > open) {
         possum += size;
         pos_cnt++;
      }else{
          negsum += size;
          neg_cnt++;
      }
   }
   if (negsum == 0) return 100;
   double pos_neg_ratio = possum/negsum;
   return MathCeil(pos_neg_ratio * 100) * 1.0 /100;
}

void testMonitor() {
   logs = "";
   string filename = "";
   string val = "";
   int handle;
   int bandtype[7];
   int along20[7];
   int along70[7];
   int along200[7];
   double z[7];
   double z30[7];
   double zcloud[7];
   int candlepos[7];
   datetime alerttime[7];
   int skyrocket[7];
   int emapos[7];
   double hige15[7];
   double hige30[7];
   double hige1H[7];
   int ticks[7];
   double tickchange[7];
   int cnt = 0;
   for (int i=0; i<ArraySize(PAIRS); i++) {
      cnt = 0;
      filename = PAIRS[i]+".csv";
      handle = FileOpen(filename, FILE_CSV|FILE_READ|FILE_SHARE_READ, ',');
      while(!FileIsEnding(handle)){
         val = FileReadNumber(handle);
         switch (cnt) {
            case 0://type
            bandtype[i] = StringToDouble(val);
            break;
            case 1://along20
            along20[i] = StringToDouble(val);
            break;
            case 2://along70
            along70[i] = StringToDouble(val);
            break;
            case 3://along200
            along200[i] = StringToDouble(val);
            break;
            case 4://z1H
            z[i] = StringToDouble(val);
            break;
            case 5://z30m
            z30[i] = StringToDouble(val);
            break;
            case 6://cloud size
            zcloud[i] = StringToDouble(val);
            break;
            case 7://candle position
            candlepos[i] = StringToDouble(val);
            break;
            case 8://alerttime
            alerttime[i] = StringToTime(val);
            break;
            case 9://skyrocket
            break;
            case 10://emapos
            emapos[i] = StringToInteger(val);
            break;
            case 11://hige15
            hige15[i] = StringToInteger(val);
            break;
            case 12://hige30
            hige30[i] = StringToInteger(val);
            break;
            case 13://hige1H
            hige1H[i] = StringToInteger(val);
            break;
            case 14://ticks
            ticks[i] = StringToInteger(val);
            break;
            case 15://tickchange
            tickchange[i] = StringToInteger(val);
            break;
            default:
            break;
         }
         cnt++;
      }
      FileClose(handle);
   }
   double hige15mu = mean("hige15",hige15,false);
   double hige30mu = mean("hige30",hige30,false);
   double hige1Hmu = mean("hige1H",hige1H,false);
   double z30mu = mean("z30",z30,true);
   double cloudmu = mean("zcloud",zcloud,true);
   for (i=0; i<ArraySize(zcloud); i++) {
      Print("i="+i+" data="+zcloud[i]);
   }
   Print(" z30mu="+z30mu+" cloud="+cloudmu);
}
bool isStableEMA(int count, int timeframe) {
   double ema20 = 0;
   double ema70 = 0;
   double ema200 = 0;
   double open = iCustom(Symbol(),timeframe,"HeikenAshi_DM",2,0);
   double close = iCustom(Symbol(),timeframe,"HeikenAshi_DM",3,0);
   double leadingA = iIchimoku(Symbol(),timeframe,9,26,52,3,0); //一目均衡(先行スパンA)
   double leadingB = iIchimoku(Symbol(),timeframe,9,26,52,4,0); //一目均衡(先行スパンB)
   int candle_position_org = getHeikenPosition(open,close,leadingA,leadingB);
   if (candle_position_org != 2 && candle_position_org != 3) return(false);
   int candle_position = 0;

   for (int i=0; i<count;i++) {
      open = iCustom(Symbol(),timeframe,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),timeframe,"HeikenAshi_DM",3,i);
      leadingA = iIchimoku(Symbol(),timeframe,9,26,52,3,i); //一目均衡(先行スパンA)
      leadingB = iIchimoku(Symbol(),timeframe,9,26,52,4,i); //一目均衡(先行スパンB)
      candle_position = getHeikenPosition(open,close,leadingA,leadingB);
      if (candle_position != candle_position_org)return(false);

      ema20 = iMA(Symbol(),timeframe,20,0,MODE_EMA,PRICE_CLOSE,i); //指数移動平均(20)
      ema70 = iMA(Symbol(),timeframe,70,0,MODE_EMA,PRICE_CLOSE,i); //指数移動平均(70)
      ema200 = iMA(Symbol(),timeframe,200,0,MODE_EMA,PRICE_CLOSE,i); //指数移動平均(200)

     if (candle_position_org == 2) {
      if (ema20 > ema70 && ema70 > ema200) {
         continue;
      }
     }else if (candle_position_org == 3) {
      if (ema20 < ema70 && ema70 < ema200) {
         continue;
      }
      }
      return(false);
   }
   return(true);
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

double mean(string prefix, double &data[], bool ignoremax) {
   double sum = 0;
   int count = 0;
   int  maxidx = ArrayMaximum(data,WHOLE_ARRAY,0);
   for (int i=0; i<ArraySize(data);i++) {
      sum += data[i];
      count++;
   }
   if (ignoremax) {
      sum -= data[maxidx];
      count--;
   }
   double mean = sum/count;
   logs += " mean-"+prefix+"="+mean;
   return mean;
}

double getMeanEntity(string symbol,int period, int count, int shift) {
   double open;
   double close;
   double sum;
   for (int i=shift; i<count+shift; i++) {
      open = iCustom(symbol,period,"HeikenAshi_DM",2,i);
      close = iCustom(symbol,period,"HeikenAshi_DM",3,i);
      sum += getEntitySize(open,close);
   }
   return sum/count;
}

double getStdEntity(double mean, string symbol,int period, int count, int shift) {
   double open;
   double close;
   double dev_sum;
   for (int i=shift; i<count+shift; i++) {
      open = iCustom(symbol,period,"HeikenAshi_DM",2,i);
      close = iCustom(symbol,period,"HeikenAshi_DM",3,i);
      dev_sum += MathPow((
         getEntitySize(open,close)-mean
       ),2);
   }
   double variance = dev_sum/count;
   double std = MathSqrt(variance);
   return std;
}

double getZ(double mean, double std, double sample) {
   return MathCeil(((sample - mean)/std) * 100) * 1.0/100;
}


double getZscore(double &mu[], double &sigma[], double sample) {
   double mean = mu[getIndex()];
   double std = sigma[getIndex()];
   return MathCeil(((sample - mean)/std) * 100) * 1.0/100;
 }
//0:"USDJPY" 1:"EURUSD" 2:"GBPJPY" 3:"EURJPY" 4:"AUDUSD" 5:"AUDJPY" 6:"NZDJPY"};
bool stableAlong(string prefix, int &along[], int minumum) {
   int num = 0;
   logs += " "+prefix+":";
   if (along[1] > 4 || along[3] > 4) {
      if (-1 == StringFind(logs,"EURUSD",0)) logs += "EURUSD/";
      if (-1 == StringFind(logs,"EURJPY",0)) logs += "EURJPY/";
      num++;
   }
   if (along[1] > 4 || along[0] > 4) {
      if (-1 == StringFind(logs,"EURUSD",0)) logs += "EURUSD/";
      if (-1 == StringFind(logs,"USDJPY",0)) logs += "USDJPY/";
      num++;
   }
   if (along[4] > 4 || along[1] > 4) {
      if (-1 == StringFind(logs,"EURUSD",0)) logs += "EURUSD/";
      if (-1 == StringFind(logs,"AUDUSD",0)) logs += "AUDUSD/";
      num++;
   }
   if (along[4] > 4 || along[0] > 4) {
      if (-1 == StringFind(logs,"USDJPY",0)) logs += "USDJPY/";
      if (-1 == StringFind(logs,"AUDUSD",0)) logs += "AUDUSD/";
      num++;
   }
   if (along[2] > 4 || along[3] > 4) {
      if (-1 == StringFind(logs,"GBPJPY",0)) logs += "GBPJPY/";
      if (-1 == StringFind(logs,"EURJPY",0)) logs += "EURJPY/";
      num++;
   }
   if (along[5] > 4 || along[6] > 4) {
      if (-1 == StringFind(logs,"NZDJPY",0)) logs += "NZDJPY/";
      if (-1 == StringFind(logs,"AUDJPY",0)) logs += "AUDJPY/";
      num++;
   }
   logs += " "+prefix+"num="+num;
   if (num > minumum)return(true);
   else return(false);
}
//0:"USDJPY" 1:"EURUSD" 2:"GBPJPY" 3:"EURJPY" 4:"AUDUSD" 5:"AUDJPY" 6:"NZDJPY"};
bool stableBandType(int &bandType[], int minumum) {
   int num = 0;
   if (bandType[1] > 0 || bandType[3] > 0) {
      num++;
   }
   if (bandType[1] > 0 || bandType[0] > 0) {
      num++;
   }
   if (bandType[4] > 0 || bandType[1] > 0) {
      num++;
   }
   if (bandType[4] > 0 || bandType[0] > 0) {
      num++;
   }
   if (bandType[2] > 0 || bandType[3] > 0) {
      num++;
   }
   if (bandType[5] > 0 || bandType[6] > 0) {
      num++;
   }
   logs += " bandtypenum="+num;
   if (num > minumum)return(true);
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
   logs += " "+prefix+"="+num;
   if (num > minimum)return(true);
   else return(false);
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

 string pastEntitySizes(int interval, int start_idx) {
   double max = 0;
   double min = 0;
   double close = 0;
   double open = 0;
   double size = 0;
   double sum = 0;

   for (int i=0; i<interval; i++) {
      close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,i+start_idx);
      open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,i+start_idx);
      size = MathAbs(open-close);
      if (i == 0) {
         max = min = size;
      }
      if (size > max) {
         max = size;
      }
      if (size < min) {
         min = size;
      }
      sum += size;
   }

   double mean = sum/interval;
   return "max="+max+" min="+min+" mean="+mean;

 }

 string getAllPastEntity(int count, int period) {
   double low = 0;
   double high = 0;
   double size = 0;
   string entities = "";
   for (int i=0; i<count; i++) {
      low = iCustom(Symbol(),period,"HeikenAshi_DM",0,i);
      high = iCustom(Symbol(),period,"HeikenAshi_DM",1,i);
      size = MathAbs(high-low);
      entities += size+"\n";
   }
   return entities;
 }

  string getAllPastCloudsize() {
   int count = 65345;
   double leadingA = 0;
   double leadingB = 0;
   double size = 0;
   string entities = "";
   for (int i=0; i<count; i++) {
      leadingA = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,i); //一目均衡(先行スパンA)
	   leadingB = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,i); //一目均衡(先行スパンB)
      size = MathAbs(leadingA-leadingB);
      entities += size+"\n";
   }
   return entities;
 }

 void task (int shift) {

   double upper = getValueByText("High_Low_Plus_UpperPrice");
   double lower = getValueByText("High_Low_Plus_LowerPrice");

   double ema5 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(5)
   double ema20 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(20)s
   double ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(200)
   double ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(200)
   double close5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,shift);
   double open5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,shift);

   double entity_size5 = getEntitySize(open5, close5);

   int entity_type5 = getEntity(open5,close5);
   bool isAsc;
   double low5 = 0;
   double high5 = 0;
   if (entity_type5 == 1) {
      low5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,shift);
      high5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,shift);
      isAsc = true;
   }else if (entity_type5 == 2) {
      low5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,shift);
      high5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,shift);
      isAsc = false;
   }

   double innerEma200Hige = 0;
   double outerEma200Hige = 0;
   double bid = MarketInfo(Symbol(),MODE_BID);
   string message = "";
   message += " close="+close5;
   if (ema5 < ema200 && ema20 < ema200 && ema70 < ema200 && isAsc && close5 < ema200 && (ema200 < bid || ema200 < high5)){
      double above_ema = 0;
      if (bid>high5) {
         above_ema = bid;
         message += " highbid="+bid;
      }else{
         above_ema = high5;
         message += " highhigh="+high5;
      }
      innerEma200Hige = (ema200-close5)/entity_size5;
      outerEma200Hige = (above_ema - ema200)/entity_size5;
      innerEma200Hige = MathCeil(innerEma200Hige * 100) * 1.0/100;
      outerEma200Hige = MathCeil(outerEma200Hige * 100) * 1.0/100;
      message += " inner="+innerEma200Hige+" outer="+outerEma200Hige;
      Alert(message);
   }else if(ema5 > ema200 && ema20 > ema200 && ema70 > ema200 && !isAsc && close5 > ema200 && (ema200 > bid || ema200 > low5)) {
      double below_ema = 0;
      if (bid < low5) {
         below_ema = bid;
         message += " lowbid="+bid;
      }else{
         below_ema = low5;
         message += " lowlow="+low5;
      }
      innerEma200Hige = (close5 - ema200)/entity_size5;
      outerEma200Hige = (ema200 - below_ema)/entity_size5;
      innerEma200Hige = MathCeil(innerEma200Hige * 100) * 1.0/100;
      outerEma200Hige = MathCeil(outerEma200Hige * 100) * 1.0/100;
      message += " inner="+innerEma200Hige+" outer="+outerEma200Hige;
      Alert(message);
   }else{
      Alert(message);
   }
 }

  int inBand(double top_band, double bottom_band, int count) {
    double open = 0;
    double close = 0;

    for (int i=0; i<count; i++) {
      open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,i);
      if (close > top_band) {
         Print(" i="+i+" reason=close > top_band");
         return 0;
      }
      if (open > top_band) {
         Print(" i="+i+" reason=open > top_band");
         return 0;
      }
      if (open < bottom_band) {
         Print(" i="+i+" reason=open < bottom_band");
         return 0;
      }
      if (close < bottom_band) {
         Print(" i="+i+" reason=close < bottom_band");
         return 0;
      }
    }
    return 1;
 }

 /**
 * 0 Bandクロスなし
 * 1 Band20クロス
 * 2 Band20+70クロス
 * 3 Band20+70+200クロス
 */
  int bandWalk(int start_idx,int count) {
    int cnt = 0;
    double ema200 = 0;
    double ema70 = 0;
    double ema20 = 0;
    double entity[4];
    int highestIdx = 0;
    double highest = 0;
    int lowestIdx = 0;
    double lowest = 0;
    int ema20Crossed = 0;
    int ema70Crossed = 0;
    int ema200Crossed = 0;

    for (int i=0+start_idx; i<count+start_idx; i++) {
      entity[0] = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,i);//open
      entity[1] = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,i);//close
      entity[2] = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,i);//low
      entity[3] = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,i);//high
      highestIdx = ArrayMaximum(entity,WHOLE_ARRAY,0);
      highest = entity[highestIdx];
      lowestIdx = ArrayMinimum(entity,WHOLE_ARRAY,0);
      lowest = entity[lowestIdx];
      ema20 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,i); //指数移動平均(20)
      ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,i); //指数移動平均(70)
      ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,i); //指数移動平均(200)
      if (highest > ema200 && ema200 > lowest) {
         Print("ema200 crossed at="+cnt);
         ema200Crossed++;
      }
      if (highest > ema70 && ema70 > lowest) {
         Print("ema70 crossed at="+cnt);
         ema70Crossed++;
      }
      if (highest > ema20 && ema20 > lowest) {
         Print("ema20 crossed at="+cnt);
         ema20Crossed++;
      }
      cnt++;

    }
    if (ema20Crossed > 0 && ema70Crossed == 0 && ema200Crossed == 0) {
      Print("ema20 crossed num="+ema20Crossed);
      return 1;
    }

    if (ema20Crossed > 0 && ema70Crossed > 0 && ema200Crossed == 0) {
      Print("ema20 crossed num="+ema20Crossed+" ema70Crossed num="+ema70Crossed);
      return 2;
    }
    if (ema20Crossed > 0 && ema70Crossed > 0 && ema200Crossed > 0) {
      Print("ema20 crossed num="+ema20Crossed+" ema70Crossed num="+ema70Crossed+" ema200Crossed num="+ema200Crossed);
      return 3;
    }
    Print("Nothing has crossed");
    return 0;
 }

 string analysis(string symbol, int start_idx, int count) {
    double open = 0;
    double close = 0;
    double entity_size = 0;
    double ENTITY_SIZE[60];
    double cloud_size = 0;
    double CLOUD_SIZE[60];
    double entity_sum = 0;
    double cloud_sum = 0;
    double entity_deviance_sum = 0;
    double cloud_deviance_sum = 0;
    string msg = "";
    double leadingA = 0;
    double leadingB = 0;

    for (int i=0; i<count; i++) {
      open = iCustom(symbol,PERIOD_M5,"HeikenAshi_DM",2,start_idx+i);
      close = iCustom(symbol,PERIOD_M5,"HeikenAshi_DM",3,start_idx+i);
      leadingA = iIchimoku(symbol,PERIOD_M5,9,26,52,3,start_idx+i); //一目均衡(先行スパンA)
	   leadingB = iIchimoku(symbol,PERIOD_M5,9,26,52,4,start_idx+i); //一目均衡(先行スパンB)
      entity_size = getEntitySize(open, close);
      ENTITY_SIZE[i] = entity_size;
      entity_sum += entity_size;
      cloud_size = MathAbs(leadingA-leadingB);
      CLOUD_SIZE[i] = cloud_size;
      cloud_sum += cloud_size;
    }

    double entity_mean = entity_sum/count;
    double cloud_mean = cloud_sum/count;

    for (i=0; i<count; i++) {
       entity_deviance_sum += MathPow((
         ENTITY_SIZE[i]-entity_mean
       ),2);
       cloud_deviance_sum += MathPow((
         CLOUD_SIZE[i]-cloud_mean
       ),2);
    }
    double entity_variance = entity_deviance_sum/count;
    double entity_std = MathSqrt(entity_variance);
    entity_std = entity_std/entity_mean;
    entity_std = MathCeil(entity_std * 100000) * 1.0/100000;
    double cloud_variance = cloud_deviance_sum/count;
    double cloud_std = MathSqrt(cloud_variance);
    cloud_std = cloud_std/cloud_mean;
    cloud_std = MathCeil(cloud_std * 100000) * 1.0/100000;

    msg += " sizemean="+entity_mean;
    msg += " sizestd="+entity_std;
    msg += " cloudmean="+cloud_mean;
    msg += " cloudstd="+cloud_std;

    return msg;
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
 bool willBreakEMA () {
   string logs = "";
   double omegaHigh = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",0,0);
   double omegaLow = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",1,0);
   double open5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,0);
   double close5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,0);
   double open51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,1);
   double close51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,1);
   double low5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,0);
   double high5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,0);
   double low51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,1);
   double high51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,1);
   double entity_size5 = getEntitySize(open5, close5);
   double entity_size51 = getEntitySize(open51, close51);
   double size5 = MathAbs(high5 - low5);
   double size51 = MathAbs(high51 - low51);
   double ema20 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(20)
   double ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(70)
   double ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(200)
   int entity_type5 = getEntity(open5,close5);
   if (entity_type5 == 0) {
      return false;
   }

   bool isAsc;
   if (entity_type5 == 1) {
      isAsc = true;
   }else if (entity_type5 == 2) {
      isAsc = false;
   }
   double bid = MarketInfo(Symbol(),MODE_BID);
   double ema200_1 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,1); //指数移動平均(200)
   if (isAsc) {
      logs += " isAsc";
      if (bid > ema200) logs += " A";
      if (ema200 < (high5 + entity_size5)) logs += " B";
      if (close51 <= ema200_1) logs += " C";
      if (ema200 > ema70) logs += " D";
      if (ema200 > ema20) logs += " E";
   }else{
      logs += " isDesc";
      if (bid < ema200) logs += " A";
      if (ema200 > (low5 - entity_size5)) logs += " B";
      if (close51 >= ema200_1) logs += " C";
      if (ema200 < ema70) logs += " D";
      if (ema200 < ema20) logs += " E";
   }
   Print(logs);
   //EMA200を超えそうか判定
   if (isAsc && bid > ema200 && close51 <= ema200_1 && ema200 > ema70 && ema200 > ema20) {
      return true;
   }else if (!isAsc && bid < ema200 && close51 >= ema200_1 && ema200 < ema70 && ema200 < ema20) {
      return true;
   }

   return false;
 }

 void updateOmega (int count) {
   double highest = 0;
   double lowest = 0;
   double omegaHigh = 0;
   double omegaLow = 0;

   for (int i=0; i<count;i++) {
      omegaHigh = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",0,i);
      omegaLow = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",1,i);
      if (highest == 0 || omegaHigh > highest) highest = omegaHigh;
      if (lowest == 0 || omegaLow < lowest) lowest = omegaLow;
   }
 }

 double getWhiskerSize (bool isAsc, int index) {
   double open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,index);
   double close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,index);
   double low = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,index);
   double high = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,index);
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

int getEntityType (string symbol, int timeframe, int shift) {
   double open = iCustom(symbol,timeframe,"HeikenAshi_DM",2,shift);
   double close = iCustom(symbol,timeframe,"HeikenAshi_DM",3,shift);
   return getEntity(open,close);
}

void hasWhisker () {
   double open = iCustom(Symbol(),PERIOD_M1,"HeikenAshi_DM",2,0);
   double close = iCustom(Symbol(),PERIOD_M1,"HeikenAshi_DM",3,0);
   int entity_type = getEntity(open,close);
   bool isAscOne;
   if (entity_type == 1) {
      isAscOne = true;
   }else if (entity_type == 2) {
      isAscOne = false;
   }else{
      return;
   }

   double high = iCustom(Symbol(),PERIOD_M1,"HeikenAshi_DM",0,0);
   double low = iCustom(Symbol(),PERIOD_M1,"HeikenAshi_DM",1,0);
   double size = getEntitySize(open,close);
   double ratio;
   bool isWhisker = false;
   if (isAscOne) {
      if (low < open) isWhisker = true;
      ratio = (high-close)/size;
   } else {
      if (open < high) isWhisker = true;
      ratio = (close-low)/size;
   }
   Print("ratio="+ratio+" isWhisker="+isWhisker+" isAsc="+isAscOne);
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

double getMeanEntityRatio(int count, int timeframe) {
   double ratioSum = 0;
   double open = 0;
   double close = 0;
   double high = 0;
   double low = 0;
   double entity_type = 0;
   for (int i=0; i<count;i++) {
      open = iCustom(Symbol(),timeframe,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),timeframe,"HeikenAshi_DM",3,i);

      entity_type = getEntity(open,close);
      //上昇
      if (entity_type == 1) {
         low = iCustom(Symbol(),timeframe,"HeikenAshi_DM",0,i);
         high = iCustom(Symbol(),timeframe,"HeikenAshi_DM",1,i);
         if (open > low) {
            ratioSum += (open-low)/(high-low);
            Print("asc @"+i+" ratio="+(open-low)/(high-low));
         }
      }else if (entity_type == 2) {
         low = iCustom(Symbol(),timeframe,"HeikenAshi_DM",1,i);
         high = iCustom(Symbol(),timeframe,"HeikenAshi_DM",0,i);
         if (high > open) {
            ratioSum += (high-open)/(high-low);
            Print("desc @"+i+" ratio="+(high-open)/(high-low));
         }
      }else{
            Print("flat @"+i);
         }
         Print("open="+open+"&high="+high+"&close="+close+"&low="+low);

   }
   return MathCeil((ratioSum/count) * 100) * 1.0/100;
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
   Print("http response status="+WebR);
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