<?php

class Model_Ema extends Model_Base
{

    protected static $_table_name = 'daily_ema';
    protected static $_primary_key = 'id';
    protected static $_properties = [
        'id',
        'pair',
        'ema',
        'created_at',
        'updated_at'
    ];
}
