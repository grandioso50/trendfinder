<?php
use Fuel\Core\DBUtil;

class Controller_Transit extends Controller_Rest
{

  private function clear() {
    $entry = Model_Change::find(['order_by' => ['created_at' => 'desc'],'limit'=>1]);
    if (!$entry) return;
    $last_updated;
    foreach ($entry as $key => $value) {
      $last_updated = $value->created_at;
    }
    //一定の時間を過ぎたら削除
    if ((time()-strtotime($last_updated))/60 > 60) {
      \DBUtil::truncate_table('daily_change');
    }
  }

  public function post_rsquare() {
    $data = Input::json();
    $pair = Arr::get($data,'pair');
    $this->findOrDelete($pair);
    $fit = Arr::get($data,'fit');
    $fit = Arr::get($fit,'polynomial');
    Model_Regression::forge(
      [
        'pair' => $pair,
        'regression' => json_encode(Arr::get($data,'data')),
        'function' => json_encode($fit)
      ]
    )->save();
  }

  private function findOrDelete($pair) {
    $entries = Model_Regression::find_by('pair',$pair);
    if (count($entries) > 0) {
      foreach ($entries as $key => $value) {
        $value->delete();
      }
    }
  }

  private function deleteLast($pair) {
    $entries = Model_Change::find_by([
      'pair' => $pair,
      ['created_at','<',date("Y-m-d H:i:s",strtotime("-1 hour"))]
    ]);
    if ($entries) {
      foreach ($entries as $key => $value) {
        $value->delete();
      }
    }
  }

  public function post_index()
  {
    $this->clear();
    $this->deleteLast(Input::post('pair'));
    Model_Change::forge(
      [
        'pair' => Input::post('pair'),
        'change' => Input::post('change'),
      ]
    )->save();
    $this->response([],200);
  }
}
