import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/streaming_server_model.dart';

class ServerSelectionSheet extends StatelessWidget {
  final List<StreamingServer> servers;
  final StreamingServer? currentServer;
  final Function(StreamingServer) onServerSelected;

  const ServerSelectionSheet({
    super.key,
    required this.servers,
    required this.currentServer,
    required this.onServerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2433),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            "اختر السيرفر",
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // List
          ...servers.map((server) {
            final isSelected = server.id == currentServer?.id;
            return InkWell(
              onTap: () {
                Navigator.pop(context);
                onServerSelected(server);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF16C47F).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: const Color(0xFF16C47F))
                      : null,
                ),
                child: Row(
                  children: [
                    // Icon
                    Icon(
                      server.isBackup
                          ? Icons.warning_amber_rounded
                          : Icons.dns_rounded,
                      color: isSelected ? const Color(0xFF16C47F) : Colors.grey,
                    ),
                    const SizedBox(width: 12),

                    // Name & Quality
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            server.name,
                            style: GoogleFonts.cairo(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[300],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            server.quality,
                            style: GoogleFonts.cairo(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Dot (Fake signal)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getQualityColor(server.priority),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getQualityColor(
                              server.priority,
                            ).withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Color _getQualityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFF16C47F); // Green
      case 2:
        return Colors.amber;
      default:
        return Colors.red;
    }
  }
}
