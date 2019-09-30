<?php

namespace Fuel\Migrations;

class Create_regression
{

    function up()
    {
    \DBUtil::create_table('regression', array(
                'id' => array('constraint' => 11, 'type' => 'int', 'auto_increment' => true, 'unsigned' => true),
                'pair' => array('type' => 'varchar(255)'),
                'regression' => array('type' => 'text'),
                'created_at' => array('type' => 'timestamp', 'null' => false, 'default' => \DB::expr('CURRENT_TIMESTAMP')),
                'updated_at' => array('type' => 'timestamp', 'null' => true),
              ), array('id'),true, 'InnoDB');
    }

    function down()
    {
       \DBUtil::drop_table('daily_ema');
    }
}
