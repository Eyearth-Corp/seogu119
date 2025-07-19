import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/dashboard_data.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> 
    with TickerProviderStateMixin {
  String _selectedDate = 'all';
  DashboardData? _currentData;
  bool _isLoading = true;
  String? _error;
  int _touchedBarIndex = -1;
  int _touchedPieIndex = -1;
  bool _showAvgLine = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Modern color palette inspired by fl_chart samples
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF06B6D4);
  
  static const List<Color> chartColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple  
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFFEF4444), // Red
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF84CC16), // Lime
    Color(0xFFF97316), // Orange
    Color(0xFF6B7280), // Gray
    Color(0xFF14B8A6), // Teal
    Color(0xFF3B82F6), // Blue
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await DashboardDataManager.loadDataForDate(_selectedDate);
      if (data != null) {
        setState(() {
          _currentData = data;
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _error = '데이터를 불러올 수 없습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '데이터 로드 중 오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }

  void _onDateChanged(String? newDate) {
    if (newDate != null && newDate != _selectedDate) {
      setState(() {
        _selectedDate = newDate;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: primaryColor.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            children: [
              _buildModernHeader(),
              Expanded(
                child: _isLoading 
                    ? _buildLoadingState()
                    : _error != null
                        ? _buildErrorState()
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildContent(),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            secondaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          '대한민국 골목경제 1번지',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '서구 골목형상점가 지정 현황',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildModernDateSelector(),
              ],
            ),
            const SizedBox(height: 24),
            if (_currentData != null) _buildModernSummaryCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '데이터를 불러오는 중...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: warningColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: warningColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: warningColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: warningColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: warningColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDate,
          onChanged: _onDateChanged,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 20,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: primaryColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          items: DashboardDataManager.getAvailableDates()
              .map((date) => DropdownMenuItem<String>(
                    value: date.date,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        date.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildModernSummaryCards() {
    if (_currentData == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildModernSummaryCard(
            '총 구역수',
            '${_currentData!.summary.areas}',
            '개',
            Icons.location_on_rounded,
            accentColor,
            0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildModernSummaryCard(
            '총 점포수',
            _currentData!.summary.stores.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
              (Match m) => '${m[1]},'
            ),
            '개',
            Icons.store_rounded,
            infoColor,
            1,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildModernSummaryCard(
            '완료율',
            _currentData!.summary.completionRate.toStringAsFixed(1),
            '%',
            Icons.check_circle_rounded,
            successColor,
            2,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildModernSummaryCard(
            '온누리가맹점',
            _currentData!.onNuriCardRate.toStringAsFixed(1),
            '%',
            Icons.credit_card_rounded,
            secondaryColor,
            3,
          ),
        ),
      ],
    );
  }

  Widget _buildModernSummaryCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 200)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        unit,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_currentData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedDate == 'all') ...[
            _buildModernPhaseChart(),
            const SizedBox(height: 32),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildModernCategoryChart(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildCategoryPieChart(),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (_currentData!.onNuriTrendData != null) 
            _buildModernTrendChart(),
        ],
      ),
    );
  }

  Widget _buildModernPhaseChart() {
    if (_currentData?.phaseData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '차수별 지정 현황',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      '단계별 상점가 지정 진행 상황',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _currentData!.phaseData!
                    .map((e) => e.stores.toDouble())
                    .reduce((a, b) => a > b ? a : b) * 1.2,
                barTouchData: BarTouchData(
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        _touchedBarIndex = -1;
                        return;
                      }
                      _touchedBarIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => primaryColor.withOpacity(0.9),
                    tooltipBorder: BorderSide(color: Colors.transparent),
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final phase = _currentData!.phaseData![group.x.toInt()];
                      return BarTooltipItem(
                        '${phase.phase}\n${phase.stores}개 점포\n${phase.date}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _currentData!.phaseData!.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _currentData!.phaseData![index].phase,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                  drawVerticalLine: false,
                ),
                barGroups: _currentData!.phaseData!
                    .asMap()
                    .entries
                    .map((entry) {
                      final isTouched = entry.key == _touchedBarIndex;
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.stores.toDouble(),
                            color: isTouched 
                                ? chartColors[entry.key % chartColors.length]
                                : chartColors[entry.key % chartColors.length].withOpacity(0.7),
                            width: isTouched ? 28 : 24,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                chartColors[entry.key % chartColors.length].withOpacity(0.8),
                                chartColors[entry.key % chartColors.length],
                              ],
                            ),
                          ),
                        ],
                      );
                    })
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '골목형 상점가 업종별 현황',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _currentData!.storesByCategory.values
                      .reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.blue.withOpacity(0.8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final category = _currentData!.storesByCategory.keys.elementAt(group.x.toInt());
                        final count = _currentData!.storesByCategory[category]!;
                        return BarTooltipItem(
                          '$category\n$count개',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 60),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 80,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          final categories = _currentData!.storesByCategory.keys.toList();
                          if (index >= 0 && index < categories.length) {
                            return RotatedBox(
                              quarterTurns: 1,
                              child: Text(
                                categories[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _currentData!.storesByCategory.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) => BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.value.toDouble(),
                                color: Colors.blue.shade600,
                                width: 16,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnNuriTrendChart() {
    final trendData = _currentData!.onNuriTrendData!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '온누리상품권 가맹점 현황',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < trendData.length) {
                            return Text(
                              trendData[index].date,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  minX: 0,
                  maxX: (trendData.length - 1).toDouble(),
                  minY: 0,
                  maxY: 50,
                  lineBarsData: [
                    LineChartBarData(
                      spots: trendData
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value.rate,
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: Colors.green,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.2),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => Colors.green.withOpacity(0.8),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          final point = trendData[index];
                          return LineTooltipItem(
                            '${point.date}\n${point.rate}%',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCategoryChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: infoColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '골목형 상점가 업종별 현황',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      '업종별 점포 수 분포',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _currentData!.storesByCategory.values
                    .reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => infoColor.withOpacity(0.9),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final category = _currentData!.storesByCategory.keys.elementAt(group.x.toInt());
                      final count = _currentData!.storesByCategory[category]!;
                      return BarTooltipItem(
                        '$category\n$count개',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 60),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 80,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        final categories = _currentData!.storesByCategory.keys.toList();
                        if (index >= 0 && index < categories.length) {
                          return RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                              categories[index],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _currentData!.storesByCategory.entries
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) => BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.value.toDouble(),
                              color: chartColors[entry.key % chartColors.length],
                              width: 16,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    final topCategories = _currentData!.storesByCategory.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = topCategories.take(5).toList();
    final others = topCategories.skip(5).fold<int>(0, (sum, entry) => sum + entry.value);
    
    final pieData = [
      ...top5.map((entry) => entry),
      if (others > 0) MapEntry('기타', others),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '업종 분포',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.0,
            child: PieChart(
              PieChartData(
                sections: pieData.asMap().entries.map((entry) {
                  final isTouched = entry.key == _touchedPieIndex;
                  final value = entry.value.value.toDouble();
                  final total = _currentData!.storesByCategory.values.fold<int>(0, (sum, v) => sum + v);
                  final percentage = (value / total * 100);
                  
                  return PieChartSectionData(
                    color: chartColors[entry.key % chartColors.length],
                    value: value,
                    title: '${percentage.toStringAsFixed(1)}%',
                    radius: isTouched ? 80 : 70,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 60,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...pieData.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: chartColors[entry.key % chartColors.length],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value.key,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Text(
                  '${entry.value.value}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildModernTrendChart() {
    final trendData = _currentData!.onNuriTrendData!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: successColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '온누리상품권 가맹점 현황',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      '시간별 가맹점 비율 증가 추이',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < trendData.length) {
                          return Text(
                            trendData[index].date,
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (trendData.length - 1).toDouble(),
                minY: 0,
                maxY: 50,
                lineBarsData: [
                  LineChartBarData(
                    spots: trendData
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(
                              entry.key.toDouble(),
                              entry.value.rate,
                            ))
                        .toList(),
                    isCurved: true,
                    color: successColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 6,
                        color: successColor,
                        strokeWidth: 3,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          successColor.withOpacity(0.3),
                          successColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}