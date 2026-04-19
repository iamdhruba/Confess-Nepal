import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../features/confession/providers/confession_provider.dart';
import '../features/ask_nepal/providers/ask_nepal_provider.dart';
import '../features/confession/screens/home_screen.dart';
import '../features/confession/screens/trending_screen.dart';
import '../features/confession/screens/create_confession_screen.dart';
import '../features/ask_nepal/screens/ask_nepal_screen.dart';
import '../features/profile/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final PageController _pageController;

  final _screens = const [
    HomeScreen(),
    TrendingScreen(),
    AskNepalScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ProfileProvider.init() already handles auth — just load data
      context.read<ConfessionProvider>().loadFeed();
      context.read<ConfessionProvider>().loadConfessionOfDay();
      context.read<ConfessionProvider>().loadTrending();
      context.read<ConfessionProvider>().loadStats();
      context.read<AskNepalProvider>().loadQuestions();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      _openCreateScreen();
      return;
    }
    final pageIndex = index > 2 ? index - 1 : index;
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(pageIndex);
  }

  void _openCreateScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CreateConfessionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }


  Widget _buildBottomNav(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 70 + MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.backgroundDeep.withValues(alpha: 0.92)
                : AppColors.lightSurface.withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.backgroundElevated.withValues(alpha: 0.3)
                    : AppColors.lightBorder.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: _currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              _NavItem(
                icon: Icons.local_fire_department_rounded,
                label: 'Trending',
                isSelected: _currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
              // Center Action (aligned withothers)
              GestureDetector(
                onTap: _openCreateScreen,
                child: SizedBox(
                  width: 60,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4D94), Color(0xFFFFA057)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF4D94).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Post',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textTertiary
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.help_outline_rounded,
                label: 'Ask',
                isSelected: _currentIndex == 3,
                onTap: () => _onTabTapped(3),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: _currentIndex == 4,
                onTap: () => _onTabTapped(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? AppColors.primary
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textTertiary
                        : AppColors.textTertiaryLight),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primary
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textTertiary
                        : AppColors.textTertiaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
