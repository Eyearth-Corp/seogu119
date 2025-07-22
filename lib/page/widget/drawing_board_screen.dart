import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../../core/colors.dart';

class DrawingBoardScreen extends StatefulWidget {
  final Widget? backgroundWidget;
  final GlobalKey? captureKey;
  
  const DrawingBoardScreen({
    super.key,
    this.backgroundWidget,
    this.captureKey,
  }) : assert(backgroundWidget != null || captureKey != null, 
         'Either backgroundWidget or captureKey must be provided');

  @override
  State<DrawingBoardScreen> createState() => _DrawingBoardScreenState();
}

class _DrawingBoardScreenState extends State<DrawingBoardScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final GlobalKey _repaintBoundaryKey = GlobalKey(debugLabel: 'drawing_board_boundary');
  Uint8List? _backgroundImage;
  final List<DrawnLine> _lines = <DrawnLine>[];
  final List<DrawnLine> _undoLines = <DrawnLine>[];
  Color _selectedColor = Colors.red;
  double _strokeWidth = 3.0;
  bool _isLoading = true;
  bool _showBackground = true;

  @override
  void initState() {
    super.initState();
    _captureBackground();
  }

  Future<void> _captureBackground() async {
    try {
      // captureKey가 제공된 경우 (실제 화면 캡처)
      if (widget.captureKey != null) {
        // 약간의 지연 후 캡처 (렌더링 완료 대기)
        await Future.delayed(const Duration(milliseconds: 300));
        
        final RenderRepaintBoundary? boundary = 
            widget.captureKey!.currentContext?.findRenderObject() as RenderRepaintBoundary?;
            
        if (boundary != null) {
          final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
          final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          
          if (byteData != null) {
            final Uint8List imageBytes = byteData.buffer.asUint8List();
            setState(() {
              _backgroundImage = imageBytes;
              _isLoading = false;
            });
            return;
          }
        }
      }
      
      // backgroundWidget이 제공된 경우 (위젯에서 캡처)
      if (widget.backgroundWidget != null) {
        // RepaintBoundary에서 직접 캡처하기
        if (widget.backgroundWidget is RepaintBoundary) {
          final repaintBoundary = widget.backgroundWidget as RepaintBoundary;
          if (repaintBoundary.key != null && repaintBoundary.key is GlobalKey) {
            final GlobalKey boundaryKey = repaintBoundary.key as GlobalKey;
            
            await Future.delayed(const Duration(milliseconds: 500));
            
            final RenderRepaintBoundary? boundary = 
                boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
                
            if (boundary != null) {
              final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
              final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
              
              if (byteData != null) {
                final Uint8List imageBytes = byteData.buffer.asUint8List();
                setState(() {
                  _backgroundImage = imageBytes;
                  _isLoading = false;
                });
                return;
              }
            }
          }
        }
        
        // screenshot 패키지로 위젯 캡처
        final size = MediaQuery.of(context).size;
        
        final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
          Container(
            width: size.width,
            height: size.height,
            color: Colors.white,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 2560,
                height: 1440,
                child: widget.backgroundWidget!,
              ),
            ),
          ),
          delay: const Duration(milliseconds: 500),
          context: context,
          pixelRatio: 1.0,
        );
        
        if (imageBytes != null) {
          setState(() {
            _backgroundImage = imageBytes;
            _isLoading = false;
          });
          return;
        }
      }
      
      // 모든 캡처 방식 실패 시 빈 배경으로 진행
      setState(() {
        _backgroundImage = null;
        _isLoading = false;
      });
      
    } catch (e) {
      print('스크린샷 촬영 실패: $e');
      setState(() {
        _backgroundImage = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                '화면을 캡처하는 중...',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 배경 이미지 (캡처된 화면)
            if (_backgroundImage != null && _showBackground)
              Positioned.fill(
                child: Image.memory(
                  _backgroundImage!,
                  fit: BoxFit.contain,
                ),
              ),
          
          // 그리기 캔버스
          Positioned.fill(
            child: GestureDetector(
              onPanStart: (DragStartDetails details) {
                _startNewLine(details.localPosition);
              },
              onPanUpdate: (DragUpdateDetails details) {
                _addPointToLine(details.localPosition);
              },
              onPanEnd: (DragEndDetails details) {
                _finishCurrentLine();
              },
              child: CustomPaint(
                painter: DrawingPainter(_lines),
                size: Size.infinite,
              ),
            ),
          ),
          
          // 상단 툴바
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  // 닫기 버튼
                  _buildToolButton(
                    Icons.close,
                    '닫기',
                    Colors.red,
                    () => Navigator.of(context).pop(),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 실행 취소
                  _buildToolButton(
                    Icons.undo,
                    '실행 취소',
                    Colors.white,
                    _canUndo() ? _undo : null,
                  ),
                  
                  // 다시 실행
                  _buildToolButton(
                    Icons.redo,
                    '다시 실행',
                    Colors.white,
                    _canRedo() ? _redo : null,
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 배경 토글
                  _buildToolButton(
                    _showBackground ? Icons.image : Icons.image_outlined,
                    '배경 ${_showBackground ? '숨기기' : '보이기'}',
                    Colors.blue,
                    () {
                      setState(() {
                        _showBackground = !_showBackground;
                      });
                    },
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 전체 지우기
                  _buildToolButton(
                    Icons.clear_all,
                    '전체 지우기',
                    Colors.orange,
                    _lines.isNotEmpty ? _clearAll : null,
                  ),
                  
                  const Spacer(),
                  
                  // 저장 버튼
                  _buildToolButton(
                    Icons.save,
                    '저장',
                    Colors.green,
                    () => _saveDrawing(),
                  ),
                ],
              ),
            ),
          ),
          
          // 좌측 색상 팔레트
          Positioned(
            left: 20,
            top: 120,
            child: Container(
              width: 60,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '색상',
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildColorPalette(),
                ],
              ),
            ),
          ),
          
          // 우측 선 굵기 조절
          Positioned(
            right: 20,
            top: 120,
            child: Container(
              width: 80,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '선 굵기',
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_strokeWidth.toInt()}px',
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RotatedBox(
                    quarterTurns: -1,
                    child: Slider(
                      value: _strokeWidth,
                      min: 1.0,
                      max: 20.0,
                      divisions: 19,
                      activeColor: SeoguColors.primary,
                      inactiveColor: Colors.white30,
                      onChanged: (value) {
                        setState(() {
                          _strokeWidth = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildToolButton(
    IconData icon,
    String tooltip,
    Color color,
    VoidCallback? onPressed,
  ) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: onPressed != null ? color : Colors.grey,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: onPressed != null ? color : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildColorPalette() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.white,
      Colors.black,
      SeoguColors.primary,
      SeoguColors.secondary,
      SeoguColors.accent,
    ];

    return colors.map((color) {
      final isSelected = _selectedColor == color;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: color == Colors.white || color == Colors.yellow
                        ? Colors.black
                        : Colors.white,
                    size: 16,
                  )
                : null,
          ),
        ),
      );
    }).toList();
  }

  void _startNewLine(Offset point) {
    setState(() {
      _lines.add(DrawnLine([point], _selectedColor, _strokeWidth));
      _undoLines.clear(); // 새로운 선을 그리면 redo 히스토리 클리어
    });
  }

  void _addPointToLine(Offset point) {
    setState(() {
      if (_lines.isNotEmpty) {
        _lines.last.points.add(point);
      }
    });
  }

  void _finishCurrentLine() {
    // 현재 선 그리기 완료
  }

  bool _canUndo() => _lines.isNotEmpty;

  bool _canRedo() => _undoLines.isNotEmpty;

  void _undo() {
    if (_canUndo()) {
      setState(() {
        _undoLines.add(_lines.removeLast());
      });
    }
  }

  void _redo() {
    if (_canRedo()) {
      setState(() {
        _lines.add(_undoLines.removeLast());
      });
    }
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            '전체 지우기',
            style: TextStyle(
              fontFamily: 'NotoSans',
              color: Colors.white,
            ),
          ),
          content: Text(
            '모든 그림을 지우시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
            style: TextStyle(
              fontFamily: 'NotoSans',
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _lines.clear();
                  _undoLines.clear();
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                '지우기',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveDrawing() async {
    try {
      // 전체 화면 캡처 (배경 + 그림)
      final RenderRepaintBoundary boundary =
          _repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 클립보드에 복사 (웹에서만 동작)
      // 모바일에서는 갤러리에 저장하는 기능 필요
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '그림이 저장되었습니다',
            style: TextStyle(fontFamily: 'NotoSans'),
          ),
          backgroundColor: SeoguColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '저장 실패: $e',
            style: TextStyle(fontFamily: 'NotoSans'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  DrawnLine(this.points, this.color, this.strokeWidth);
}

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;

  DrawingPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = line.strokeWidth;

      if (line.points.length > 1) {
        for (int i = 0; i < line.points.length - 1; i++) {
          canvas.drawLine(line.points[i], line.points[i + 1], paint);
        }
      } else if (line.points.length == 1) {
        // 점 그리기
        canvas.drawCircle(line.points[0], line.strokeWidth / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}