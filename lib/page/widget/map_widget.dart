import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:speech_balloon/speech_balloon.dart';
import 'dart:math';
import 'dart:async';

// Import the Dong data
import '../data/dong_list.dart';
import 'dong_merchant_dialog.dart';

// MapWidget을 외부에서 제어하기 위한 컨트롤러
class MapWidgetController {
  void Function(Merchant)? _navigateToMerchant;
  
  void _setNavigateFunction(void Function(Merchant) navigateFunc) {
    _navigateToMerchant = navigateFunc;
  }
  
  void navigateToMerchant(Merchant merchant) {
    _navigateToMerchant?.call(merchant);
  }
}

class MapWidget extends StatefulWidget {
  final Function(Merchant)? onMerchantSelected;
  final Function(Dong?)? onDongSelected;
  final MapWidgetController? controller;
  final bool isMapLeft;
  
  const MapWidget({super.key, this.onMerchantSelected, this.onDongSelected, this.controller, this.isMapLeft = false});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final TransformationController _transformationController = TransformationController();
  Timer? _autoResetTimer;

  // State for layer visibility
  bool _showTerrain = true;
  bool _showNumber = true;
  bool _showDongName = true;
  bool _showDisableDongAreas = false;
  bool _showDongAreas = false;
  bool _showCapturedBackground = false;

  // State for Dong selection
  Dong? _selectedDong;
  Set<int> _selectedMerchants = {};
  bool _isSelectionMode = false;
  
  // State for last selected merchant (for highlighting)
  Merchant? _lastSelectedMerchant;

  // Fixed map size
  final double _mapWidth = 2403;
  final double _mapHeight = 2900;

  // Touch optimization for 84-inch display
  static const double _touchTargetSize = 46.0;
  static const double _fontSize = 16.0;
  static const Duration _autoResetDuration = Duration(minutes: 5);

  final GlobalKey interactiveViewerKey = GlobalKey(debugLabel: 'map_interactive_viewer');
  
  // Performance optimization
  final Set<int> _visibleMerchants = {};
  final Set<int> _renderedMerchants = {};
  bool _isLoading = false;
  Rect? _currentViewport;

