import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/friend.dart';

class FriendCard extends StatefulWidget {
  final Friend friend;
  final VoidCallback? onTap;

  const FriendCard({super.key, required this.friend, this.onTap});

  @override
  State<FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends State<FriendCard> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(FriendCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.friend.imagePath != widget.friend.imagePath) {
      _loadImage();
    }
  }

  void _loadImage() async {
    debugPrint('=== FriendCard _loadImage ===');
    debugPrint('Friend name: ${widget.friend.name}');
    debugPrint('Image path: ${widget.friend.imagePath}');

    if (widget.friend.imagePath != null && widget.friend.imagePath!.isNotEmpty) {
      File? imageFile;

      // Check if this is a relative path (new format)
      if (widget.friend.imagePath!.startsWith('friend_images/')) {
        debugPrint('Detected relative path');
        try {
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          final fullPath = '${appDocDir.path}/${widget.friend.imagePath}';
          imageFile = File(fullPath);
          debugPrint('Constructed full path: $fullPath');
        } catch (e) {
          debugPrint('Error constructing full path: $e');
          return;
        }
      }
      // Check if this is an absolute path (old format)
      else {
        debugPrint('Detected absolute path');
        imageFile = File(widget.friend.imagePath!);

        // If absolute path doesn't exist, try migration from different locations
        if (!imageFile.existsSync()) {
          debugPrint('Absolute path file does not exist, attempting migration');

          final fileName = widget.friend.imagePath!.split('/').last;
          debugPrint('Extracted filename for migration: $fileName');

          // Try multiple possible locations
          final locations = await _getPossibleImageLocations(fileName);

          for (final location in locations) {
            final possibleFile = File(location);
            debugPrint('Checking: $location');
            if (possibleFile.existsSync()) {
              debugPrint('Found image at: $location');

              // Copy to the new standard location
              try {
                final Directory appDocDir = await getApplicationDocumentsDirectory();
                final Directory imageDir = Directory('${appDocDir.path}/friend_images');
                if (!await imageDir.exists()) {
                  await imageDir.create(recursive: true);
                }

                final newPath = '${imageDir.path}/$fileName';
                await possibleFile.copy(newPath);
                debugPrint('Migrated image to: $newPath');

                // Update the friend's image path to relative format
                widget.friend.updateImagePath('friend_images/$fileName');
                await widget.friend.save();

                imageFile = File(newPath);
                break;
              } catch (e) {
                debugPrint('Error during migration: $e');
              }
            }
          }

          if (imageFile == null || !imageFile.existsSync()) {
            debugPrint('Image not found in any location');
            return;
          }
        }
      }

      debugPrint('Checking file exists: ${imageFile.path}');
      debugPrint('File exists: ${imageFile.existsSync()}');

      if (imageFile.existsSync()) {
        try {
          final bytes = await imageFile.readAsBytes();
          debugPrint('Image loaded successfully, bytes length: ${bytes.length}');
          if (mounted) {
            setState(() {
              _imageBytes = bytes;
            });
          }
        } catch (e) {
          debugPrint('Error loading image: $e');
        }
      } else {
        debugPrint('Image file does not exist at path: ${imageFile.path}');
      }
    } else {
      debugPrint('No image path set for friend');
    }
  }

  Future<List<String>> _getPossibleImageLocations(String fileName) async {
    final locations = <String>[];

    try {
      // Check Documents directory locations
      final Directory docDir = await getApplicationDocumentsDirectory();
      locations.add('${docDir.path}/friend_images/$fileName');
      locations.add('${docDir.path}/picked_images/$fileName');

      // Check Application Support directory (old location)
      final Directory supportDir = await getApplicationSupportDirectory();
      locations.add('${supportDir.path}/friend_images/$fileName');
      locations.add('${supportDir.path}/picked_images/$fileName');
    } catch (e) {
      debugPrint('Error getting possible locations: $e');
    }

    return locations;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFE5E5EA),
        ),
        child: Column(
          children: [
            // Photo section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildPhoto(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Name section
            Text(
              widget.friend.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
        child: CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[300],
          child: Text(
            widget.friend.name.isNotEmpty ? widget.friend.name[0].toUpperCase() : 'F',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
