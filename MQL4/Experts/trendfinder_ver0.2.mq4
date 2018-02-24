//+------------------------------------------------------------------+
//|                                           trendfinder_ver0.2.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

bool AlertFlag = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int tick_cnt = 0;
int stable_cnt = 0;
int now_highlow = 1;
int before_highlow = 1;
double BIDS[50];

int OnInit()
  {
//--- create timer
   EventSetTimer(15);
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   BIDS[tick_cnt] = MarketInfo(Symbol(),MODE_BID);
   tick_cnt++;
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if (!existTrend()){
      deinitialize();
      return;
   }
   double mg = getMagnitude();
   //Print("tick count: "+tick_cnt);
   if (mg > 2.5) {
      stable_cnt++;
      Print("magnitude: "+mg+" before trend:"+before_highlow+" now trend: "+now_highlow);
   }else{
      stable_cnt = 0;
   }
   if (stable_cnt > 1 && now_highlow == before_highlow) {
      if (AlertFlag == false ) {
         string message = Symbol()+" w/ volume: "+iVolume(Symbol(),PERIOD_M1,0)+" ticks: "+tick_cnt;
         int res = slack(message);
         if (res == -1) {
            Print("slack notify failed");
         }else{
            Print("slack notify succeeded.");
         }
         Alert(message);
         AlertFlag = true;
      }  
    }else{
      AlertFlag = false;
    }
   
   deinitialize();
  }
//+------------------------------------------------------------------+

void deinitialize(){
   tick_cnt = 0;
   before_highlow = now_highlow;
   ArrayInitialize(BIDS,0);
}

double getMagnitude(){
   int i = 0;
   double sum = 0;
   double max = 0;
   double min = 0;
   double deviations = 0;
   int count = 0;
   while(BIDS[i] != 0){
      if (BIDS[i] > max){
         max = BIDS[i];
      }
      if (BIDS[i] < min){
         min = BIDS[i];
      }
      count++;
      i++;
   }
   if (count == 0) {
      Print("no tick within periods.");
      return 0;
   }
   /*
   for (int k=0; k<count; k++) {
      sum += (BIDS[k]-min)/(max-min);
   }
   double mean = sum/count;
   */
   for (int j=0; j<count; j++) {
      if (j+1 != count){
         deviations += MathPow((
         (BIDS[j]-min)/(max-min)-
         (BIDS[j+1]-min)/(max-min)
         ),2);
      }   
   }
   double vec = (BIDS[count-1]-min)/(max-min)-
         (BIDS[0]-min)/(max-min);
   if (vec > 0) {
      now_highlow = 1;
   } else {
      now_highlow = 0;
   }
   double delta = MathAbs(vec);
   //Print("deviations: "+deviations*1000000000);
   //Print("deltas: "+delta*10000);
   if (deviations == 0) {
      return 0;
   }
   return count * delta * 10000/(deviations*1000000000);

}

bool existTrend () {
   int local_minute = TimeMinute(TimeLocal());
   int local_hour = TimeHour(TimeLocal());
   string server_minute = Minute();
   if (local_minute != server_minute) {
      Print("now_minute="+local_minute+" server minute="+server_minute);
   return false;
   }
   bool isTrend = false;
      bool stable;
      int trendType;
      long volume = iVolume(Symbol(),PERIOD_M1,0);
      double open = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",2,0);
      double close = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",3,0);
      double leadingA = iIchimoku(Symbol(),PERIOD_M1,9,26,52,3,0); //一目均衡(先行スパンA)
		double leadingB = iIchimoku(Symbol(),PERIOD_M1,9,26,52,4,0); //一目均衡(先行スパンB)
		int candle_position = getHeikenPosition(open,close,leadingA,leadingB);

		if (candle_position==2) {
		   trendType=1;
		}else if (candle_position==3) {
		   trendType=2;
		}else{
		   Print(Symbol()+" bad candle position");
		   return false;
		}

      return true;
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

double getMAVariation (string symbol, int time, int period) {
   int bar_before = 15;
   double ma_from = iMA(symbol, time, period, 0, MODE_EMA, PRICE_CLOSE, bar_before);
   double ma_to = iMA(symbol, time, period, 0, MODE_EMA, PRICE_CLOSE, 0);
   return (ma_to - ma_from)/Point;
}