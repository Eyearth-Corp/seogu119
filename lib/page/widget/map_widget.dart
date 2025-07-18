import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:math';
import 'dart:async';

// Import the Dong data
import '../data/dong_list.dart';

class MapWidget extends StatefulWidget {
  final Function(Merchant)? onMerchantSelected;
  
  const MapWidget({super.key, this.onMerchantSelected});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  Animation<Matrix4>? _matrixAnimation;
  Animation<double>? _pulseAnimation;
  Animation<double>? _fadeAnimation;
  Timer? _autoResetTimer;

  // State for layer visibility
  bool _showTerrain = true;
  bool _showNumber = true;
  bool _showDongName = true;
  bool _showDongAreas = false;
  bool _showDongTags = false;

  // State for Dong selection
  Dong? _selectedDong;
  Set<int> _selectedMerchants = {};
  bool _isSelectionMode = false;

  // Fixed map size
  final double _mapWidth = 2403;
  final double _mapHeight = 2900;

  // Touch optimization for 84-inch display
  static const double _touchTargetSize = 46.0;
  static const double _fontSize = 16.0;
  static const Duration _autoResetDuration = Duration(minutes: 5);

  final GlobalKey interactiveViewerKey = GlobalKey();
  
  // Performance optimization
  final Set<int> _visibleMerchants = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _transformationController.value = Matrix4.identity();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _startAutoResetTimer();
    _calculateVisibleMerchants();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _autoResetTimer?.cancel();
    super.dispose();
  }

  void _startAutoResetTimer() {
    _autoResetTimer?.cancel();
    _autoResetTimer = Timer(_autoResetDuration, () {
      _resetToInitialState();
    });
  }

  void _resetToInitialState() {
    if (mounted) {
      setState(() {
        _selectedDong = null;
        _selectedMerchants.clear();
        _isSelectionMode = false;
        _showTerrain = true;
        _showNumber = true;
        _showDongName = true;
        _showDongAreas = false;
        _showDongTags = false;
      });
      _transformationController.value = Matrix4.identity();
      _startAutoResetTimer();
    }
  }

  void _calculateVisibleMerchants() {
    _visibleMerchants.clear();
    if (_selectedDong != null) {
      for (var merchant in _selectedDong!.merchantList) {
        _visibleMerchants.add(merchant.id);
      }
    } else {
      for (var dong in DongList.all) {
        for (var merchant in dong.merchantList) {
          _visibleMerchants.add(merchant.id);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main map container with glass effect
        Container(
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
            child: Stack(
              children: [
                // Interactive map viewer
                InteractiveViewer(
                  key: interactiveViewerKey,
                  transformationController: _transformationController,
                  minScale: 0.1,
                  maxScale: 3.0,
                  boundaryMargin: const EdgeInsets.all(400),
                  constrained: false,
                  child: GestureDetector(
                    onTapUp: _handleTapUp,
                    onDoubleTap: _handleDoubleTap,
                    onLongPress: _handleLongPress,
                    child: SizedBox(
                      width: _mapWidth,
                      height: _mapHeight,
                      child: Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          // Base map image
                          Image.asset(
                            'assets/map/base.png',
                            fit: BoxFit.contain,
                            width: _mapWidth,
                            height: _mapHeight,
                            filterQuality: FilterQuality.high,
                          ),
                          // Terrain layer
                          AnimatedOpacity(
                            opacity: _showTerrain ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Image.asset(
                              'assets/map/mount.png',
                              fit: BoxFit.contain,
                              width: _mapWidth,
                              height: _mapHeight,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          // Dong areas
                          ..._buildDongAreas(),
                          // Dong name layer
                          AnimatedOpacity(
                            opacity: _showDongName ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Image.asset(
                              'assets/map/dong_name.png',
                              fit: BoxFit.contain,
                              width: _mapWidth,
                              height: _mapHeight,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          // Dong tags
                          ..._buildDongTags(),
                          // Merchant numbers
                          ..._buildMerchantNumbers(),
                        ],
                      ),
                    ),
                  ),
                ),
                // Loading overlay
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Enhanced legend
        _buildEnhancedLegend(),
        // Dong selection panel
        _buildDongSelectionPanel(),
        // Touch feedback overlay
        _buildTouchFeedback(),
      ],
    );
  }

  void _animateToRect(Rect rect) {
    final context = interactiveViewerKey.currentContext;
    if (context == null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final widgetSize = renderBox.size;

    final scale = min(widgetSize.width / rect.width, widgetSize.height / rect.height) * 0.8;
    final dx = (widgetSize.width - rect.width * scale) / 2 - rect.left * scale;
    final dy = (widgetSize.height - rect.height * scale) / 2 - rect.top * scale;

    final endMatrix = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);

    _matrixAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _animationController.addListener(() {
      if (_matrixAnimation != null) {
        _transformationController.value = _matrixAnimation!.value;
      }
    });

    _animationController.forward(from: 0);
  }

  void _handleTapUp(TapUpDetails details) {
    _startAutoResetTimer();
    final position = _transformationController.toScene(details.localPosition);
    
    // Check if tapping on a merchant
    final tappedMerchant = _findMerchantAtPosition(position);
    if (tappedMerchant != null) {
      _handleMerchantTap(tappedMerchant);
    } else {
      _copyPositionToClipboard(position);
    }
  }

  void _handleDoubleTap() {
    _startAutoResetTimer();
    // Reset zoom or zoom to fit
    _transformationController.value = Matrix4.identity();
  }

  void _handleLongPress() {
    _startAutoResetTimer();
    setState(() {
      _isSelectionMode = !_isSelectionMode;
    });
    
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSelectionMode ? '선택 모드 활성화' : '선택 모드 비활성화',
          style: const TextStyle(fontSize: 18),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Merchant? _findMerchantAtPosition(Offset position) {
    const touchRadius = _touchTargetSize / 2;
    
    for (var dong in DongList.all) {
      if (_selectedDong != null && dong != _selectedDong) continue;
      
      for (var merchant in dong.merchantList) {
        final distance = sqrt(
          pow(merchant.x - position.dx, 2) + pow(merchant.y - position.dy, 2)
        );
        if (distance <= touchRadius) {
          return merchant;
        }
      }
    }
    return null;
  }

  void _handleMerchantTap(Merchant merchant) {
    HapticFeedback.lightImpact();
    
    if (_isSelectionMode) {
      setState(() {
        if (_selectedMerchants.contains(merchant.id)) {
          _selectedMerchants.remove(merchant.id);
        } else {
          _selectedMerchants.add(merchant.id);
        }
      });
    } else {
      _showMerchantDetails(merchant);
      widget.onMerchantSelected?.call(merchant);
    }
  }

  void _showMerchantDetails(Merchant merchant) {
    showDialog(
      context: context,
      builder: (context) => _buildMerchantDetailsModal(merchant),
    );
  }

  Widget _buildMerchantDetailsModal(Merchant merchant) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Text(
        merchant.name,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('상인회 ID: ${merchant.id}', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 12),
          Text('위치: (${merchant.x.toInt()}, ${merchant.y.toInt()})', 
               style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          // Add more merchant details here
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기', style: TextStyle(fontSize: 20)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _animateToMerchant(merchant);
          },
          child: const Text('위치로 이동', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  void _animateToMerchant(Merchant merchant) {
    final rect = Rect.fromCenter(
      center: Offset(merchant.x, merchant.y),
      width: 200,
      height: 200,
    );
    _animateToRect(rect);
  }

  List<Widget> _buildMerchantNumbers() {
    if (!_showNumber) return [];

    List<Widget> widgets = [];
    int animationIndex = 0;

    for (var dong in DongList.all) {
      if (_selectedDong != null && dong != _selectedDong) continue;
      
      for (var merchant in dong.merchantList) {
        if (!_visibleMerchants.contains(merchant.id)) continue;
        
        final isSelected = _selectedMerchants.contains(merchant.id);
        final isHighlighted = _isSelectionMode && isSelected;
        
        widgets.add(
          Positioned(
            left: merchant.x,
            top: merchant.y,
            child: AnimationConfiguration.staggeredList(
              position: animationIndex,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildMerchantMarker(merchant, dong, isHighlighted),
                ),
              ),
            ),
          ),
        );
        animationIndex++;
      }
    }
    
    return widgets;
  }

  Widget _buildMerchantMarker(Merchant merchant, Dong dong, bool isHighlighted) {
    return AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) {
        final scale = isHighlighted ? _pulseAnimation!.value : 1.0;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: _touchTargetSize,
            height: _touchTargetSize,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isHighlighted ? Colors.orange : dong.color,
                width: isHighlighted ? 4 : 3,
              ),
              borderRadius: BorderRadius.circular(_touchTargetSize / 2),
              boxShadow: [
                BoxShadow(
                  color: dong.color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    merchant.id.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: _fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isHighlighted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.orange,
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDongAreas() {
    if (!_showDongAreas) return [];
    
    List<Widget> widgets = [];
    
    for (var dong in DongList.all) {
      if (_selectedDong != null && dong != _selectedDong) continue;
      
      widgets.add(
        Positioned.fromRect(
          rect: dong.area,
          child: AnimatedOpacity(
            opacity: dong.isShow ? 0.3 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                color: dong.color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: dong.color.withOpacity(0.8),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return widgets;
  }

  List<Widget> _buildDongTags() {
    if (!_showDongTags) return [];
    
    List<Widget> widgets = [];
    
    for (var dong in DongList.all) {
      if (_selectedDong != null && dong != _selectedDong) continue;
      
      widgets.add(
        Positioned.fromRect(
          rect: dong.dongTagArea,
          child: AnimatedOpacity(
            opacity: dong.isShow ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Image.asset(
              dong.dongTagAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      );
    }
    
    return widgets;
  }

  Widget _buildEnhancedLegend() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: GlassContainer(
        height: 110,
        width: double.infinity,
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.40), Colors.white.withOpacity(0.10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.60), Colors.white.withOpacity(0.10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Colors.white.withOpacity(0.3),
        blur: 15,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildEnhancedToggle(
                      title: '지형',
                      icon: Icons.terrain,
                      value: _showTerrain,
                      onChanged: (value) {
                        setState(() {
                          _showTerrain = value;
                        });
                        _startAutoResetTimer();
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildEnhancedToggle(
                      title: '번호',
                      icon: Icons.numbers,
                      value: _showNumber,
                      onChanged: (value) {
                        setState(() {
                          _showNumber = value;
                        });
                        _startAutoResetTimer();
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildEnhancedToggle(
                      title: '동이름',
                      icon: Icons.location_city,
                      value: _showDongName,
                      onChanged: (value) {
                        setState(() {
                          _showDongName = value;
                        });
                        _startAutoResetTimer();
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildEnhancedToggle(
                      title: '구역',
                      icon: Icons.map,
                      value: _showDongAreas,
                      onChanged: (value) {
                        setState(() {
                          _showDongAreas = value;
                        });
                        _startAutoResetTimer();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedToggle({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? Colors.blue.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? Colors.blue : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: value ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: value ? Colors.blue : Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDongSelectionPanel() {
    return Positioned(
      top: 24,
      right: 24,
      child: GlassContainer(
        height: 400,
        width: 300,
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.40), Colors.white.withOpacity(0.10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.60), Colors.white.withOpacity(0.10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Colors.white.withOpacity(0.3),
        blur: 15,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                '행정구역 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: DongList.all.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildDongSelectionItem(null, '전체 구역');
                  }
                  final dong = DongList.all[index - 1];
                  return _buildDongSelectionItem(dong, dong.name);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDongSelectionItem(Dong? dong, String title) {
    final isSelected = _selectedDong == dong;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: dong != null
            ? Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: dong.color,
                  shape: BoxShape.circle,
                ),
              )
            : const Icon(Icons.select_all, size: 24),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: dong != null
            ? Text(
                '${dong.merchantList.length}개',
                style: const TextStyle(fontSize: 14),
              )
            : Text(
                '${DongList.all.fold(0, (sum, d) => sum + d.merchantList.length)}개',
                style: const TextStyle(fontSize: 14),
              ),
        onTap: () {
          setState(() {
            _selectedDong = dong;
            _selectedMerchants.clear();
            _calculateVisibleMerchants();
          });
          
          if (dong != null) {
            _animateToRect(dong.area);
          } else {
            _transformationController.value = Matrix4.identity();
          }
          
          _startAutoResetTimer();
        },
      ),
    );
  }

  Widget _buildTouchFeedback() {
    return AnimatedBuilder(
      animation: _fadeAnimation!,
      builder: (context, child) {
        return Positioned(
          top: 24,
          left: 24,
          child: AnimatedOpacity(
            opacity: _isSelectionMode ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: GlassContainer(
              height: 60,
              width: 200,
              gradient: LinearGradient(
                colors: [Colors.orange.withOpacity(0.40), Colors.orange.withOpacity(0.10)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [Colors.orange.withOpacity(0.60), Colors.orange.withOpacity(0.10)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderColor: Colors.orange.withOpacity(0.3),
              blur: 15,
              borderRadius: BorderRadius.circular(16),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, color: Colors.orange, size: 24),
                    SizedBox(width: 8),
                    Text(
                      '선택 모드',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _copyPositionToClipboard(Offset position) {
    final int x = position.dx.clamp(0, _mapWidth).round();
    final int y = position.dy.clamp(0, _mapHeight).round();

    final String textToCopy = 'X: $x, Y: $y';
    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.copy, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '좌표 복사됨: $textToCopy',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  void selectDong(Dong? dong) {
    setState(() {
      _selectedDong = dong;
      _selectedMerchants.clear();
      _calculateVisibleMerchants();
    });
    
    if (dong != null) {
      _animateToRect(dong.area);
    } else {
      _transformationController.value = Matrix4.identity();
    }
    
    _startAutoResetTimer();
  }

  void toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
    });
  }

  List<Merchant> getSelectedMerchants() {
    List<Merchant> merchants = [];
    for (var dong in DongList.all) {
      for (var merchant in dong.merchantList) {
        if (_selectedMerchants.contains(merchant.id)) {
          merchants.add(merchant);
        }
      }
    }
    return merchants;
  }
}