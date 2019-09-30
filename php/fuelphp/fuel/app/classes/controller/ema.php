<?php
use Fuel\Core\DBUtil;

class Controller_EMA extends Controller_Rest
{

  private function clear($pair) {
    $entry = Model_Ema::find(['order_by' => ['created_at' => 'desc'],'limit'=>1]);
    if (!$entry) return;
    $last_updated;
    foreach ($entry as $key => $value) {
      $last_updated = $value->created_at;
    }
    //一定の時間を過ぎたら削除
    if ((time()-strtotime($last_updated))/60 > 60) {
      \DBUtil::truncate_table('daily_ema');
    }
  }

  public function post_index()
  {
    \Log::info(Input::post('ema'));
    \Log::info(serialize(Format::forge(Input::post('ema'), 'json')->to_array()));
    // $this->clear(Input::post('pair'));
    // Model_Ema::forge(
    //   [
    //     'pair' => Input::post('pair'),
    //     'ema' => Input::post('ema'),
    //   ]
    // )->save();
    $this->response([],200);
  }
}
