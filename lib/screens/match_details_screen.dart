import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../widgets/football_pitch.dart';
import 'live_player_screen.dart';

class MatchDetailsScreen extends StatefulWidget {
  final Match match;

  const MatchDetailsScreen({super.key, required this.match});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 4 Tabs: Details, Lineup, Standings, News
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 320.0,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF0B0F1A),
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Stadium Background with Blur
                    Image.network(
                      'https://images.unsplash.com/photo-1522778119026-d647f0565c6a?auto=format&fit=crop&q=80',
                      fit: BoxFit.cover,
                    ),
                    // Gradient Overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black26, Color(0xFF0B0F1A)],
                          stops: [0.0, 1.0],
                        ),
                      ),
                    ),

                    // Watch Now Button
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LivePlayerScreen(match: widget.match),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                          label: Text(
                            "شاهد البث المباشر",
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16C47F),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Match Score Content
                    Positioned(
                      bottom: 80,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          // League Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(
                              widget.match.league,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTeamColumn(
                                widget.match.homeTeam.name,
                                widget.match.homeTeam.logoUrl,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    widget.match.isLive
                                        ? (widget.match.score ?? "0 - 0")
                                        : "VS",
                                    style: GoogleFonts.cairo(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (widget.match.isLive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.4),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        "82'", // Mock Time
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  else
                                    Text(
                                      _formatTime(widget.match.matchTime),
                                      style: GoogleFonts.cairo(
                                        color: Colors.grey[300],
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              _buildTeamColumn(
                                widget.match.awayTeam.name,
                                widget.match.awayTeam.logoUrl,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: div(),
              ),
            ),

            // Re-pinned TabBar (To avoid FlexibleSpaceBar overlap issues, sometimes preferredSize in bottom of SliverAppBar is better, but let's try StickyHeader later if needed. For now default bottom is fine).
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF16C47F),
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: const Color(0xFF16C47F),
                  unselectedLabelColor: Colors.grey,
                  labelStyle: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: GoogleFonts.cairo(fontSize: 14),
                  tabs: const [
                    Tab(text: "التفاصيل"),
                    Tab(text: "التشكيلة"),
                    Tab(text: "الترتيب"),
                    Tab(text: "الأخبار"),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(),
            _buildLineupTab(),
            _buildStandingsTab(),
            const Center(
              child: Text(
                "أخبار الفريقين",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget div() => Container(
    height: 10,
    decoration: const BoxDecoration(
      color: Color(0xFF0B0F1A),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
  );

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailRow("البطولة", widget.match.league),
        _buildDetailRow("الجولة", widget.match.round),
        _buildDetailRow("الملعب", widget.match.venue),
        _buildDetailRow("القناة الناقلة", widget.match.channel),
        _buildDetailRow("المعلق", widget.match.commentator),
        _buildDetailRow("حكم المباراة", widget.match.referee),

        const SizedBox(height: 24),
        Text(
          "آخر 5 مباريات",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index % 2 == 0
                    ? const Color(0xFF16C47F)
                    : Colors.redAccent,
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Text(
                  index % 2 == 0 ? "W" : "L",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2433),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineupTab() {
    return Column(
      children: [
        // Pitch visual
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FootballPitch(
              homeLineup: widget.match.homeLineup,
              awayLineup: widget.match.awayLineup,
              homeFormation: widget.match.homeFormation,
              awayFormation: widget.match.awayFormation,
            ),
          ),
        ),
        // Coach Info Bottom Sheet style
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1E2433),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "المدرب",
                      style: GoogleFonts.cairo(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "بيب غوارديولا",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF16C47F).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF16C47F)),
                ),
                child: Text(
                  widget.match.homeFormation,
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF16C47F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Standings Tab copied from previous step
  Widget _buildStandingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E2433),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FixedColumnWidth(40), // Pos
              1: FlexColumnWidth(), // Club
              2: FixedColumnWidth(40), // P
              3: FixedColumnWidth(40), // +/-
              4: FixedColumnWidth(40), // Pts
            },
            children: [
              // Header
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white12)),
                ),
                children: [
                  _buildTableHeader("#"),
                  _buildTableHeader("الفريق"),
                  _buildTableHeader("لعب"),
                  _buildTableHeader("+/-"),
                  _buildTableHeader("نقاط"),
                ],
              ),
              // Rows
              ...List.generate(6, (index) => _buildTableRow(index)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TableRow _buildTableRow(int index) {
    final isHomeTeam = index == 0;
    final isAwayTeam = index == 1;
    final textColor = (isHomeTeam || isAwayTeam)
        ? Colors.white
        : Colors.white70;

    return TableRow(
      decoration: BoxDecoration(
        color: (isHomeTeam || isAwayTeam)
            ? const Color(0xFF16C47F).withOpacity(0.05)
            : null,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            "${index + 1}",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(color: textColor),
          ),
        ),
        Row(
          children: [
            // Mock Logo
            const Icon(Icons.shield, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                index == 0 ? "الهلال" : (index == 1 ? "النصر" : "فريق"),
                style: GoogleFonts.cairo(
                  color: textColor,
                  fontWeight: (isHomeTeam || isAwayTeam)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        Text(
          "20",
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(color: textColor),
        ),
        Text(
          "+12",
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(color: textColor),
        ),
        Text(
          "${60 - (index * 2)}",
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamColumn(String name, String logoUrl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
            ],
          ),
          child: CachedNetworkImage(
            imageUrl: logoUrl,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
                const Icon(Icons.shield, color: Colors.grey, size: 40),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFF0B0F1A), child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
