import 'package:flutter/material.dart';
import 'package:odeum_list/components/addFriendButton.dart';
import '../../../components/friend_card.dart';
import '../../../models/friend.dart';
import '../../friend_detail.dart';
import 'filters.dart';

class FriendsList extends StatelessWidget {
  final List<Friend> friends;
  final VoidCallback? onAddFriend;

  const FriendsList({super.key, required this.friends, this.onAddFriend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'My friends',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          const FiltersMain(),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                return FriendCard(
                  friend: friends[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendDetailScreen(friend: friends[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: AddFriendButton(onPressed: onAddFriend ?? () {}),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
