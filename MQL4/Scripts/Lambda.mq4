double BIG[] = {0.048,0.00048,0.048,0.000048,0.048,0.048,0.048};
string PAIRS[] = {"USDJPY","EURUSD","GBPJPY","EURJPY","AUDUSD","AUDJPY","NZDJPY"};
double MEAN[] = {0.0417450223664439,0.000332018131403119,0.0527167807799457,0.000411982524392215,0.0663341607698775,0.0372893966384425,0.0352369842692413};
double STD[] = {0.0141825157985687,0.000123181988689167,0.019949887948807,0.000177617192047747,0.0257662478856787,0.0119274401866431,0.0128039908008507};
string logs = "";
void OnStart()
  {
   double open5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,2);
   double close5 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,2);
   double open51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,3);
   double close51 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,3);
   double entity_size5 = getEntitySize(open5, close5);
   double entity_size51 = getEntitySize(open51, close51);
   double timesLarger = MathCeil((entity_size5/entity_size51) * 100) * 1.0/100;
   //double mean_size_30m = meanEntitySize(6);
   string csv = getAllPastEntity();
   //exportData(Symbol()+"-ent",csv,true);
   //testMonitor();
   //slackprivate("CYCLE private");
   //slack("normal slack");
   double leadingA = iIchimoku(Symbol(),PERIOD_M5,9,26,52,3,-14); //一目均衡(先行スパンA)
	double leadingB = iIchimoku(Symbol(),PERIOD_M5,9,26,52,4,-14); //一目均衡(先行スパンB)
   double size = MathAbs(leadingA-leadingB);
   double std = getStds(216,12);
   double posnegratio = getPOSNEGRatio(192,6);
   int shift = iBarShift(Symbol(),PERIOD_M5,D'2019.01.11 10:45');
   //sizeChangeAt(1440,2);
   //Alert("shift="+shift+" change="+getSizeChange(123,122)+" time="+TimeToString(iTime(Symbol(),PERIOD_M5,0)));
   double mean = meanEntitySize(1,3);
      //last30m
   double z = getZscore(MEAN,STD,mean);
   Alert(z);
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
      sizechange = getSizeChange(i+1,i,true);
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

double getSizeChange(int before, int after, bool fullsize) {
   double entity[4];
   double open1 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,before);
   double close1 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,before);
   double open2 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,after);
   double close2 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,after);
   if (fullsize) {
      double low2 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,after);
      double high2 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,after);
      entity[0] = open2;
      entity[1] = close2;
      entity[2] = low2;
      entity[3] = high2;
      int highestIdx = ArrayMaximum(entity,WHOLE_ARRAY,0);
      double highest = entity[highestIdx];
      int lowestIdx = ArrayMinimum(entity,WHOLE_ARRAY,0);
      double lowest = entity[lowestIdx];
      return getEntitySize(highest,lowest)/getEntitySize(open1,close1);
   }
   return getEntitySize(open2,close2)/getEntitySize(open1,close1);
}

double getStds(int start_idx, int count) {
   double open = 0;
   double close= 0;
   double size = 0;
   double mean = 0;
   double sum = 0;
   double devsum = 0;
   
   for (int i=0+start_idx; i<(count+start_idx); i++) {
      open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,i);
      size = getEntitySize(open,close);
      sum += size;
   }
   
   mean = sum/count;
   for (i=0+start_idx; i<(count+start_idx); i++) {
      open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,i);
      close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,i);
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
 
 string getAllPastEntity() {
   int count = 65345;
   double low = 0;
   double high = 0;
   double size = 0;
   string entities = "";
   for (int i=0; i<count; i++) {
      low = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,i);
      high = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,i);
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
 
      Print("round="+i+" open="+open+" close="+close+" high="+high+" low="+low+" body="+body+" hige="+hige+" ratio="+(hige/body));
   }
   if (counted == 0) counted = 1;
   return MathPow(ratioProduct,(1.0/(double)counted));
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