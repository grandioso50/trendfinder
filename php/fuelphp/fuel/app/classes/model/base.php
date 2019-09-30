<?php

class Model_Base extends \Model_Crud
{
    const VALID     = 1;
    const INVALID   = 0;

    protected static $_observers = [
        'Orm\Observer_Self' => [
            'events' => [
                'after_create', 'after_load', 'before_save', 'after_save',
                'bofore_insert', 'after_insert', 'before_update',
                'after_update', 'before_delete', 'after_delete'

            ]
        ],
        'Orm\Observer_CreatedAt' => [
            'events' => ['before_insert'],
            'property' => 'created_at',
            'mysql_timestamp' => true,
            'override' => true
        ],
        'Orm\Observer_UpdatedAt' => [
            'events' => ['before_update'],
            'property' => 'updated_at',
            'mysql_timestamp' => true,
            'override' => true
        ],
        'Orm\Observer_Validation' => [
            'events' => [
                'before_save'
            ]
		],
		'Observer_DataTransaction' => [
			'events' => [
				'after_insert', 'after_update', 'after_delete'
			]
		]
    ];
}
