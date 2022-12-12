## Draw Block
```wavedrom
{'edge': [
    'A|B',
    'C-D'
],
'signal': [
{'': '',                            'node': '.AC'},
{'name': 'pxclk',                   'wave': 'p.........'},
{},
['VGA',
    ['In',
    {'name': 'vsync',               'wave': '0.........'},
    {'name': 'x',                   'wave': '==========',
                                        'data': ['(-3)','(-2)','(-1)','(0)','(1)','(2)','(3)','(4)','(5)','(6)']},
    {'name': 'y',                   'wave': '=.........',
                                        'data': ['Y0']},
    {'name': 'valid',               'wave': '1.........'},
    ],
    {},
    ['Out',
    {'name': 'rgb[]',               'wave': '0..9......',
                                        'data': ['0xFF0000']},
    ],
],
{},
['Game Engine',
    ['Out',
    {'name': 'vsync',               'wave': '0.........'},
    {'name': 'en',                  'wave': '010.......'},
    {'name': 'block_digit_n',       'wave': 'x1x.......'},
    {'name': 'hpos[]',              'wave': 'x=x.......'},
    {'name': 'vpos[]',              'wave': 'x=x.......'},
    ],
    {},
    ['In',
    {'name': 'data[3:0]',           'wave': 'x.=x......',
                                        'data': ['red']},
    ],
],
{},
['Color LUT',
    ['Out',
    {'name': 'color[]',             'wave': 'x.=x......',
                                        'data': ['red']},
    ],
    {},
    ['In',
    {'name': 'rgb[]',               'wave': 'x.9x......',
                                        'data': ['']},
    ],
],
{'': '',                            'node': '.BD'},
]}
```

## Draw Digit
```wavedrom
{'edge': [
    'A|B',
    'C-D',
    'E|F',
    'G-H'
],
'signal': [
{'name': '',                        'node': '..AC..........EG'},
{'name': 'pxclk',                   'wave': 'p.....................'},
{},
['VGA',
    ['In',
    {'name': 'vsync',               'wave': '0.....................'},
    {'name': 'x',                   'wave': '===========|==========',
                                        'data': ['(-4)','(-3)','(-2)','(-1)','(0)','(1)','(2)','(3)','(4)','(5)','(6)','(12|-4)','(13|-3)','(14|-2)','(15|-1)','0','(1)','(2)','(3)','(4)','(5)']},
    {'name': 'y',                   'wave': '=..........|.........',
                                        'data': ['Y1']},
    {'name': 'valid',               'wave': '1..........|..........'},
    ],
    {},
    ['Out',
    {'name': 'rgb[]',               'wave': '0...3.3.3.3|3.3.3.3.3.',
                                        'data': ['0','1','2','3','6','7','0','1','2']},
    ],
],
{},
['Game Engine',
    ['Out',
    {'name': 'vsync',               'wave': '0..........|..........'},
    {'name': 'en',                  'wave': '010.......|..10.......'},
    {'name': 'block_digit_n',       'wave': 'x0x.......|..0x.......'},
    {'name': 'hpos[]',              'wave': 'x=x.......|..=x.......',
                                        'data': ['0','1']},
    {'name': 'vpos[]',              'wave': 'x.....................'},
    ],
    {},
    ['In',
    {'name': 'data[3:0]',           'wave': 'x.=x......|..=x.......',
                                        'data': ['num','num']},
    ],
],
{},
['Font LUT',
    ['Out',
    {'name': 'num[]',               'wave': 'x..=.......|..=.......',
                                        'data': ['num','num']},
    {'name': 'xaddr[]',             'wave': 'x..=.=.=.=.|==.=.=.=.=',
                                        'data': ['0','1','2','3','6','7','0','1','2','3']},
    {'name': 'yaddr[]',             'wave': 'x..=.......|..........',
                                        'data': ['']},
    ],
    {},
    ['In',
    {'name': 'px',                  'wave': 'x..3.3.3.3.|33.3.3.3.3',
                                        'data': ['0','1','2','3','6','7','0','1','2','3']},
    ],
],
{'name': '',                        'node': 'x.BD..........FH'},
]}
```