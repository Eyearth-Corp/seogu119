
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:seogu119/page/data/dong_list.dart';

class DongSelectionPanel extends StatelessWidget {
  final Dong? selectedDong;
  final Function(Dong?) onDongSelected;

  const DongSelectionPanel({
    super.key,
    required this.selectedDong,
    required this.onDongSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24,
      right: 24,
      child: GlassContainer(
        height: 400,
        width: 300,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.40),
            Colors.white.withOpacity(0.10)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.60),
            Colors.white.withOpacity(0.10)
          ],
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
    final isSelected = selectedDong == dong;

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
        onTap: () => onDongSelected(dong),
      ),
    );
  }
}
