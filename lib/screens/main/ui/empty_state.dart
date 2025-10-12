import 'package:flutter/material.dart';
import 'package:odeum_list/components/addFriendButton.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback? onAddFriend;

  const EmptyState({
    super.key,
    this.onAddFriend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'My friends',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Spacer(),
          Image.asset(
            'lib/assets/images/no_data_main.png',
            width: 311,
            height: 207,
          ),
          const Text(
            'You don`t have any friends added yet. To add a friend`s profile, click on the "Add friend" button.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF757d88),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          const SizedBox(height: 40),
          AddFriendButton(
            onPressed: onAddFriend ?? () => print('Add friend pressed'),
          ),
        ],
      ),
    );
  }
}