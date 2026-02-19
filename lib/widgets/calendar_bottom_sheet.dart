import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CalendarBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarBottomSheet({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  late DateTime _focusedDate;
  late DateTime _tempSelectedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.selectedDate;
    _tempSelectedDate = widget.selectedDate;
  }

  void _onMonthChanged(int offset) {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + offset);
    });
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      _tempSelectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      decoration: const BoxDecoration(
        color: Color(0xFF0B0F1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
                Text(
                  "اختر التاريخ",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Month Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(
                  icon: Icons.chevron_left,
                  onTap: () => _onMonthChanged(-1),
                ),
                Text(
                  DateFormat("MMMM yyyy", "ar").format(_focusedDate),
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF16C47F),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildCircleButton(
                  icon: Icons.chevron_right,
                  onTap: () => _onMonthChanged(1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Days of Week
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["س", "ح", "ن", "ث", "ر", "خ", "ج"]
                  .map(
                    (day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Calendar Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount:
                  _daysInMonth(_focusedDate) + _firstDayOffset(_focusedDate),
              itemBuilder: (context, index) {
                final int firstDayOffset = _firstDayOffset(_focusedDate);
                if (index < firstDayOffset) return const SizedBox();

                final int day = index - firstDayOffset + 1;
                final DateTime date = DateTime(
                  _focusedDate.year,
                  _focusedDate.month,
                  day,
                );

                return _buildDayCell(date);
              },
            ),
          ),

          // Filter Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  widget.onDateSelected(_tempSelectedDate);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16C47F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "الفلترة",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2433),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final bool isSelected =
        date.year == _tempSelectedDate.year &&
        date.month == _tempSelectedDate.month &&
        date.day == _tempSelectedDate.day;

    final bool isToday =
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return GestureDetector(
      onTap: () => _onDaySelected(date),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF16C47F) : Colors.transparent,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: const Color(0xFF16C47F), width: 1.5)
              : null,
        ),
        child: Text(
          "${date.day}",
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : Colors.white,
            fontWeight: isSelected || isToday
                ? FontWeight.bold
                : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _firstDayOffset(DateTime date) {
    // 1 = Monday, 7 = Sunday
    // We want to map to our array ["س", "ح", "ن", "ث", "ر", "خ", "ج"]
    // Assumed: Sat, Sun, Mon, Tue, Wed, Thu, Fri
    // DateTime.weekday: Mon(1)..Sun(7)

    // Target mapping (Saturday start):
    // Sat (6) -> 0
    // Sun (7) -> 1
    // Mon (1) -> 2
    // Tue (2) -> 3
    // Wed (3) -> 4
    // Thu (4) -> 5
    // Fri (5) -> 6

    final int weekday = DateTime(date.year, date.month, 1).weekday;
    // Map standard weekday to our custom index
    if (weekday == DateTime.saturday) return 0;
    if (weekday == DateTime.sunday) return 1;
    return weekday + 1;
  }
}
