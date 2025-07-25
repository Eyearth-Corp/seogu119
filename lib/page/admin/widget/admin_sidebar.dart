import 'package:flutter/material.dart';
import '../admin_dashboard_page.dart';

class AdminSidebar extends StatelessWidget {
  final AdminPageType currentPage;
  final bool isCollapsed;
  final Function(AdminPageType) onPageChanged;
  final VoidCallback onToggleCollapse;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.currentPage,
    required this.isCollapsed,
    required this.onPageChanged,
    required this.onToggleCollapse,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final width = isCollapsed ? 80.0 : 280.0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      decoration: const BoxDecoration(
        color: Color(0xFF1F2937),
        border: Border(
          right: BorderSide(color: Color(0xFF374151), width: 1),
        ),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '서구 골목 관리자',
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: onToggleCollapse,
                  icon: Icon(
                    isCollapsed ? Icons.menu_open : Icons.menu,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: Color(0xFF374151), height: 1),
          
          // 메뉴 항목들
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard,
                  title: '대시보드',
                  pageType: AdminPageType.dashboard,
                ),
                _buildMenuItem(
                  icon: Icons.store,
                  title: '가맹점 관리',
                  pageType: AdminPageType.merchants,
                ),
                _buildMenuItem(
                  icon: Icons.data_usage,
                  title: '데이터 관리',
                  pageType: AdminPageType.data,
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: '설정',
                  pageType: AdminPageType.settings,
                ),
              ],
            ),
          ),
          
          // 하단 메뉴
          const Divider(color: Color(0xFF374151), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildLogoutButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required AdminPageType pageType,
  }) {
    final isSelected = currentPage == pageType;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onPageChanged(pageType),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurple.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected 
                  ? Border.all(color: Colors.deepPurple.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.deepPurple.shade200 : Colors.grey.shade400,
                  size: 20,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        color: isSelected ? Colors.white : Colors.grey.shade400,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onLogout,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                Icons.logout,
                color: Colors.red.shade300,
                size: 20,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Text(
                  '로그아웃',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    color: Colors.red.shade300,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}