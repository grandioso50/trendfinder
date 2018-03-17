void OnStart()
  {
     //getMeanEntityRatio(12, PERIOD_M5);
  
     double open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,0);
     double close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,0);
     double open2 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,1);
     double close2 = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,1);
     Print("now size="+getEntitySize(open,close));
     Print("before size="+getEntitySize(open2,close2));
       /*

    double open = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",2,2);
    double close = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",3,2);
    double low = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",0,2);
    double high = iCustom(Symbol(),PERIOD_M5,"HeikenAshi_DM",1,2);
    Print("open="+open+"&high="+high+"&low="+low+"&close="+close);
    */
  
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
 
 bool isSerial(int period) {
   int count = 9;
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
      Print("true at="+count);
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