  @override
  void initState() {
    super.initState();
    
    _transformationController.value = Matrix4.identity();
    
    // 컨트롤러에 네비게이션 함수 설정
    widget.controller?._setNavigateFunction(_jumpToMerchant);
    
    _startAutoResetTimer();
    _calculateVisibleMerchants();
    
    // 시작시 전체 지도가 보이게 축소
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _zoomToFitEntireMap();
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
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
        _lastSelectedMerchant = null; // 선택된 상인회도 초기화
        _showTerrain = true;
        _showNumber = true;
        _showDongName = true;
        _showDongAreas = false;
      });
      _zoomToFitEntireMap();
      _startAutoResetTimer();
    }
  }

  void _calculateVisibleMerchants() {
    _visibleMerchants.clear();
    _renderedMerchants.clear();
    
    if (_selectedDong != null) {
      for (var merchant in _selectedDong!.merchantList) {
        _visibleMerchants.add(merchant.id);
        // Only add to rendered if within viewport
        if (_isInViewport(merchant.x, merchant.y)) {
          _renderedMerchants.add(merchant.id);
        }
      }
    } else {
      for (var dong in DongList.all) {
        for (var merchant in dong.merchantList) {
          _visibleMerchants.add(merchant.id);
          // Only add to rendered if within viewport
          if (_isInViewport(merchant.x, merchant.y)) {
            _renderedMerchants.add(merchant.id);
          }
        }
      }
    }
  }

  bool _isInViewport(double x, double y) {
    if (_currentViewport == null) return true; // Render all if viewport not set
    
    // Add padding around viewport for smooth scrolling
    const padding = 200.0;
    return _currentViewport!.inflate(padding).contains(Offset(x, y));
  }

  void _updateViewport() {
    final context = interactiveViewerKey.currentContext;
    if (context == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final transform = _transformationController.value;
    final viewport = renderBox.size;
    
    // Calculate the current viewport in scene coordinates
    final sceneTopLeft = transform.getTranslation();
    final scale = transform.getMaxScaleOnAxis();
    
    _currentViewport = Rect.fromLTWH(
      -sceneTopLeft.x / scale,
      -sceneTopLeft.y / scale,
      viewport.width / scale,
      viewport.height / scale,
    );
    
    // Recalculate visible merchants based on new viewport
    _calculateVisibleMerchants();
  }

  void _zoomToFitEntireMap() {
    final context = interactiveViewerKey.currentContext;
    if (context == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final widgetSize = renderBox.size;
    
    // Calculate scale to fit entire map in the viewport
    final scaleX = widgetSize.width / _mapWidth;
    final scaleY = widgetSize.height / _mapHeight;
    final scale = min(scaleX, scaleY) * 0.9; // 0.9 for some padding
    
    // Center the map
    final dx = (widgetSize.width - _mapWidth * scale) / 2;
    final dy = (widgetSize.height - _mapHeight * scale) / 2;
    
    final matrix = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);
    
    _transformationController.value = matrix;
  }

  void _jumpToMerchant(Merchant merchant) {
    setState(() {
      _lastSelectedMerchant = merchant;
    });
    
    final rect = Rect.fromCenter(
      center: Offset(merchant.x, merchant.y),
      width: 200,
      height: 200,
    );
    _jumpToRect(rect);
    
    _startAutoResetTimer();
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
                  maxScale: 2.0,
                  boundaryMargin: const EdgeInsets.all(400),
                  constrained: false,
                  onInteractionUpdate: (details) {
                    // Update viewport on pan/zoom
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _updateViewport();
                      }
                    });
                  },
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
                          // Base map image with caching (WebP)
                          RepaintBoundary(
                            child: Image.asset(
                              'assets/map/base.webp',
                              fit: BoxFit.contain,
                              width: _mapWidth,
                              height: _mapHeight,
                              filterQuality: FilterQuality.medium,
                              cacheWidth: (_mapWidth * 0.8).toInt(), // Reduce memory usage
                              cacheHeight: (_mapHeight * 0.8).toInt(),
                            ),
                          ),
                          // Captured background layer
                          if (_showCapturedBackground)
                            RepaintBoundary(
                              child: Opacity(
                                opacity: _showCapturedBackground ? 0.7 : 0.0,
                                child: Image.asset(
                                  'assets/map/captured_background.webp', // 캡처한 배경 이미지 파일
                                  fit: BoxFit.contain,
                                  width: _mapWidth,
                                  height: _mapHeight,
                                  filterQuality: FilterQuality.medium,
                                  cacheWidth: (_mapWidth * 0.8).toInt(),
                                  cacheHeight: (_mapHeight * 0.8).toInt(),
                                  errorBuilder: (context, error, stackTrace) {
                                    // 파일이 없을 경우 빈 컨테이너 반환
                                    return Container();
                                  },
                                ),
                              ),
                            ),
                          // Terrain layer with lazy loading
                          if (_showTerrain)
                            RepaintBoundary(
                              child: Opacity(
                                opacity: _showTerrain ? 1.0 : 0.0,
                                child: Image.asset(
                                  'assets/map/mount.webp',
                                  fit: BoxFit.contain,
                                  width: _mapWidth,
                                  height: _mapHeight,
                                  filterQuality: FilterQuality.medium,
                                  cacheWidth: (_mapWidth * 0.8).toInt(),
                                  cacheHeight: (_mapHeight * 0.8).toInt(),
                                ),
                              ),
                            ),

                          // 동 지역별 비활성화 (전체 지역을 회색으로 표시)
                          // _showDisableDongAreas가 true이고 전체가 선택된 경우에만 표시
                          if (_showDisableDongAreas)
                            RepaintBoundary(
                              child: Opacity(
                                opacity: _showDisableDongAreas ? 1.0 : 0.0,
                                child: Image.asset(
                                  'assets/map/base_gray.webp',
                                  fit: BoxFit.contain,
                                  width: _mapWidth,
                                  height: _mapHeight,
                                  filterQuality: FilterQuality.medium,
                                  cacheWidth: (_mapWidth * 0.8).toInt(),
                                  cacheHeight: (_mapHeight * 0.8).toInt(),
                                ),
                              ),
                            ),

                          // 동 선택 지역 표시 (선택된 동의 지역만 표시)
                          // _showDongAreas가 true이고 특정 동이 선택된 경우에만 표시
                          if (_showDongAreas && _selectedDong != null)
                            RepaintBoundary(
                              child: Opacity(
                                opacity: 1.0,
                                child: Image.asset(
                                  _selectedDong!.areaAsset,
                                  fit: BoxFit.contain,
                                  width: _mapWidth,
                                  height: _mapHeight,
                                  filterQuality: FilterQuality.medium,
                                  cacheWidth: (_mapWidth * 0.8).toInt(),
                                  cacheHeight: (_mapHeight * 0.8).toInt(),
                                ),
                              ),
                            ),


                          // Dong areas
                          //..._buildDongAreas(),
                          // Dong name layer replaced by dong tags
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
        //_buildEnhancedLegend(),
        // Dong selection panel
        _buildDongSelectionPanel(),
        // Touch feedback overlay
        _buildTouchFeedback(),
      ],
    );
  }

  void _jumpToRect(Rect rect) {
    final context = interactiveViewerKey.currentContext;
    if (context == null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final widgetSize = renderBox.size;

    final scale = min(widgetSize.width / rect.width, widgetSize.height / rect.height) * 0.55;
    final dx = (widgetSize.width - rect.width * scale) / 2 - rect.left * scale;
    final dy = (widgetSize.height - rect.height * scale) / 2 - rect.top * scale;

    final endMatrix = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);

    // Directly set the transformation without animation
    _transformationController.value = endMatrix;
  }

  void _handleTapUp(TapUpDetails details) {
    _startAutoResetTimer();
    final position = _transformationController.toScene(details.localPosition);
    
    // Check if tapping on a merchant
    final tappedMerchant = _findMerchantAtPosition(position);
    if (tappedMerchant != null) {
      _handleMerchantTap(tappedMerchant);
    }
  }

  void _handleDoubleTap() {
    _startAutoResetTimer();
    // Reset zoom to fit entire map
    _zoomToFitEntireMap();
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
      // 마커 직접 클릭 시에도 해당 상인회를 하이라이트
      setState(() {
        _lastSelectedMerchant = merchant;
      });
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

  // void _showDongMerchantDialog(Dong dong) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => DongMerchantDialog(
  //       dongName: dong.name,
  //       dongColor: dong.color,
  //     ),
  //   );
  // }

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
            _jumpToMerchant(merchant);
          },
          child: const Text('위치로 이동', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }


  List<Widget> _buildMerchantNumbers() {
    if (!_showNumber) return [];

    List<Widget> widgets = [];

    for (var dong in DongList.all) {
      if (_selectedDong != null && dong != _selectedDong) continue;
      
      for (var merchant in dong.merchantList) {
        // Use rendered merchants set for viewport optimization
        if (!_renderedMerchants.contains(merchant.id)) continue;
        
        final isSelected = _selectedMerchants.contains(merchant.id);
        final isHighlighted = _isSelectionMode && isSelected;
        final isLastSelected = _lastSelectedMerchant?.id == merchant.id;
        
        widgets.add(
          Positioned(
            left: merchant.x,
            top: merchant.y,
            child: RepaintBoundary(
              key: ValueKey('merchant_${merchant.id}'),
              child: _buildMerchantMarker(merchant, dong, isHighlighted, isLastSelected),
            ),
          ),
        );
      }
    }
    
    return widgets;
  }

  Widget _buildMerchantMarker(Merchant merchant, Dong dong, bool isHighlighted, bool isLastSelected) {
    final scale = isHighlighted ? 1.1 : 1.0;
        
        // 마지막 선택된 상인회는 노란색 배경, 일반 선택 모드에서는 오렌지색 테두리
        Color backgroundColor = Colors.white;
        Color borderColor = dong.color;
        double borderWidth = 3;
        
        if (isLastSelected) {
          backgroundColor = Colors.yellow.shade300;
          borderColor = Colors.orange;
          borderWidth = 4;
        } else if (isHighlighted) {
          borderColor = Colors.orange;
          borderWidth = 4;
        }
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: _touchTargetSize,
            height: _touchTargetSize,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
              borderRadius: BorderRadius.circular(_touchTargetSize / 2),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
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
  }

  List<Widget> _buildDongAreas() {
    if (!_showDongAreas) return [];
    
    List<Widget> widgets = [];
    
    for (var dong in DongList.all) {
      if (_selectedDong != null && dong != _selectedDong) continue;
      
      widgets.add(
        Positioned.fromRect(
          rect: dong.area,
          child: Opacity(
            opacity: dong.isShow ? 0.3 : 0.0,
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
    if (!_showDongName) return [];
    
    List<Widget> widgets = [];
    
    for (var dong in DongList.all) {
      if (_selectedDong != null && dong != _selectedDong) continue;
      
      widgets.add(
        Positioned.fromRect(
          rect: dong.dongTagArea,
          child: RepaintBoundary(
            key: ValueKey('dong_tag_${dong.name}'),
            child: Opacity(
              opacity: 1.0,
              child: GestureDetector(
                onTap: () {
                  //_showDongMerchantDialog(dong);
                  _startAutoResetTimer();
                },
                child: Container(
                  width: dong.dongTagArea.width,
                  height: 52,
                  alignment: Alignment.topLeft,
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //   border: Border.all(
                  //     color: Colors.red,
                  //     width: 2
                  //   ),
                  // ),
                  child: SpeechBalloon(
                    width: dong.dongTagArea.width,
                    height: 52,
                    borderRadius: 12,
                    borderWidth: 8,
                    nipLocation: NipLocation.bottom,
                    nipHeight: 18,
                    color: Colors.white,
                    borderColor: dong.color,
                    child: Center(
                      child: Text(
                        dong.name,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                // child: Image.asset(
                //   dong.dongTagAsset,
                //   fit: BoxFit.contain,
                //   filterQuality: FilterQuality.medium,
                //   cacheWidth: dong.dongTagArea.width.toInt(),
                //   cacheHeight: dong.dongTagArea.height.toInt(),
                // ),
              ),
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
                  Expanded(
                    child: _buildEnhancedToggle(
                      title: '캡처배경',
                      icon: Icons.wallpaper,
                      value: _showCapturedBackground,
                      onChanged: (value) {
                        setState(() {
                          _showCapturedBackground = value;
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
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? Colors.black.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? Colors.black : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: value ? Colors.black : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: value ? Colors.black : Colors.grey.shade700,
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
      left: widget.isMapLeft ? 24 : null,
      right: widget.isMapLeft ? null : 24,

      child: GlassContainer(
        height: 1000,
        width: 140,
        padding: EdgeInsets.only(top: 6),

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
        blur: 10,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: DongList.all.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildDongSelectionItem(null, '전체');
                  }
                  final dong = DongList.all[index - 1];
                  return _buildDongSelectionItem(dong, dong.name);
                },
              ),
            ),
            Container(
              height: 160,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEnhancedToggle(
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
                  _buildEnhancedToggle(
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
                  _buildEnhancedToggle(
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
                  // _buildEnhancedToggle(
                  //   title: '선택구역',
                  //   icon: Icons.crop_free,
                  //   value: _showDongAreas,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _showDongAreas = value;
                  //     });
                  //     _startAutoResetTimer();
                  //   },
                  // ),
                  // _buildEnhancedToggle(
                  //   title: '비활성화',
                  //   icon: Icons.blur_on,
                  //   value: _showDisableDongAreas,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _showDisableDongAreas = value;
                  //     });
                  //     _startAutoResetTimer();
                  //   },
                  // ),
                  // _buildEnhancedToggle(
                  //   title: '동태그',
                  //   icon: Icons.label,
                  //   value: _showDongTags,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _showDongTags = value;
                  //     });
                  //     _startAutoResetTimer();
                  //   },
                  // ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildDongSelectionItem(Dong? dong, String title) {
    final isSelected = _selectedDong == dong;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              dong != null
                  ? Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: dong.color,
                  shape: BoxShape.circle,
                ),
              ) : const Icon(Icons.select_all, size: 16),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () {
          setState(() {
            _selectedDong = dong;
            _selectedMerchants.clear();
            
            // 자동 상태 관리
            if (dong == null) {
              // "전체" 선택 시
              _showDisableDongAreas = false;
              _showDongAreas = false;
            } else {
              // 특정 동 선택 시
              _showDisableDongAreas = true;
              _showDongAreas = true;
            }
          });
          
          // 대시보드에 동 선택 전달
          widget.onDongSelected?.call(dong);
          
          _calculateVisibleMerchants();
          
          if (dong != null) {
            _jumpToRect(dong.area);
            // 동을 선택하면 해당 동별 가맹점 현황 다이얼로그 표시
            //_showDongMerchantDialog(dong);
          } else {
            // 전체를 선택하면 전체 지도가 보이게 축소한다.
            _zoomToFitEntireMap();
          }
          
          _startAutoResetTimer();
        },
      ),
    );
  }

  Widget _buildTouchFeedback() {
    return Positioned(
      top: 24,
      left: 24,
      child: Opacity(
        opacity: _isSelectionMode ? 1.0 : 0.0,
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
  }

  void selectDong(Dong? dong) {
    setState(() {
      _selectedDong = dong;
      _selectedMerchants.clear();
      _calculateVisibleMerchants();
      
      // 자동 상태 관리
      if (dong == null) {
        // "전체" 선택 시
        _showDisableDongAreas = false;
        _showDongAreas = false;
      } else {
        // 특정 동 선택 시
        _showDisableDongAreas = true;
        _showDongAreas = true;
      }
    });
    
    if (dong != null) {
      _jumpToRect(dong.area);
      // 동을 선택하면 해당 동별 가맹점 현황 다이얼로그 표시
      //_showDongMerchantDialog(dong);
    } else {
      _zoomToFitEntireMap();
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