<?php

class Controller_Function extends Controller
{
	public function action_index()
	{
    $bids = [
      1,3,2,1,5,6,10,9,8,7,0
    ];
    $current = 0;
    $next = 0;
    $count = 0;
    $max_asc = 0;
    $max_desc = 0;
    $num_ascs = 0;
    $num_descs = 0;
    $was_asc = false;
    $was_desc = false;

      while($bids[$count] != 0){
       $next = $bids[$count+1];
       $current = $bids[$count];
       if ($next != 0) {
          if ($next > $current) {
            if ($num_descs > $max_desc) {
              $max_desc = $num_descs;
            }
            $num_descs = 0;
            $was_asc = true;
            $was_desc = false;
            if ($was_asc) {
               $num_ascs++;
             }
          } else if ($next < $current) {
            if ($num_ascs > $max_asc) {
              $max_asc = $num_ascs;
            }
            $num_ascs = 0;
             $was_asc = false;
             $was_desc = true;
             if ($was_desc) {
                $num_descs++;
              }
          }
       }
       $count++;
       if ($bids[$count] == 0) {
         if ($max_asc == 0 || $num_ascs > $max_asc)$max_asc = $num_ascs;
         if ($max_desc == 0 || $num_descs > $max_desc)$max_desc = $num_descs;
       }
     }
     echo "max asc".$max_asc;
     echo "\n";
     echo "max desc".$max_desc;
	}


}
