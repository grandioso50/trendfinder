
#property indicator_chart_window

extern int ExtDepth=6;
extern int ExtDeviation=5;
extern int ExtBackstep=3;

extern string TREND_FONT_NAME = "Arial Bold";
extern int    TREND_FONT_SIZE = 24;
extern int    TREND_X = 8;
extern int    TREND_Y = 50;
extern int    TREND_CORNER = 3;
extern string TREND_CORNER_comment1 = "// 0:Top Left   1:Top Right";
extern string TREND_CORNER_comment2 = "// 2:Bottom Left   3:Bottom Right";
extern string TREND_UP_TEXT = "UP";
extern color  TREND_UP_COLOR = Lime;
extern string TREND_DOWN_TEXT = "DOWN";
extern color  TREND_DOWN_COLOR = Red;
extern string PRICE_FONT_NAME = "Arial";
extern int    PRICE_FONT_SIZE = 16;
extern int    UPPER_PRICE_X = 8;
extern int    UPPER_PRICE_Y = 28;
extern int    UPPER_PRICE_CORNER = 3;
extern color  UPPER_PRICE_COLOR = Lime;
extern int    LOWER_PRICE_X = 8;
extern int    LOWER_PRICE_Y = 8;
extern int    LOWER_PRICE_CORNER = 3;
extern color  LOWER_PRICE_COLOR = Red;
extern color  UPPER_LINE_COLOR = LimeGreen;
extern color  LOWER_LINE_COLOR = Crimson;

string objTrend = "High_Low_Plus_Trend";
string objUpperPrice = "High_Low_Plus_UpperPrice";
string objLowerPrice = "High_Low_Plus_LowerPrice";
string objUpper = "High_Low_Plus_Upper";
string objLower = "High_Low_Plus_Lower";

#define TREND_UNKNOWN  0
#define TREND_UP       1
#define TREND_DOWN     2
int gTrend; // TREND_XXXX

#define ZIGZAG_LIMIT 3
double gZigZag[ZIGZAG_LIMIT];
datetime gZigZagTime[ZIGZAG_LIMIT];
double gUpper;
datetime gUpperTime;
double gLower;
datetime gLowerTime;


void DeleteObjects()
{
   ObjectDelete(objTrend);
   ObjectDelete(objUpperPrice);
   ObjectDelete(objLowerPrice);
   ObjectDelete(objUpper);
   ObjectDelete(objLower);
}

void ClearZigZag()
{
   for (int i=0; i<ZIGZAG_LIMIT; i++)
   {
      gZigZag[i] = 0;
      gZigZagTime[i] = 0;
   }
}

int init()
{
   ClearZigZag();
   DeleteObjects();
   gTrend = TREND_UNKNOWN;

   return(0);
}

int deinit()
{
   DeleteObjects();
   
   return(0);
}

string GetTrendText()
{
   switch (gTrend)
   {
   case TREND_UP: return(TREND_UP_TEXT);
   case TREND_DOWN: return(TREND_DOWN_TEXT);
   case TREND_UNKNOWN: break;
   }
   return("");
}

color GetTrendTextColor()
{
   switch (gTrend)
   {
   case TREND_UP: return(TREND_UP_COLOR);
   case TREND_DOWN: return(TREND_DOWN_COLOR);
   case TREND_UNKNOWN: break;
   }
   return(Black);
}

void IndicateTrend()
{
   if (ObjectFind(objTrend) == -1)
   {
      ObjectCreate(objTrend, OBJ_LABEL, 0, 0, 0);
      ObjectSet(objTrend, OBJPROP_CORNER, TREND_CORNER);
      ObjectSet(objTrend, OBJPROP_XDISTANCE, TREND_X);
      ObjectSet(objTrend, OBJPROP_YDISTANCE, TREND_Y);
   }
   ObjectSetText(objTrend, GetTrendText(), TREND_FONT_SIZE, TREND_FONT_NAME, GetTrendTextColor());
}

void IndicateUpperPrice()
{
   if (ObjectFind(objUpperPrice) == -1)
   {
      ObjectCreate(objUpperPrice, OBJ_LABEL, 0, 0, 0);
      ObjectSet(objUpperPrice, OBJPROP_CORNER, UPPER_PRICE_CORNER);
      ObjectSet(objUpperPrice, OBJPROP_XDISTANCE, UPPER_PRICE_X);
      ObjectSet(objUpperPrice, OBJPROP_YDISTANCE, UPPER_PRICE_Y);
   }
   ObjectSetText(objUpperPrice, DoubleToStr(gUpper,Digits), PRICE_FONT_SIZE, PRICE_FONT_NAME, UPPER_PRICE_COLOR);
}

