<?php
$now = microtime(true);
$filepath = $argv[1].".csv";
$file = new SplFileObject($filepath);
$file->setFlags(SplFileObject::READ_CSV);
$csv = fgetcsv($file);
$records = [];
foreach ($file as $line) {
  $records[] = $line;
}
$raw = $records;
$getFuture = function ($after,$current,$idx = 5) {
  if (is_null($after)) return "null";
  return $after[$idx] > $current ? "1" : "0";
};

foreach ($records as $idx => $record) {
  $current_bid = (int)$records[$idx][3];
  $after_1m = array_key_exists($idx+1,$records) ? $records[$idx+1] : null;
  $after_3m = array_key_exists($idx+3,$records) ? $records[$idx+3] : null;
  $after_5m = array_key_exists($idx+5,$records) ? $records[$idx+5] : null;
  $after_10m = array_key_exists($idx+10,$records) ? $records[$idx+10] : null;
  $after_1m_val = $getFuture($after_1m,$current_bid);
  $after_3m_val =  $getFuture($after_3m,$current_bid);
  $after_5m_val =  $getFuture($after_5m,$current_bid);
  $after_10m_val =  $getFuture($after_10m,$current_bid);
  $records[$idx][] = $after_1m_val;
  $records[$idx][] = $after_3m_val;
  $records[$idx][] = $after_5m_val;
  $records[$idx][] = $after_10m_val;
}

$serialize = function ($array) {
  $multi_dim = [];
  foreach ($array as $val) {
    $multi_dim[][] = $val;
  }
  return $multi_dim;
};

array_splice($records,-10,10);
array_splice($raw,-10,10);

$after_1m = array_column($records,count($records[0])-4);
$after_3m = array_column($records,count($records[0])-3);
$after_5m = array_column($records,count($records[0])-2);
$after_10m = array_column($records,count($records[0])-1);
$after_1m = $serialize($after_1m);
$after_3m = $serialize($after_3m);
$after_5m = $serialize($after_5m);
$after_10m = $serialize($after_10m);

$file = new SplFileObject($filepath."_input.csv",'w');
foreach ($raw as $fields) {
  $file->fputcsv($fields);
}

$file = new SplFileObject($filepath."_label_1m.csv",'w');
foreach ($after_1m as $fields) {
  $file->fputcsv($fields);
}
$file = new SplFileObject($filepath."_label_3m.csv",'w');
foreach ($after_3m as $fields) {
  $file->fputcsv($fields);
}
$file = new SplFileObject($filepath."_label_5m.csv",'w');
foreach ($after_5m as $fields) {
  $file->fputcsv($fields);
}
$file = new SplFileObject($filepath."_label_10m.csv",'w');
foreach ($after_10m as $fields) {
  $file->fputcsv($fields);
}
$end = microtime(true);
echo "formatting done...";
echo "time elasped...: ".$end-$now;
