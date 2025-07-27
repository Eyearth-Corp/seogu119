import 'package:flutter/material.dart';
import '../data/admin_service.dart';
import '../../core/colors.dart';

class DongAdminDashboardPage extends StatefulWidget {
  final String dongName;
  
  const DongAdminDashboardPage({
    super.key,
    required this.dongName,
  });

  @override
  State<DongAdminDashboardPage> createState() => _DongAdminDashboardPageState();
}

class _DongAdminDashboardPageState extends State<DongAdminDashboardPage> {
  Map<String, dynamic>? _districtData;
  List<dynamic> _merchants = [];
  List<dynamic> _notices = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadDistrictData();
  }

  /// 동별 데이터 로드
  Future<void> _loadDistrictData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 동별 상인회 정보 로드
      final merchantsData = await AdminService.getMerchantsByDistrict(widget.dongName);
      if (merchantsData != null) {
        setState(() {
          _districtData = merchantsData['district'];
          _merchants = merchantsData['merchants'];
        });
      }

      // 동별 공지사항 로드
      final noticesData = await AdminService.getDistrictNotices(widget.dongName);
      if (noticesData != null) {
        setState(() {
          _notices = noticesData['notices'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 로드 실패: ${AdminService.getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 상인회 정보 수정
  Future<void> _editMerchant(Map<String, dynamic> merchant) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _MerchantEditDialog(merchant: merchant),
    );

    if (result != null) {
      try {
        final success = await AdminService.updateMerchant(
          merchant['id'],
          merchantName: result['merchant_name'],
          president: result['president'],
          storeCount: result['store_count'],
          memberStoreCount: result['member_store_count']?.toDouble(),
          membershipRate: result['membership_rate']?.toDouble(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? '상인회 정보가 수정되었습니다.' : '수정에 실패했습니다.'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
          
          if (success) {
            _loadDistrictData(); // 데이터 새로고침
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('수정 실패: ${AdminService.getErrorMessage(e)}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 새 공지사항 추가
  Future<void> _addNotice() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _NoticeEditDialog(),
    );

    if (result != null && result['title']!.isNotEmpty) {
      try {
        final success = await AdminService.createDistrictNotice(
          widget.dongName,
          result['title']!,
          result['content']!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? '공지사항이 생성되었습니다.' : '생성에 실패했습니다.'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
          
          if (success) {
            _loadDistrictData(); // 데이터 새로고침
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('생성 실패: ${AdminService.getErrorMessage(e)}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 공지사항 수정
  Future<void> _editNotice(Map<String, dynamic> notice) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _NoticeEditDialog(
        title: notice['title'],
        content: notice['content'],
      ),
    );

    if (result != null) {
      try {
        final success = await AdminService.updateNotice(
          notice['id'],
          title: result['title'],
          content: result['content'],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? '공지사항이 수정되었습니다.' : '수정에 실패했습니다.'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
          
          if (success) {
            _loadDistrictData(); // 데이터 새로고침
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('수정 실패: ${AdminService.getErrorMessage(e)}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 공지사항 삭제
  Future<void> _deleteNotice(Map<String, dynamic> notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공지사항 삭제'),
        content: Text('정말로 "${notice['title']}"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await AdminService.deleteNotice(notice['id']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? '공지사항이 삭제되었습니다.' : '삭제에 실패했습니다.'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
          
          if (success) {
            _loadDistrictData(); // 데이터 새로고침
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 실패: ${AdminService.getErrorMessage(e)}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dongName} 관리자 대시보드'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDistrictData,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _districtData == null
              ? const Center(child: Text('데이터를 불러올 수 없습니다.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildDistrictSummary(),
                      const SizedBox(height: 20),
                      _buildMerchantsSection(),
                      const SizedBox(height: 20),
                      _buildNoticesSection(),
                    ],
                  ),
                ),
    );
  }

  /// 동 요약 정보
  Widget _buildDistrictSummary() {
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
            '${widget.dongName} 현황',
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
                child: _buildSummaryCard(
                  '상인회 수',
                  '${_districtData!['merchant_count']}개',
                  SeoguColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  '총 점포 수',
                  '${_districtData!['total_stores']}개',
                  SeoguColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  '가맹점포 수',
                  '${_districtData!['total_member_stores']}개',
                  SeoguColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  '전체 가맹률',
                  '${_districtData!['overall_membership_rate']}%',
                  SeoguColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 요약 카드
  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: SeoguColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 상인회 섹션
  Widget _buildMerchantsSection() {
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
          const Text(
            '🏪 상인회 관리',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: SeoguColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_merchants.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  '등록된 상인회가 없습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: SeoguColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _merchants.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final merchant = _merchants[index];
                return _buildMerchantItem(merchant);
              },
            ),
        ],
      ),
    );
  }

  /// 상인회 아이템
  Widget _buildMerchantItem(Map<String, dynamic> merchant) {
    final membershipRate = _parseToDouble(merchant['membership_rate']) * 100;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: Text(
        merchant['merchant_name'],
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: SeoguColors.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (merchant['president'] != null && merchant['president'].isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('회장: ${merchant['president']}'),
          ],
          const SizedBox(height: 4),
          Text('점포: ${merchant['store_count']}개 | 가맹: ${merchant['member_store_count']}개'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getMembershipRateColor(membershipRate).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getMembershipRateColor(membershipRate).withOpacity(0.3),
              ),
            ),
            child: Text(
              '${membershipRate.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getMembershipRateColor(membershipRate),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            color: SeoguColors.primary,
            onPressed: () => _editMerchant(merchant),
            tooltip: '수정',
          ),
        ],
      ),
    );
  }

  /// 공지사항 섹션
  Widget _buildNoticesSection() {
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
              const Text(
                '📢 공지사항 관리',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: SeoguColors.textPrimary,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addNotice,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('공지사항 추가'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SeoguColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_notices.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  '등록된 공지사항이 없습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: SeoguColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notices.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final notice = _notices[index];
                return _buildNoticeItem(notice);
              },
            ),
        ],
      ),
    );
  }

  /// 공지사항 아이템
  Widget _buildNoticeItem(Map<String, dynamic> notice) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: Text(
        notice['title'],
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: SeoguColors.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notice['content'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(notice['created_at']),
            style: const TextStyle(
              fontSize: 13,
              color: SeoguColors.textSecondary,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            color: SeoguColors.primary,
            onPressed: () => _editNotice(notice),
            tooltip: '수정',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Colors.red.shade400,
            onPressed: () => _deleteNotice(notice),
            tooltip: '삭제',
          ),
        ],
      ),
    );
  }

  /// 가맹률에 따른 색상 반환
  Color _getMembershipRateColor(double rate) {
    if (rate >= 80) return SeoguColors.success;
    if (rate >= 60) return SeoguColors.warning;
    return SeoguColors.error;
  }

  /// 날짜 포맷팅
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}/${date.month}/${date.day}';
    } catch (e) {
      return dateString;
    }
  }

  /// String 또는 숫자를 안전하게 double로 변환
  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // 반복된 값이 있는 경우 (예: "0.5920.5920.592...") 첫 번째 값만 사용
      final cleanValue = value.replaceAll(RegExp(r'([0-9]*\.?[0-9]+).*'), r'$1');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    
    return 0.0;
  }
}

/// 상인회 편집 다이얼로그
class _MerchantEditDialog extends StatefulWidget {
  final Map<String, dynamic> merchant;

  const _MerchantEditDialog({required this.merchant});

  @override
  State<_MerchantEditDialog> createState() => _MerchantEditDialogState();
}

class _MerchantEditDialogState extends State<_MerchantEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _presidentController;
  late TextEditingController _storeCountController;
  late TextEditingController _memberStoreCountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.merchant['merchant_name']);
    _presidentController = TextEditingController(text: widget.merchant['president'] ?? '');
    _storeCountController = TextEditingController(text: widget.merchant['store_count'].toString());
    _memberStoreCountController = TextEditingController(text: widget.merchant['member_store_count'].toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _presidentController.dispose();
    _storeCountController.dispose();
    _memberStoreCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('상인회 정보 수정'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '상인회명',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _presidentController,
                decoration: const InputDecoration(
                  labelText: '회장',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _storeCountController,
                decoration: const InputDecoration(
                  labelText: '총 점포 수',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _memberStoreCountController,
                decoration: const InputDecoration(
                  labelText: '가맹점포 수',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            final storeCount = int.tryParse(_storeCountController.text) ?? 0;
            final memberStoreCount = int.tryParse(_memberStoreCountController.text) ?? 0;
            final membershipRate = storeCount > 0 ? memberStoreCount / storeCount : 0.0;

            Navigator.pop(context, {
              'merchant_name': _nameController.text,
              'president': _presidentController.text,
              'store_count': storeCount,
              'member_store_count': memberStoreCount,
              'membership_rate': membershipRate,
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: SeoguColors.primary),
          child: const Text('저장'),
        ),
      ],
    );
  }
}

/// 공지사항 편집 다이얼로그
class _NoticeEditDialog extends StatefulWidget {
  final String? title;
  final String? content;

  const _NoticeEditDialog({this.title, this.content});

  @override
  State<_NoticeEditDialog> createState() => _NoticeEditDialogState();
}

class _NoticeEditDialogState extends State<_NoticeEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title ?? '');
    _contentController = TextEditingController(text: widget.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title == null ? '공지사항 추가' : '공지사항 수정'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '내용',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'title': _titleController.text,
              'content': _contentController.text,
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: SeoguColors.primary),
          child: const Text('저장'),
        ),
      ],
    );
  }
}