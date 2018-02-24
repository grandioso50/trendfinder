#include <datacollector.mqh>

bool AlertFlag = false;

int OnInit()
  {
//--- create timer
   EventSetTimer(60);
      
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
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
     int local_minute = TimeMinute(TimeLocal());
     int local_hour = TimeHour(TimeLocal());
     string server_minute = Minute();
     if (local_minute != server_minute) {
      Print("now_minute="+local_minute+" server minute="+server_minute);
      return;
     }
     if (local_hour == 9) {
       Print("JAPAN Marcket starting");
     }
     if (local_hour == 16) {
       Print("Euro Marcket starting");
     }
     if (local_hour == 21) {
       Print("US Market staring");
     }
    
      //grabEconomicIndicator();
      existTrend();
      deinitialize();
  }
//+------------------------------------------------------------------+
void existTrend () {
   string message = "Potential Trend found in pair(s): ";
   bool isTrend = false;
    for (int i=0; i<ArraySize(PAIRS); i++) {
      Print("PAIR="+PAIRS[i]+" evaluation starts.");
      bool stable;
      int trendType;
      long volume = iVolume(PAIRS[i],PERIOD_M1,0);
      double open = iCustom(PAIRS[i],PERIOD_M1,"Heiken Ashi",2,0);
      double close = iCustom(PAIRS[i],PERIOD_M1,"Heiken Ashi",3,0);
      double leadingA = iIchimoku(PAIRS[i],PERIOD_M1,9,26,52,3,0); //一目均衡(先行スパンA)
		double leadingB = iIchimoku(PAIRS[i],PERIOD_M1,9,26,52,4,0); //一目均衡(先行スパンB)
		int candle_position = getHeikenPosition(open,close,leadingA,leadingB);
		Print(PAIRS[i]+" volume is: "+volume);
	/*	
		if (volume > 20) {
		   Print(PAIRS[i]+" too many ticks: "+volume);
		   continue;
		}
*/
		if (candle_position==2) {
		   trendType=1;
		}else if (candle_position==3) {
		   trendType=2;
		}else{
		   Print(PAIRS[i]+" bad candle position");
		   continue;
		}
		//一個前
		open = iCustom(PAIRS[i],PERIOD_M1,"Heiken Ashi",2,1);
      close = iCustom(PAIRS[i],PERIOD_M1,"Heiken Ashi",3,1);
      leadingA = iIchimoku(PAIRS[i],PERIOD_M1,9,26,52,3,1); //一目均衡(先行スパンA)
		leadingB = iIchimoku(PAIRS[i],PERIOD_M1,9,26,52,4,1); //一目均衡(先行スパンB)
		candle_position = getHeikenPosition(open,close,leadingA,leadingB);
		if (candle_position != 2 && candle_position != 3) {
		   Print(PAIRS[i]+" bad candle position");
		   continue;
		}
		//二個前
		open = iCustom(PAIRS[i],PERIOD_M1,"Heiken Ashi",2,2);
      close = iCustom(PAIRS[i],PERIOD_M1,"Heiken Ashi",3,2);
      leadingA = iIchimoku(PAIRS[i],PERIOD_M1,9,26,52,3,2); //一目均衡(先行スパンA)
		leadingB = iIchimoku(PAIRS[i],PERIOD_M1,9,26,52,4,2); //一目均衡(先行スパンB)
		candle_position = getHeikenPosition(open,close,leadingA,leadingB);
		if (candle_position != 2 && candle_position != 3) {
		   Print(PAIRS[i]+" bad candle position");
		   continue;
		}
		//三個前
		open = iCustom(PAIRS[i],PERIOD_M1,"Heiken Ashi",2,3);
      close = iCustom(PAIRS[i],PERIOD_M1,"Heiken Ashi",3,3);
      leadingA = iIchimoku(PAIRS[i],PERIOD_M1,9,26,52,3,3); //一目均衡(先行スパンA)
		leadingB = iIchimoku(PAIRS[i],PERIOD_M1,9,26,52,4,3); //一目均衡(先行スパンB)
		candle_position = getHeikenPosition(open,close,leadingA,leadingB);
		if (candle_position != 2 && candle_position != 3) {
		   Print(PAIRS[i]+" bad candle position");
		   continue;
		}
		//四個前
		open = iCustom(PAIRS[i],PERIOD_M1,"Heiken Ashi",2,4);
      close = iCustom(PAIRS[i],PERIOD_M1,"Heiken Ashi",3,4);
      leadingA = iIchimoku(PAIRS[i],PERIOD_M1,9,26,52,3,4); //一目均衡(先行スパンA)
		leadingB = iIchimoku(PAIRS[i],PERIOD_M1,9,26,52,4,4); //一目均衡(先行スパンB)
		candle_position = getHeikenPosition(open,close,leadingA,leadingB);
		if (candle_position != 2 && candle_position != 3) {
		   Print(PAIRS[i]+" bad candle position");
		   continue;
		}
		//五個前
		open = iCustom(PAIRS[i],PERIOD_M1,"Heiken Ashi",2,5);
      close = iCustom(PAIRS[i],PERIOD_M1,"Heiken Ashi",3,5);
      leadingA = iIchimoku(PAIRS[i],PERIOD_M1,9,26,52,3,5); //一目均衡(先行スパンA)
		leadingB = iIchimoku(PAIRS[i],PERIOD_M1,9,26,52,4,5); //一目均衡(先行スパンB)
		candle_position = getHeikenPosition(open,close,leadingA,leadingB);
		if (candle_position != 2 && candle_position != 3) {
		   Print(PAIRS[i]+" bad candle position");
		   continue;
		}
		
		
		double ema5 = iMA(PAIRS[i],PERIOD_M1,5,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(5)
      double ema20 = iMA(PAIRS[i],PERIOD_M1,20,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(20)
      double ema70 = iMA(PAIRS[i],PERIOD_M1,70,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(70)
      double ema200 = iMA(PAIRS[i],PERIOD_M1,200,0,MODE_EMA,PRICE_CLOSE,0); //指数移動平均(200)
      double ema20diff = getMAVariation(PAIRS[i],PERIOD_M1,20); //移動平均線の変動値（期間20）
	   double ema70diff = getMAVariation(PAIRS[i],PERIOD_M1,70); //移動平均線の変動値（期間70）
	   double ema200diff = getMAVariation(PAIRS[i],PERIOD_M1,200); //移動平均線の変動値（期間200）
	   double ema5_20diff = MathAbs(ema5-ema20);
	   double ema20_70diff = MathAbs(ema20-ema70);
	   
	   if (isDetatched(ema5_20diff,ema20_70diff) == false) {
	      Print("ema diff not wide enough.");
	      continue;
	   }

      if (trendType == 1) {
         if (!(ema5 > ema20 && ema20 > ema70 && ema70 > ema200)) {
            Print("no trend due to bad ema position on up cloud");
            continue;
         }
         if (ema20diff < 0 || ema70diff < 0 || ema200diff < 0) {
            Print("no trend due to unmatching ema orientation on up cloud");
            continue;
         }
      }else if (trendType == 2) {
         if (!(ema5 < ema20 && ema20 < ema70 && ema70 < ema200)) {
            Print("no trend due to bad ema position on down cloud");
            continue;
         }
         if (ema20diff > 0 || ema70diff > 0 || ema200diff > 0) {
            Print("no trend due to unmatching ema orientation on down cloud");
            continue;
         }
         
      }
      stable = isStable(PAIRS[i],trendType);
      if (stable == TRUE) {
         message += " "+PAIRS[i]+"\r\n volume:"+volume+"\r\n";
         isTrend = true;
      }
    }
    if (isTrend == true) {
    /*
         int res = slack(message);
         if (res == -1) {
            Print("slack notify failed");
         }else{
            Print("slack notify succeeded.");
         }
         */
      if (AlertFlag == false ) {
         Alert(message);
         AlertFlag = true;
      }  
    }else{
      Print("no good trend found at all.");
      AlertFlag = false;
    }
}

//EMA5-20の差とEMA20-70の差の比較　差が大きいほど戻りたがるとみなす
bool isDetatched(double ema5_20diff, double ema20_70diff) {
   double ratio = ema5_20diff/ema20_70diff;
   if (ratio > 0.7) {
      return true;
   }
   return false;
}

bool isStable(string symbol,int trendType) {
   int past = 4;
   int pos_count;
   int neg_count;
   
   double open;
   double close;
   double high;
   double low;
   double max;
   double min;
   
   bool stable = TRUE;
   
   for (int i=1; i<past && stable != FALSE; i++) {
      open = iCustom(symbol,PERIOD_M1,"Heiken Ashi",2,i);
      close = iCustom(symbol,PERIOD_M1,"Heiken Ashi",3,i);
      if (open > close) { //陰線
         neg_count++;
         high = iCustom(symbol,PERIOD_M1,"Heiken Ashi",0,i);
         //low = iCustom(symbol,PERIOD_M1,"Heiken Ashi",1,i);
         if (high > open) {
            stable = FALSE;
            Print("unstable negative entity");
         } 
      } else {
         pos_count++;
         //high = iCustom(symbol,PERIOD_M1,"Heiken Ashi",0,i);
         low = iCustom(symbol,PERIOD_M1,"Heiken Ashi",1,i);
         if (open > low) {
            Print("unstable positive entity");
            stable = FALSE;
         } 
      } 
   }
   
   if (trendType == 1) {
      if (pos_count ==past-1 && stable == TRUE) {
         return TRUE;
      }
   } else {
      if (neg_count ==past-1 && stable == TRUE) {
         return TRUE;
      }
   }
   return FALSE;
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