import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/admin_service.dart';
import '../../data/dashboard_data.dart';

class MerchantManagementWidget extends StatefulWidget {
  const MerchantManagementWidget({super.key});

  @override
  State<MerchantManagementWidget> createState() => _MerchantManagementWidgetState();
}

class _MerchantManagementWidgetState extends State<MerchantManagementWidget> {
  String _selectedDate = 'all';
  String? _selectedDong;
  String? _selectedCategory;
  String? _selectedStatus;
  
  List<Map<String, dynamic>> _merchants = [];
  Map<String, dynamic>? _pagination;
  bool _isLoading = false;
  
  int _currentPage = 1;
  final int _limit = 20;

  final List<String> _dongNames = [
    '동천동', '유촌동', '광천동', '치평동', '상무1동', '화정1동',
    '농성1동', '양동', '마륵동', '상무2동', '금호1동', '화정4동',
    '화정3동', '화정2동', '농성2동', '금호2동', '풍암동', '매월동', '서창동'
  ];
  
  final List<String> _categories = [
    '일반음식점', '수퍼마켓', '편의점', '학원', '병원의원', '이용뷰티',
    '일반주점', '여가시설', '부동산업', '가구인테리어', '생활서비스', '기타도소매'
  ];
  
  final List<String> _statuses = ['영업중', '휴업', '이전', '신규개점'];

  @override
  void initState() {
    super.initState();
    _loadMerchants();
  }

  Future<void> _loadMerchants() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await AdminService.getMerchants(
        date: _selectedDate,
        dongName: _selectedDong,
        category: _selectedCategory,
        status: _selectedStatus,
        page: _currentPage,
        limit: _limit,
      );
      
      if (result != null) {
        setState(() {
          _merchants = List<Map<String, dynamic>>.from(result['merchants'] ?? []);
          _pagination = result['pagination'];
        });
      }
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

  void _resetFilters() {
    setState(() {
      _selectedDong = null;
      _selectedCategory = null;
      _selectedStatus = null;
      _currentPage = 1;
    });
    _loadMerchants();
  }

  void _showMerchantDialog({Map<String, dynamic>? merchant}) {
    showDialog(
      context: context,
      builder: (context) => MerchantFormDialog(
        merchant: merchant,
        date: _selectedDate,
        onSaved: () {
          _loadMerchants();
        },
      ),
    );
  }

  Future<void> _deleteMerchant(int merchantId, String merchantName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('가맹점 삭제', style: GoogleFonts.notoSansKr()),
        content: Text(
          '$merchantName을(를) 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
          style: GoogleFonts.notoSansKr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소', style: GoogleFonts.notoSansKr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('삭제', style: GoogleFonts.notoSansKr(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await AdminService.deleteMerchant(_selectedDate, merchantId);
        if (success) {
          _loadMerchants();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('가맹점이 삭제되었습니다.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 필터 섹션
        _buildFilters(),
        const SizedBox(height: 16),
        
        // 액션 버튼들
        _buildActionButtons(),
        const SizedBox(height: 16),
        
        // 가맹점 목록
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildMerchantList(),
        ),
        
        // 페이지네이션
        if (_pagination != null) _buildPagination(),
      ],
    );
  }

