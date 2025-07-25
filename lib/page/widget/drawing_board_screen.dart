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
  double _strokeWidth = 4.0;
  bool _isLoading = true;
  bool _showBackground = true;

  @override
  void initState() {
    super.initState();
    _captureBackground();
  }

  @override
  void dispose() {
    _backgroundImage = null; // 메모리 해제
    super.dispose();
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
                child: Padding(
                  padding: EdgeInsets.only(left: 80, right: 80, top: 100),
                  child: Image.memory(
                    _backgroundImage!,
                    fit: BoxFit.contain,
                  ),
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

            // 좌측 패널
            Positioned(
              left: 0,
              top: 120,
              bottom: 0,
              child: _buildTool(),
            ),

            // 우축 패널
            Positioned(
              right: 0,
              top: 120,
              bottom: 0,
              child: _buildTool(),
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildTool() {
    return Container(
      alignment: Alignment.center,
      child: Container(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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

            const SizedBox(height: 16),

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
            Text('배경 ${_showBackground ? '숨기기' : '보이기'}',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // 전체 지우기
            _buildToolButton(
              Icons.clear_all,
              '전체 지우기',
              Colors.orange,
              _lines.isNotEmpty ? _clearAll : null,
            ),
            Text('전체 지우기',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),
            Text(
              '색상',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildColorPalette(),
            const SizedBox(height: 24),
            Text(
              '굵기',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ..._buildStrokeWidth(),
            const SizedBox(height: 32),
            // 닫기 버튼
            _buildToolButton(
              Icons.close,
              '닫기',
              Colors.red,
                  () => Navigator.of(context).pop(),
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
            width: 32,
            height: 32,
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
      Colors.white,
      Colors.black,
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


  List<Widget> _buildStrokeWidth() {
    final strokeWidths = [4.0, 8.0, 12.0];
    return strokeWidths.map((strokeWidth) {
      final isSelected = _strokeWidth == strokeWidth;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _strokeWidth = strokeWidth;
            });
          },
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Container(
              color: isSelected?Colors.yellow:Colors.white,
              width: 32,
              height: strokeWidth,
            ),
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