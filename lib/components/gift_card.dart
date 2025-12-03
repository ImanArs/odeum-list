import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/gift.dart';

class GiftCard extends StatelessWidget {
  final Gift gift;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const GiftCard({
    super.key,
    required this.gift,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gift Image
            _buildGiftImage(),
            const SizedBox(width: 16),
            // Gift Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Link section
                  if (gift.imageUrl != null &&
                      gift.imageUrl!.isNotEmpty &&
                      !_isLocalFile(gift.imageUrl!)) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            gift.imageUrl!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Note section
                  if (gift.description != null &&
                      gift.description!.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Note:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            gift.description!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Holiday Tag
            if (gift.holidayTag != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  gift.holidayTag!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftImage() {
    // If imageUrl is a local file path, display it
    if (gift.imageUrl != null &&
        gift.imageUrl!.isNotEmpty &&
        _isLocalFile(gift.imageUrl!)) {
      // Return a FutureBuilder to handle async path resolution
      return FutureBuilder<File?>(
        future: _getImageFile(gift.imageUrl!),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.existsSync()) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                snapshot.data!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              ),
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
          gift.imageUrl = 'gift_images/$fileName';
          await gift.save();

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
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.card_giftcard,
        size: 40,
        color: Colors.grey[500],
      ),
    );
  }

  bool _isLocalFile(String path) {
    return path.startsWith('/') ||
           path.startsWith('file://') ||
           path.startsWith('gift_images/');
  }
}
