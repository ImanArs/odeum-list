import 'package:flutter/material.dart';
import 'empty_state.dart';
import 'friends_list.dart';
import 'add_friend_screen/add_friend_screen.dart';
import '../../../models/friend.dart';
import '../../../services/storage_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Friend> friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  void _loadFriends() {
    setState(() {
      friends = StorageService.getAllFriends();
    });
  }

  Future<void> _navigateToAddFriend() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddFriendScreen(),
      ),
    );
    // Refresh friends list when returning
    _loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: friends.isNotEmpty
            ? FriendsList(
                friends: friends,
                onAddFriend: () => _navigateToAddFriend(),
              )
            : EmptyState(
                onAddFriend: () => _navigateToAddFriend(),
              ),
      ),
    );
  }
}
