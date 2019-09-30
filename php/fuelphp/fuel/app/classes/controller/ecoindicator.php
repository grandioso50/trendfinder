<?php

class Controller_EcoIndicator extends Controller_Rest
{
	protected $format = 'json';
	private $result = [
		"USDJPY" => null,
		"USDCAD" => null,
		"USDCHF" => null,
		"GBPUSD" => null,
		"GBPAUD" => null,
		"GBPJPY" => null,
		"AUDJPY" => null,
		"AUDNZD" => null,
		"AUDUSD" => null,
		"EURGBP" => null,
		"EURAUD" => null,
		"EURJPY" => null,
		"EURUSD" => null,
		"CADJPY" => null,
		"NZDJPY" => null,
		"NZDUSD" => null,
		"CHFJPY" => null
	];

	/**
	 * effect - 経済指標が特定の通貨ペアに及ぼす影響度の数値
	 * count - 注目指標の数
	 * @return [type] [description]
	 */
	private function init() {
		foreach ($this->result as $pair => $val) {
			$this->result[$pair] = [
				"past_total_effect" => 0,
				"future_total_effect" => 0
			];
		}
	}

	public function get_index()
	{
		// $time_start = microtime(true);
		$this->init();
		$trs = $this->getContents();
		foreach ($trs->tr as $child) {
			$news = [];
			$news = $this->setProperty($child,$news);
			if (empty($news)) continue;
			$news = $this->getEffect($news);
			$this->setResult($news);
		}
		// $time = microtime(true) - $time_start;
		// echo "{$time} 秒";
		// \debug::dump($pre_formatted,);
		$this->response(json_encode($this->result));
	}

	private function getContents () {
		try {
			$cached = \Cache::get($this->_cacheKey());
			return json_decode($cached);
		}
		catch (\CacheNotFoundException $e) {
			$url = 'http://min-fx.jp/if/market/indicators/if_indicators_w/';
			$html = file_get_contents($url);
			$dom = new DOMDocument();
			$dom->loadHTML($html);
			$xml = $dom->saveXML();
			$xml = str_replace('xmlns="http://www.w3.org/1999/xhtml"',"",$xml);
			$xml_obj = simplexml_load_string($xml);
			$json = json_encode($xml_obj->body->div->table->tbody,true);
			//本日いっぱいの時間分キャッシュする
			\Cache::set($this->_cacheKey(), $json, $this->secondsToTomorrow());
			return json_decode($json);
		}
	}

	private function _cacheKey() {
		return "todayseconomicindicator.";
	}

	private function secondsToTomorrow () {
		return strtotime('tomorrow') - time();
	}

	private function setProperty ($child,$news) {
		for ($i = 0; $i < 3; $i++) {
			switch ($i) {
				case 0:
				$time_left = $this->getWithin1h($child->td[$i]);
				if (!$time_left) {
					return;
				}
				$news['time_to'] = $time_left;
				break;
				case 1:
				$child->td[$i] = trim($child->td[$i]);
				$news['target'] = substr($child->td[$i],0,3);
				break;
				case 2:
				$level = $this->setLevel($child->td[$i]);
				if ($level === 1) return; //重要度0は無視
				$news['level'] = $level;
				break;
				default:
				break;
			}
		}
		return $news;
	}

	private function setLevel ($level) {
		if (!property_exists($level,"img")) return 1;
		switch ($level->img->{'@attributes'}->alt) {
			case "重要度中":
				return 2;
			case "重要度高":
				return 3;
			default:
				return 1;
		}
	}

	/**
	 * 前後1時間かつ本日付の指標がある場合、時間差を取得
	 * @param  [type]  $time [description]
	 * @return boolean       [description]
	 */
	private function getWithin1h ($time) {
		// $array = ["24日 09:35","24日 09:35","24日 09:35"];
		// $index = array_rand(
		// 	$array,
		// 	1
		// );
		// $time = $array[$index];
		//*日までの文字列取得
		$date = preg_match('/^.*[日]/',$time,$matches);
		//d[日]のdを取得
		$date = str_replace("日","",$matches[0]);
		//今日付け以外はreturn
		if ($date !== date('j')) return false;
		//後方の時間 H:mを取得
		$hour = substr($time,-5);
		$hour_stamp = strtotime($hour);
		$now = time();
		$minus = strtotime('-60 minute');
		$plus = strtotime('+60 minute');
		if ($minus < $hour_stamp and $hour_stamp < $plus) {
			return $hour_stamp - $now;
		}
		return false;
	}

	const K = 3;
	/**
	 * model -(K^level)*log(time_diff/3600)
	 * @param $news ±60分以内の経済指標
	 * @return [type] [description]
	 */
	private function getEffect ($news) {
		$news["effect"] = -pow(self::K,$news["level"])*log10(abs($news["time_to"]/3600));
		return $news;
	}

	private function setResult ($news) {
		switch ($news["target"]) {
			case "JPY":
			$target_keys = $this->array_find("JPY",$this->result);
			$this->setEffect($target_keys,$news);
			break;
			case "GBP":
			$target_keys = $this->array_find("GBP",$this->result);
			$this->setEffect($target_keys,$news);
			break;
			case "DEM":
			$target_keys = $this->array_find("EUR",$this->result);
			$this->setEffect($target_keys,$news);
			break;
			case "FRF":
			$target_keys = $this->array_find("EUR",$this->result);
			$this->setEffect($target_keys,$news);
			break;
			case "EUR":
			$target_keys = $this->array_find("EUR",$this->result);
			$this->setEffect($target_keys,$news);
			break;
			case "USD":
			$target_keys = $this->array_find("USD",$this->result);
			$this->setEffect($target_keys,$news);
			break;
			case "NZD":
			$target_keys = $this->array_find("NZD",$this->result);
			$this->setEffect($target_keys,$news);
			break;
			case "AUD":
			$target_keys = $this->array_find("AUD",$this->result);
			$this->setEffect($target_keys,$news);
			break;
			case "CHF":
			$target_keys = $this->array_find("CHF",$this->result);
			$this->setEffect($target_keys,$news);
			break;
			case "CAD":
			$target_keys = $this->array_find("CAD",$this->result);
			$this->setEffect($target_keys,$news);
			break;
			default:
		}
	}

	private function setEffect (array $keys,$news) {
		foreach ($keys as $key) {
			if ($this->isPast($news)) {
				$this->result[$key]["past_total_effect"] += $news["effect"];
			} else {
				$this->result[$key]["future_total_effect"] += $news["effect"];
			}
		}
	}

	private function array_find($needle, array $haystack) {
		$keys = [];
    	foreach ($haystack as $key => $value) {
        	if (false !== stripos($key, $needle)) {
            	$keys[] = $key;
        	}
    	}
    	return $keys;
	}

	private function isPast ($news) {
		return $news["time_to"] < 0;
	}

}
