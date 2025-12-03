import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/gift.dart';
import '../services/storage_service.dart';
import 'edit_gift_screen.dart';

class GiftDetailScreen extends StatefulWidget {
  final Gift gift;

  const GiftDetailScreen({super.key, required this.gift});

  @override
  State<GiftDetailScreen> createState() => _GiftDetailScreenState();
}

class _GiftDetailScreenState extends State<GiftDetailScreen> {
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
        title: const Text(
          'Gift',
          style: TextStyle(
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Gift Image
                    _buildGiftImage(),
                    const SizedBox(height: 24),
                    // Gift Information Block
                    _buildGiftInformation(),
                  ],
                ),
              ),
            ),
            // Edit Button at the bottom
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Get friend information
                    final friend = widget.gift.friendId != null
                        ? StorageService.getFriendById(widget.gift.friendId!)
                        : null;

                    if (friend == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Friend not found'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditGiftScreen(
                          gift: widget.gift,
                          friend: friend,
                        ),
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
                    'Edit gift',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    // If imageUrl is a local file path, display it
    if (widget.gift.imageUrl != null &&
        widget.gift.imageUrl!.isNotEmpty &&
        _isLocalFile(widget.gift.imageUrl!)) {
      return FutureBuilder<File?>(
        future: _getImageFile(widget.gift.imageUrl!),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.existsSync()) {
            return Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            );
          }
          return _buildPlaceholder();
        },
      );
    }

    // If no valid image, show placeholder
    return _buildPlaceholder();
  }

  Future<File?> _getImageFile(String imagePath) async {
    // Check if this is a relative path (new format)
    if (imagePath.startsWith('gift_images/')) {
      try {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final fullPath = '${appDocDir.path}/$imagePath';
        final file = File(fullPath);
        if (file.existsSync()) {
          return file;
        }
      } catch (e) {
        debugPrint('Error loading relative path image: $e');
      }
    }

    // Try absolute path
    final file = File(imagePath);
    if (file.existsSync()) {
      return file;
    }

    // If absolute path doesn't exist, try migration from different locations
    debugPrint('Image not found at $imagePath, attempting migration');
    final fileName = imagePath.split('/').last;

    // Try multiple possible locations
    final locations = await _getPossibleImageLocations(fileName);

    for (final location in locations) {
      final possibleFile = File(location);
      debugPrint('Checking: $location');
      if (possibleFile.existsSync()) {
        debugPrint('Found image at: $location');

        // Copy to the new standard location and update gift
        try {
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          final Directory imageDir = Directory('${appDocDir.path}/gift_images');
          if (!await imageDir.exists()) {
            await imageDir.create(recursive: true);
          }

          final newPath = '${imageDir.path}/$fileName';
          await possibleFile.copy(newPath);
          debugPrint('Migrated image to: $newPath');

          // Update the gift's image path to relative format
          widget.gift.imageUrl = 'gift_images/$fileName';
          await widget.gift.save();

          return File(newPath);
        } catch (e) {
          debugPrint('Error during migration: $e');
        }
      }
    }

    debugPrint('Image not found in any location');
    return null;
  }

  Future<List<String>> _getPossibleImageLocations(String fileName) async {
    final locations = <String>[];

    try {
      // Check Documents directory locations
      final Directory docDir = await getApplicationDocumentsDirectory();
      locations.add('${docDir.path}/gift_images/$fileName');
      locations.add('${docDir.path}/odeum_list_gifts/$fileName');

      // Check Application Support directory (old location)
      final Directory supportDir = await getApplicationSupportDirectory();
      locations.add('${supportDir.path}/gift_images/$fileName');
      locations.add('${supportDir.path}/odeum_list_gifts/$fileName');

      // Check temp directory (where old gifts might be)
      final Directory tempDir = Directory.systemTemp;
      locations.add('${tempDir.path}/odeum_list_gifts/$fileName');
    } catch (e) {
      debugPrint('Error getting possible locations: $e');
    }

    return locations;
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.card_giftcard,
          size: 80,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  bool _isLocalFile(String path) {
    return path.startsWith('/') ||
           path.startsWith('file://') ||
           path.startsWith('gift_images/');
  }

  Widget _buildGiftInformation() {
    return Container(
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
            'Gift information:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          // TAG
          if (widget.gift.holidayTag != null) ...[
            Row(
              children: [
                const Text(
                  'TAG:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.gift.holidayTag!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          // Link
          if (widget.gift.imageUrl != null &&
              widget.gift.imageUrl!.isNotEmpty &&
              !_isLocalFile(widget.gift.imageUrl!)) ...[
            Row(
              children: [
                const Text(
                  'Link:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.gift.imageUrl!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _openLink,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.copy,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          // Note
          if (widget.gift.description != null &&
              widget.gift.description!.isNotEmpty) ...[
            const Text(
              'Note:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.gift.description!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openLink() async {
    if (widget.gift.imageUrl != null && widget.gift.imageUrl!.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: widget.gift.imageUrl!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link copied to clipboard'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Gift'),
          content: const Text(
            'Are you sure you want to delete this gift?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await StorageService.deleteGift(widget.gift.id);
                if (mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Return to previous screen
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
