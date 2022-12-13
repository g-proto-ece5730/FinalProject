## Block Draw
```wavedrom
{'edge': [
    'AB',
    'CD',
    'EF',
    'GH',
    'IJ',
    'X->A IDLE',
    'A<->C BORDER_L',
    'C<->G BLOCKS',
    'G<->I BORDER_R',
    'I<->Z IDLE',
],
'signal': [

{'name': 'state',               'node': 'X.AC.....E.......GI.Z'},
{'name': 'pxclk',               'wave': 'p.....|....|..|....'},
['VGA',
    ['In',
    {'name': 'x[]',             'wave': '======|====|==|====',
                                    'data': ['174','175','176','177','178','','207','208','209','','','','464','465','466','467']},
    {'name': 'y[]  ',           'wave': '=.....|....|..|....',
                                    'data': ['18']},
    {'name': 'valid',           'wave': '1.....|....|..|....'},
    ],
    ['Out',
    {'name': 'rgb[]',           'wave': '0.13..|..4.|.=|8.10'},
    ]
],
{},
['Block FIFO',
    ['Out',
    {'name': 'rack',            'wave': '0.10..|.10.|10|....'},
    ],
    ['In',
    {'name': 'dout[]',          'wave': '3..4..|..5.|=.|x...'},
    ]
],
{'': '',                        'node': '..BD.....F.......HJ'},

]}
```

<br>

## Score Draw
```wavedrom
{'edge': [
    'AB',
    'CD',
    'X->A IDLE',
    'A<->C SCORE',
    'C<->Z IDLE',
],
'signal': [

{'name': 'state',               'node': 'X.A........C.Z'},
{'name': 'pxclk',               'wave': 'p......|....'},
{},
['VGA',
    ['In',
    {'name': 'x[]',             'wave': '=======|====',
                                    'data': ['478','479','480','481','482','483','','621','622','623','624']},
    {'name': 'y[]  ',           'wave': '=......|....',
                                    'data': ['320']},
    {'name': 'valid',           'wave': '1......|....'},
    ],
    ['Out',
    {'name': 'rgb[]',           'wave': '0.3456=|9340'},
    ]
],
{},
['Font FIFO',
    ['Out',
    {'name': 'rack',            'wave': '01........0.'},
    ],
    ['In',
    {'name': 'dout[]',          'wave': '3.4567=|34x.'},
    ]
],
{'': '',                        'node': '..B........D'},

]}
```
