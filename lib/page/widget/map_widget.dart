import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';

// Import the Dong data
import '../data/dong_list.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with SingleTickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _matrixAnimation;

  // State for layer visibility
  bool _showTerrain = true;
  bool _showNumber = true;
  bool _showDongName = true;

  // State for Dong selection
  Dong? _selectedDong;

  // Fixed map size
  final double _mapWidth = 2403;
  final double _mapHeight = 2900;


  // 변경 후
  final GlobalKey interactiveViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _transformationController.value = Matrix4.identity();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.red,
                        Colors.blue
                      ]
                  )
              )
          ),
          InteractiveViewer(
            key: interactiveViewerKey,
            transformationController: _transformationController,
            minScale: 0.1, // Use 1.0 to prevent initial scaling down
            maxScale: 1.0,
            boundaryMargin: EdgeInsets.all(400),
            constrained: false,
            child: GestureDetector(
              onTapUp: (details) {
                final position =
                _transformationController.toScene(details.localPosition);
                _copyPositionToClipboard(position);
              },
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
                    ),

                    //Terrain layer
                    Visibility(
                      visible: _showTerrain,
                      child: Image.asset(
                        'assets/map/mount.png',
                        fit: BoxFit.contain,
                        width: _mapWidth,
                        height: _mapHeight,
                      ),
                    ),
                    // Dong name layer
                    Visibility(
                      visible: _showDongName,
                      child: Image.asset(
                        'assets/map/dong_name.png',
                        fit: BoxFit.contain,
                        width: _mapWidth,
                        height: _mapHeight,
                      ),
                    ),
                    // Dynamically rendered merchant numbers
                    ..._buildMerchantNumbers(),
                  ],
                ),
              ),
            ),
          ),
          // Legend at the bottom
          _buildLegend(),
        ],
      ),
    );
  }

  void _animateToRect(Rect rect) {
    // InteractiveViewer의 BuildContext를 가져옵니다.
    final context = interactiveViewerKey.currentContext;
    if (context == null) return;

    // BuildContext에서 RenderBox를 찾아 위젯의 크기를 가져옵니다.
    final renderBox = context.findRenderObject() as RenderBox;
    final widgetSize = renderBox.size;

    // 확대/축소 비율을 계산합니다.
    // 위젯의 너비와 높이에 맞춰 Rect가 꽉 차도록 scale 값을 계산합니다.
    final scale = min(widgetSize.width / rect.width, widgetSize.height / rect.height) * 0.7;

    // 화면 중앙에 위치시키기 위한 offset을 계산합니다.
    final dx = (widgetSize.width - rect.width * scale) / 2 - rect.left * scale;
    final dy = (widgetSize.height - rect.height * scale) / 2 - rect.top * scale;

    // 최종 변환 Matrix를 생성합니다.
    final endMatrix = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);

    // 애니메이션을 설정하고 시작합니다.
    _matrixAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.addListener(() {
      if (_matrixAnimation != null) {
        _transformationController.value = _matrixAnimation!.value;
      }
    });

    _animationController.forward(from: 0);
  }


  /// Builds the list of merchant number widgets to display on the map.
  List<Widget> _buildMerchantNumbers() {

    List<Widget> res = [];

    if (!_showNumber) return [];

    Color borderColor = Colors.transparent;

    List<Merchant> merchantsToShow = [];
    if (_selectedDong == null) {
      // If "All" is selected, get merchants from all dongs.
      for (var dong in DongList.all) {
        borderColor = dong.color;
        for(var merchant in dong.merchantList) {
          res.add(
              Positioned(
                left: merchant.x,
                top: merchant.y,
                child: Tooltip(
                  message: merchant.name,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: borderColor, width: 3),
                      borderRadius: const BorderRadius.all(Radius.circular(22)),
                    ),
                    child: Center(
                      child: Text(
                        merchant.id.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              )
          );
        }
      }
    } else {
      // Otherwise, get merchants from the selected dong only.
      merchantsToShow = _selectedDong!.merchantList;
    }
    return res;
  }

  /// Builds the legend widget at the bottom of the map.
  Widget _buildLegend() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendCheckbox(
                title: '지형',
                value: _showTerrain,
                onChanged: (bool? value) {
                  setState(() {
                    _showTerrain = value ?? false;
                  });
                },
              ),
              _buildLegendCheckbox(
                title: '번호',
                value: _showNumber,
                onChanged: (bool? value) {
                  setState(() {
                    _showNumber = value ?? false;
                  });
                },
              ),
              _buildLegendCheckbox(
                title: '동이름',
                value: _showDongName,
                onChanged: (bool? value) {
                  setState(() {
                    _showDongName = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget to create a checkbox with a label for the legend.
  Widget _buildLegendCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Text(title),
      ],
    );
  }

  /// Copies the coordinates of a tapped position to the clipboard.
  void _copyPositionToClipboard(Offset position) {
    final int x = position.dx.clamp(0, _mapWidth).round();
    final int y = position.dy.clamp(0, _mapHeight).round();

    final String textToCopy = 'X: $x, Y: $y';
    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      Fluttertoast.showToast(
        msg: "좌표 복사됨: $textToCopy",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }
}
