<?php

class Model_Change extends Model_Base
{

    protected static $_table_name = 'daily_change';
    protected static $_primary_key = 'id';
    protected static $_properties = [
        'id',
        'pair',
        'change',
        'created_at',
        'updated_at'
    ];
}
