import 'package:flutter/material.dart';

/// 행정동 데이터를 표현하는 클래스
class Dong {
  final String name;
  final Color color;
  final List<Merchant> merchantList;
  final Rect area;
  final String areaAsset;
  final Rect dongTagArea;

  bool isShow = false;

  Dong({required this.name, required this.color, required this.merchantList, required this.area, required this.areaAsset, required this.dongTagArea});
}

class Merchant {
  final int id;
  final String name;
  final double x;
  final double y;
  bool isShow = false;

  Merchant({required this.id, required this.name, required this.x, required this.y});
}

class DongList {
  static final List<Dong> all = [
    // 1-5
    Dong(name: '동천동', color: const Color(0xFFd15382),
        area: Rect.fromLTWH(178, 84, 944, 298),
        dongTagArea: Rect.fromLTWH(536, 286, 132, 52),
        areaAsset: 'assets/map/dong_동천.webp',
        merchantList : [
          Merchant(id: 1, name: "하남대로가구의거리상인회", x: 360, y: 257),
          Merchant(id: 2, name: "동천동먹자골목1번가상인회", x: 764, y: 201),
          Merchant(id: 3, name: "동천동상인회", x: 761, y: 257),
          Merchant(id: 4, name: "동천동먹자골목2번가상인회", x: 1018, y: 139),
          Merchant(id: 5, name: "동천동벚꽃길상인회", x: 1061, y: 91),
        ]
    ),
    // 6-8
    Dong(name: '유덕동', color: Color(0xFFc38753),
        area: Rect.fromLTWH(630, 314, 454, 276),
        dongTagArea: Rect.fromLTWH(973, 345, 133, 52),
        areaAsset: 'assets/map/dong_유촌.webp',
        merchantList : [
          Merchant(id: 6, name: "유촌마을상인회", x: 888, y: 349),
          Merchant(id: 7, name: "버들마을상인회", x: 794, y: 459),
          Merchant(id: 8, name: "유촌동상인회", x: 861, y: 432),
        ]
    ),
    // 9
    Dong(name: '광천동', color: Color(0xFFabcd6e),
        area: Rect.fromLTWH(1232, 115, 342, 274),
        dongTagArea: Rect.fromLTWH(1228, 101, 133, 52),
        areaAsset: 'assets/map/dong_광천.webp',
        merchantList : [
          Merchant(id: 9, name: "광천동상인회", x: 1389, y: 234),
        ]
    ),
    // 10-27
    Dong(name: '치평동', color: Color(0xFF6e73b5),
        area: Rect.fromLTWH(420, 735, 501, 606),
        dongTagArea: Rect.fromLTWH(659, 749, 133, 52),
        areaAsset: 'assets/map/dong_치평.webp',
        merchantList : [
          Merchant(id: 10, name: "치평동1002상인회", x: 452, y: 780),
          Merchant(id: 11, name: "시청음식문화거리번영회", x: 520, y: 741),
          Merchant(id: 12, name: "시청역상가상인회", x: 561, y: 785),
          Merchant(id: 13, name: "상무시청상인회", x: 584, y: 843),
          Merchant(id: 14, name: "우체국보험광주회관주변상인회", x: 626, y: 826),
          Merchant(id: 15, name: "해광한신상가번영회", x: 495, y: 947),
          Merchant(id: 16, name: "치평동중흥상가상인회", x: 569, y: 900),
          Merchant(id: 17, name: "치평동아파트연합상인회", x: 590, y: 1075),
          Merchant(id: 18, name: "김대중컨벤션상인회", x: 589, y: 1273),
          Merchant(id: 19, name: "상무화원상인회", x: 645, y: 1211),
          Merchant(id: 20, name: "상무중앙상인회", x: 622, y: 935),
          Merchant(id: 21, name: "상무연하상인회", x: 679, y: 912),
          Merchant(id: 22, name: "상무지구청년상인회", x: 786, y: 859),
          Merchant(id: 23, name: "상무중앙로46구역상인회", x: 663, y: 1028),
          Merchant(id: 24, name: "상무역4번출구상인회", x: 692, y: 1095),
          Merchant(id: 25, name: "치평상무역상인회", x: 738, y: 1053),
          Merchant(id: 26, name: "치평광명상가상인회", x: 738, y: 980),
          Merchant(id: 27, name: "상무평화상인회", x: 799, y: 940),
        ]
    ),
    // 28-39
    Dong(name: '상무1동', color: Color(0xFF35a280),
        area: Rect.fromLTWH(773, 525, 437, 429),
        dongTagArea: Rect.fromLTWH(913, 763, 155, 52),
        areaAsset: 'assets/map/dong_상무1.webp',
        merchantList : [
          Merchant(id: 28, name: "계수마을상인회", x: 786, y: 582),
          Merchant(id: 29, name: "상무1동아파트상인회1", x: 884, y: 573),
          Merchant(id: 119, name: "상무1동아파트상인회2", x: 1024, y: 533),
          Merchant(id: 120, name: "상무1동아파트상인회3", x: 1086, y: 690),
          Merchant(id: 30, name: "상암마을상인회", x: 974, y: 577),
          Merchant(id: 31, name: "상무오월로상인회", x: 908, y: 645),
          Merchant(id: 32, name: "518먹자골목상인회", x: 932, y: 693),
          Merchant(id: 33, name: "파랑새원룸상인회", x: 994, y: 659),
          Merchant(id: 34, name: "참샘상인회", x: 1099, y: 590),
          Merchant(id: 35, name: "운천역상인회", x: 910, y: 900),
          Merchant(id: 36, name: "상무민주로상인회", x: 950, y: 878),
          Merchant(id: 37, name: "서광주세무서앞상인회", x: 1022, y: 845),
          Merchant(id: 38, name: "쌍촌골상인회", x: 1089, y: 758),
          Merchant(id: 39, name: "쌍촌역상인회", x: 1143, y: 767),
        ]
    ),
    // 40-45
    Dong(name: '화정1동', color: Color(0xFFc5acd0),
        area: Rect.fromLTWH(1135, 428, 448, 343),
        dongTagArea: Rect.fromLTWH(1293, 557, 155, 52),
        areaAsset: 'assets/map/dong_화정1.webp',
        merchantList : [
          Merchant(id: 40, name: "늘해랑상인회", x: 1187, y: 570),
          Merchant(id: 41, name: "맛조이상인회", x: 1317, y: 509),
          Merchant(id: 42, name: "늘솔길상인회", x: 1369, y: 439),
          Merchant(id: 43, name: "온새미로상인회", x: 1478, y: 470),
          Merchant(id: 44, name: "한울상인회", x: 1334, y: 647),
          Merchant(id: 45, name: "온누리상인회", x: 1472, y: 532),
        ]
    ),
    // 46-50
    Dong(name: '농성1동', color: Color(0xFF626db2),
        area: Rect.fromLTWH(1516, 284, 399, 271),
        dongTagArea: Rect.fromLTWH(1542, 370, 155, 52),
        areaAsset: 'assets/map/dong_농성1.webp',
        merchantList : [
          Merchant(id: 46, name: "신세계앞상인회", x: 1523, y: 328),
          Merchant(id: 47, name: "광주캠코앞상인회", x: 1609, y: 502),
          Merchant(id: 48, name: "상록벚꽃상인회1", x: 1630, y: 443),
          Merchant(id: 48, name: "상록벚꽃상인회2", x: 1803, y: 390),
          Merchant(id: 49, name: "농성동벚꽃상인회", x: 1712, y: 389),
          Merchant(id: 50, name: "월산로상인회", x: 1791, y: 474),
        ]
    ),
    // 51
    Dong(name: '양3동', color: Color(0xFFf5aa4e),
        area: Rect.fromLTWH(1685, 244, 260, 136),
        dongTagArea: Rect.fromLTWH(1962, 320, 132, 52),
        areaAsset: 'assets/map/dong_양동.webp',
        merchantList : [
          Merchant(id: 51, name: "발산마을상인회", x: 1794, y: 267),
        ]
    ),
    // 52-53
    Dong(name: '서창(마륵)동', color: Color(0xFFe6bb39),
        area: Rect.fromLTWH(393, 1187, 586, 345),
        dongTagArea: Rect.fromLTWH(724, 1325, 152, 52),
        areaAsset: 'assets/map/dong_마륵.webp',
        merchantList : [
          Merchant(id: 52, name: "상무원마륵상인회", x: 475, y: 1421),
          Merchant(id: 53, name: "마륵동상인회", x: 873, y: 1286),
        ]
    ),
    // 54-64
    Dong(name: '상무2동', color: Color(0xFF429bd5),
        area: Rect.fromLTWH(843, 774, 511, 496),
        dongTagArea: Rect.fromLTWH(1123, 861, 155, 52),
        areaAsset: 'assets/map/dong_상무2.webp',
        merchantList : [
          Merchant(id: 54, name: "운천호수공원상인회", x: 854, y: 1092),
          Merchant(id: 55, name: "운천테라스길상인회", x: 938, y: 1004),
          Merchant(id: 56, name: "쌍촌명지상인회", x: 992, y: 1051),
          Merchant(id: 57, name: "상무운천역상인회", x: 1062, y: 1017),
          Merchant(id: 58, name: "운천상무시장상인회", x: 1062, y: 912),
          Merchant(id: 59, name: "쌍촌로상인회", x: 1228, y: 923),
          Merchant(id: 60, name: "상무쌍촌역상인회", x: 1264, y: 783),
          Merchant(id: 61, name: "상무백운상인회", x: 983, y: 1180),
          Merchant(id: 62, name: "상무중앙공원상인회1", x: 1049, y: 1151),
          Merchant(id: 62, name: "상무중앙공원상인회2", x: 1090, y: 1066),
          Merchant(id: 63, name: "상무운천로상인회", x: 1088, y: 1186),
          Merchant(id: 64, name: "쌍학로상인회", x: 1188, y: 1015),
        ]
    ),
    // 65-68
    Dong(name: '금호1동', color: Color(0xFFe27c7a),
        area: Rect.fromLTWH(993, 1213, 332, 328),
        dongTagArea: Rect.fromLTWH(899, 1404, 155, 52),
        areaAsset: 'assets/map/dong_금호1.webp',
        merchantList : [
          Merchant(id: 65, name: "금호운천로상인회", x: 1075, y: 1327),
          Merchant(id: 66, name: "금호1동상가번영회", x: 1127, y: 1396),
          Merchant(id: 67, name: "금부로상인회", x: 1160, y: 1288),
          Merchant(id: 68, name: "금화로상인회", x: 1202, y: 1363),
        ]
    ),
    // 69-74
    Dong(name: '화정4동', color: Color(0xFFb960a2),
        area: Rect.fromLTWH(1321, 975, 264, 273),
        dongTagArea: Rect.fromLTWH(1275, 1133, 155, 52),
        areaAsset: 'assets/map/dong_화정4.webp',
        merchantList : [
          Merchant(id: 69, name: "화정로상가상인회", x: 1377, y: 972),
          Merchant(id: 70, name: "염주먹자골목B구역상인회", x: 1419, y: 998),
          Merchant(id: 71, name: "염주먹자골목A구역상인회", x: 1451, y: 1053),
          Merchant(id: 72, name: "염주포스코상인회", x: 1494, y: 1074),
          Merchant(id: 73, name: "염주B상인회", x: 1445, y: 1114),
          Merchant(id: 74, name: "염주상인회", x: 1461, y: 1178),
        ]
    ),
    // 75-78
    Dong(name: '화정3동', color: Color(0xFFe77117),
        area: Rect.fromLTWH(1354, 748, 324, 371),
        dongTagArea: Rect.fromLTWH(1362, 833, 155, 52),
        areaAsset: 'assets/map/dong_화정3.webp',
        merchantList : [
          Merchant(id: 75, name: "화정소담상인회", x: 1382, y: 774),
          Merchant(id: 76, name: "화정꽃마을상인회", x: 1455, y: 907),
          Merchant(id: 77, name: "화삼골상인회", x: 1512, y: 957),
          Merchant(id: 78, name: "화정한울타리상인회", x: 1592, y: 1022),
        ]
    ),
    // 79-86
    Dong(name: '화정2동', color: Color(0xFFedb2a0),
        area: Rect.fromLTWH(1457, 629, 403, 415),
        dongTagArea: Rect.fromLTWH(1553, 784, 155, 52),
        areaAsset: 'assets/map/dong_화정2.webp',
        merchantList : [
          Merchant(id: 79, name: "고은상인회", x: 1502, y: 742),
          Merchant(id: 80, name: "화운로상인회", x: 1495, y: 692),
          Merchant(id: 81, name: "화정역상인회", x: 1503, y: 643),
          Merchant(id: 82, name: "짚봉산상인회", x: 1711, y: 973),
          Merchant(id: 83, name: "염주골상인회", x: 1740, y: 914),
          Merchant(id: 84, name: "힐스상인회", x: 1727, y: 831),
          Merchant(id: 85, name: "화정금화로상인회", x: 1799, y: 826),
          Merchant(id: 86, name: "화정로상인회", x: 1696, y: 741),
        ]
    ),
    // 87-91
    Dong(name: '농성2동', color: Color(0xFFbfa37c),
        area: Rect.fromLTWH(1591, 551, 311, 185),
        dongTagArea: Rect.fromLTWH(1656, 611, 155, 52),
        areaAsset: 'assets/map/dong_농성2.webp',
        merchantList : [
          Merchant(id: 87, name: "군분로꽁양상인회", x: 1626, y: 676),
          Merchant(id: 88, name: "상공회의소누리상인회", x: 1605, y: 606),
          Merchant(id: 89, name: "농성누리상인회", x: 1743, y: 669),
          Merchant(id: 90, name: "서구청먹자골목상인회", x: 1690, y: 563),
          Merchant(id: 91, name: "농성세대공감상인회", x: 1818, y: 586),
        ]
    ),
    // 92-100
    Dong(name: '금호2동', color: Color(0xFF8c5425),
        area: Rect.fromLTWH(852, 1425, 517, 409),
        dongTagArea: Rect.fromLTWH(1211, 1591, 155, 52),
        areaAsset: 'assets/map/dong_금호2.webp',
        merchantList : [
          Merchant(id: 92, name: "금호푸른상인회", x: 964, y: 1668),
          Merchant(id: 93, name: "금호아파트상인회", x: 1041, y: 1617),
          Merchant(id: 93, name: "금호아파트상인회1", x: 1045, y: 1735),
          Merchant(id: 93, name: "금호아파트상인회2", x: 1264, y: 1461),
          Merchant(id: 94, name: "금호상인회", x: 1079, y: 1578),
          Merchant(id: 95, name: "화개1로78번길상인회", x: 1130, y: 1543),
          Merchant(id: 96, name: "금화상인회", x: 1180, y: 1492),
          Merchant(id: 97, name: "화개상인회", x: 1078, y: 1693),
          Merchant(id: 98, name: "중앙상인회", x: 1183, y: 1688),
          Merchant(id: 99, name: "중앙공원상인회", x: 1290, y: 1729),
          Merchant(id: 100, name: "마재상인회", x: 1319, y: 1769),
        ]
    ),
    // 101-117
    Dong(name: '풍암동', color: Color(0xFF50bdb8),
        area: Rect.fromLTWH(1393, 1265, 648, 638),
        dongTagArea: Rect.fromLTWH(1623, 1388, 133, 52),
        areaAsset: 'assets/map/dong_풍암.webp',
        merchantList : [
          Merchant(id: 101, name: "풍암운리중상인회", x: 1422, y: 1765),
          Merchant(id: 102, name: "풍암새누리상인회", x: 1497, y: 1795),
          Merchant(id: 103, name: "풍암SK·광명상가상인회", x: 1595, y: 1831),
          Merchant(id: 104, name: "운리공원상인회", x: 1504, y: 1667),
          Merchant(id: 105, name: "풍암고앞상인회", x: 1549, y: 1702),
          Merchant(id: 106, name: "풍암동부상인회", x: 1608, y: 1721),
          Merchant(id: 107, name: "풍암호수앞상인회", x: 1605, y: 1615),
          Merchant(id: 108, name: "풍암초앞상인회1", x: 1680, y: 1539),
          Merchant(id: 108, name: "풍암초앞상인회2", x: 1763, y: 1615),
          Merchant(id: 109, name: "풍암순환로상인회", x: 1923, y: 1617),
          Merchant(id: 110, name: "풍암1로상인회", x: 1777, y: 1546),
          Merchant(id: 111, name: "풍암벚꽃길상인회", x: 1774, y: 1467),
          Merchant(id: 112, name: "풍암중앙상인회", x: 1780, y: 1421),
          Merchant(id: 113, name: "풍암우미상인회", x: 1833, y: 1404),
          Merchant(id: 114, name: "풍암금당상인회", x: 1889, y: 1361),
          Merchant(id: 115, name: "풍암당산상인회", x: 1859, y: 1483),
          Merchant(id: 116, name: "금당산길상인회", x: 1948, y: 1450),
          Merchant(id: 117, name: "풍암신암상인회", x: 1951, y: 1533),
        ]
    ),
    // 118-119
    Dong(name: '서창(매월)동', color: Color(0xFFe7bc3a),
        area: Rect.fromLTWH(1009, 1880, 458, 433),
        dongTagArea: Rect.fromLTWH(1167, 2062, 152, 52),
        areaAsset: 'assets/map/dong_매월.webp',
        merchantList : [
          Merchant(id: 118, name: "전평제상인회", x: 1119, y: 2160),
          Merchant(id: 119, name: "매월동상인회", x: 1273, y: 2157),
        ]
    ),
  ];
}