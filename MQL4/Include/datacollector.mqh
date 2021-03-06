#include <hash.mqh>
#include <json.mqh>
JSONParser *parser;
JSONValue *jv;
JSONObject *jo;
//取得する通貨ペアリスト
string PAIRS[] = {"USDJPY","EURUSD","GBPJPY","EURJPY","AUDUSD","AUDJPY","NZDJPY"};
//取得する時間足リスト
int PERIOD[] = {PERIOD_CURRENT,PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1};
int shift_size = 50; //データを取る足の数
int data_size = ArraySize(PAIRS);
//取得するバーの位置
int SHIFT[];
//指標値データ配列
string DATA[];
//CSV形式の指標値データ（1通貨ペア）
string HistoryData;
//CANDLE[i][0] = 上ヒゲ CANDLE[i][1] 下ヒゲ CANDLE[i][2] 陽線実体 CANDLE[i][3] 陰線実体
double CANDLE[][4];

void initialize () {
   ArrayResize(CANDLE,shift_size);
   ArrayResize(SHIFT,shift_size);
   for (int i; i<shift_size; i++) {
		SHIFT[i]= i;
	}
   ArrayResize(DATA,data_size);
}

void initCandle() {
	for (int i; i<shift_size; i++) {
		CANDLE[i][0] = 0;
		CANDLE[i][1] = 0;
		CANDLE[i][2] = 0;
		CANDLE[i][3] = 0;
	}

}

void deinitialize () {
    delete jv;
    delete parser;
}

/**
 * 経済指標データ取得
 */
