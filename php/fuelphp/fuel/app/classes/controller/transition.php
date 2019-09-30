<?php

class Controller_Transition extends Controller
{
	const SIZE = 16;

	public function action_regression() {
		$data = [];
		$USDJPY = Model_Regression::find_one_by('pair',"USDJPY");
		$EURUSD = Model_Regression::find_one_by('pair',"EURUSD");
		$GBPJPY = Model_Regression::find_one_by('pair',"GBPJPY");
		$EURJPY = Model_Regression::find_one_by('pair',"EURJPY");
		$AUDUSD = Model_Regression::find_one_by('pair',"AUDUSD");
		$AUDJPY = Model_Regression::find_one_by('pair',"AUDJPY");
		$NZDJPY = Model_Regression::find_one_by('pair',"NZDJPY");
		// $data = $this->decode($data,$USDJPY);
		// $data = $this->decode($data,$EURUSD);
		// $data = $this->decode($data,$GBPJPY);
		// $data = $this->decode($data,$EURJPY);
		// $data = $this->decode($data,$AUDUSD);
		// $data = $this->decode($data,$AUDJPY);
		// $data = $this->decode($data,$NZDJPY);
		$view = View::forge('fx/regression');
		// $view->set_safe('data',$data);
		$view->set_safe('usdjpy',$USDJPY);
		$view->set_safe('eurusd',$EURUSD);
		$view->set_safe('gbpjpy',$GBPJPY);
		$view->set_safe('eurjpy',$EURJPY);
		$view->set_safe('audusd',$AUDUSD);
		$view->set_safe('audjpy',$AUDJPY);
		$view->set_safe('nzdjpy',$NZDJPY);
		$view->set_safe('uj_json',$USDJPY ? json_encode($USDJPY->function) : json_encode([]));
		$view->set_safe('eu_json',$EURUSD ? json_encode($EURUSD->function) : json_encode([]));
		$view->set_safe('gj_json',$GBPJPY ? json_encode($GBPJPY->function) : json_encode([]));
		$view->set_safe('ej_json',$EURJPY ? json_encode($EURJPY->function) : json_encode([]));
		$view->set_safe('au_json',$AUDUSD ? json_encode($AUDUSD->function) : json_encode([]));
		$view->set_safe('aj_json',$AUDJPY ? json_encode($AUDJPY->function) : json_encode([]));
		$view->set_safe('nj_json',$NZDJPY ? json_encode($NZDJPY->function) : json_encode([]));
		return $view;
	}

	private function decode($arr,$entry) {
		if ($entry) {
			$arr[$entry->pair] = json_decode($entry->regression,true);
		}
		return $arr;
	}

	private function outputFFT($entry) {
		if (count($entry) == static::SIZE) {
			$data = [];
			foreach ($entry as $key => $value) {
				$data[] = $value->ema;
			}
			$fft = Fourier::get($data,1);
			echo $entry[0]->pair;
			Debug::dump($fft);
		}

	}

