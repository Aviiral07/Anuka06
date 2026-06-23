import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/need_item.dart';
import '../services/auth_service.dart';
import '../services/need_service.dart';
import '../widgets/need_card.dart';
import 'create_need_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({
    super.key,
    required this.currentUser,
  });

  final AppUser currentUser;

  Future<void> _claimNeed(BuildContext context, NeedItem need) async {
    try {
      await NeedService.instance.claimNeed(
        needId: need.id,
        helperId: currentUser.userId,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are now helping on this need.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _markCompleted(BuildContext context, NeedItem need) async {
    try {
      await NeedService.instance.markCompleted(
        need: need,
        userId: currentUser.userId,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Need marked as completed.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anuka'),
        actions: [
          IconButton(
            onPressed: () => AuthService.instance.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateNeedScreen(currentUserId: currentUser.userId),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Post Need'),
      ),
      body: StreamBuilder<List<NeedItem>>(
        stream: NeedService.instance.watchNeeds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load needs right now.'),
            );
          }

          final needs = snapshot.data ?? <NeedItem>[];
          if (needs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.volunteer_activism_outlined, size: 56),
                    const SizedBox(height: 12),
                    Text(
                      'No needs posted yet.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Be the first to post a real need and start validating the loop.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: needs.length,
              itemBuilder: (context, index) {
                final need = needs[index];
                return NeedCard(
                  need: need,
                  currentUserId: currentUser.userId,
                  onHelp: need.isOpen && need.createdBy != currentUser.userId
                      ? () => _claimNeed(context, need)
                      : null,
                  onComplete:
                      need.isHelping &&
                              (need.createdBy == currentUser.userId ||
                                  need.helperId == currentUser.userId)
                          ? () => _markCompleted(context, need)
                          : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

