//作成画面とバッファの指定
#property indicator_separate_window
#property indicator_minimum -1
#property indicator_maximum 2

//初期設定変数
extern bool Grid = false;
extern bool YEAR = false;
extern bool MONTH = true;
extern bool DAY = true;
extern bool HOUR = true;
extern bool MINUTE = true;
extern bool SECOND = false;
extern bool ARROW = false;
extern bool NewLine = false;
extern color GridColor = LightSlateGray;
extern int Time_difference = 7;
extern int FontSize = 8;
extern int TimeInterval = 12;
extern color TextColor = White;

string ObjArray[300000];
datetime JPNT,StandardTime;
//string JPND,JPNM,WinName="JPN_Time_Sub";
string JPND,JPNM,WinName=" ";
int DefPeri,DefWin,ObjTotal;

//初期化
int init(){
   IndicatorShortName(" ");
   if(DefPeri != Period()){
      DefPeri = Period();
      DeleteTimeObject();
   }

   return(0);
}


//終了時　時間表示を削除
int deinit(){
   DeleteTimeObject();
   return(0);
}


int start(){

   int limit=Bars-IndicatorCounted();

   for(int i=limit; i>=0; i--){

      //基準時間を超えたら作成
      if(StandardTime <= Time[i]){
         //日本時間の生成
         JPNT = Time[i] + Time_difference * 3600;
         SetTimeText(Time[i]);
  
         //次の基準時間を設定する
         datetime Period_Interval=DefPeri * 60 * TimeInterval;
         for(StandardTime = Time[i] + Period_Interval;(TimeDayOfWeek(StandardTime) == 0 || TimeDayOfWeek(StandardTime) == 6) && DefPeri < PERIOD_H1;StandardTime += Period_Interval){}
      }
   }
   return(0);

}

void SetTimeText(datetime settime){
   //日付文字列の作成
   string Y="";
   string M="";
   string D="";
  
   JPND = StringSubstr(TimeToStr(JPNT, TIME_DATE),2);
  
   if(YEAR){
      Y=StringSubstr(JPND,0,2);
   }
   if(MONTH){
      if(YEAR){
         Y=StringConcatenate(Y,".");
      }
      M=StringSubstr(JPND,3,2);
   }
   if(DAY){
      if(YEAR || MONTH){
         M=StringConcatenate(M,".");
      }
      D=StringSubstr(JPND,6,2);
   }
   JPND=StringConcatenate(Y,M,D);
 

   //時間文字列の作成
   string h="";
   string m="";
   string s="";

   JPNM = TimeToStr(JPNT, TIME_SECONDS);
   if(HOUR){
      h=StringSubstr(JPNM,0,2);
   }
   if(MINUTE){
      if(HOUR){
         h=StringConcatenate(h,":");
      }
      m=StringSubstr(JPNM,3,2);
   }
   if(SECOND){
      if(HOUR || MINUTE){
         m=StringConcatenate(m,":");
      }
      s=StringSubstr(JPNM,6,2);
   }
   JPNM=StringConcatenate(h,m,s);

   //同じオブジェクトが存在しなければ作成
   if(ObjectFind(StringConcatenate("JPNTS_Arrow",JPND,"_",JPNM)) == -1){
      MakeTimeObject(StringConcatenate("JPNTS_Arrow",JPND,"_",JPNM),StringConcatenate("JPNTS_Text",JPND,"_",JPNM,"_1"),StringConcatenate("JPNTS_Text",JPND,"_",JPNM,"_2"),StringConcatenate("JPNTS_GridJPN",JPND,"_",JPNM),JPND,JPNM,settime);
   }
}

void MakeTimeObject(string ArrowName,string TimeTextName1,string TimeTextName2,string GridName,string DATE,string TIME,datetime settime){
   DefWin=WindowFind(WinName);//念の為
   int Pos=2;

   //矢印の作成
   if(ARROW){
      ObjArray[ObjTotal]=ArrowName;
      ObjTotal++;
      ObjectCreate(ArrowName, OBJ_ARROW,DefWin,settime, Pos);
      Pos--;
      ObjectSet(ArrowName,OBJPROP_ARROWCODE,241);
      ObjectSet(ArrowName,OBJPROP_COLOR,TextColor);

   }
   
   if(NewLine){
      //2行で表示
      //日付の作成
      ObjArray[ObjTotal]=TimeTextName1;
      ObjTotal++;
      ObjectCreate(TimeTextName1, OBJ_TEXT,DefWin,settime, Pos);
      Pos--;
      ObjectSetText(TimeTextName1, DATE, FontSize, "Arial", TextColor);

   
      //時間の作成
      ObjArray[ObjTotal]=TimeTextName2;
      ObjTotal++;
      ObjectCreate(TimeTextName2, OBJ_TEXT,DefWin,settime, Pos);
      Pos--;
      ObjectSetText(TimeTextName2, TIME, FontSize, "Arial", TextColor);

   }else{
      //1行で表示
      ObjArray[ObjTotal]=StringConcatenate(TimeTextName1,"_",TimeTextName2);

      ObjectCreate(ObjArray[ObjTotal], OBJ_TEXT,DefWin,settime, Pos);
      Pos--;
      if(YEAR || MONTH || DAY){
         if(HOUR || MINUTE || SECOND){
            ObjectSetText(ObjArray[ObjTotal], StringConcatenate(DATE,"_",TIME), FontSize, "Arial", TextColor);
         }else{
            ObjectSetText(ObjArray[ObjTotal], DATE, FontSize, "Arial", TextColor);
         }
      }else if(HOUR || MINUTE || SECOND){
            ObjectSetText(ObjArray[ObjTotal], TIME, FontSize, "Arial", TextColor);
      }
      ObjTotal++;
   }
   //グリッドの作成
   if(Grid){
      ObjArray[ObjTotal]=GridName;
      ObjTotal++;
      ObjectCreate(GridName,OBJ_TREND, 0, settime,0,settime,WindowPriceMax(0));
      ObjectSet(GridName,OBJPROP_COLOR,GridColor);
      ObjectSet(GridName, OBJPROP_STYLE, STYLE_DOT);
   }
   ObjectsRedraw();

}

void DeleteTimeObject(){
   DefWin=WindowFind(WinName);

   //配列に格納した名前で削除   
   for(int i = 0 ; i < ObjTotal ;i++){
      if(ObjArray[i] != ""){
         ObjectDelete(ObjArray[i]);
         ObjArray[i]="";
      }
   }
   
   //メソッドからすべてのオブジェクトを取得して削除
   ObjTotal=ObjectsTotal();
   for(i=ObjTotal;i>=0;i--){
      string ObjName=ObjectName(i);
      if(StringSubstr(ObjName,0,5) == "JPNTS"){
         ObjectDelete(ObjName);
      }
   }
  
   
   ObjTotal=0;
}






