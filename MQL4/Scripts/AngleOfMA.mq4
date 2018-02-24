//+------------------------------------------------------------------+
//|                                                    AngleOfMA.mq4 |
//|                                                  Andy Bruckstone |
//|                                    http://blog.livedoor.jp/zein/ |
//+------------------------------------------------------------------+
#property copyright "Andy Bruckstone"
#property link      "http://blog.livedoor.jp/zein/"

#property indicator_separate_window
#property indicator_minimum -90
#property indicator_maximum 90
#property indicator_buffers 3
#property indicator_color1 White
#property indicator_color2 Aqua
#property indicator_color3 Red
//--- input parameters
extern string  expMA0 = "0 : Simple moving average (SMA)";
extern string  expMA1 = "1 : Exponential moving avera (EMA)";
extern string  expMA2 = "2 : Smoothed moving average (SMMA)";
extern string  expMA3 = "3 : Linear weighted moving average (LWMA)";
extern int     MA_Method = 0;
extern int     MA_Period = 50;
extern string  expAP0 = "0 : Close price.";
extern string  expAP1 = "1 : Open price.";
extern string  expAP2 = "2 : High price.";
extern string  expAP3 = "3 : Low price.";
extern string  expAP4 = "4 : Median price, (high+low)/2.";
extern string  expAP5 = "5 : Typical price, (high+low+close)/3.";
extern string  expAP6 = "6 : Weighted close price, (high+low+close+close)/4.";
extern int     Applied_Price = 0;
extern double  Angle_Threshold=45;
extern int     intFromL=1;
extern int     intToR=0;  

string         strMA_Method;

double         HeadBuffer[];
double         FootBuffer[];
double         BodyBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,BodyBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,HeadBuffer);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,FootBuffer);
   
   switch (MA_Method)
   {
      case 1: strMA_Method="EMA"; break;
      case 2: strMA_Method="SMMA"; break;
      case 3: strMA_Method="LWMA"; break;
      default: strMA_Method="SMA"; break;
   }
   //----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int    counted_bars=IndicatorCounted();
//----
   double dblPips, dblAngle, dblMA_R, dblMA_L;
   int i, intPosMax;
 
   if(intFromL < 1 || intToR < 0 || intFromL <= intToR )
   {
      intFromL = 1;
      intToR = 0;      
   }

//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   intPosMax = Bars-counted_bars;

//----
   for(i=0; i<intPosMax; i++)
   {
      dblMA_L=iMA(NULL,0,MA_Period,0,MA_Method,Applied_Price,i+intFromL);
      dblMA_R=iMA(NULL,0,MA_Period,0,MA_Method,Applied_Price,i+intToR);
      
      dblPips = (dblMA_R - dblMA_L)/Point;
      
      //Arctangent(y/x)*180/Pi
      dblAngle = MathArctan( dblPips/(intFromL-intToR) )*180/3.14159265;

      HeadBuffer[i] = EMPTY_VALUE;
      FootBuffer[i] = EMPTY_VALUE;
      
      BodyBuffer[i] = dblAngle;
      if(dblAngle > Angle_Threshold){
         HeadBuffer[i] = dblAngle;
      }else if(dblAngle < -Angle_Threshold){
         FootBuffer[i] = dblAngle;
      }
   }

   //----
   return(0);
}
//+------------------------------------------------------------------+


