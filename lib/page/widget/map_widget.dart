import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:speech_balloon/speech_balloon.dart';
import 'dart:math';
import 'dart:async';

// Import the Dong data
import '../data/dong_list.dart';

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

  // Loading state
  bool _isLoading = false;

  // Fixed map size
  final double _mapWidth = 2403;
  final double _mapHeight = 2900;

  // Touch optimization for 84-inch display
  static const double _touchTargetSize = 46.0;
  static const double _fontSize = 16.0;
  static const Duration _autoResetDuration = Duration(minutes: 5);

  final GlobalKey interactiveViewerKey = GlobalKey(debugLabel: 'map_interactive_viewer');


  @override
  void initState() {
    super.initState();
    
    _transformationController.value = Matrix4.identity();
    
    // 컨트롤러에 네비게이션 함수 설정
    widget.controller?._setNavigateFunction(_jumpToMerchant);
    
    _startAutoResetTimer();
    
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

  void _updateViewport() {
    // Update viewport calculation for optimized rendering
    // This method can be implemented if viewport optimization is needed
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


  /// 전체 지도가 화면에 맞도록 줌과 위치를 초기화합니다.
  /// InteractiveViewer의 크기에 맞춰 지도 전체가 보이도록 자동 조절합니다.
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

  /// 특정 상인회로 즉시 이동합니다.
  /// [_merchant]: 이동할 목표 상인회 객체
  /// 해당 상인회가 속한 동을 선택하고 마지막 선택된 상인회로 설정합니다.
  void _jumpToMerchant(Merchant _merchant) {
    for (var dong in DongList.all) {
      for (var merchant in dong.merchantList) {
        if (merchant.id == _merchant.id) {
          selectDong(dong);
          _lastSelectedMerchant = merchant;
          break;
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
                        ..._buildDongTags(),
                        ..._buildMerchantNumbers(),
                      ],
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
        // Dong selection panel
        _buildDongSelectionPanel(),
        // Touch feedback overlay
        _buildTouchFeedback(),
      ],
    );
  }

  /// 지정된 사각형 영역으로 즉시 점프하여 화면에 맞춥니다.
  /// [rect]: 이동할 목표 사각형 영역
  /// 적절한 스케일과 위치를 계산하여 해당 영역이 화면 중앙에 오도록 조정합니다.
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

  /// 지도 위에 상인회 번호 마커들을 생성합니다.
  /// 현재 선택된 동과 설정에 따라 표시할 상인회들을 필터링하고,
  /// 각 상인회의 위치에 번호와 선택 상태를 표시하는 위젯을 생성합니다.
  /// 
  /// Returns: 상인회 마커 위젯들의 리스트
  List<Widget> _buildMerchantNumbers() {
    if (!_showNumber) return [];

    List<Widget> widgets = [];

    for (var dong in DongList.all) {
      if (_selectedDong != null && dong != _selectedDong) continue;
      
      for (var merchant in dong.merchantList) {
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
                  selectDong(dong);
                },
                child: Container(
                  width: dong.dongTagArea.width,
                  height: 52,
                  alignment: Alignment.topLeft,
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
              ),
            ),
          ),
        ),
      );
    }
    
    return widgets;
  }

  Widget _buildDongSelectionPanel() {
    final lifeAreaGroups = _groupDongsByLifeArea();
    
    return Positioned(
      top: 24,
      left: widget.isMapLeft ? 24 : null,
      right: widget.isMapLeft ? null : 24,

      child: GlassContainer(
        height: 832,
        width: 160,
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
              child: ListView(
                children: [
                  _buildDongSelectionItem(null, '전체'),
                  const Divider(height: 1, color: Colors.white30),
                  ...lifeAreaGroups.entries.map((entry) =>
                    _buildLifeAreaGroup(entry.key, entry.value)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<Dong>> _groupDongsByLifeArea() {
    final Map<String, List<Dong>> groups = {};
    
    for (final dong in DongList.all) {
      if (!groups.containsKey(dong.lifeArea)) {
        groups[dong.lifeArea] = [];
      }
      groups[dong.lifeArea]!.add(dong);
    }
    
    // Sort by a specific order for life areas
    final orderedKeys = [
      '함께하는 생활권',
      '성장하는 생활권', 
      '살기좋은 생활권',
      '행복한 생활권'
    ];
    
    final Map<String, List<Dong>> orderedGroups = {};
    for (final key in orderedKeys) {
      if (groups.containsKey(key)) {
        orderedGroups[key] = groups[key]!;
      }
    }
    
    return orderedGroups;
  }

  Widget _buildLifeAreaGroup(String lifeArea, List<Dong> dongs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            lifeArea,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5377ca),
            ),
          ),
        ),
        ...dongs.map((dong) => _buildDongSelectionItem(dong, dong.name)),
        const SizedBox(height: 4),
      ],
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
          selectDong(dong);
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

  /// 동(구역)을 선택하거나 전체 보기로 전환합니다.
  /// [dong]: 선택할 동 객체. null이면 전체 보기로 전환됩니다.
  /// 
  /// 주요 기능:
  /// - 선택된 동 상태 업데이트
  /// - 상인회 선택 상태 초기화
  /// - 레이어 가시성 조정 (동 영역, 비활성화 영역)
  /// - 대시보드에 선택 상태 알림
  /// - 해당 동 영역으로 지도 이동 또는 전체 지도 보기
  /// - 자동 리셋 타이머 재시작
  void selectDong(Dong? dong) {
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

    if (dong != null) {
      _jumpToRect(dong.area);
      // 동을 선택하면 해당 동별 가맹점 현황 다이얼로그 표시
    } else {
      // 전체를 선택하면 전체 지도가 보이게 축소한다.
      _zoomToFitEntireMap();
    }

    _startAutoResetTimer();
  }


}