  Widget _buildFilters() {
    final availableDates = DashboardDataManager.getAvailableDates();
    
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            '필터',
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDate,
                  decoration: const InputDecoration(
                    labelText: '데이터 기준일',
                    border: OutlineInputBorder(),
                  ),
                  items: availableDates.map((date) {
                    return DropdownMenuItem(
                      value: date.date,
                      child: Text(date.displayName, style: GoogleFonts.notoSansKr()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDate = value;
                        _currentPage = 1;
                      });
                      _loadMerchants();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDong,
                  decoration: const InputDecoration(
                    labelText: '동 선택',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('전체')),
                    ..._dongNames.map((dong) => DropdownMenuItem(
                      value: dong,
                      child: Text(dong, style: GoogleFonts.notoSansKr()),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDong = value;
                      _currentPage = 1;
                    });
                    _loadMerchants();
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('전체')),
                    ..._categories.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category, style: GoogleFonts.notoSansKr()),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _currentPage = 1;
                    });
                    _loadMerchants();
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '상태',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('전체')),
                    ..._statuses.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status, style: GoogleFonts.notoSansKr()),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                      _currentPage = 1;
                    });
                    _loadMerchants();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => _showMerchantDialog(),
          icon: const Icon(Icons.add),
          label: Text('가맹점 추가', style: GoogleFonts.notoSansKr()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        
        OutlinedButton.icon(
          onPressed: _resetFilters,
          icon: const Icon(Icons.refresh),
          label: Text('필터 초기화', style: GoogleFonts.notoSansKr()),
        ),
        
        const Spacer(),
        
        if (_pagination != null)
          Text(
            '총 ${_pagination!['total_items']}개 중 ${(_currentPage - 1) * _limit + 1}-${(_currentPage - 1) * _limit + _merchants.length}개',
            style: GoogleFonts.notoSansKr(color: Colors.grey.shade600),
          ),
      ],
    );
  }

  Widget _buildMerchantList() {
    if (_merchants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '가맹점 데이터가 없습니다.',
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

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
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 16,
          columns: [
            DataColumn(
              label: Text('가맹점명', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('동', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('카테고리', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('상태', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('직원 수', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('월 매출', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('온누리', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('작업', style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold)),
            ),
          ],
          rows: _merchants.map((merchant) {
            return DataRow(cells: [
              DataCell(
                Text(
                  merchant['name'] ?? '',
                  style: GoogleFonts.notoSansKr(),
                ),
              ),
              DataCell(
                Text(
                  merchant['dong_name'] ?? '',
                  style: GoogleFonts.notoSansKr(),
                ),
              ),
              DataCell(
                Text(
                  merchant['category'] ?? '',
                  style: GoogleFonts.notoSansKr(),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(merchant['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    merchant['status'] ?? '',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${merchant['employee_count']}명',
                  style: GoogleFonts.notoSansKr(),
                ),
              ),
              DataCell(
                Text(
                  '${merchant['monthly_revenue']?.toStringAsFixed(0)}만원',
                  style: GoogleFonts.notoSansKr(),
                ),
              ),
              DataCell(
                Icon(
                  merchant['has_on_nuri_card'] == true ? Icons.check_circle : Icons.cancel,
                  color: merchant['has_on_nuri_card'] == true ? Colors.green : Colors.red,
                  size: 18,
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showMerchantDialog(merchant: merchant),
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: '수정',
                    ),
                    IconButton(
                      onPressed: () => _deleteMerchant(
                        merchant['id'],
                        merchant['name'] ?? '',
                      ),
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      tooltip: '삭제',
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final totalPages = _pagination!['total_pages'] as int;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1 ? () {
              setState(() => _currentPage--);
              _loadMerchants();
            } : null,
            icon: const Icon(Icons.chevron_left),
          ),
          
          ...List.generate(
            totalPages > 7 ? 7 : totalPages,
            (index) {
              int pageNumber;
              if (totalPages <= 7) {
                pageNumber = index + 1;
              } else {
                if (_currentPage <= 4) {
                  pageNumber = index + 1;
                } else if (_currentPage >= totalPages - 3) {
                  pageNumber = totalPages - 6 + index;
                } else {
                  pageNumber = _currentPage - 3 + index;
                }
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextButton(
                  onPressed: () {
                    setState(() => _currentPage = pageNumber);
                    _loadMerchants();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: _currentPage == pageNumber 
                        ? Colors.deepPurple 
                        : Colors.transparent,
                    foregroundColor: _currentPage == pageNumber 
                        ? Colors.white 
                        : Colors.black,
                  ),
                  child: Text(pageNumber.toString()),
                ),
              );
            },
          ),
          
          IconButton(
            onPressed: _currentPage < totalPages ? () {
              setState(() => _currentPage++);
              _loadMerchants();
            } : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case '영업중':
        return Colors.green;
      case '휴업':
        return Colors.red;
      case '이전':
        return Colors.orange;
      case '신규개점':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// 가맹점 추가/수정 다이얼로그 (별도 파일로 분리 가능)
class MerchantFormDialog extends StatefulWidget {
  final Map<String, dynamic>? merchant;
  final String date;
  final VoidCallback onSaved;

  const MerchantFormDialog({
    super.key,
    this.merchant,
    required this.date,
    required this.onSaved,
  });

  @override
  State<MerchantFormDialog> createState() => _MerchantFormDialogState();
}

class _MerchantFormDialogState extends State<MerchantFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeController = TextEditingController();
  final _revenueController = TextEditingController();
  
  String _selectedDong = '동천동';
  String _selectedCategory = '일반음식점';
  String _selectedStatus = '영업중';
  String _selectedScale = '소형';
  bool _hasOnNuriCard = false;
  bool _isLoading = false;

  final List<String> _dongNames = [
    '동천동', '유촌동', '광천동', '치평동', '상무1동', '화정1동',
    '농성1동', '양동', '마륵동', '상무2동', '금호1동', '화정4동',
    '화정3동', '화정2동', '농성2동', '금고2동', '풍암동', '매월동', '서창동'
  ];
  
  final List<String> _categories = [
    '일반음식점', '수퍼마켓', '편의점', '학원', '병원의원', '이용뷰티',
    '일반주점', '여가시설', '부동산업', '가구인테리어', '생활서비스', '기타도소매'
  ];
  
  final List<String> _statuses = ['영업중', '휴업', '이전', '신규개점'];
  final List<String> _scales = ['소형', '중형', '대형'];

  @override
  void initState() {
    super.initState();
    if (widget.merchant != null) {
      _nameController.text = widget.merchant!['name'] ?? '';
      _addressController.text = widget.merchant!['address'] ?? '';
      _ownerController.text = widget.merchant!['owner_name'] ?? '';
      _phoneController.text = widget.merchant!['phone_number'] ?? '';
      _employeeController.text = widget.merchant!['employee_count']?.toString() ?? '';
      _revenueController.text = widget.merchant!['monthly_revenue']?.toString() ?? '';
      
      _selectedDong = widget.merchant!['dong_name'] ?? '동천동';
      _selectedCategory = widget.merchant!['category'] ?? '일반음식점';
      _selectedStatus = widget.merchant!['status'] ?? '영업중';
      _selectedScale = widget.merchant!['scale'] ?? '소형';
      _hasOnNuriCard = widget.merchant!['has_on_nuri_card'] ?? false;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final merchantData = {
        'dong_name': _selectedDong,
        'merchant_id': widget.merchant?['merchant_id'] ?? 
            '${_selectedDong}_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'status': _selectedStatus,
        'scale': _selectedScale,
        'employee_count': int.parse(_employeeController.text),
        'monthly_revenue': double.parse(_revenueController.text),
        'has_on_nuri_card': _hasOnNuriCard,
        'registered_date': DateTime.now().toIso8601String(),
        'address': _addressController.text.trim(),
        'owner_name': _ownerController.text.trim(),
        'phone_number': _phoneController.text.trim(),
      };

      bool success;
      if (widget.merchant == null) {
        success = await AdminService.createMerchant(widget.date, merchantData);
      } else {
        success = await AdminService.updateMerchant(
          widget.date, 
          widget.merchant!['id'], 
          merchantData,
        );
      }

      if (success) {
        widget.onSaved();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.merchant == null ? '가맹점이 추가되었습니다.' : '가맹점이 수정되었습니다.')),
          );
        }
      } else {
        throw Exception('저장에 실패했습니다.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.merchant == null ? '가맹점 추가' : '가맹점 수정',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDong,
                        decoration: const InputDecoration(
                          labelText: '동',
                          border: OutlineInputBorder(),
                        ),
                        items: _dongNames.map((dong) => DropdownMenuItem(
                          value: dong,
                          child: Text(dong, style: GoogleFonts.notoSansKr()),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedDong = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: '카테고리',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category, style: GoogleFonts.notoSansKr()),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedCategory = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '가맹점명',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.trim().isEmpty == true ? '가맹점명을 입력하세요' : null,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: '상태',
                          border: OutlineInputBorder(),
                        ),
                        items: _statuses.map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status, style: GoogleFonts.notoSansKr()),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedStatus = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedScale,
                        decoration: const InputDecoration(
                          labelText: '규모',
                          border: OutlineInputBorder(),
                        ),
                        items: _scales.map((scale) => DropdownMenuItem(
                          value: scale,
                          child: Text(scale, style: GoogleFonts.notoSansKr()),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedScale = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _employeeController,
                        decoration: const InputDecoration(
                          labelText: '직원 수',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => 
                          int.tryParse(value ?? '') == null ? '숫자를 입력하세요' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _revenueController,
                        decoration: const InputDecoration(
                          labelText: '월 매출 (만원)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => 
                          double.tryParse(value ?? '') == null ? '숫자를 입력하세요' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _ownerController,
                  decoration: const InputDecoration(
                    labelText: '사업주명',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.trim().isEmpty == true ? '사업주명을 입력하세요' : null,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: '전화번호',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.trim().isEmpty == true ? '전화번호를 입력하세요' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: '주소',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.trim().isEmpty == true ? '주소를 입력하세요' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                CheckboxListTile(
                  title: Text('온누리상품권 가맹점', style: GoogleFonts.notoSansKr()),
                  value: _hasOnNuriCard,
                  onChanged: (value) => setState(() => _hasOnNuriCard = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('취소', style: GoogleFonts.notoSansKr()),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('저장', style: GoogleFonts.notoSansKr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}