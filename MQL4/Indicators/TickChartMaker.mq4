//+------------------------------------------------------------------+
//|                                               TickChartMaker.mq4 |
//|                                         Copyright (c) 2009, fai. |
//|                                    http://d.hatena.ne.jp/fai_fx/ |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2009, fai."
#property link      "http://d.hatena.ne.jp/fai_fx/"

#property indicator_chart_window

#include <WinUser32.mqh>
#define  CHART_CMD_UPDATE_DATA            33324
#define  HEADER_BYTE                        129
#define  DATA_BYTE                           44

extern int     MaxTicks  = 5000;
extern int     OmitDigit = 0;


int      FileHandle = -1;
int      TickCount = 0;
string   MySymbol ="";

int init()
  {
   MySymbol = Symbol() + "_T";
   if (OpenHistoryFile() < 0) return (-1);
   TickCount = 0;
   WriteHistoryHeader();
   return(0);
  }
  
int start()
  {
   static bool LogReWrite = false;
   if(LogReWrite) return(0);
   TickCount++;
   WriteHistoryData();
   UpdateChartWindow();
   //Comment(TickCount);
   if(MaxTicks != 0 && MathMod(TickCount,MaxTicks)==0){
      LogReWrite = true;
      LogReWrite();
      LogReWrite = false;   
   }
   return(0);
  }
//+------------------------------------------------------------------+
int OpenHistoryFile()
{
   FileHandle = FileOpenHistory(MySymbol + "1.hst", FILE_BIN|FILE_WRITE);
   if (FileHandle < 0) return(-1);
   return (0);
}

int WriteHistoryHeader()
{
   string c_copyright;
   int    i_digits = Digits-OmitDigit;
   int    i_unused[13] = {0};
   int    version = 400;   

   if (FileHandle < 0) return (-1);
   c_copyright = "(C)opyright 2003, MetaQuotes Software Corp.";
   FileWriteInteger(FileHandle, version, LONG_VALUE);
   FileWriteString(FileHandle, c_copyright, 64);
   FileWriteString(FileHandle, MySymbol, 12);
   FileWriteInteger(FileHandle, 1, LONG_VALUE);
   FileWriteInteger(FileHandle, i_digits, LONG_VALUE);
   FileWriteInteger(FileHandle, 0, LONG_VALUE);       //timesign
   FileWriteInteger(FileHandle, 0, LONG_VALUE);       //last_sync
   FileWriteArray(FileHandle, i_unused, 0, ArraySize(i_unused));
   return (0);
}
//+------------------------------------------------------------------+
void WriteHistoryData()
{
   if (FileHandle >= 0) {
      FileWriteInteger(FileHandle, TickCount, LONG_VALUE);
      FileWriteDouble(FileHandle, Ask, DOUBLE_VALUE);
      FileWriteDouble(FileHandle, Bid, DOUBLE_VALUE);
      FileWriteDouble(FileHandle, Ask, DOUBLE_VALUE);
      FileWriteDouble(FileHandle, Bid, DOUBLE_VALUE);
      FileWriteDouble(FileHandle, 1, DOUBLE_VALUE);
      FileFlush(FileHandle);

   }
}
//+------------------------------------------------------------------+
int UpdateChartWindow()
{
   static int hwnd = 0;

   if (FileHandle < 0) {
      //no HST file opened, no need updating.
      return (-1);
   }
   if(hwnd == 0) {
      //trying to detect the chart window for updating
      hwnd = WindowHandle(MySymbol, 1);
   }
   if(hwnd!= 0) {
      if (IsDllsAllowed() == false) {
         //DLL calls must be allowed
         Alert("ERROR: [Allow DLL imports] NOT Checked.");
         return (-1);
      }
      if (PostMessageA(hwnd,WM_COMMAND,CHART_CMD_UPDATE_DATA,0) == 0) {
         //PostMessage failed, chart window closed
         hwnd = 0;
      } else {
         //PostMessage succeed
         return (0);
      }
   }
   //window not found or PostMessage failed
   return (-1);
}
//+------------------------------------------------------------------+
void LogReWrite()
{
      Print("TickLogReWrite"+TimeToStr(TimeLocal(),TIME_SECONDS));
      FileClose(FileHandle);
      FileHandle = FileOpenHistory(MySymbol + "1.hst", FILE_BIN|FILE_READ);
      int StokTicks = (FileSize(FileHandle)-HEADER_BYTE)/2/DATA_BYTE;
      if(StokTicks <1){
         Print("No TickLog Stok");
         FileHandle = FileOpenHistory(MySymbol + "1.hst", FILE_BIN|FILE_WRITE);
         if (FileHandle < 0){Alert("LogReWriteError"); return (-1);} 
         WriteHistoryHeader();      
         return (-1);
      }
      if(StokTicks > MaxTicks/2) StokTicks = MaxTicks/2;
      FileSeek(FileHandle, -(StokTicks)*DATA_BYTE, SEEK_END);
      double d_opens[]; double d_closes[]; double d_highs[];
      double d_lows[];  double d_vols[]; datetime d_times[];
      ArrayResize(d_opens ,StokTicks);
      ArrayResize(d_closes,StokTicks);
      ArrayResize(d_highs ,StokTicks);
      ArrayResize(d_lows  ,StokTicks);
      ArrayResize(d_vols  ,StokTicks);
      ArrayResize(d_times ,StokTicks);
      for(int i= 0;i<StokTicks;i++){
         d_times[i] = FileReadInteger(FileHandle, LONG_VALUE);
         d_opens[i] = FileReadDouble(FileHandle , DOUBLE_VALUE);
         d_lows[i]  = FileReadDouble(FileHandle , DOUBLE_VALUE);
         d_highs[i] = FileReadDouble(FileHandle , DOUBLE_VALUE);
         d_closes[i]= FileReadDouble(FileHandle , DOUBLE_VALUE);
         d_vols[i]  = FileReadDouble(FileHandle , DOUBLE_VALUE);
      }
      FileClose(FileHandle);
      //if (OpenHistoryFile() < 0){Alert("LogReWriteError"); return (-1);}  
      FileHandle = FileOpenHistory(MySymbol + "1.hst", FILE_BIN|FILE_WRITE);
      if (FileHandle < 0){Alert("LogReWriteError"); return (-1);} 
      WriteHistoryHeader();
      for(i= 0;i<StokTicks;i++){
         FileWriteInteger(FileHandle,d_times[i], LONG_VALUE);
         FileWriteDouble(FileHandle,d_opens[i] , DOUBLE_VALUE);
         FileWriteDouble(FileHandle,d_lows[i]  , DOUBLE_VALUE);
         FileWriteDouble(FileHandle,d_highs[i] , DOUBLE_VALUE);
         FileWriteDouble(FileHandle,d_closes[i], DOUBLE_VALUE);
         FileWriteDouble(FileHandle,d_vols[i]  , DOUBLE_VALUE);
      }
      ArrayResize(d_opens ,0);
      ArrayResize(d_closes,0);
      ArrayResize(d_highs ,0);
      ArrayResize(d_lows  ,0);
      ArrayResize(d_vols  ,0);
      ArrayResize(d_times ,0);
}