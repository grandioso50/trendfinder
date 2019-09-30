<?php

namespace Fuel\Migrations;

class Add_function_to_regression
{
	public function up()
	{
		\DBUtil::add_fields('regression', array(
			'function' => array('type' => 'text', 'after' => 'regression'),

		));
	}

	public function down()
	{
		\DBUtil::drop_fields('regression', array(
			'function'

		));
	}
}
