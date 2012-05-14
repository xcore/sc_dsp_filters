// Copyright (c) 2012, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "asrc.h"
#include "coeffs.h"


int asrcCoeffs[(ASRC_ORDER * ASRC_UPSAMPLING)/2 + 1] = {

#if ((ASRC_ORDER == 8) && (ASRC_UPSAMPLING == 125))

    0,
    -2689,
    -5390,
    -8102,
    -10825,
    -13560,
    -16306,
    -19064,
    -21834,
    -24616,
    -27411,
    -30218,
    -33037,
    -35868,
    -38712,
    -41568,
    -44437,
    -47317,
    -50209,
    -53113,
    -56028,
    -58955,
    -61892,
    -64839,
    -67796,
    -70762,
    -73736,
    -76718,
    -79707,
    -82702,
    -85703,
    -88707,
    -91715,
    -94724,
    -97735,
    -100744,
    -103752,
    -106755,
    -109754,
    -112746,
    -115729,
    -118701,
    -121661,
    -124607,
    -127536,
    -130446,
    -133335,
    -136200,
    -139039,
    -141850,
    -144629,
    -147374,
    -150082,
    -152750,
    -155375,
    -157954,
    -160484,
    -162961,
    -165382,
    -167744,
    -170043,
    -172276,
    -174438,
    -176527,
    -178538,
    -180467,
    -182311,
    -184066,
    -185728,
    -187292,
    -188755,
    -190112,
    -191359,
    -192493,
    -193508,
    -194400,
    -195166,
    -195801,
    -196301,
    -196661,
    -196877,
    -196945,
    -196861,
    -196620,
    -196218,
    -195651,
    -194914,
    -194005,
    -192918,
    -191649,
    -190196,
    -188553,
    -186717,
    -184684,
    -182451,
    -180013,
    -177369,
    -174513,
    -171444,
    -168158,
    -164651,
    -160921,
    -156966,
    -152783,
    -148369,
    -143722,
    -138839,
    -133720,
    -128362,
    -122764,
    -116924,
    -110840,
    -104513,
    -97941,
    -91124,
    -84061,
    -76752,
    -69198,
    -61398,
    -53352,
    -45063,
    -36531,
    -27756,
    -18742,
    -9489,
    0,
    9723,
    19678,
    29862,
    40271,
    50902,
    61751,
    72814,
    84088,
    95567,
    107246,
    119120,
    131185,
    143433,
    155859,
    168457,
    181220,
    194141,
    207212,
    220427,
    233777,
    247254,
    260849,
    274555,
    288361,
    302260,
    316240,
    330292,
    344407,
    358573,
    372780,
    387016,
    401272,
    415535,
    429794,
    444036,
    458249,
    472422,
    486541,
    500594,
    514567,
    528447,
    542221,
    555875,
    569395,
    582767,
    595978,
    609012,
    621856,
    634495,
    646914,
    659098,
    671032,
    682702,
    694093,
    705189,
    715975,
    726436,
    736557,
    746322,
    755717,
    764725,
    773333,
    781524,
    789284,
    796598,
    803450,
    809826,
    815711,
    821091,
    825950,
    830275,
    834052,
    837265,
    839903,
    841951,
    843395,
    844223,
    844422,
    843978,
    842881,
    841118,
    838677,
    835546,
    831716,
    827175,
    821913,
    815919,
    809186,
    801703,
    793462,
    784455,
    774674,
    764112,
    752762,
    740617,
    727673,
    713924,
    699366,
    683993,
    667804,
    650794,
    632961,
    614304,
    594822,
    574514,
    553379,
    531420,
    508637,
    485032,
    460608,
    435369,
    409318,
    382461,
    354803,
    326350,
    297110,
    267089,
    236296,
    204741,
    172433,
    139383,
    105602,
    71102,
    35897,
    0,
    -36575,
    -73813,
    -111697,
    -150212,
    -189339,
    -229061,
    -269359,
    -310212,
    -351601,
    -393505,
    -435900,
    -478766,
    -522079,
    -565813,
    -609945,
    -654450,
    -699300,
    -744469,
    -789930,
    -835654,
    -881611,
    -927774,
    -974111,
    -1020591,
    -1067183,
    -1113855,
    -1160574,
    -1207308,
    -1254021,
    -1300680,
    -1347250,
    -1393695,
    -1439979,
    -1486067,
    -1531920,
    -1577503,
    -1622776,
    -1667702,
    -1712243,
    -1756359,
    -1800011,
    -1843160,
    -1885765,
    -1927787,
    -1969185,
    -2009918,
    -2049945,
    -2089226,
    -2127719,
    -2165383,
    -2202176,
    -2238057,
    -2272984,
    -2306915,
    -2339809,
    -2371624,
    -2402318,
    -2431850,
    -2460178,
    -2487261,
    -2513057,
    -2537527,
    -2560628,
    -2582320,
    -2602563,
    -2621317,
    -2638542,
    -2654198,
    -2668248,
    -2680651,
    -2691370,
    -2700367,
    -2707605,
    -2713047,
    -2716657,
    -2718399,
    -2718238,
    -2716140,
    -2712071,
    -2705997,
    -2697888,
    -2687710,
    -2675433,
    -2661027,
    -2644462,
    -2625711,
    -2604745,
    -2581537,
    -2556063,
    -2528296,
    -2498214,
    -2465792,
    -2431010,
    -2393846,
    -2354281,
    -2312295,
    -2267871,
    -2220992,
    -2171643,
    -2119809,
    -2065478,
    -2008637,
    -1949275,
    -1887383,
    -1822954,
    -1755978,
    -1686452,
    -1614370,
    -1539728,
    -1462526,
    -1382763,
    -1300439,
    -1215556,
    -1128118,
    -1038129,
    -945596,
    -850526,
    -752928,
    -652813,
    -550191,
    -445077,
    -337484,
    -227428,
    -114927,
    0,
    117334,
    237053,
    359135,
    483555,
    610287,
    739305,
    870579,
    1004081,
    1139779,
    1277640,
    1417631,
    1559716,
    1703859,
    1850021,
    1998165,
    2148249,
    2300231,
    2454069,
    2609718,
    2767133,
    2926267,
    3087072,
    3249499,
    3413499,
    3579018,
    3746005,
    3914407,
    4084169,
    4255235,
    4427548,
    4601050,
    4775684,
    4951389,
    5128105,
    5305770,
    5484323,
    5663699,
    5843836,
    6024668,
    6206130,
    6388156,
    6570679,
    6753632,
    6936947,
    7120555,
    7304387,
    7488373,
    7672444,
    7856528,
    8040555,
    8224454,
    8408153,
    8591580,
    8774662,
    8957329,
    9139506,
    9321122,
    9502103,
    9682377,
    9861872,
    10040513,
    10218229,
    10394947,
    10570594,
    10745099,
    10918388,
    11090391,
    11261034,
    11430249,
    11597962,
    11764105,
    11928607,
    12091398,
    12252410,
    12411575,
    12568823,
    12724089,
    12877306,
    13028408,
    13177329,
    13324007,
    13468377,
    13610377,
    13749945,
    13887020,
    14021544,
    14153457,
    14282701,
    14409219,
    14532957,
    14653860,
    14771874,
    14886948,
    14999030,
    15108072,
    15214024,
    15316840,
    15416474,
    15512881,
    15606019,
    15695847,
    15782323,
    15865411,
    15945071,
    16021269,
    16093970,
    16163143,
    16228755,
    16290777,
    16349182,
    16403943,
    16455036,
    16502437,
    16546125,
    16586080,
    16622285,
    16654723,
    16683379,
    16708241,
    16729296,
    16746537,
    16759954,
    16769542,
    16775297,
    16777216,         // 1.0

#elif ((ASRC_ORDER == 8) && (ASRC_UPSAMPLING == 64))

    0,
    -5263,
    -10569,
    -15919,
    -21314,
    -26755,
    -32243,
    -37778,
    -43359,
    -48988,
    -54660,
    -60376,
    -66131,
    -71922,
    -77745,
    -83593,
    -89459,
    -95336,
    -101214,
    -107084,
    -112932,
    -118748,
    -124515,
    -130219,
    -135843,
    -141369,
    -146777,
    -152045,
    -157153,
    -162077,
    -166792,
    -171272,
    -175492,
    -179422,
    -183035,
    -186301,
    -189190,
    -191672,
    -193714,
    -195285,
    -196354,
    -196888,
    -196856,
    -196225,
    -194965,
    -193045,
    -190435,
    -187105,
    -183028,
    -178176,
    -172523,
    -166047,
    -158725,
    -150536,
    -141462,
    -131489,
    -120602,
    -108791,
    -96049,
    -82370,
    -67754,
    -52201,
    -35718,
    -18314,
    0,
    19206,
    39285,
    60212,
    81958,
    104491,
    127773,
    151763,
    176415,
    201680,
    227503,
    253825,
    280583,
    307711,
    335138,
    362787,
    390579,
    418432,
    446259,
    473969,
    501469,
    528663,
    555450,
    581728,
    607393,
    632338,
    656453,
    679629,
    701754,
    722715,
    742399,
    760692,
    777482,
    792654,
    806099,
    817703,
    827360,
    834961,
    840402,
    843581,
    844401,
    842767,
    838589,
    831781,
    822263,
    809959,
    794800,
    776724,
    755673,
    731600,
    704462,
    674225,
    640864,
    604362,
    564710,
    521908,
    475969,
    426910,
    374763,
    319567,
    261374,
    200243,
    136247,
    69468,
    0,
    -72052,
    -146575,
    -223440,
    -302511,
    -383638,
    -466664,
    -551418,
    -637719,
    -725376,
    -814190,
    -903948,
    -994430,
    -1085407,
    -1176639,
    -1267880,
    -1358874,
    -1449358,
    -1539061,
    -1627708,
    -1715013,
    -1800689,
    -1884442,
    -1965974,
    -2044982,
    -2121161,
    -2194204,
    -2263802,
    -2329644,
    -2391419,
    -2448817,
    -2501530,
    -2549251,
    -2591675,
    -2628501,
    -2659434,
    -2684183,
    -2702463,
    -2713994,
    -2718507,
    -2715739,
    -2705437,
    -2687358,
    -2661268,
    -2626947,
    -2584185,
    -2532787,
    -2472568,
    -2403362,
    -2325013,
    -2237384,
    -2140353,
    -2033814,
    -1917679,
    -1791876,
    -1656354,
    -1511078,
    -1356033,
    -1191222,
    -1016670,
    -832419,
    -638533,
    -435095,
    -222209,
    0,
    231389,
    471792,
    721025,
    978881,
    1245136,
    1519545,
    1801841,
    2091743,
    2388945,
    2693128,
    3003951,
    3321059,
    3644076,
    3972612,
    4306263,
    4644605,
    4987205,
    5333612,
    5683366,
    6035991,
    6391004,
    6747909,
    7106201,
    7465369,
    7824891,
    8184241,
    8542887,
    8900294,
    9255923,
    9609231,
    9959677,
    10306718,
    10649813,
    10988423,
    11322014,
    11650054,
    11972018,
    12287388,
    12595653,
    12896311,
    13188870,
    13472851,
    13747783,
    14013212,
    14268696,
    14513809,
    14748139,
    14971293,
    15182895,
    15382586,
    15570029,
    15744905,
    15906916,
    16055785,
    16191259,
    16313104,
    16421113,
    16515100,
    16594903,
    16660384,
    16711432,
    16747957,
    16769898,
    16777216

#elif ((ASRC_ORDER == 16) && (ASRC_UPSAMPLING == 64))

    0,
    -2626,
    -5257,
    -7890,
    -10519,
    -13139,
    -15747,
    -18337,
    -20905,
    -23445,
    -25954,
    -28425,
    -30855,
    -33238,
    -35570,
    -37845,
    -40059,
    -42208,
    -44285,
    -46286,
    -48207,
    -50042,
    -51787,
    -53436,
    -54987,
    -56432,
    -57769,
    -58992,
    -60098,
    -61081,
    -61938,
    -62665,
    -63257,
    -63712,
    -64024,
    -64191,
    -64210,
    -64077,
    -63790,
    -63346,
    -62742,
    -61977,
    -61049,
    -59956,
    -58696,
    -57270,
    -55676,
    -53915,
    -51985,
    -49889,
    -47626,
    -45198,
    -42607,
    -39855,
    -36944,
    -33878,
    -30659,
    -27292,
    -23782,
    -20132,
    -16349,
    -12437,
    -8404,
    -4256,
    0,
    4356,
    8804,
    13335,
    17941,
    22611,
    27336,
    32106,
    36909,
    41735,
    46573,
    51409,
    56232,
    61030,
    65790,
    70498,
    75141,
    79707,
    84181,
    88549,
    92797,
    96912,
    100880,
    104686,
    108317,
    111759,
    114997,
    118019,
    120811,
    123360,
    125653,
    127677,
    129421,
    130872,
    132020,
    132854,
    133363,
    133538,
    133371,
    132852,
    131975,
    130733,
    129119,
    127129,
    124759,
    122005,
    118865,
    115337,
    111422,
    107120,
    102432,
    97362,
    91914,
    86091,
    79902,
    73353,
    66452,
    59210,
    51637,
    43745,
    35547,
    27057,
    18292,
    9267,
    0,
    -9490,
    -19184,
    -29060,
    -39097,
    -49272,
    -59561,
    -69940,
    -80384,
    -90866,
    -101360,
    -111838,
    -122271,
    -132633,
    -142892,
    -153020,
    -162987,
    -172763,
    -182317,
    -191619,
    -200640,
    -209348,
    -217713,
    -225706,
    -233297,
    -240457,
    -247157,
    -253368,
    -259065,
    -264220,
    -268807,
    -272802,
    -276181,
    -278922,
    -281002,
    -282402,
    -283104,
    -283089,
    -282343,
    -280852,
    -278602,
    -275583,
    -271787,
    -267207,
    -261838,
    -255676,
    -248721,
    -240975,
    -232440,
    -223122,
    -213028,
    -202170,
    -190558,
    -178208,
    -165137,
    -151362,
    -136905,
    -121791,
    -106044,
    -89693,
    -72768,
    -55300,
    -37325,
    -18879,
    0,
    19272,
    38894,
    58822,
    79012,
    99414,
    119982,
    140664,
    161410,
    182166,
    202879,
    223494,
    243956,
    264208,
    284194,
    303857,
    323139,
    341982,
    360330,
    378124,
    395308,
    411826,
    427621,
    442639,
    456825,
    470127,
    482492,
    493871,
    504216,
    513479,
    521616,
    528584,
    534342,
    538853,
    542080,
    543992,
    544557,
    543749,
    541543,
    537919,
    532860,
    526350,
    518379,
    508940,
    498030,
    485649,
    471800,
    456493,
    439738,
    421552,
    401955,
    380971,
    358626,
    334954,
    309991,
    283775,
    256352,
    227768,
    198076,
    167330,
    135591,
    102920,
    69384,
    35053,
    0,
    -35700,
    -71966,
    -108718,
    -145869,
    -183334,
    -221022,
    -258842,
    -296699,
    -334498,
    -372142,
    -409532,
    -446570,
    -483155,
    -519185,
    -554559,
    -589176,
    -622934,
    -655733,
    -687472,
    -718052,
    -747374,
    -775342,
    -801861,
    -826839,
    -850183,
    -871807,
    -891625,
    -909555,
    -925517,
    -939437,
    -951244,
    -960869,
    -968251,
    -973330,
    -976052,
    -976371,
    -974241,
    -969625,
    -962490,
    -952811,
    -940565,
    -925740,
    -908325,
    -888320,
    -865729,
    -840562,
    -812838,
    -782581,
    -749821,
    -714598,
    -676955,
    -636944,
    -594624,
    -550059,
    -503322,
    -454491,
    -403651,
    -350894,
    -296318,
    -240026,
    -182130,
    -122744,
    -61992,
    0,
    63099,
    127167,
    192063,
    257638,
    323742,
    390220,
    456913,
    523658,
    590292,
    656645,
    722549,
    787831,
    852319,
    915838,
    978213,
    1039269,
    1098831,
    1156724,
    1212775,
    1266812,
    1318665,
    1368166,
    1415149,
    1459454,
    1500921,
    1539398,
    1574733,
    1606783,
    1635409,
    1660476,
    1681858,
    1699434,
    1713090,
    1722721,
    1728229,
    1729522,
    1726519,
    1719148,
    1707345,
    1691055,
    1670234,
    1644848,
    1614873,
    1580294,
    1541110,
    1497327,
    1448965,
    1396054,
    1338637,
    1276765,
    1210504,
    1139929,
    1065128,
    986202,
    903260,
    816425,
    725830,
    631622,
    533956,
    433000,
    328933,
    221942,
    112228,
    0,
    -114522,
    -231110,
    -349525,
    -469521,
    -590840,
    -713221,
    -836392,
    -960073,
    -1083980,
    -1207822,
    -1331301,
    -1454114,
    -1575956,
    -1696514,
    -1815474,
    -1932519,
    -2047328,
    -2159581,
    -2268955,
    -2375127,
    -2477775,
    -2576576,
    -2671210,
    -2761360,
    -2846710,
    -2926949,
    -3001771,
    -3070871,
    -3133955,
    -3190730,
    -3240915,
    -3284232,
    -3320414,
    -3349202,
    -3370347,
    -3383608,
    -3388757,
    -3385577,
    -3373862,
    -3353417,
    -3324064,
    -3285633,
    -3237972,
    -3180943,
    -3114419,
    -3038293,
    -2952470,
    -2856873,
    -2751440,
    -2636126,
    -2510903,
    -2375760,
    -2230702,
    -2075752,
    -1910953,
    -1736361,
    -1552054,
    -1358126,
    -1154688,
    -941869,
    -719818,
    -488698,
    -248692,
    0,
    257162,
    522562,
    795947,
    1077054,
    1365599,
    1661285,
    1963798,
    2272813,
    2587986,
    2908963,
    3235375,
    3566841,
    3902966,
    4243348,
    4587569,
    4935205,
    5285819,
    5638969,
    5994202,
    6351058,
    6709072,
    7067773,
    7426684,
    7785324,
    8143209,
    8499853,
    8854767,
    9207463,
    9557452,
    9904245,
    10247357,
    10586303,
    10920604,
    11249783,
    11573370,
    11890900,
    12201915,
    12505965,
    12802607,
    13091410,
    13371951,
    13643817,
    13906609,
    14159939,
    14403431,
    14636725,
    14859473,
    15071344,
    15272020,
    15461202,
    15638606,
    15803966,
    15957032,
    16097575,
    16225382,
    16340260,
    16442036,
    16530556,
    16605686,
    16667312,
    16715340,
    16749698,
    16770334,
    16777216, // 1.0

#elif ((ASRC_ORDER == 4) && (ASRC_UPSAMPLING == 125))

    0,
    -5392,
    -10839,
    -16353,
    -21946,
    -27629,
    -33417,
    -39320,
    -45351,
    -51522,
    -57846,
    -64335,
    -71001,
    -77855,
    -84910,
    -92176,
    -99666,
    -107389,
    -115356,
    -123578,
    -132065,
    -140825,
    -149868,
    -159201,
    -168834,
    -178772,
    -189023,
    -199593,
    -210487,
    -221710,
    -233266,
    -245158,
    -257388,
    -269959,
    -282870,
    -296122,
    -309714,
    -323644,
    -337909,
    -352505,
    -367428,
    -382671,
    -398229,
    -414092,
    -430253,
    -446701,
    -463425,
    -480414,
    -497652,
    -515128,
    -532823,
    -550723,
    -568810,
    -587063,
    -605463,
    -623990,
    -642619,
    -661329,
    -680093,
    -698887,
    -717682,
    -736452,
    -755166,
    -773794,
    -792305,
    -810666,
    -828844,
    -846803,
    -864509,
    -881924,
    -899010,
    -915730,
    -932043,
    -947909,
    -963287,
    -978134,
    -992408,
    -1006064,
    -1019058,
    -1031345,
    -1042879,
    -1053613,
    -1063501,
    -1072494,
    -1080545,
    -1087605,
    -1093625,
    -1098555,
    -1102346,
    -1104948,
    -1106311,
    -1106384,
    -1105118,
    -1102461,
    -1098363,
    -1092775,
    -1085644,
    -1076922,
    -1066559,
    -1054504,
    -1040709,
    -1025124,
    -1007702,
    -988394,
    -967154,
    -943933,
    -918688,
    -891371,
    -861939,
    -830347,
    -796555,
    -760519,
    -722199,
    -681557,
    -638552,
    -593149,
    -545311,
    -495004,
    -442195,
    -386852,
    -328945,
    -268445,
    -205325,
    -139559,
    -71125,
    0,
    73836,
    150402,
    229714,
    311787,
    396633,
    484262,
    574684,
    667905,
    763929,
    862759,
    964395,
    1068834,
    1176072,
    1286103,
    1398917,
    1514504,
    1632851,
    1753940,
    1877755,
    2004275,
    2133477,
    2265335,
    2399822,
    2536908,
    2676561,
    2818746,
    2963426,
    3110561,
    3260110,
    3412028,
    3566268,
    3722783,
    3881519,
    4042425,
    4205445,
    4370519,
    4537589,
    4706592,
    4877463,
    5050135,
    5224541,
    5400608,
    5578265,
    5757436,
    5938045,
    6120014,
    6303261,
    6487705,
    6673263,
    6859848,
    7047373,
    7235750,
    7424889,
    7614698,
    7805084,
    7995954,
    8187211,
    8378759,
    8570500,
    8762337,
    8954168,
    9145894,
    9337414,
    9528625,
    9719425,
    9909711,
    10099378,
    10288324,
    10476444,
    10663632,
    10849786,
    11034798,
    11218566,
    11400984,
    11581947,
    11761352,
    11939095,
    12115072,
    12289180,
    12461317,
    12631382,
    12799273,
    12964891,
    13128137,
    13288912,
    13447121,
    13602666,
    13755454,
    13905392,
    14052388,
    14196351,
    14337194,
    14474830,
    14609173,
    14740140,
    14867649,
    14991621,
    15111979,
    15228646,
    15341551,
    15450621,
    15555787,
    15656984,
    15754148,
    15847216,
    15936129,
    16020831,
    16101268,
    16177389,
    16249144,
    16316488,
    16379378,
    16437774,
    16491637,
    16540933,
    16585631,
    16625702,
    16661119,
    16691861,
    16717906,
    16739239,
    16755846,
    16767716,
    16774841,
    16777216, // 1.0

#elif ((ASRC_ORDER == 4) && (ASRC_UPSAMPLING == 250))

    0,
    -2690,
    -5392,
    -8108,
    -10839,
    -13587,
    -16353,
    -19139,
    -21946,
    -24775,
    -27629,
    -30509,
    -33417,
    -36353,
    -39320,
    -42318,
    -45351,
    -48418,
    -51522,
    -54664,
    -57846,
    -61069,
    -64335,
    -67645,
    -71001,
    -74404,
    -77855,
    -81357,
    -84910,
    -88516,
    -92176,
    -95892,
    -99666,
    -103497,
    -107389,
    -111341,
    -115356,
    -119435,
    -123578,
    -127788,
    -132065,
    -136410,
    -140825,
    -145310,
    -149868,
    -154498,
    -159201,
    -163980,
    -168834,
    -173764,
    -178772,
    -183858,
    -189023,
    -194268,
    -199593,
    -204999,
    -210487,
    -216057,
    -221710,
    -227446,
    -233266,
    -239170,
    -245158,
    -251231,
    -257388,
    -263631,
    -269959,
    -276372,
    -282870,
    -289453,
    -296122,
    -302876,
    -309714,
    -316637,
    -323644,
    -330735,
    -337909,
    -345166,
    -352505,
    -359926,
    -367428,
    -375010,
    -382671,
    -390411,
    -398229,
    -406123,
    -414092,
    -422136,
    -430253,
    -438442,
    -446701,
    -455030,
    -463425,
    -471887,
    -480414,
    -489003,
    -497652,
    -506361,
    -515128,
    -523949,
    -532823,
    -541749,
    -550723,
    -559744,
    -568810,
    -577917,
    -587063,
    -596246,
    -605463,
    -614712,
    -623990,
    -633293,
    -642619,
    -651966,
    -661329,
    -670706,
    -680093,
    -689488,
    -698887,
    -708286,
    -717682,
    -727072,
    -736452,
    -745818,
    -755166,
    -764493,
    -773794,
    -783066,
    -792305,
    -801506,
    -810666,
    -819780,
    -828844,
    -837853,
    -846803,
    -855690,
    -864509,
    -873255,
    -881924,
    -890511,
    -899010,
    -907419,
    -915730,
    -923940,
    -932043,
    -940035,
    -947909,
    -955662,
    -963287,
    -970780,
    -978134,
    -985345,
    -992408,
    -999316,
    -1006064,
    -1012646,
    -1019058,
    -1025293,
    -1031345,
    -1037209,
    -1042879,
    -1048349,
    -1053613,
    -1058666,
    -1063501,
    -1068112,
    -1072494,
    -1076641,
    -1080545,
    -1084202,
    -1087605,
    -1090748,
    -1093625,
    -1096229,
    -1098555,
    -1100596,
    -1102346,
    -1103799,
    -1104948,
    -1105788,
    -1106311,
    -1106512,
    -1106384,
    -1105922,
    -1105118,
    -1103966,
    -1102461,
    -1100596,
    -1098363,
    -1095759,
    -1092775,
    -1089405,
    -1085644,
    -1081485,
    -1076922,
    -1071949,
    -1066559,
    -1060746,
    -1054504,
    -1047827,
    -1040709,
    -1033143,
    -1025124,
    -1016646,
    -1007702,
    -998287,
    -988394,
    -978019,
    -967154,
    -955794,
    -943933,
    -931567,
    -918688,
    -905291,
    -891371,
    -876922,
    -861939,
    -846416,
    -830347,
    -813729,
    -796555,
    -778820,
    -760519,
    -741647,
    -722199,
    -702171,
    -681557,
    -660352,
    -638552,
    -616153,
    -593149,
    -569536,
    -545311,
    -520468,
    -495004,
    -468914,
    -442195,
    -414842,
    -386852,
    -358221,
    -328945,
    -299020,
    -268445,
    -237214,
    -205325,
    -172774,
    -139559,
    -105677,
    -71125,
    -35900,
    0,
    36578,
    73836,
    111777,
    150402,
    189714,
    229714,
    270405,
    311787,
    353862,
    396633,
    440099,
    484262,
    529124,
    574684,
    620945,
    667905,
    715567,
    763929,
    812994,
    862759,
    913226,
    964395,
    1016264,
    1068834,
    1122103,
    1176072,
    1230739,
    1286103,
    1342163,
    1398917,
    1456365,
    1514504,
    1573334,
    1632851,
    1693054,
    1753940,
    1815508,
    1877755,
    1940678,
    2004275,
    2068542,
    2133477,
    2199075,
    2265335,
    2332252,
    2399822,
    2468042,
    2536908,
    2606416,
    2676561,
    2747340,
    2818746,
    2890777,
    2963426,
    3036689,
    3110561,
    3185037,
    3260110,
    3335776,
    3412028,
    3488861,
    3566268,
    3644244,
    3722783,
    3801876,
    3881519,
    3961705,
    4042425,
    4123674,
    4205445,
    4287729,
    4370519,
    4453809,
    4537589,
    4621853,
    4706592,
    4791798,
    4877463,
    4963578,
    5050135,
    5137126,
    5224541,
    5312371,
    5400608,
    5489242,
    5578265,
    5667666,
    5757436,
    5847566,
    5938045,
    6028864,
    6120014,
    6211482,
    6303261,
    6395339,
    6487705,
    6580350,
    6673263,
    6766432,
    6859848,
    6953498,
    7047373,
    7141461,
    7235750,
    7330230,
    7424889,
    7519716,
    7614698,
    7709825,
    7805084,
    7900465,
    7995954,
    8091540,
    8187211,
    8282954,
    8378759,
    8474612,
    8570500,
    8666413,
    8762337,
    8858259,
    8954168,
    9050051,
    9145894,
    9241686,
    9337414,
    9433064,
    9528625,
    9624083,
    9719425,
    9814639,
    9909711,
    10004628,
    10099378,
    10193948,
    10288324,
    10382494,
    10476444,
    10570161,
    10663632,
    10756845,
    10849786,
    10942441,
    11034798,
    11126844,
    11218566,
    11309950,
    11400984,
    11491654,
    11581947,
    11671851,
    11761352,
    11850438,
    11939095,
    12027310,
    12115072,
    12202366,
    12289180,
    12375501,
    12461317,
    12546615,
    12631382,
    12715605,
    12799273,
    12882373,
    12964891,
    13046817,
    13128137,
    13208840,
    13288912,
    13368343,
    13447121,
    13525232,
    13602666,
    13679411,
    13755454,
    13830785,
    13905392,
    13979263,
    14052388,
    14124754,
    14196351,
    14267169,
    14337194,
    14406419,
    14474830,
    14542418,
    14609173,
    14675083,
    14740140,
    14804331,
    14867649,
    14930082,
    14991621,
    15052256,
    15111979,
    15170778,
    15228646,
    15285573,
    15341551,
    15396569,
    15450621,
    15503696,
    15555787,
    15606886,
    15656984,
    15706074,
    15754148,
    15801197,
    15847216,
    15892195,
    15936129,
    15979010,
    16020831,
    16061586,
    16101268,
    16139871,
    16177389,
    16213815,
    16249144,
    16283371,
    16316488,
    16348493,
    16379378,
    16409140,
    16437774,
    16465274,
    16491637,
    16516858,
    16540933,
    16563859,
    16585631,
    16606246,
    16625702,
    16643993,
    16661119,
    16677076,
    16691861,
    16705472,
    16717906,
    16729163,
    16739239,
    16748134,
    16755846,
    16762374,
    16767716,
    16771872,
    16774841,
    16776622,
    16777216, // 1.0

#else

#error "Unsupported combination of ASRC_ORDER and ASRC_UPSAMPLING. See coeffs.xc for supported combination(s)"

#endif

};