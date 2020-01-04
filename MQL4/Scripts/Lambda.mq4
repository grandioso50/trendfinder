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
   int current = 9;
   pits_d[0] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",0,current);
   pits_d[1] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",1,current);
   pits_d[2] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",2,current);
   pits_d[3] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",3,current);
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
   int target_shift = iBarShift(Symbol(),PERIOD_M5,D'2019.09.24 10:35');
   //ShellExecuteW(NULL,"open","C:\Users\Kiyoshi\Desktop\batch\minute.bat",NULL,NULL,1);
   //getDailyPhase();

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
   int shift = iBarShift(Symbol(),PERIOD_M5,D'2020.01.03 01:30');
   /*
   for (int i=shift+2500; i >= shift; i--) {
      hasSignal(i);
   }
   */
   testSignal();
   
   //Print(isFactorial(Symbol(),10,shift));
   
  }
void testSignal() {
   string start_date = "2019.10.12 00:00";
   datetime today = TimeCurrent();
   int month = TimeMonth(today);
   int date = TimeDay(today);
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

int hasSignal(int shift) {
   int weight = 0;
   double threshold = 0.4;
   string text = "";
   if (isCorrelated("AUDJPY","NZDJPY",shift,threshold) == 1) {
      text += "a/n,";
      weight++;
   }
   if (isCorrelated("AUDJPY","USDJPY",shift,threshold) == 1) {
      text += "a/u,";
      weight++;
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
   }
   if (isCorrelated("USDJPY","EURJPY",shift,threshold) == 1) {
      text += "u/e,";
      weight++;
   }
   if (isCorrelated("USDJPY","GBPJPY",shift,threshold) == 1) {
      text += "u/g,";
      weight++;
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
   
   string ema_pairs = "";
   
   int ema_strength = 0;
   if (isEMAStrong("AUDJPY",shift)) {
      ema_pairs += "aud,";
      ema_strength++;
   }
   if (isEMAStrong("NZDJPY",shift)) {
      ema_pairs += "nzd,";
      ema_strength++;
   }
   if (isEMAStrong("USDJPY",shift)) {
      ema_pairs += "usd,";
      ema_strength++;
   }
   if (isEMAStrong("EURJPY",shift)) {
      ema_pairs += "eur,";
      ema_strength++;
   }
   if (isEMAStrong("GBPJPY",shift)) {
      ema_pairs += "gbp,";
      ema_strength++;
   }
   
   if (ema_strength < 4) return 0;
   
   string target_time = TimeToStr(iTime(Symbol(),PERIOD_M5,shift) + 32400);
   
   Print("time="+(target_time)+" correlated pairs="+text+" emas="+ema_pairs);
   
   Print("possible trend StrongCCnum="+weight+"/10 alignedEMAnum="+ema_strength+"/5");;

   return 1;
}

bool isEMAStrong(string symbol, int shift) {
   double ema5 = iMA(symbol,PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(5);
   double ema20 = iMA(symbol,PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(20)
   double ema70 = iMA(symbol,PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(70)
   double ema200 = iMA(symbol,PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,shift);//指数移動平均(200)
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

int getDailyPhase() {
    //if become large
    int threshold = 0.4;
    double pits_d[4];
    pits_d[0] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",0,0);
    pits_d[1] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",1,0);
    pits_d[2] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",2,0);
    pits_d[3] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",3,0);
    int highestPitIdx = ArrayMaximum(pits_d,WHOLE_ARRAY,0);
    int lowestPitIdx = ArrayMinimum(pits_d,WHOLE_ARRAY,0);
    double sizeday = MathAbs(pits_d[highestPitIdx] - pits_d[lowestPitIdx]);
    double dailyZ = getDailyZ(sizeday,PERIOD_D1,31,0);
    pits_d[0] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",0,1);
    pits_d[1] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",1,1);
    pits_d[2] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",2,1);
    pits_d[3] = iCustom(Symbol(),PERIOD_D1,"HeikenAshi_DM",3,1);
    highestPitIdx = ArrayMaximum(pits_d,WHOLE_ARRAY,0);
    lowestPitIdx = ArrayMinimum(pits_d,WHOLE_ARRAY,0);
    sizeday = MathAbs(pits_d[highestPitIdx] - pits_d[lowestPitIdx]);
    double last_dailyZ = getDailyZ(sizeday,PERIOD_D1,31,1);
    Print("z0="+dailyZ+" z1="+last_dailyZ);
    if (last_dailyZ < dailyZ) {
       double diff = MathAbs(dailyZ - last_dailyZ);
       if (diff > threshold) {
           return 1;
       }
    }

    int conversion_examine_dates = 3;
    int phase = 0;
    bool crossed_before = false;
    for (int i=1; i < 1+conversion_examine_dates; i++) {
        if (!crossed_before) {
            crossed_before = isCross(PERIOD_D1,i);
        }
    }
    bool crossed_today = isCross(PERIOD_D1,0);
    int serialnums = serialNum(PERIOD_D1,conversion_examine_dates-1,1);
    Print("serialnums="+serialnums+" crossed_today="+crossed_today+" crossed_before="+crossed_before);
    //daily converted or cross state
    if (crossed_today && !crossed_before && serialnums == conversion_examine_dates) {
        return 2;
    }
    return 0;

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

int ema200Surpass(int shift, int threshold) {
   int start_shift = shift;
   double ema5 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(5);
   double ema20 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(20)
   double ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(70)
   double ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,shift);//指数移動平均(200)
   double bid = MarketInfo(Symbol(),MODE_BID);
   double close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,shift);
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
      ema5 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(5);
      ema20 = iMA(Symbol(),PERIOD_M5,20,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(20)
      ema70 = iMA(Symbol(),PERIOD_M5,70,0,MODE_EMA,PRICE_CLOSE,shift); //指数移動平均(70)
      ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,shift);//指数移動平均(200)
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
   ema200 = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,start_shift); //指数移動平均(20)
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

bool isCross(int timeframe, int shift) {
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

double getDailyZ(double sample, int timeshift, int count, int initial) {
   if (daily_std != 0 && daily_mean != 0) {
      return MathCeil(((sample - daily_mean)/daily_std) * 100) * 1.0/100;
   }
   double sum = 0;
   double devsum = 0;
   double pits[4];
   int highestIdx = 0;
   int lowestIdx = 0;

   for (int i=0+initial; i<count+initial; i++) {
      pits[0] = iCustom(Symbol(),timeshift,"HeikenAshi_DM",0,i);
      pits[1] = iCustom(Symbol(),timeshift,"HeikenAshi_DM",1,i);
      pits[2] = iCustom(Symbol(),timeshift,"HeikenAshi_DM",2,i);
      pits[3] = iCustom(Symbol(),timeshift,"HeikenAshi_DM",3,i);
      highestIdx = ArrayMaximum(pits,WHOLE_ARRAY,0);
      lowestIdx = ArrayMinimum(pits,WHOLE_ARRAY,0);
      sum += MathAbs(pits[highestIdx] - pits[lowestIdx]);
   }

   daily_mean = sum/count;
   for (i=0; i<count; i++) {
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
