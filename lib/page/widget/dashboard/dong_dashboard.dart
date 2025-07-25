import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/dong_list.dart';
import '../../../core/colors.dart';

class DongDashboard extends StatefulWidget {
  final Dong dong;
  final VoidCallback onBackPressed;
  final Function(Merchant) onMerchantSelected;

  const DongDashboard({
    super.key,
    required this.dong,
    required this.onBackPressed,
    required this.onMerchantSelected,
  });

  @override
  State<DongDashboard> createState() => _DongDashboardState();
}

class _DongDashboardState extends State<DongDashboard> {
  Map<String, dynamic>? dongData;

  @override
  void initState() {
    super.initState();
    _loadDongData();
  }

  Future<void> _loadDongData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/dong_data.json');
      final Map<String, dynamic> data = json.decode(response);
      setState(() {
        dongData = data[widget.dong.name];
      });
    } catch (e) {
      print('동별 대시보드 데이터 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dongData == null) {
      return Container(
        margin: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.indigo.shade100,
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.indigo.shade100,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // 뒤로가기 헤더
            Container(
              padding: const EdgeInsets.all(16),
              child: _buildDongHeader(),
            ),
            // 동별 대시보드 (스크롤 가능)
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // 동별 메트릭 카드들
                    _buildDongMetrics(),
                    const SizedBox(height: 20),
                    // 동별 주요 성과
                    _buildDongWeeklyAchievements(),
                    const SizedBox(height: 20),
                    // 동별 민원 현황
                    _buildDongComplaints(),
                    const SizedBox(height: 20),
                    // 업종별 가맹점 현황
                    _buildBusinessTypeStatus(),
                    const SizedBox(height: 20),
                    // 상인회 목록
                    _buildMerchantGridView()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDongHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: widget.onBackPressed,
          icon: const Icon(Icons.arrow_back, size: 24),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: widget.dong.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${widget.dong.name} 대시보드',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: SeoguColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDongMetrics() {
    final metrics = dongData?['dongMetrics'] as List<dynamic>? ?? [];

    
    if (metrics.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: SeoguColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '데이터가 없습니다.',
            style: TextStyle(
              fontSize: 19,
              color: SeoguColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    
    return Row(
      children: [
        for (int i = 0; i < metrics.length && i < 3; i++) ...[
          Expanded(
            child: _buildMetricCard(
              metrics[i]['title'] ?? '',
              metrics[i]['value'] ?? '',
              metrics[i]['unit'] ?? '',
              i == 0 ? widget.dong.color : (i == 1 ? SeoguColors.success : SeoguColors.warning),
            ),
          ),
          if (i < metrics.length - 1 && i < 2) const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SeoguColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              color: SeoguColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 16,
                    color: SeoguColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDongWeeklyAchievements() {
    final achievements = dongData?['weeklyAchievements'] as List<dynamic>? ?? [];
    
    // 기본값 설정 (데이터가 없을 경우)
    if (achievements.isEmpty) {
      final newMerchants = (widget.dong.merchantList.length * 0.1).toInt().clamp(1, 10);
      final complaints = (widget.dong.merchantList.length * 0.05).toInt().clamp(0, 5);
      final budget = ((widget.dong.merchantList.length * 0.2) + 10).toInt();
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SeoguColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 ${widget.dong.name} 금주 성과',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: SeoguColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAchievementCard('신규 가맹', '${newMerchants}개', widget.dong.color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAchievementCard('민원 해결', '${complaints}건', SeoguColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAchievementCard('지원 예산', '${budget}만원', SeoguColors.accent),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SeoguColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 ${widget.dong.name} 금주 성과',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (int i = 0; i < achievements.length && i < 3; i++) ...[
                Expanded(
                  child: _buildAchievementCard(
                    achievements[i]['title'] ?? '',
                    achievements[i]['value'] ?? '',
                    i == 0 ? widget.dong.color : (i == 1 ? SeoguColors.primary : SeoguColors.accent),
                  ),
                ),
                if (i < achievements.length - 1 && i < 2) const SizedBox(width: 16),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              color: SeoguColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDongComplaints() {
    final complaints = dongData?['complaints'] as List<dynamic>? ?? [];
    
    // 기본값 설정 (데이터가 없을 경우)
    if (complaints.isEmpty) {
      final defaultComplaints = ['주차 문제', '소음 방해', '청소 문제'];
      final counts = [(widget.dong.merchantList.length * 0.3).toInt(), (widget.dong.merchantList.length * 0.2).toInt(), (widget.dong.merchantList.length * 0.1).toInt()];
      
      return Container(
        height: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SeoguColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔥 ${widget.dong.name} 민원 현황',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: SeoguColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  for (int i = 0; i < defaultComplaints.length; i++)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: i == 0 ? SeoguColors.highlight :
                                  i == 1 ? SeoguColors.warning :
                                  SeoguColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: SeoguColors.surface,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                defaultComplaints[i],
                                style: const TextStyle(
                                  fontSize: 19,
                                  color: SeoguColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${counts[i]}건',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: SeoguColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SeoguColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔥 ${widget.dong.name} 민원 현황',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < complaints.length && i < 3; i++)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: i == 0 ? SeoguColors.highlight :
                                i == 1 ? SeoguColors.warning :
                                SeoguColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: SeoguColors.surface,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              complaints[i]['keyword'] ?? '',
                              style: const TextStyle(
                                fontSize: 19,
                                color: SeoguColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${complaints[i]['count'] ?? 0}건',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: SeoguColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessTypeStatus() {
    final businessTypes = dongData?['businessTypes'] as List<dynamic>? ?? [];
    final colors = [SeoguColors.primary, SeoguColors.secondary, SeoguColors.accent, SeoguColors.info];
    
    // 기본값 설정 (데이터가 없을 경우)
    if (businessTypes.isEmpty) {
      final defaultBusinessTypes = ['음식점', '소매점', '서비스업', '기타'];
      final counts = [
        (widget.dong.merchantList.length * 0.4).toInt(), // 음식점 40%
        (widget.dong.merchantList.length * 0.3).toInt(), // 소매점 30%
        (widget.dong.merchantList.length * 0.2).toInt(), // 서비스업 20%
        (widget.dong.merchantList.length * 0.1).toInt(), // 기타 10%
      ];
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SeoguColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏢 ${widget.dong.name} 업종별 가맹점 현황',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: SeoguColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...defaultBusinessTypes.asMap().entries.map((entry) {
              final index = entry.key;
              final businessType = entry.value;
              final count = counts[index];
              final percentage = widget.dong.merchantList.length > 0 
                  ? (count / widget.dong.merchantList.length * 100) 
                  : 0.0;
              final color = colors[index];
              return _buildBusinessTypeItem(businessType, count, percentage, color);
            }).toList(),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SeoguColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏢 ${widget.dong.name} 업종별 가맹점 현황',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...businessTypes.asMap().entries.map((entry) {
            final index = entry.key;
            final businessTypeData = entry.value;
            final businessType = businessTypeData['type'] ?? '';
            final count = businessTypeData['count'] ?? 0;
            final percentage = businessTypeData['percentage']?.toDouble() ?? 0.0;
            final color = colors[index % colors.length];
            return _buildBusinessTypeItem(businessType, count, percentage, color);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBusinessTypeItem(String businessType, int count, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 100,
            child: Text(
              businessType,
              style: const TextStyle(
                fontSize: 19,
                color: SeoguColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 80,
            alignment: Alignment.centerRight,
            child: Text(
              '${count}개 (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: SeoguColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantGridView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SeoguColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: widget.dong.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '🏪 ${widget.dong.name} 상인회 목록 (${widget.dong.merchantList.length}개)',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: SeoguColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          widget.dong.merchantList.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(40),
                  child: const Center(
                    child: Text(
                      '데이터가 없습니다.',
                      style: TextStyle(
                        fontSize: 19,
                        color: SeoguColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3.2,
                  ),
                  itemCount: widget.dong.merchantList.length,
                  itemBuilder: (context, index) {
                    final merchant = widget.dong.merchantList[index];
                    return _buildMerchantCard(merchant);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard(Merchant merchant) {
    return InkWell(
      onTap: () => widget.onMerchantSelected(merchant),
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.dong.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.dong.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          '${merchant.id}.\n${merchant.name}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: SeoguColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}