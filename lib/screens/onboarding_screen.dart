import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import '../models/team_model.dart';
import '../widgets/particle_background.dart';
import '../widgets/team_selection_card.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // State for selections
  final Set<String> _selectedClubIds = {};
  final Set<String> _selectedNationalTeamIds = {};

  // Data
  List<Team> _clubs = [];
  List<Team> _nationalTeams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    // Simulate API fetch delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _clubs = List.generate(
          12,
          (index) => Team(
            id: 'c_$index',
            name: 'Classic Club $index',
            logoUrl:
                'https://upload.wikimedia.org/wikipedia/en/thumb/f/fa/Al_Hilal_SFC_Logo.svg/1200px-Al_Hilal_SFC_Logo.svg.png', // Placeholder
          ),
        );

        _nationalTeams = List.generate(
          8,
          (index) => Team(
            id: 'n_$index',
            name: 'National Team $index',
            logoUrl:
                'https://upload.wikimedia.org/wikipedia/en/thumb/8/87/Al_Nassr_Saudi_Club_Logo.svg/1200px-Al_Nassr_Saudi_Club_Logo.svg.png', // Placeholder
          ),
        );

        _isLoading = false;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    // Save selected teams if needed

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> _requestNotificationPermission() async {
    await Permission.notification.request();
    _finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF000000), Color(0xFF0D0D0D)],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: ParticleBackground()),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Progress Indicator
                      Row(
                        children: List.generate(3, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? const Color(0xFF16C47F)
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      // Skip Button
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          "تخطي",
                          style: GoogleFonts.cairo(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable swipe to force flow? Or allow it. User prompt said smooth animation but usually multi-step forms block swipe until valid or uses buttons. Let's allow physics but keep buttons primary.
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      _buildStep(
                        title: "اختر فرقك المفضلة",
                        subtitle: "لنصلك بأهم المباريات فورًا",
                        items: _clubs,
                        selectedIds: _selectedClubIds,
                      ),
                      _buildStep(
                        title: "اختر المنتخبات التي تتابعها",
                        subtitle: "تابع أخبار ونتائج منتخباتك",
                        items: _nationalTeams,
                        selectedIds: _selectedNationalTeamIds,
                      ),
                      _buildNotificationStep(),
                    ],
                  ),
                ),

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == 2) {
                          _requestNotificationPermission();
                        } else {
                          _nextPage();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16C47F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: const Color(0xFF16C47F).withOpacity(0.4),
                      ),
                      child: Text(
                        _currentPage == 2 ? "تفعيل الإشعارات" : "التالي",
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_currentPage == 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        "لاحقًا",
                        style: GoogleFonts.cairo(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required List<Team> items,
    required Set<String> selectedIds,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _isLoading
              ? _buildShimmerGrid()
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final team = items[index];
                    final isSelected = selectedIds.contains(team.id);
                    return TeamSelectionCard(
                      team: team,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedIds.remove(team.id);
                          } else {
                            selectedIds.add(team.id);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNotificationStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFF16C47F).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_active,
            size: 80,
            color: const Color(0xFF16C47F).withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          "لا تفوت أي مباراة",
          style: GoogleFonts.cairo(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            "سنرسل لك إشعارات قبل بداية مباريات فرقك المفضلة لتكون في قلب الحدث دائمًا.",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[900]!,
          highlightColor: Colors.grey[800]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
