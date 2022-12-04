```wavedrom
{'edge': [
    'A|B'
],
'signal': [
{'name': 'pxclk',                   'wave': 'p.............'},
{},
['VGA',
    ['In',
    {'name': 'vsync',               'wave': '0.............'},
    {'name': 'x',                   'wave': 'x.456.......7.',
                                        'data': ['A0','A1','A2','A3','A4']},
    {'name': 'y',                   'wave': 'x.456.......7.',
                                        'data': ['A0','A1','A2','A3','A4']},
    {'name': 'valid',               'wave': 'x1...........'},
    ],
    {},
    ['Out',
    {'name': 'rgb',                 'wave': 'x01...........'},
    ],
],
{},
['Game Engine',
    ['Out',
    {'name': 'vsync',               'wave': ''},
    {'name': 'en',                  'wave': ''},
    {'name': 'block_digit_n',       'wave': ''},
    {'name': 'xaddr[]',             'wave': ''},
    {'name': 'yaddr[]',             'wave': ''},
    ],
    {},
    ['In',
    {'name': 'data[3:0]',           'wave': ''},
    ],
]
]}
```