void grabEconomicIndicator(){
   string url = "http://localhost/fuelphp/public/ecoindicator";
   string cookie=NULL,headers;
   char post[],result[];
   int res;
   ResetLastError();
   int timeout=5000;
   res=WebRequest("GET",url,cookie,NULL,timeout,post,0,result,headers);
   if(res==-1)
     {
      //Print("Error in WebRequest. Error code  =",GetLastError());
      MessageBox("Add the address '"+url+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
        string json = CharArrayToString(result);
        StringReplace(json,"\\u0022","\"");
        StringReplace(json,"\"{","{");
        StringReplace(json,"\"}","}");
        extractJson(json);
     }
}

/**
 * JSONパース
 */
void extractJson (string s) {
    parser = new JSONParser();
    jv = parser.parse(s);
    if (jv == NULL) {
        //Print("error:"+(string)parser.getErrorCode()+parser.getErrorMessage());
    } else {
        if (jv.isObject()) {
            jo = jv;
        } else {
            //Print("There is no object");
        }
    }
}

void collectData () {
    //現在時間を取得
    string dayOfYear =  DayOfYear();
    string month = Month();
    string day = Day();
    string dayOfWeek = DayOfWeek();
    string hour = Hour();
    string minute = Minute();
    string second = Seconds();
    double open;
    double OPEN[];
    double close;
    double CLOSE[];
    double high;
    double HIGH[];
    double low;
    double LOW[];

    ArrayResize(OPEN,shift_size);
    ArrayResize(CLOSE,shift_size);
    ArrayResize(HIGH,shift_size);
    ArrayResize(LOW,shift_size);

    for (int i=0; i<ArraySize(PAIRS); i++) {
        //初期化
       HistoryData = "";
       //通貨ペア情報記入
       HistoryData += getMACross(PAIRS[i])
                +","+ getMACDCross(PAIRS[i])
                +","+ getStochasticCross(PAIRS[i])
                +","+ getFutureEffect(PAIRS[i])
                +","+ getPastEffect(PAIRS[i])
                +","+ MarketInfo(PAIRS[i],MODE_BID)
                +","+ MarketInfo(PAIRS[i],MODE_ASK)
                +","+ MarketInfo(PAIRS[i],MODE_TICKSIZE)
                ;
       for (int j=0; j<ArraySize(PERIOD); j++) {
          for (int k=0; k<ArraySize(SHIFT); k++) {
		  	initCandle();
            open = iOpen(PAIRS[i],PERIOD[j],SHIFT[k]);
            close = iClose(PAIRS[i],PERIOD[j],SHIFT[k]);
            high = iHigh(PAIRS[i],PERIOD[j],SHIFT[k]);
            low = iLow(PAIRS[i],PERIOD[j],SHIFT[k]);
            OPEN[k] = open;
            CLOSE[k] = close;
            HIGH[k] = high;
            LOW[k] = low;
			double leadingA = iIchimoku(PAIRS[i],PERIOD[j],9,26,52,3,SHIFT[k]); //一目均衡(先行スパンA)
			double leadingB = iIchimoku(PAIRS[i],PERIOD[j],9,26,52,4,SHIFT[k]); //一目均衡(先行スパンB)
            evaluateCandle(OPEN,CLOSE,HIGH,LOW,SHIFT[k]);
             HistoryData += ","+ open
                +","+ close
                +","+ high
                +","+ low
                +","+ CANDLE[SHIFT[k]][0] //上ひげの長さ
                +","+ CANDLE[SHIFT[k]][1] //下ひげの長さ
                +","+ CANDLE[SHIFT[k]][2] //陽線の大きさ
                +","+ CANDLE[SHIFT[k]][3] //陰線の大きさ
                +","+ iMA(PAIRS[i],PERIOD[j],5,0,MODE_EMA,PRICE_CLOSE,SHIFT[k]) //指数移動平均(5)
                +","+ iMA(PAIRS[i],PERIOD[j],20,0,MODE_EMA,PRICE_CLOSE,SHIFT[k]) //指数移動平均(20)
                +","+ iMA(PAIRS[i],PERIOD[j],70,0,MODE_EMA,PRICE_CLOSE,SHIFT[k]) //指数移動平均(70)
                +","+ iMA(PAIRS[i],PERIOD[j],200,0,MODE_EMA,PRICE_CLOSE,SHIFT[k]) //指数移動平均(200)
                +","+ iBands(PAIRS[i],PERIOD[j],20,2,0,PRICE_CLOSE,1,SHIFT[k]) //ボリンジャー上方
                +","+ iBands(PAIRS[i],PERIOD[j],20,2,0,PRICE_CLOSE,2,SHIFT[k]) //ボリンジャー下方
                +","+ iMACD(PAIRS[i],PERIOD[j],12,26,9,PRICE_CLOSE,0,SHIFT[k]) //MACD
                +","+ iMACD(PAIRS[i],PERIOD[j],12,26,9,PRICE_CLOSE,1,SHIFT[k]) //シグナル
                +","+ iRSI(PAIRS[i],PERIOD[j],5,PRICE_CLOSE,SHIFT[k]) //RSI(5)
                +","+ iRSI(PAIRS[i],PERIOD[j],9,PRICE_CLOSE,SHIFT[k]) //RSI(9)
                +","+ iRSI(PAIRS[i],PERIOD[j],14,PRICE_CLOSE,SHIFT[k]) //RSI(14)
                +","+ iIchimoku(PAIRS[i],PERIOD[j],9,26,52,1,SHIFT[k]) //一目均衡(基準線)
                +","+ iIchimoku(PAIRS[i],PERIOD[j],9,26,52,2,SHIFT[k]) //一目均衡(転換線)
                +","+ leadingA
                +","+ leadingB
                +","+ iIchimoku(PAIRS[i],PERIOD[j],9,26,52,5,SHIFT[k]+26) //一目均衡(遅行線)
                +","+ iStochastic(PAIRS[i],PERIOD[j],5,3,3,MODE_EMA,1,0,SHIFT[k]) //ストキャスティクス(メイン)
                +","+ iStochastic(PAIRS[i],PERIOD[j],5,3,3,MODE_EMA,1,1,SHIFT[k]) //ストキャスティクス(シグナル)
                +","+ Volume[SHIFT[k]]
				    +","+ getCandlePosition(open,close,leadingA,leadingB)
				    +","+ getMAVariation(PAIRS[i],PERIOD[j],5) //移動平均線の変動値（期間5）
				    +","+ getMAVariation(PAIRS[i],PERIOD[j],20) //移動平均線の変動値（期間20）
				    +","+ getMAVariation(PAIRS[i],PERIOD[j],70) //移動平均線の変動値（期間70）
				    +","+ getMAVariation(PAIRS[i],PERIOD[j],200); //移動平均線の変動値（期間200）
       }

    }
     datetime now = TimeMinute(TimeLocal());
     if (now != minute) {
      Print("now_minute="+now+" server minute="+minute);
     }
     string time = (3600*StrToInteger(hour)+60*StrToInteger(minute)+StrToInteger(second));
     HistoryData += ","+ dayOfYear
                +","+ month
                +","+ dayOfWeek
                +","+ hour
                +","+ minute
                +","+ second
                +","+ time;
    DATA[i] = HistoryData;
    if (PAIRS[i] == "EURJPY") {
      Print("Pair name="+PAIRS[i]);
      Print("BID="+MarketInfo(PAIRS[i],MODE_BID));
      Print("Hour="+hour);
      Print("Minute="+minute);
      Print("Second="+second);
      Print("Time="+time);
    }

    }
}

void collectOutput () {
    //データ収集時間　15分
    int collectTime = 9000;
    int now = 0;
    //1秒づつデータ収集する
    int duration =  1000;

    while (now < collectTime) {
        Sleep(duration);
        for (int i=0; i<ArraySize(PAIRS); i++) {
            //BID(売値)をデータに追加
            DATA[i] += "," + MarketInfo(PAIRS[i],MODE_BID);
        }
        now += duration;
    }
}

void exportData () {
   string suffix = "_fxTradeHistory";
   string filename;
   int handle;
   string format = ".csv";
   
   //取得したデータをまとめてファイル書き出し
   for (int i=0; i<ArraySize(DATA); i++) {
        filename = PAIRS[i] + suffix + format;
        //ファイルオープン
        handle = FileOpen(filename, FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ',');
        //末尾にポインターを移動
        FileSeek(handle,0,SEEK_END);
       //FileWrite(handle,getHeader());
        FileWrite(handle,DATA[i]);
        FileClose(handle);
   }
      
 }

void evaluateCandle (double OPEN[], double CLOSE[], double HIGH[], double LOW[],int i) {
      //陽線
      if (CLOSE[i] > OPEN[i]) {
         CANDLE[i][0] += HIGH[i] - CLOSE[i]; //上ひげ
         CANDLE[i][1] += OPEN[i] - LOW[i]; //下ひげ
         CANDLE[i][2] += CLOSE[i] - OPEN[i]; //陽線の大きさ
      }else{ //陰線
         CANDLE[i][0] += HIGH[i] - OPEN[i]; //上ひげ
         CANDLE[i][1] += CLOSE[i] - LOW[i]; //下ひげ
         CANDLE[i][3] += OPEN[i] - CLOSE[i]; //陰線の大きさ
      }
}

string getHeader () {
   //ヘダーを作成
   string header = "";
       header += "MAクロス(1:NC 2:GC 3:DC)"
                +","+ "MACDクロス"
                +","+ "ストキャスティクスクロス"
                +","+ "過去経済指標影響指数"
                +","+ "未来経済指標影響指数"
                +","+ "ビッド値"
                +","+ "アスク値"
                +","+ "ティックサイズ"
                ;
       for (int j=0; j<ArraySize(PERIOD); j++) {
          for (int k=0; k<ArraySize(SHIFT); k++) {
             header += ","+ j+"_"+k+"_"+"始値"
                +","+ j+"_"+k+"_"+"終値"
                +","+ j+"_"+k+"_"+"高値"
                +","+ j+"_"+k+"_"+"低値"
                +","+ j+"_"+k+"_"+"上ひげ長さ"
                +","+ j+"_"+k+"_"+"下ひげ長さ"
                +","+ j+"_"+k+"_"+"陽線サイズ"
                +","+ j+"_"+k+"_"+"陰線サイズ"
                +","+ j+"_"+k+"_"+"指数移動平均(5)"
                +","+ j+"_"+k+"_"+"指数移動平均(20)"
                +","+ j+"_"+k+"_"+"指数移動平均(70)"
                +","+ j+"_"+k+"_"+"指数移動平均(200)"
                +","+ j+"_"+k+"_"+"ボリンジャー上方バンド"
                +","+ j+"_"+k+"_"+"ボリンジャー下方バンド"
                +","+ j+"_"+k+"_"+"MACDメイン"
                +","+ j+"_"+k+"_"+"MACDシグナル"
                +","+ j+"_"+k+"_"+"RSI(5)"
                +","+ j+"_"+k+"_"+"RSI(9)"
                +","+ j+"_"+k+"_"+"RSI(14)"
                +","+ j+"_"+k+"_"+"一目均衡（基準線）"
                +","+ j+"_"+k+"_"+"一目均衡(転換線)"
                +","+ j+"_"+k+"_"+"一目均衡(先行スパンA)"
                +","+ j+"_"+k+"_"+"一目均衡（先行スパン）B"
                +","+ j+"_"+k+"_"+"一目均衡(遅行線)"
                +","+ j+"_"+k+"_"+"ストキャスティクス（メイン）"
                +","+ j+"_"+k+"_"+"ストキャスティクス(シグナル)"
                +","+ j+"_"+k+"_"+"出来高"
				    +","+ j+"_"+k+"_"+"足の位置(1:in_twist 2:above 3:below 4:on_LA 5:on_LB 6:in_cloud)"
				    +","+ j+"_"+k+"_"+"移動平均線変動値(5)"
				    +","+ j+"_"+k+"_"+"移動平均線変動値(20)"
				    +","+ j+"_"+k+"_"+"移動平均線変動値(70)"
				    +","+ j+"_"+k+"_"+"移動平均線変動値(200)";
       }

    }
     header += ","+ "経過日数(1年)"
                +","+ "月"
                +","+ "曜日"
                +","+ "時間"
                +","+ "分"
                +","+ "秒"
                +","+ "経過秒数(1日)";
     return header;
}

int getMACross (string symbol) {
   double fast_0 = iMA(symbol,PERIOD_M1,5,0,MODE_EMA,PRICE_CLOSE,1);
   double fast_1 = iMA(symbol,PERIOD_M1,5,0,MODE_EMA,PRICE_CLOSE,2);
   double slow_0 = iMA(symbol,PERIOD_M1,20,0,MODE_EMA,PRICE_CLOSE,1);
   double slow_1 = iMA(symbol,PERIOD_M1,20,0,MODE_EMA,PRICE_CLOSE,2);

   if (fast_1 <= slow_1 && fast_0 > slow_0)
   {
      return 2; //ゴールデンクロス
   }
   if (fast_1 >= slow_1 && fast_0 < slow_0)
   {
      return 3; //デッドクロス
   }
   return 1; //クロスなし
}

int getMACDCross (string symbol) {
   //一つ前のＭＡＣＤのメイン
   double main_1　= iMACD(symbol,PERIOD_M1,12,26,9,PRICE_CLOSE,0,1);
   //一つ前のＭＡＣＤのシグナル
   double signal_1 = iMACD(symbol,PERIOD_M1,12,26,9,PRICE_CLOSE,1,1);

   //現在のＭＡＣＤのメイン
   double main_0　= iMACD(symbol,PERIOD_M1,12,26,9,PRICE_CLOSE,0,0);
   //現在のＭＡＣＤのシグナル
   double signal_0　= iMACD(symbol,PERIOD_M1,12,26,9,PRICE_CLOSE,1,0);
   //もしメインがシグナルを下から上にクロスしたら
   if (main_1　 < signal_1 && main_0　>= signal_0　) {
      return 2; //買い
   }
   //もしメインがシグナルを上から下にクロスしたら
   if ( main_1　 > signal_1 && main_0　<= signal_0　){
      return 3; //売り
   }
   return 1;
}

int getStochasticCross (string symbol) {
   double Stoc_Level_UPPER = 80;
   double Stoc_Level_LOWER = 20;
   double Stoc_MAIN0 = iStochastic(symbol,PERIOD_M1,5,3,3,MODE_EMA,1,MODE_MAIN,0);
   double Stoc_SIGNAL0 = iStochastic(symbol,PERIOD_M1,5,3,3,MODE_EMA,1,MODE_SIGNAL,0);
   double Stoc_MAIN1 = iStochastic(symbol,PERIOD_M1,5,3,3,MODE_EMA,1,MODE_MAIN,1);
   double Stoc_SIGNAL1 = iStochastic(symbol,PERIOD_M1,5,3,3,MODE_EMA,1,MODE_SIGNAL,1);


   //ストキャスが20以下でゴールデンクロス
   if (Stoc_MAIN0 <= Stoc_Level_LOWER && Stoc_MAIN0 > Stoc_SIGNAL0 && Stoc_MAIN1 <= Stoc_SIGNAL1) {
      return 2;
   }

   //ストキャスが80以上でデッドクロス
   if (Stoc_MAIN0 >= Stoc_Level_UPPER && Stoc_MAIN0 < Stoc_SIGNAL0 && Stoc_MAIN1 >= Stoc_SIGNAL1) {
      return 3;
   }
   return 1;
}

double getCloudThickness (string symbol) {
   double leading_a = iIchimoku(symbol,PERIOD_M1,9,26,52,3,0); //一目均衡(先行スパンA)
   double leading_b = iIchimoku(symbol,PERIOD_M1,9,26,52,4,0); //一目均衡(先行スパンB)

   if (leading_a > leading_b) {
      return leading_a - leading_b;
   } else {
      return leading_b - leading_a;
   }
}

int getCandlePosition (double open, double close, double leading_a, double leading_b) {
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

double getFutureEffect (string symbol) {
  return jo.getObject(symbol).getDouble("future_total_effect");
}

double getPastEffect (string symbol) {
  return jo.getObject(symbol).getDouble("past_total_effect");
}