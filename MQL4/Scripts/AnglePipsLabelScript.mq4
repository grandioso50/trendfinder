//+------------------------------------------------------------------+
//|                                         AnglePipsLabelScript.mq4 |
//|                           Copyright (c) 2010, Fai Software Corp. |
//|                                    http://d.hatena.ne.jp/fai_fx/ |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2010, Fai Software Corp."
#property link      "http://d.hatena.ne.jp/fai_fx/"

#property show_inputs

extern int TimeUnit = 60;
extern string _TimeUnit ="TimeUnit is 0(Auto) , 1(min) , 60(h) , 1440(day) ";

//+------------------------------------------------------------------+
int start()
{

if(TimeUnit == 0){
   if(Period()<60){
      TimeUnit = 1;
   }else if(Period()<1440){
      TimeUnit = 60;
   }else{
      TimeUnit = 1440;
   }
}

string UnitString;

if(TimeUnit == 1){
   UnitString = "pp/min";
}else if(TimeUnit == 60){
   UnitString = "pp/h";
}else if(TimeUnit == 1440){
   UnitString = "pp/day";
}else{
   Alert("TimeUnit "+TimeUnit +" is not supported..");
   return(0);
}

while(!IsStopped()){

  int    obj_total=ObjectsTotal();
  string name;
  for(int i=0;i<obj_total;i++)
    {
     name=ObjectName(i);
     if(ObjectType(name)==OBJ_TREND){
     int tm1 = ObjectGet(name,OBJPROP_TIME1);
     int tm2 = ObjectGet(name,OBJPROP_TIME2);
     double pr1 = ObjectGet(name,OBJPROP_PRICE1);
     double pr2 = ObjectGet(name,OBJPROP_PRICE2);
     double a =  tm2-tm1;
     double b=(pr2-pr1)/Point;
     double angle;
     if(tm2==tm1){
      if(pr2>pr1) angle = 999;
      if(pr2<pr1) angle = -999;
     }else{
      angle = (b/a)*60*TimeUnit;
     }   
   if(ObjectFind(name+"_angle") != 0){   
      ObjectCreate(name+"_angle", OBJ_TEXT, 0, tm1, pr1);     
   }else{
      ObjectMove(name+"_angle", 0, tm1, pr1);
   }
   int fl = 1;
   if(TimeUnit == 1440) fl = 0;
   if(MathAbs(angle) < 1) fl = 2;
   ObjectSetText(name+"_angle", DoubleToStr(angle,fl)+UnitString, 12, "Arial", ObjectGet(name,OBJPROP_COLOR)); 
   WindowRedraw();
     }
    }//for
Sleep(300);
}//while
}//start

int deinit()
{
   int    obj_total=ObjectsTotal();
   string name;
   for(int i=0;i<obj_total;i++)
   {
      name=ObjectName(i);
      if(StringFind(name,"_angle")!=-1)ObjectDelete(name);
   }
   WindowRedraw();
}