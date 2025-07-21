import 'package:flutter/material.dart';
import '../../data/dong_list.dart';
import '../../../core/colors.dart';

class DongDashboard extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
          onPressed: onBackPressed,
          icon: const Icon(Icons.arrow_back, size: 24),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: dong.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${dong.name} 대시보드',
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
    return Row(
      children: [
        Expanded(child: _buildMetricCard('🏪 총 상인회', '${dong.merchantList.length}', '개', dong.color)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('✨ 가맹률', '${(dong.merchantList.length / 30 * 100).toStringAsFixed(1)}', '%', SeoguColors.success)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('📊 이번주 방문', '${(dong.merchantList.length * 1.2).toInt()}', '회', SeoguColors.warning)),
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
    final newMerchants = (dong.merchantList.length * 0.1).toInt().clamp(1, 10);
    final complaints = (dong.merchantList.length * 0.05).toInt().clamp(0, 5);
    final budget = ((dong.merchantList.length * 0.2) + 10).toInt();
    
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
            '🎯 ${dong.name} 금주 성과',
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
                child: _buildAchievementCard('신규 가맹', '${newMerchants}개', dong.color),
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
    // 동별 민원 데이터 (샘플)
    final complaints = ['주차 문제', '소음 방해', '청소 문제'];
    final counts = [(dong.merchantList.length * 0.3).toInt(), (dong.merchantList.length * 0.2).toInt(), (dong.merchantList.length * 0.1).toInt()];
    
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
            '🔥 ${dong.name} 민원 현황',
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
                for (int i = 0; i < complaints.length; i++)
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
                              complaints[i],
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
                  color: dong.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '🏪 ${dong.name} 상인회 목록 (${dong.merchantList.length}개)',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: SeoguColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: dong.merchantList.length,
            itemBuilder: (context, index) {
              final merchant = dong.merchantList[index];
              return _buildMerchantCard(merchant);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard(Merchant merchant) {
    return InkWell(
      onTap: () => onMerchantSelected(merchant),
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: dong.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: dong.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          '${merchant.id}\n${merchant.name}',
          style: const TextStyle(
            fontSize: 18,
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