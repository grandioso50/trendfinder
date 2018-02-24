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
bool flagged = false;
bool nightOnly = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int tick_cnt = 0;
int now_highlow = 1;
int before_highlow = 1;
int now_entity_type = 0;
int before_entity_type = 0;
double BIDS[50];
double now_bids = 0;
double before_bids = 0;
double delta = 0;
double deviations = 0;

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
   double vol = iVolume(Symbol(),PERIOD_M1,0);
   now_bids = MarketInfo(Symbol(),MODE_BID);
   if (flagged) {
      if ((before_entity_type == 1 && before_bids < now_bids) || (before_entity_type == 2 && before_bids > now_bids)){
         slack(Symbol()+": Predicted right.");
      }
   }
   bool mg = getMagnitude();
   if (!existTrend() || vol < 30 || tick_cnt > 20 || !mg ){
      deinitialize();
      flagged = false;
      return;
   }
   string message = Symbol()+" w/ volume: "+vol+" ticks: "+tick_cnt+" \ndelta: "+delta+" \nstd: "+deviations;
   
   if (now_highlow == before_highlow) {
      flagged = true;
      if (AlertFlag == false ) {
        /* 
         int res = slack(message);

         if (res == -1) {
            Print("slack notify failed");
         }else{
            Print("slack notify succeeded.");
         }
         */
         Alert(message);
         AlertFlag = true;
      }  
    }else{
      flagged = false;
      AlertFlag = false;
    }
   
   deinitialize();
  }
//+------------------------------------------------------------------+

void deinitialize(){
   tick_cnt = 0;
   delta = 0;
   deviations = 0;
   before_highlow = now_highlow;
   before_bids = now_bids;
   before_entity_type = now_entity_type;
   ArrayInitialize(BIDS,0);
}

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

bool getMagnitude(){
   int i = 0;
   double sum = 0;
   double max = 0;
   double min = 0;
   deviations = 0;
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
   delta = MathAbs(vec);
   if (deviations == 0) {
      return false;
   }
   if (delta == 0) {
      return false;
   }
   if (deviations*1000000000 >= 10) {
      return false;
   }
   delta = delta*10000;
   deviations = deviations * 1000000000;
   return true;

}

bool existTrend () {
   int local_minute = TimeMinute(TimeLocal());
   int local_hour = TimeHour(TimeLocal());
   string server_minute = Minute();
   if (nightOnly) {
      if (local_hour != 23 && local_hour != 0 && local_hour != 1) {
      Print("Not good local_hour="+local_hour);
      return false;
   } else {
      Print("Good local_hour="+local_hour);
   }
   }

   if (local_minute != server_minute) {
      Print("now_minute="+local_minute+" server minute="+server_minute);
      return false;
   }
   if (!isGoodPos(PERIOD_M1)) {
      return false;
   }
   if (!isGoodPos(PERIOD_M5)) {
      return false;
   }
   if (!isGoodPos(PERIOD_M15)) {
      return false;
   }
   
   
   double open = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",2,0);
   double close = iCustom(Symbol(),PERIOD_M1,"Heiken Ashi",3,0);
   now_entity_type = getEntity(open,close);
   
   return true;

}

bool isGoodPos (int foot) {
   long volume = iVolume(Symbol(),foot,0);
   double open = iCustom(Symbol(),foot,"Heiken Ashi",2,0);
   double close = iCustom(Symbol(),foot,"Heiken Ashi",3,0);
   double leadingA = iIchimoku(Symbol(),foot,9,26,52,3,0); //一目均衡(先行スパンA)
	double leadingB = iIchimoku(Symbol(),foot,9,26,52,4,0); //一目均衡(先行スパンB)
	int candle_position = getHeikenPosition(open,close,leadingA,leadingB);
	if (candle_position !=2 && candle_position != 3) {
	   Print(Symbol()+" bad candle position at foot="+foot);
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