void IndicateLowerPrice()
{
   if (ObjectFind(objLowerPrice) == -1)
   {
      ObjectCreate(objLowerPrice, OBJ_LABEL, 0, 0, 0);
      ObjectSet(objLowerPrice, OBJPROP_CORNER, LOWER_PRICE_CORNER);
      ObjectSet(objLowerPrice, OBJPROP_XDISTANCE, LOWER_PRICE_X);
      ObjectSet(objLowerPrice, OBJPROP_YDISTANCE, LOWER_PRICE_Y);
   }
   ObjectSetText(objLowerPrice, DoubleToStr(gLower,Digits), PRICE_FONT_SIZE, PRICE_FONT_NAME, LOWER_PRICE_COLOR);
}

void IndicateUpperLine()
{
   if (ObjectFind(objUpper) == -1)
   {
      ObjectCreate(objUpper, OBJ_HLINE, 0, gUpperTime, gUpper);
      ObjectSet(objUpper, OBJPROP_COLOR, UPPER_LINE_COLOR);
      ObjectSet(objUpper, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(objUpper, OBJPROP_BACK, true);
   }
   else
   {
      ObjectMove(objUpper, 0, gUpperTime, gUpper);
   }
}

void IndicateLowerLine()
{
   if (ObjectFind(objLower) == -1)
   {
      ObjectCreate(objLower, OBJ_HLINE, 0, gLowerTime, gLower);
      ObjectSet(objLower, OBJPROP_COLOR, LOWER_LINE_COLOR);
      ObjectSet(objLower, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(objLower, OBJPROP_BACK, true);
   }
   else
   {
      ObjectMove(objLower, 0, gLowerTime, gLower);
   }
}

void IndicateAll()
{
   IndicateTrend();
   IndicateUpperPrice();
   IndicateLowerPrice();
   IndicateUpperLine();
   IndicateLowerLine();
}

void MakeTrend()
{
   if (gZigZag[0] > gUpper)
   { // Up
      gTrend = TREND_UP;
   }
   else if (gZigZag[0] < gLower)
   { // Down
      gTrend = TREND_DOWN;
   }
}

void MakeZigZagUpperAndLower()
{
   if (gZigZag[1] > gZigZag[2])
   {
      gUpper = gZigZag[1];
      gUpperTime = gZigZagTime[1];
      gLower = gZigZag[2];
      gLowerTime = gZigZagTime[2];
   }
   else
   {
      gUpper = gZigZag[2];
      gUpperTime = gZigZagTime[2];
      gLower = gZigZag[1];               
      gLowerTime = gZigZagTime[1];
   }
}

void ShiftZigZag()
{
   for (int i=0; i<ZIGZAG_LIMIT-1; i++)
   {
      gZigZag[i] = gZigZag[i+1];
      gZigZagTime[i] = gZigZagTime[i+1];
   }
}

void MakeInitialTrend()
{
   for (int i=0; i<Bars; i++)
   {
      double a = iCustom(NULL, 0, "ZigZag", ExtDepth, ExtDeviation, ExtBackstep, 0, i);
      if (a != 0)
      {
         ShiftZigZag();
         gZigZag[ZIGZAG_LIMIT-1] = a;
//         gZigZagTime[ZIGZAG_LIMIT-1] = Time[i];
         if (gZigZag[0] != 0)
         {
            if (gZigZag[0] > gZigZag[1])
            { // The last line is up.
               if (gZigZag[0] > gZigZag[2])
               {
                  gTrend = TREND_UP;
                  return;
               }
            }
            else
            { // The last line is down.
               if (gZigZag[0] < gZigZag[2])
               {
                  gTrend = TREND_DOWN;
                  return;
               }
            }
         }
      }
   }   
   gTrend = TREND_UNKNOWN;
}

bool MakeZigZag()
{
   if (IndicatorCounted()==0)
   {
      ClearZigZag();
      MakeInitialTrend();
      ClearZigZag();
   }

   bool IsSame = false;
   int c = 0;
   for (int i=0; i<Bars; i++)
   {
      double a = iCustom(NULL, 0, "ZigZag", ExtDepth, ExtDeviation, ExtBackstep, 0, i);
      if (a != 0)
      {
         if (gZigZag[c] == a && gZigZagTime[c] == Time[i])
         {
            IsSame = true;
         }
         else
         {
            IsSame = false;
            gZigZag[c] = a;
            gZigZagTime[c] = Time[i];
         }
         c++;
         if (IsSame || c == ZIGZAG_LIMIT)
         {
            MakeZigZagUpperAndLower();
            return(true);
         }
      }
   }   
   return(false);
}

int start()
{
   if (MakeZigZag())
   {
      MakeTrend();
      IndicateAll();
   }

   return(0);
}