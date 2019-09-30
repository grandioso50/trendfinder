//+------------------------------------------------------------------+
//|                                          ScreenCaptureScript.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
/* 
this script will make  screen capture of your chart and saved it in the specified folder in your MT4 installed folder.
e.g. C:\Program Files\Interbank FX Trader 4_Demo\experts\files\...
...
you can use this as script or add these codes to indicator/EA/  to  capture chart status in realtime mode when your own technical 
conditions are triggered
...
 
*/

extern string note1 = "*** Capture chart ON/OFF ***";
extern bool ScreenshotON = True; //FALSE;
extern string SavedChartsFolder = "charts screenshot/"; // name the folder you want to save your charts


string PeriodDesc(int TF_0) {
   switch (TF_0) {
   case 1:
      return ("M1");
   case 5:
      return ("M5");
   case 15:
      return ("M15");
   case 30:
      return ("M30");
   case 60:
      return ("H1");
   case 240:
      return ("H4");
   case 1440:
      return ("D1");
   case 10080:
      return ("W1");
   case 43200:
      return ("MN");
   }
   return ("Unknown TF");
}
   
string DateTimeReformat(string dat_0) {
   string dat_8;
   string dat_ret_16 = "";
   dat_0 = " " + dat_0;
   int dat_len_24 = StringLen(dat_0);
   for (int dat_28 = 0; dat_28 < dat_len_24; dat_28++) {
      dat_8 = StringSetChar(dat_8, 0, StringGetChar(dat_0, dat_28));
      if (dat_8 != ":" && dat_8 != " " && dat_8 != ".") dat_ret_16 = dat_ret_16 + dat_8;
   }
   return (dat_ret_16);
} 
   
 //+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start() {   

string pretxt_40;
   
pretxt_40 = SavedChartsFolder + Symbol() + "_" + PeriodDesc(Period()) + "_" + "strategy name"+"_" + DateTimeReformat(TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS));
WindowScreenShot(pretxt_40 + ".png",1200, 600, 0, -1, -1); // * careful with file type
PlaySound ("shutter.wav");            
}
   return(0);
//+------------------------------------------------------------------+