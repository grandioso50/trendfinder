//+------------------------------------------------------------------+
//|                                            AngleLabelScript2.mq4 |
//|                           Copyright (c) 2010, Fai Software Corp. |
//|                                    http://d.hatena.ne.jp/fai_fx/ |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2010, Fai Software Corp."
#property link      "http://d.hatena.ne.jp/fai_fx/"

//+------------------------------------------------------------------+
int start()
{
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

      if(ObjectFind("_angleX") != 0){   
      ObjectCreate("_angleX", OBJ_TRENDBYANGLE, 0, tm1, pr1);     
      }else ObjectMove("_angleX", 0, tm1, pr1); 
      ObjectSet("_angleX", OBJPROP_TIME2,tm2);
      ObjectSet("_angleX", OBJPROP_PRICE2,pr2);
      ObjectSet("_angleX", OBJPROP_RAY,false);
      WindowRedraw();
      Sleep(500);
      double angle = ObjectGet("_angleX",OBJPROP_ANGLE);
      if(angle>180) angle = angle-360;
      //Comment("ag="+angle);
      ObjectDelete("_angleX");
      if(ObjectFind(name+"_angle") != 0){   
         ObjectCreate(name+"_angle", OBJ_TEXT, 0, tm1, pr1);     
         }else ObjectMove(name+"_angle", 0, tm1, pr1); 
         ObjectSetText(name+"_angle", DoubleToStr(angle,0), 12, "Arial", ObjectGet(name,OBJPROP_COLOR)); 
      }
      WindowRedraw();
   }//for
   
Sleep(2000);
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