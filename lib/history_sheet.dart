import 'package:flutter/material.dart';
import 'calculator_engine.dart';

/// A beautiful slide-up history panel
class HistorySheet extends StatelessWidget {
  final List<HistoryEntry> history;
  final void Function(HistoryEntry entry) onTapEntry;
  final VoidCallback onClearHistory;

  const HistorySheet({
    super.key,
    required this.history,
    required this.onTapEntry,
    required this.onClearHistory,
  });

  // ── Colors ───────────────────────────────────────────────────────────────
  static const Color _sheetBg = Color(0xFF13131B);
  static const Color _cardBg = Color(0xFF1C1C28);
  static const Color _orange = Color(0xFFFF7A00);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textMuted = Color(0xFF9090A8);
  static const Color _divider = Color(0xFF2A2A3A);

  static void show(
    BuildContext context, {
    required List<HistoryEntry> history,
    required void Function(HistoryEntry entry) onTapEntry,
    required VoidCallback onClearHistory,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => HistorySheet(
        history: history,
        onTapEntry: (entry) {
          onTapEntry(entry);
          Navigator.of(ctx).pop();
        },
        onClearHistory: () {
          onClearHistory();
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.7),
      decoration: const BoxDecoration(
        color: _sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history_rounded, color: _orange, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'History',
                      style: TextStyle(
                        color: _textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                if (history.isNotEmpty)
                  GestureDetector(
                    onTap: onClearHistory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              color: _orange, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Clear All',
                            style: TextStyle(
                              color: _orange,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Divider ──────────────────────────────────────────────────────
          Container(height: 1, color: _divider),

          // ── List ─────────────────────────────────────────────────────────
          Flexible(
            child: history.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      return _buildHistoryCard(entry, index);
                    },
                  ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calculate_outlined,
            size: 56,
            color: _divider,
          ),
          SizedBox(height: 16),
          Text(
            'No calculations yet',
            style: TextStyle(
              color: _textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your calculation history will appear here',
            style: TextStyle(
              color: _divider,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(HistoryEntry entry, int index) {
    return GestureDetector(
      onTap: () => onTapEntry(entry),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200 + index * 50),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _divider.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Expression
            Row(
              children: [
                // Index badge
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: _orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Expression text
                Expanded(
                  child: Text(
                    entry.expression,
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Time ago
                Text(
                  _timeAgo(entry.timestamp),
                  style: TextStyle(
                    color: _textMuted.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Result
            Text(
              entry.result,
              style: const TextStyle(
                color: _textWhite,
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: -1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Tap hint
            const Text(
              'Tap to use',
              style: TextStyle(
                color: _orange,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
