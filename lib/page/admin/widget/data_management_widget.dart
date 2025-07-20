import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/admin_service.dart';
import '../../data/dashboard_data.dart';

class DataManagementWidget extends StatefulWidget {
  const DataManagementWidget({super.key});

  @override
  State<DataManagementWidget> createState() => _DataManagementWidgetState();
}

class _DataManagementWidgetState extends State<DataManagementWidget> {
  List<Map<String, dynamic>> _availableDates = [];
  Map<String, Map<String, dynamic>> _statistics = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // 사용 가능한 날짜 목록 로드
      final dates = await AdminService.getAvailableDates();
      
      // 각 날짜별 통계 정보 로드
      final statistics = <String, Map<String, dynamic>>{};
      for (final dateInfo in dates) {
        final stats = await AdminService.getStatistics(dateInfo['date']);
        if (stats != null) {
          statistics[dateInfo['date']] = stats;
        }
      }
      
      setState(() {
        _availableDates = dates;
        _statistics = statistics;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 실패: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('데이터가 새로고침되었습니다.')),
      );
    }
  }

  void _showDateDetailDialog(Map<String, dynamic> dateInfo) {
    showDialog(
      context: context,
      builder: (context) => DateDetailDialog(
        dateInfo: dateInfo,
        statistics: _statistics[dateInfo['date']],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 및 액션 버튼
          _buildHeader(),
          const SizedBox(height: 24),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            // 전체 통계 요약
            _buildSummaryCards(),
            const SizedBox(height: 24),
            
            // 데이터 목록
            _buildDataList(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          '데이터 관리',
          style: GoogleFonts.notoSansKr(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        
        OutlinedButton.icon(
          onPressed: _refreshData,
          icon: const Icon(Icons.refresh),
          label: Text('새로고침', style: GoogleFonts.notoSansKr()),
        ),
        const SizedBox(width: 12),
        
        ElevatedButton.icon(
          onPressed: () {
            // TODO: 데이터 내보내기 기능
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('데이터 내보내기 기능은 준비 중입니다.')),
            );
          },
          icon: const Icon(Icons.download),
          label: Text('데이터 내보내기', style: GoogleFonts.notoSansKr()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    if (_statistics.isEmpty) {
      return const SizedBox.shrink();
    }

    // 전체 통계 계산
    int totalMerchants = 0;
    int totalOperating = 0;
    int totalOnNuriCard = 0;
    double totalRevenue = 0.0;
    
    for (final stats in _statistics.values) {
      totalMerchants += (stats['total_merchants'] as int? ?? 0);
      totalOperating += (stats['operating_merchants'] as int? ?? 0);
      totalOnNuriCard += (stats['on_nuri_card_merchants'] as int? ?? 0);
      totalRevenue += (stats['total_revenue'] as double? ?? 0.0);
    }

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: '총 데이터 세트',
            value: '${_availableDates.length}개',
            icon: Icons.dataset,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            title: '총 가맹점 수',
            value: '${totalMerchants.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}개',
            icon: Icons.store,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            title: '영업중 가맹점',
            value: totalMerchants > 0 
                ? '${(totalOperating / totalMerchants * 100).toStringAsFixed(1)}%'
                : '0%',
            icon: Icons.check_circle,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            title: '총 매출',
            value: '${(totalRevenue / 10000).toStringAsFixed(0)}억원',
            icon: Icons.attach_money,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '데이터 세트 목록',
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          if (_availableDates.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.dataset, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      '데이터가 없습니다.',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _availableDates.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final dateInfo = _availableDates[index];
                final statistics = _statistics[dateInfo['date']];
                
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        dateInfo['phase'] ?? '',
                        style: GoogleFonts.notoSansKr(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    '${dateInfo['phase']} - ${dateInfo['date']}',
                    style: GoogleFonts.notoSansKr(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: statistics != null
                      ? Text(
                          '가맹점 ${statistics['total_merchants']}개 | 영업중 ${statistics['operating_merchants']}개 | 매출 ${(statistics['total_revenue'] / 10000).toStringAsFixed(0)}억원',
                          style: GoogleFonts.notoSansKr(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        )
                      : Text(
                          '통계 정보 없음',
                          style: GoogleFonts.notoSansKr(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(dateInfo['date']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(dateInfo['date']),
                          style: GoogleFonts.notoSansKr(
                            fontSize: 12,
                            color: _getStatusColor(dateInfo['date']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showDateDetailDialog(dateInfo),
                        icon: const Icon(Icons.visibility),
                        tooltip: '상세보기',
                      ),
                    ],
                  ),
                  onTap: () => _showDateDetailDialog(dateInfo),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String date) {
    if (date == 'all') return Colors.blue;
    
    final now = DateTime.now();
    final dataDate = DateTime.tryParse(date.replaceAll('-', ''));
    
    if (dataDate == null) return Colors.grey;
    
    final difference = now.difference(dataDate).inDays;
    
    if (difference < 30) return Colors.green;
    if (difference < 90) return Colors.orange;
    return Colors.red;
  }

  String _getStatusText(String date) {
    if (date == 'all') return '전체';
    
    final now = DateTime.now();
    final dataDate = DateTime.tryParse(date.replaceAll('-', ''));
    
    if (dataDate == null) return '오류';
    
    final difference = now.difference(dataDate).inDays;
    
    if (difference < 30) return '최신';
    if (difference < 90) return '보통';
    return '오래됨';
  }
}

// 날짜별 상세 정보 다이얼로그
class DateDetailDialog extends StatelessWidget {
  final Map<String, dynamic> dateInfo;
  final Map<String, dynamic>? statistics;

  const DateDetailDialog({
    super.key,
    required this.dateInfo,
    this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${dateInfo['phase']} 데이터 상세 정보',
              style: GoogleFonts.notoSansKr(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // 기본 정보
            _buildInfoRow('수집 날짜', dateInfo['date']),
            _buildInfoRow('차수', dateInfo['phase']),
            _buildInfoRow('제목', dateInfo['title'] ?? '-'),
            
            if (statistics != null) ...[
              const Divider(height: 32),
              
              Text(
                '통계 정보',
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildInfoRow('총 가맹점 수', '${statistics!['total_merchants']}개'),
              _buildInfoRow('영업중 가맹점', '${statistics!['operating_merchants']}개'),
              _buildInfoRow('휴업 가맹점', '${statistics!['closed_merchants']}개'),
              _buildInfoRow('영업률', '${statistics!['operating_rate'].toStringAsFixed(1)}%'),
              _buildInfoRow('온누리상품권 가맹점', '${statistics!['on_nuri_card_merchants']}개'),
              _buildInfoRow('온누리상품권 가입률', '${statistics!['on_nuri_card_rate'].toStringAsFixed(1)}%'),
              _buildInfoRow('총 매출', '${(statistics!['total_revenue'] / 10000).toStringAsFixed(1)}억원'),
              _buildInfoRow('평균 매출', '${statistics!['average_revenue'].toStringAsFixed(0)}만원'),
              
              if (statistics!['category_stats'] != null) ...[
                const SizedBox(height: 16),
                Text(
                  '업종별 분포',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...((statistics!['category_stats'] as Map<String, dynamic>)
                    .entries
                    .take(5)
                    .map((entry) => _buildInfoRow(entry.key, '${entry.value}개'))),
              ],
            ],
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('닫기', style: GoogleFonts.notoSansKr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.notoSansKr(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.notoSansKr(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}