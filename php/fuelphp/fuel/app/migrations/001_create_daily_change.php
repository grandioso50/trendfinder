<?php

namespace Fuel\Migrations;

class Create_daily_change
{

    function up()
    {
    \DBUtil::create_table('daily_change', array(
                'id' => array('constraint' => 11, 'type' => 'int', 'auto_increment' => true, 'unsigned' => true),
                'pair' => array('type' => 'varchar(255)'),
                'change' => array('type' => 'double'),
                'created_at' => array('type' => 'timestamp', 'null' => false, 'default' => \DB::expr('CURRENT_TIMESTAMP')),
                'updated_at' => array('type' => 'timestamp', 'null' => true),
              ), array('id'),true, 'InnoDB');
    }

    function down()
    {
       \DBUtil::drop_table('daily_change');
    }
}
