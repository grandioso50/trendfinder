<?php
namespace Fuel\Tasks;
use Fuel\Core\Cli;
use Fuel\Core\DB;
use Fuel\Core\DBUtil;
use Curl\CurlUtil;

class Minute
{
    public function run()
    {
        \Log::info("minute task called.");
        $file = new SplFileObject("C:\Users\Kiyoshi\AppData\Roaming\MetaQuotes\Terminal\915566BA06ADA407569C544CC0D97611\MQL4\USDJPY_bid.csv");
        foreach ($file as $line) {
          if (is_null($line[0]) {}
            $records[] = $line;
         }
         \Log::info(serialize($records));
    }
}