	public function action_index()
	{
    $view = View::forge('fx/index');
		$usdjpy = $this->getValue('USDJPY');
		$eurusd = $this->getValue('EURUSD');
		$gbpjpy = $this->getValue('GBPJPY');
		$eurjpy = $this->getValue('EURJPY');
		$audusd = $this->getValue('AUDUSD');
		$audjpy = $this->getValue('AUDJPY');
		$nzdjpy = $this->getValue('NZDJPY');
		$time = $this->getTime('USDJPY');
		$merged = array_merge($usdjpy,$eurusd,$gbpjpy,$eurjpy,$audusd,$audjpy,$nzdjpy);
		$max = ceil(max($merged));
		$min = ceil(min($merged));
		// $unit= ($max-$min)/10;
		$uj_max = ceil(max($usdjpy));
		$eu_max = ceil(max($eurusd));
		$gj_max = ceil(max($gbpjpy));
		$ej_max = ceil(max($eurjpy));
		$au_max = ceil(max($audusd));
		$aj_max = ceil(max($audjpy));
		$nj_max = ceil(max($nzdjpy));
		$uj_min = ceil(min($usdjpy));
		$eu_min = ceil(min($eurusd));
		$gj_min = ceil(min($gbpjpy));
		$ej_min = ceil(min($eurjpy));
		$au_min = ceil(min($audusd));
		$aj_min = ceil(min($audjpy));
		$nj_min = ceil(min($nzdjpy));
		$uj_slope = substr($this->linear_regression($usdjpy,30),0,4);
		$eu_slope = substr($this->linear_regression($eurusd,30),0,4);
		$gj_slope = substr($this->linear_regression($gbpjpy,30),0,4);
		$ej_slope = substr($this->linear_regression($eurjpy,30),0,4);
		$au_slope = substr($this->linear_regression($audusd,30),0,4);
		$aj_slope = substr($this->linear_regression($audjpy,30),0,4);
		$nj_slope = substr($this->linear_regression($nzdjpy,30),0,4);

		$USDJPY2 = Model_Regression::find_one_by('pair',"USDJPY");
		$EURUSD2 = Model_Regression::find_one_by('pair',"EURUSD");
		$GBPJPY2 = Model_Regression::find_one_by('pair',"GBPJPY");
		$EURJPY2 = Model_Regression::find_one_by('pair',"EURJPY");
		$AUDUSD2 = Model_Regression::find_one_by('pair',"AUDUSD");
		$AUDJPY2 = Model_Regression::find_one_by('pair',"AUDJPY");
		$NZDJPY2 = Model_Regression::find_one_by('pair',"NZDJPY");
		$view->set_safe('usdjpy2',$USDJPY2);
		$view->set_safe('eurusd2',$EURUSD2);
		$view->set_safe('gbpjpy2',$GBPJPY2);
		$view->set_safe('eurjpy2',$EURJPY2);
		$view->set_safe('audusd2',$AUDUSD2);
		$view->set_safe('audjpy2',$AUDJPY2);
		$view->set_safe('nzdjpy2',$NZDJPY2);

    $view->set_safe('usdjpy',json_encode($usdjpy));
    $view->set_safe('eurusd',json_encode($eurusd));
    $view->set_safe('gbpjpy',json_encode($gbpjpy));
    $view->set_safe('eurjpy',json_encode($eurjpy));
    $view->set_safe('audusd',json_encode($audusd));
    $view->set_safe('audjpy',json_encode($audjpy));
    $view->set_safe('nzdjpy',json_encode($nzdjpy));
		$view->set_safe('time',json_encode($time));
		$view->set_safe('max',$max);
		$view->set_safe('min',$min);
		$view->set_safe('uj_max',$uj_max);
		$view->set_safe('eu_max',$eu_max);
		$view->set_safe('gj_max',$gj_max);
		$view->set_safe('ej_max',$ej_max);
		$view->set_safe('au_max',$au_max);
		$view->set_safe('aj_max',$aj_max);
		$view->set_safe('nj_max',$nj_max);
		$view->set_safe('uj_min',$uj_min);
		$view->set_safe('eu_min',$eu_min);
		$view->set_safe('gj_min',$gj_min);
		$view->set_safe('ej_min',$ej_min);
		$view->set_safe('au_min',$au_min);
		$view->set_safe('aj_min',$aj_min);
		$view->set_safe('nj_min',$nj_min);
		$view->set_safe('uj_slope',$uj_slope);
		$view->set_safe('eu_slope',$eu_slope);
		$view->set_safe('gj_slope',$gj_slope);
		$view->set_safe('ej_slope',$ej_slope);
		$view->set_safe('au_slope',$au_slope);
		$view->set_safe('aj_slope',$aj_slope);
		$view->set_safe('nj_slope',$nj_slope);
    return $view;
	}

	private function getTime($pair) {
		$data = [];
		$model = Model_Change::find_by('pair',$pair);
		if (!isset($model)) return $data;
		foreach ($model as $key => $value) {
			$data[] = $key+1;
		}
		return $data;
	}


	private function getValue($pair) {
	    $data = [];
	    $model = Model_Change::find_by('pair',$pair);
	    if (!isset($model)) return $data;
	    foreach ($model as $key => $value) {
	      $data[] = $value->change;
	    }
	    return $data;
	  }

  function linear_regression($sample, $count) {
		//return 0;
		if (count($sample) < $count) return 0;
		$x = [];
		for($i = $count; $i != 0; $i--) {
				$x[] = $sample[count($sample)-$i];
		}
		$y = [];
		for($i = 1; $i < $count+1; $i++) {
			$y[] = $i;
		}
		$n     = count($x);     // number of items in the array
		$x_sum = array_sum($x); // sum of all X values
		$y_sum = array_sum($y); // sum of all Y values

		$xx_sum = 0;
		$xy_sum = 0;

		for($i = 0; $i < $n; $i++) {
				$xy_sum += ( $x[$i]*$y[$i] );
				$xx_sum += ( $x[$i]*$x[$i] );
		}
		return 0;
		// Slope
		// return ( ( $n * $xy_sum ) - ( $x_sum * $y_sum ) ) / ( ( $n * $xx_sum ) - ( $x_sum * $x_sum ) );

	}


		public function action_fourier()
		{
			// $USDJPY = Model_Ema::find_by('pair',"USDJPY");
			// $EURUSD = Model_Ema::find_by('pair',"EURUSD");
			// $GBPJPY = Model_Ema::find_by('pair',"GBPJPY");
			// $EURJPY = Model_Ema::find_by('pair',"EURJPY");
			// $AUDUSD = Model_Ema::find_by('pair',"AUDUSD");
			// $AUDJPY = Model_Ema::find_by('pair',"AUDJPY");
			// $NZDJPY = Model_Ema::find_by('pair',"NZDJPY");
			// // $data = [119.41364991,119.40597487,119.3949623,119.38794345,119.38891518,119.39387277,119.39630916,119.39896374,119.40194561,119.39391842,119.38087762,119.37881644,119.37672466,119.38108698,119.38263047,119.39194571];
			// $this->outputFFT($USDJPY);
			// $this->outputFFT($EURUSD);
			// $this->outputFFT($GBPJPY);
			// $this->outputFFT($EURJPY);
			// $this->outputFFT($AUDUSD);
			// $this->outputFFT($AUDJPY);
			// $this->outputFFT($NZDJPY);
			$data = file_get_contents(DOCROOT."USDJPY_bid.csv");
	 		$data = Format::forge($data, 'csv')->to_array();
			Debug::dump($data);
		}
}
