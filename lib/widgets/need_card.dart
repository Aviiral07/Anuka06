import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/need_item.dart';

class NeedCard extends StatelessWidget {
  const NeedCard({
    super.key,
    required this.need,
    required this.currentUserId,
    this.onHelp,
    this.onComplete,
  });

  final NeedItem need;
  final String currentUserId;
  final VoidCallback? onHelp;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final isOwner = need.createdBy == currentUserId;
    final isHelper = need.helperId == currentUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    need.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusChip(status: need.status),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(icon: Icons.category_outlined, label: need.category),
                _MetaChip(icon: Icons.location_on_outlined, label: need.location),
                _MetaChip(
                  icon: Icons.access_time,
                  label: _formatCreatedAt(need.createdAt),
                ),
              ],
            ),
            if (need.description.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(need.description),
            ],
            const SizedBox(height: 16),
            if (onHelp != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onHelp,
                  child: const Text('I Can Help'),
                ),
              ),
            if (onComplete != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onComplete,
                  child: const Text('Mark Completed'),
                ),
              ),
            if (need.isOpen && isOwner)
              const Text('Waiting for someone to respond.'),
            if (need.isHelping && isOwner && !isHelper)
              const Text('Someone has offered to help.'),
            if (need.isHelping && isHelper)
              const Text('You are the helper for this need.'),
            if (need.isCompleted)
              const Text('This need has been completed.'),
          ],
        ),
      ),
    );
  }

  String _formatCreatedAt(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Just now';
    }
    return DateFormat('dd MMM, hh:mm a').format(dateTime.toLocal());
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
  });

  final NeedStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      NeedStatus.open => (const Color(0xFFE8F5E9), const Color(0xFF256029)),
      NeedStatus.helping =>
        (const Color(0xFFFFF4E5), const Color(0xFF9A5B00)),
      NeedStatus.completed =>
        (const Color(0xFFE3F2FD), const Color(0xFF0D47A1)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
