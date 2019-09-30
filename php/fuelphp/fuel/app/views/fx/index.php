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
								if ($usdjpy2) {
									$value = json_decode($usdjpy2->regression,true);
									echo "<tr>";
									echo "<td>USDJPY</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$usdjpy2->created_at."</td>";
									echo "</tr>";
								}
								if ($eurusd2) {
									$value = json_decode($eurusd2->regression,true);
									echo "<tr>";
									echo "<td>EURUSD</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$eurusd2->created_at."</td>";
									echo "</tr>";
								}
								if ($gbpjpy2) {
									$value = json_decode($gbpjpy2->regression,true);
									echo "<tr>";
									echo "<td>GBPJPY</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$gbpjpy2->created_at."</td>";
									echo "</tr>";
								}
								if ($eurjpy2) {
									$value = json_decode($eurjpy2->regression,true);
									echo "<tr>";
									echo "<td>EURJPY</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$eurjpy2->created_at."</td>";
									echo "</tr>";
								}
								if ($audusd2) {
									$value = json_decode($audusd2->regression,true);
									echo "<tr>";
									echo "<td>AUDUSD</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$audusd2->created_at."</td>";
									echo "</tr>";
								}
								if ($audjpy2) {
									$value = json_decode($audjpy2->regression,true);
									echo "<tr>";
									echo "<td>AUDJPY</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$audjpy2->created_at."</td>";
									echo "</tr>";
								}
								if ($nzdjpy2) {
									$value = json_decode($nzdjpy2->regression,true);
									echo "<tr>";
									echo "<td>NZDJPY</td>";
									echo "<td>".substr($value[0],0,4)."</td>";
									echo "<td>".substr($value[1],0,4)."</td>";
									echo "<td>".substr($value[2],0,4)."</td>";
									echo "<td>".substr($value[3],0,4)."</td>";
									echo "<td>".substr($value[4],0,4)."</td>";
									echo "<td>".substr($value[4]-$value[0],0,4)."</td>";
									echo "<td>".$nzdjpy2->created_at."</td>";
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
		var maxes = [
			<?php echo $uj_max; ?>,
			<?php echo $eu_max; ?>,
			<?php echo $gj_max; ?>,
			<?php echo $ej_max; ?>,
			<?php echo $au_max; ?>,
			<?php echo $aj_max; ?>,
			<?php echo $nj_max; ?>,
		];
		var ctx = document.getElementById('myChart').getContext('2d');
		var myChart = new Chart(ctx, {
				type: 'bar',
				data: {
						labels: JSON.parse('<?php echo $time; ?>'),
						datasets: [{
								label: 'USDJPY('+'<?php echo $uj_slope; ?>)',
								type: "line",
								fill: false,
								data: JSON.parse('<?php echo $usdjpy; ?>'),
								borderColor: "rgb(154, 162, 235)",
								yAxisID: "y-axis-1",
						}, {
								label: 'EURUSD('+'<?php echo $eu_slope; ?>)',
								type: "line",
								fill: false,
								data: JSON.parse('<?php echo $eurusd; ?>'),
								borderColor: "rgb(160, 0, 100)",
								yAxisID: "y-axis-1",
						},{
							label: 'GBPJPY('+'<?php echo $gj_slope; ?>)',
							type: "line",
							fill: false,
							data: JSON.parse('<?php echo $gbpjpy; ?>'),
							borderColor: "rgb(116, 150, 100)",
							yAxisID: "y-axis-1",
						},{
							label: 'EURJPY('+'<?php echo $ej_slope; ?>)',
							type: "line",
							fill: false,
							data: JSON.parse('<?php echo $eurjpy; ?>'),
							borderColor: "rgb(200, 225, 0)",
							yAxisID: "y-axis-1",
						},{
							label: 'AUDUSD('+'<?php echo $au_slope; ?>)',
							type: "line",
							fill: false,
							data: JSON.parse('<?php echo $audusd; ?>'),
							borderColor: "rgb(150, 110, 0)",
							yAxisID: "y-axis-1",
						},{
							label: 'AUDJPY('+'<?php echo $aj_slope; ?>)',
							type: "line",
							fill: false,
							data: JSON.parse('<?php echo $audjpy; ?>'),
							borderColor: "rgb(200, 0, 0)",
							yAxisID: "y-axis-1",
						},{
							label: 'NZDJPY('+'<?php echo $nj_slope; ?>)',
							type: "line",
							fill: false,
							data: JSON.parse('<?php echo $nzdjpy; ?>'),
							borderColor: "rgb(0,0,0)",
							yAxisID: "y-axis-1",
						}]
				},
				options: {
						tooltips: {
								mode: 'nearest',
								intersect: false,
						},
						legend: {
							// a callback that will handle
							onClick: function(e, legendItem) {
								var index = legendItem.datasetIndex;
								var ci = this.chart;
								var meta = ci.getDatasetMeta(index);

								// See controller.isDatasetVisible comment
								meta.hidden = meta.hidden === null ? !ci.data.datasets[index].hidden : null;
								
								var shown = [];
								$.each(ci.data.datasets, function(idx, val) {
									if (ci.isDatasetVisible(idx)) shown.push(idx);
								});
								var visible_maxes = [];
								$.each(shown, function(idx, val) {
									visible_maxes.push(maxes[val]);
								});
								var new_max = Math.max.apply(null,visible_maxes);
								if (new_max > 0) {
									ci.options.scales.yAxes[0].ticks.max = new_max;
									ci.options.scales.yAxes[1].ticks.max = new_max;
								}

								// We hid a dataset ... rerender the chart
								ci.update();
							},
						},
						responsive: true,
						scales: {
								yAxes: [{
										id: "y-axis-1",
										type: "linear",
										position: "left",
										ticks: {
												max: 2,
												min: -2
										},
								}, {
										id: "y-axis-2",
										type: "linear",
										position: "right",
										ticks: {
												max: 2,
												min: -2
										},
										gridLines: {
												drawOnChartArea: false,
										},
								}],
						},
				}
		});
	});
	</script>

</body>
</html>
