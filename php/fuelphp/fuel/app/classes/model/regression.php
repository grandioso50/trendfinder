<?php

class Model_Regression extends Model_Base
{

    protected static $_table_name = 'regression';
    protected static $_primary_key = 'id';
    protected static $_properties = [
        'id',
        'pair',
        'regression',
        'function',
        'created_at',
        'updated_at'
    ];
}
