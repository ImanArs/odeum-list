import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/friend.dart';
import '../services/storage_service.dart';
import '../components/gift_card.dart';
import 'edit_friend_screen.dart';
import 'add_gift_screen.dart';
import 'gift_detail_screen.dart';

class FriendDetailScreen extends StatefulWidget {
  final Friend friend;

  const FriendDetailScreen({super.key, required this.friend});

  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadImage();
  }

  void _loadImage() async {
    if (widget.friend.imagePath != null && widget.friend.imagePath!.isNotEmpty) {
      File? imageFile;

      // Check if this is a relative path (new format)
      if (widget.friend.imagePath!.startsWith('friend_images/')) {
        try {
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          final fullPath = '${appDocDir.path}/${widget.friend.imagePath}';
          imageFile = File(fullPath);
        } catch (e) {
          debugPrint('Error constructing full path: $e');
          return;
        }
      } else {
        // Absolute path (old format)
        imageFile = File(widget.friend.imagePath!);
      }

      if (imageFile.existsSync()) {
        try {
          final bytes = await imageFile.readAsBytes();
          if (mounted) {
            setState(() {
              _imageBytes = bytes;
            });
          }
        } catch (e) {
          debugPrint('Error loading image: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Friend'),
          content: Text(
            'Are you sure you want to delete ${widget.friend.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(
                  context,
                  true,
                ); // Return to previous screen with result
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.friend.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[400],
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              indicatorColor: Colors.blue,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Information'),
                Tab(text: 'Gifts'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildInformationTab(), _buildGiftsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Photo
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _buildPhoto(),
            ),
          ),
          const SizedBox(height: 24),
          // Personal Information Block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                // Holidays section
                const Text(
                  'Holidays:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.friend.holidays.isEmpty)
                  const Text(
                    'No holidays added',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  )
                else
                  ...widget.friend.holidays.map((holiday) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            holiday.type,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${holiday.day} ${holiday.month.substring(0, 3)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                // Note section
                if (widget.friend.note != null &&
                    widget.friend.note!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Note:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.friend.note!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Edit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditFriendScreen(friend: widget.friend),
                  ),
                );
                if (result == true && mounted) {
                  setState(() {});
                  _loadImage(); // Reload image after edit
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Edit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftsTab() {
    final gifts = StorageService.getGiftsForFriend(widget.friend.id);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Gifts list or empty state
          if (gifts.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'You don\'t have any added gifts yet. To add a gift, click on the "Add gifts" button',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ] else
            Expanded(
              child: ListView.builder(
                itemCount: gifts.length,
                itemBuilder: (context, index) {
                  final gift = gifts[index];
                  return GiftCard(
                    gift: gift,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GiftDetailScreen(gift: gift),
                        ),
                      );
                      if (result == true && mounted) {
                        setState(() {});
                      }
                    },
                  );
                },
              ),
            ),
          // Add gift button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddGiftScreen(friend: widget.friend),
                  ),
                );
                if (result == true && mounted) {
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add gift',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPhoto() {
    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.person, size: 80, color: Colors.grey[400]),
      ),
    );
  }
}
