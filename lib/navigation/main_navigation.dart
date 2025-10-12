import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/screens.dart';
import '../widgets/animated_page_switcher.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MainScreen(),
    const CalendarScreen(),
    const GiftsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Добавьте это
      body: AnimatedPageSwitcher(
        currentIndex: _currentIndex,
        duration: const Duration(milliseconds: 300),
        children: _screens,
      ),
      extendBody: true, // Добавьте это для прозрачности под навигацией
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 28, right: 28, bottom: 46),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem('lib/assets/icons/main.svg', 0),
              _buildNavItem('lib/assets/icons/calendar.svg', 1),
              _buildNavItem('lib/assets/icons/gift.svg', 2),
              _buildNavItem('lib/assets/icons/settings.svg', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String iconPath, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFE5E5EA),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          iconPath,
          width: 28,
          height: 28,
          colorFilter: ColorFilter.mode(
            isSelected ? Colors.black : Colors.grey[600]!,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
