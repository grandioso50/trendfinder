void OnStart()
  {
     double low = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",1,15);
     double high = iCustom(Symbol(),PERIOD_M5,"Heiken Ashi",0,15);
     double omegaHigh = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",0,0);
     double omegaLow = iCustom(Symbol(),PERIOD_M5,"Support and Resistance (Barry)",1,0);
     Print("high="+omegaHigh);
     Print("low="+omegaLow);
  }
  
double getValueByText(string objectName) {
   if(ObjectType(objectName)==OBJ_TEXT || ObjectType(objectName)==OBJ_LABEL){
      return StrToDouble(ObjectDescription(objectName));
   }
   return 0;
}
  
  void hasWhisker () {
     double open = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",2,0);
   double close = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",3,0);
   int entity_type = getEntity(open,close);
   bool isAscOne;
   if (entity_type == 1) {
      isAscOne = true;
   }else if (entity_type == 2) {
      isAscOne = false;
   }else{
      return 0;
   }
   
   double high = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",0,0);
   double low = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",1,0);
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