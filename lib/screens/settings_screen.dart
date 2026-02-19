import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/settings_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access controller
    final settings = Provider.of<SettingsController>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "الإعدادات",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // 1. User Profile Card (Static for now)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2433) : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[800],
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "تمتع بالمزيد من الخدمات عند تسجيلك",
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2433),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF16C47F)),
                      ),
                      child: Text(
                        "دخول",
                        style: GoogleFonts.cairo(
                          color: const Color(0xFF16C47F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Notifications Section
          _buildSectionHeader("الإشعارات"),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: "عرض الإشعارات",
            trailing: Switch.adaptive(
              value: settings.notificationsEnabled,
              activeColor: const Color(0xFF16C47F),
              onChanged: (value) => settings.toggleMasterNotifications(value),
            ),
          ),
          if (settings.notificationsEnabled) ...[
            _buildSettingsTile(
              context,
              icon: Icons.sports_soccer,
              title: "إشعارات المباريات",
              trailing: Switch.adaptive(
                value: settings.matchNotifications,
                activeColor: const Color(0xFF16C47F),
                onChanged: (value) => settings.toggleMatchNotifications(value),
              ),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.newspaper,
              title: "إشعارات الأخبار",
              trailing: Switch.adaptive(
                value: settings.newsNotifications,
                activeColor: const Color(0xFF16C47F),
                onChanged: (value) => settings.toggleNewsNotifications(value),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 3. General Section
          _buildSectionHeader("عام"),
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: "اللغة",
            subtitle: settings.locale.languageCode == 'ar'
                ? "العربية"
                : "English",
            onTap: () => _showLanguageSheet(context, settings),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.sort,
            title: "ترتيب المباريات حسب",
            subtitle: _getSortLabel(settings.matchSortOrder),
            onTap: () => _showSortSheet(context, settings),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          // 4. Appearance Section
          _buildSectionHeader("المظهر"),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: "الوضع الليلي",
            trailing: Switch.adaptive(
              value: settings.themeMode == ThemeMode.dark,
              activeColor: const Color(0xFF16C47F),
              onChanged: (value) => settings.toggleTheme(value),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.text_fields,
            title: "حجم الخط",
            onTap: () => _showFontSizeSheet(context, settings),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          // 5. App Info Section
          _buildSectionHeader("التطبيق"),
          _buildSettingsTile(
            context,
            icon: Icons.share_outlined,
            title: "مشاركة التطبيق",
            onTap: () {
              Share.share(
                'حمل تطبيق شوف TV وتابع مباريات الدوري السعودي! https://shoof.tv',
              );
            },
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: "عن التطبيق",
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.verified_user_outlined,
            title: "سياسة الخصوصية",
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {},
          ),

          const SizedBox(height: 32),

          // Footer Socials
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(FontAwesomeIcons.instagram),
              const SizedBox(width: 20),
              _buildSocialButton(FontAwesomeIcons.twitter),
              const SizedBox(width: 20),
              _buildSocialButton(FontAwesomeIcons.facebook),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "الإصدار 1.0.0",
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 8),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF16C47F),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2433) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black26 : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white : Colors.black87,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
              )
            : null,
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2433),
        shape: BoxShape.circle,
      ),
      child: FaIcon(icon, color: Colors.white, size: 20),
    );
  }

  String _getSortLabel(String value) {
    switch (value) {
      case 'tournament':
        return 'البطولة';
      case 'time':
        return 'التوقيت';
      case 'important':
        return 'الهامة فقط';
      case 'favorite':
        return 'المفضلة فقط';
      default:
        return 'البطولة';
    }
  }

  // --- Bottom Sheets ---

  void _showLanguageSheet(BuildContext context, SettingsController settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0F1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "اختر اللغة",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionTile(
                context,
                "العربية",
                settings.locale.languageCode == 'ar',
                () {
                  settings.changeLanguage('ar');
                  Navigator.pop(context);
                },
              ),
              _buildOptionTile(
                context,
                "English",
                settings.locale.languageCode == 'en',
                () {
                  settings.changeLanguage('en');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortSheet(BuildContext context, SettingsController settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0F1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ترتيب المباريات حسب",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionTile(
                context,
                "البطولة",
                settings.matchSortOrder == 'tournament',
                () {
                  settings.setMatchSortOrder('tournament');
                  Navigator.pop(context);
                },
              ),
              _buildOptionTile(
                context,
                "التوقيت",
                settings.matchSortOrder == 'time',
                () {
                  settings.setMatchSortOrder('time');
                  Navigator.pop(context);
                },
              ),
              _buildOptionTile(
                context,
                "الهامة فقط",
                settings.matchSortOrder == 'important',
                () {
                  settings.setMatchSortOrder('important');
                  Navigator.pop(context);
                },
              ),
              _buildOptionTile(
                context,
                "المفضلة فقط",
                settings.matchSortOrder == 'favorite',
                () {
                  settings.setMatchSortOrder('favorite');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFontSizeSheet(BuildContext context, SettingsController settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0F1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "حجم الخط",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Details Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "واجهة التطبيق",
                        style: GoogleFonts.cairo(color: Colors.grey),
                      ),
                      Text(
                        "${(settings.fontSizeDetails * 100).toInt()}%",
                        style: GoogleFonts.cairo(color: Colors.white),
                      ),
                    ],
                  ),
                  Slider(
                    value: settings.fontSizeDetails,
                    min: 0.8,
                    max: 1.2,
                    divisions: 4,
                    activeColor: const Color(0xFF16C47F),
                    onChanged: (val) => settings.setFontSizeDetails(val),
                  ),
                  const SizedBox(height: 16),
                  // News Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "الأخبار",
                        style: GoogleFonts.cairo(color: Colors.grey),
                      ),
                      Text(
                        "${(settings.fontSizeNews * 100).toInt()}%",
                        style: GoogleFonts.cairo(color: Colors.white),
                      ),
                    ],
                  ),
                  Slider(
                    value: settings.fontSizeNews,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    activeColor: const Color(0xFF16C47F),
                    onChanged: (val) => settings.setFontSizeNews(val),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF16C47F).withOpacity(0.1)
            : const Color(0xFF1E2433),
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: const Color(0xFF16C47F)) : null,
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF16C47F))
            : null,
      ),
    );
  }
}
