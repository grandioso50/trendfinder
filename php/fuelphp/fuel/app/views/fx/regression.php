<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Daily</title>
	<?php echo Asset::css('bootstrap.css'); ?>
	<?php echo Asset::js('https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js'); ?>
	<?php echo Asset::js('https://cdn.jsdelivr.net/npm/chart.js@2.8.0/dist/Chart.min.js'); ?>
</head>
<body>
	<header>
		<div class="container">
			<div id="logo"></div>
		</div>
	</header>
	<div class="container">
		<div class="row">
			<div class="col-12">
							<canvas id="myChart"></canvas>
			</div>
		</div>
		<div class="row">
			<div class="col-12">
				<table id="regression-table" class="table table-bordered">
		        <thead>
		            <tr><th>ペア</th>
								<th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>差</th><th>更新時間</th>
								</tr>
		        </thead>
		        <tbody>
							<?php
								if ($usdjpy) {
									$value = json_decode($usdjpy->regression,true);
									echo "<tr>";
									echo "<td>USDJPY</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$usdjpy->created_at."</td>";
									echo "</tr>";
								}
								if ($eurusd) {
									$value = json_decode($eurusd->regression,true);
									echo "<tr>";
									echo "<td>EURUSD</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$eurusd->created_at."</td>";
									echo "</tr>";
								}
								if ($gbpjpy) {
									$value = json_decode($gbpjpy->regression,true);
									echo "<tr>";
									echo "<td>GBPJPY</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$gbpjpy->created_at."</td>";
									echo "</tr>";
								}
								if ($eurjpy) {
									$value = json_decode($eurjpy->regression,true);
									echo "<tr>";
									echo "<td>EURJPY</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$eurjpy->created_at."</td>";
									echo "</tr>";
								}
								if ($audusd) {
									$value = json_decode($audusd->regression,true);
									echo "<tr>";
									echo "<td>AUDUSD</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$audusd->created_at."</td>";
									echo "</tr>";
								}
								if ($audjpy) {
									$value = json_decode($audjpy->regression,true);
									echo "<tr>";
									echo "<td>AUDJPY</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$audjpy->created_at."</td>";
									echo "</tr>";
								}
								if ($nzdjpy) {
									$value = json_decode($nzdjpy->regression,true);
									echo "<tr>";
									echo "<td>NZDJPY</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$nzdjpy->created_at."</td>";
									echo "</tr>";
								}
							?>
		        </tbody>
		    </table>
			</div>
		</div>
	</div>
	<script>
	$(document).ready(function() {
		var uj = JSON.parse(<?php echo $uj_json; ?>);
		var eu = JSON.parse(<?php echo $eu_json; ?>);
		var gj = JSON.parse(<?php echo $gj_json; ?>);
		var ej = JSON.parse(<?php echo $ej_json; ?>);
		var au = JSON.parse(<?php echo $au_json; ?>);
		var aj = JSON.parse(<?php echo $aj_json; ?>);
		var nj = JSON.parse(<?php echo $nj_json; ?>);
// 		var ctx = document.getElementById("myChart");
// var data = {
// 		labels: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240],
//     datasets: [
			// {
      //   label: "USDJPY",
      //   function: function(x) { return uj[0]*x^5+uj[1]*x^4+uj[2]*x^3+uj[3]*x^2+uj[4]*x+uj[5] },
      //   borderColor: "rgb(154, 162, 235)",
      //   data: [],
      //   fill: false
    	// },
			// {
			// 	label: "EURUSD",
			// 	function: function(x) { return eu[0]*x^5+eu[1]*x^4+eu[2]*x^3+eu[3]*x^2+eu[4]*x+eu[5] },
			// 	borderColor: "rgb(160, 0, 100)",
			// 	data: [],
			// 	fill: false
			// },
			// {
			// 	label: "GBPJPY",
			// 	function: function(x) { return gj[0]*x^5+gj[1]*x^4+gj[2]*x^3+gj[3]*x^2+gj[4]*x+gj[5] },
			// 	borderColor: "rgb(116, 150, 100)",
			// 	data: [],
			// 	fill: false
			// },
			// {
			// 	label: "EURJPY",
			// 	function: function(x) { return ej[0]*x^5+ej[1]*x^4+ej[2]*x^3+ej[3]*x^2+ej[4]*x+ej[5] },
			// 	borderColor: "rgb(200, 225, 0)",
			// 	data: [],
			// 	fill: false
			// },
			// {
			// 	label: "AUDUSD",
			// 	function: function(x) { return au[0]*x^5+au[1]*x^4+au[2]*x^3+au[3]*x^2+au[4]*x+au[5] },
			// 	borderColor: "rgb(150, 110, 0)",
			// 	data: [],
			// 	fill: false
			// },
			// {
			// 	label: "AUDJPY",
			// 	function: function(x) { return aj[0]*x^5+aj[1]*x^4+aj[2]*x^3+aj[3]*x^2+aj[4]*x+aj[5] },
			// 	borderColor: "rgb(0,0,0)",
			// 	data: [],
			// 	fill: false
			// },
			// {
			// 	label: "NZDJPY",
			// 	function: function(x) { return nj[0]*x^5+nj[1]*x^4+nj[2]*x^3+nj[3]*x^2+nj[4]*x+nj[5] },
			// 	borderColor: "rgba(75, 192, 192, 1)",
			// 	data: [],
			// 	fill: false
			// },
// 			{
// 				label: "NZDJPY",
// 				function: function(x) { return (2e-12)*x^5-(1e-9)*x^4+(3e-7)*x^3-(3e-5)*x^2+0.0013*x+67.801 },
// 				borderColor: "rgba(75, 192, 192, 1)",
// 				data: [],
// 				fill: false,
// 				yAxisID: "y-axis-1"
// 			},
// 	]
// };
//
// Chart.pluginService.register({
//     beforeInit: function(chart) {
//         var data = chart.config.data;
//         for (var i = 0; i < data.datasets.length; i++) {
//             for (var j = 0; j < data.labels.length; j++) {
//             	var fct = data.datasets[i].function,
//                 	x = data.labels[j],
//                 	y = fct(x);
//                 data.datasets[i].data.push(y);
//             }
//         }
//     }
// });
//
// var myBarChart = new Chart(ctx, {
//     type: 'line',
//     data: data,
//     options: {
//         scales: {
//             yAxes: [
// 							{
// 									id: "y-axis-1",
// 									type: "linear",
// 									position: "left",
// 									ticks: {
// 											max: 75,
// 											min: 65
// 									},
// 							}
// 					]
//         }
//     }
// });
	});
	</script>

</body>
</html>
