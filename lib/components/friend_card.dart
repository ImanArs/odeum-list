import 'package:flutter/material.dart';
import 'dart:io';
import '../models/friend.dart';

class FriendCard extends StatelessWidget {
  final Friend friend;
  final VoidCallback? onTap;

  const FriendCard({super.key, required this.friend, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              friend.name,
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
    if (friend.imagePath != null && friend.imagePath!.isNotEmpty) {
      final imageFile = File(friend.imagePath!);
      if (imageFile.existsSync()) {
        return Image.file(
          imageFile,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        );
      }
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
            friend.name.isNotEmpty ? friend.name[0].toUpperCase() : 'F',
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
