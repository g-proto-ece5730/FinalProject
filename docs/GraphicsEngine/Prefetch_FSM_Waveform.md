## Prefetch FSM Waveform
```wavedrom
{'edge': [
    'AB',
    'CD',
    'EF',
    'Z->A Idle',
    'A<->C Fetch Blocks',
    'C<->G Fetch Score',
],
'signal': [

{'name': 'state',               'node': 'Z.A........C.......E.....G'},
{'name': 'pxclk',               'wave': 'p.......................'},
{},
['VGA',
    ['In',
    {'name': 'x[]',             'wave': 'x=======================',
                                    'data': ['0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22']},
    {'name': 'valid',           'wave': '01......................'},
    ],
],
{},
['Game Engine',
    ['Out',
    {'name': 'en',              'wave': '0.1.....................'},
    {'name': 'block_score_n',   'wave': 'x.1........0............'},
    {'name': 'hpos[]',          'wave': 'x.==========.......=....',
                                    'data': ['0','1','2','3','4','5','6','7','8','0','1',]},
    {'name': 'vpos[]',          'wave': 'x.=........x............',
                                    'data': ['']},
    ],
    ['In',
    {'name': 'data[]',          'wave': 'x.5555555553333333344444',
                                    'data': ['']},
    ],
],
{},{},
['Color LUT',
    ['Out',
    {'name': 'en',              'wave': '0.1........0............'},
    {'name': 'sel[]',           'wave': 'x.555555555x............',
                                    'data': ['']},
    ],
    ['In',
    {'name': 'rgb[]',           'wave': 'x.999999999x............',
                                    'data': ['']},
    ],
],
{},
['BLock FIFO',
    ['Out',
    {'name': 'wreq',            'wave': '0.1........0............'},
    {'name': 'din',             'wave': 'x.999999999x............'},
    ],
],
{},{},
['Font LUT',
    ['Out',
    {'name': 'en',              'wave': '0..........1............'},
    {'name': 'sel[]',           'wave': 'x..........3.......4....',
                                    'data': ['']},
    {'name': 'x[]',             'wave': 'x..........=============',
                                    'data': ['0','1','2','3','4','5','6','7','0','1','2','3','4']},
    {'name': 'y[]',             'wave': 'x..........=............',
                                    'data': ['']},
    ],
    ['In',
    {'name': 'px',              'wave': 'x..........9999999999999'},
    ],
],
{},
['FontFIFO',
    ['Out',
    {'name': 'wreq',            'wave': '0..........1............'},
    {'name': 'din',             'wave': 'x..........9999999999999'},
    ],
],
{'': '',                        'node': '..B........D.......F'},

]}
```