import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/friend.dart';
import '../models/holiday.dart';

class EditFriendScreen extends StatefulWidget {
  final Friend friend;

  const EditFriendScreen({super.key, required this.friend});

  @override
  State<EditFriendScreen> createState() => _EditFriendScreenState();
}

class _EditFriendScreenState extends State<EditFriendScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  File? _selectedImage;
  String _selectedHoliday = 'Birthday';
  int _selectedDay = 25;
  String _selectedMonth = 'July';
  bool _isDateSelected = false;

  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _addedHolidays = [];
  bool _showHolidayForm = false;

  final List<String> holidays = [
    'Christmas',
    'Birthday',
    'Anniversary',
    'Child\'s birthday',
    'Graduation',
    'Easter',
    'Other',
  ];

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _initializeWithFriendData();
  }

  void _initializeWithFriendData() {
    _nameController.text = widget.friend.name;

    if (widget.friend.note != null) {
      _noteController.text = widget.friend.note!;
    }

    if (widget.friend.imagePath != null && widget.friend.imagePath!.isNotEmpty) {
      _selectedImage = File(widget.friend.imagePath!);
    }

    _addedHolidays = widget.friend.holidays.map((holiday) => {
      'type': holiday.type,
      'day': holiday.day,
      'month': holiday.month,
    }).toList();

    _showHolidayForm = _addedHolidays.isEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final status = await Permission.photos.request();

      if (status.isGranted) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
          });
        }
      } else {
        await _pickImageWithFilePicker();
      }
    } catch (e) {
      await _pickImageWithFilePicker();
    }
  }

  Future<void> _pickImageWithFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showErrorDialog('Не удалось выбрать изображение. Попробуйте еще раз.');
    }
  }

  void _addHoliday() {
    if (_isDateSelected) {
      setState(() {
        _addedHolidays.add({
          'type': _selectedHoliday,
          'day': _selectedDay,
          'month': _selectedMonth,
        });

        _selectedHoliday = 'Birthday';
        _selectedDay = 25;
        _selectedMonth = 'July';
        _isDateSelected = false;
        _showHolidayForm = false;
      });
    }
  }

  void _removeHoliday(int index) {
    setState(() {
      _addedHolidays.removeAt(index);
    });
  }

  void _showAddHolidayForm() {
    setState(() {
      _showHolidayForm = true;
    });
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Editing friend',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhotoSection(),
                const SizedBox(height: 32),
                _buildNameSection(),
                const SizedBox(height: 32),
                _buildHolidaySection(),
                const SizedBox(height: 32),
                _buildNoteSection(),
                const SizedBox(height: 40),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '1: ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              TextSpan(
                text: 'Select a photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            GestureDetector(
              onTap: _pickImageFromGallery,
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(20),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Add photo',
                            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            if (_selectedImage != null)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '2: ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              TextSpan(
                text: 'Specify the user\'s name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter name',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            filled: true,
            fillColor: const Color(0xFFE5E5EA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHolidaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '3: ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              TextSpan(
                text: 'Specify the name and date of the holiday',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ..._addedHolidays.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> holiday = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3E50),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          holiday['type'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${holiday['day']} ${holiday['month'].toString().substring(0, 3)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _removeHoliday(index),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        if (_showHolidayForm) ...[
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildHolidayChip('Christmas')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildHolidayChip('Birthday')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildHolidayChip('Anniversary')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildHolidayChip('Child\'s birthday')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildHolidayChip('Graduation')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildHolidayChip('Easter')),
                ],
              ),
              const SizedBox(height: 12),
              _buildHolidayChip('Other'),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showIOSDatePicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isDateSelected
                        ? '$_selectedDay ${_selectedMonth.substring(0, 3)}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isDateSelected
                          ? Colors.black87
                          : Colors.grey[400],
                    ),
                  ),
                  const Text(
                    'Select',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isDateSelected ? _addHoliday : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5E5EA),
                foregroundColor: _isDateSelected
                    ? Colors.blue
                    : Colors.grey[400],
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: Text(
                'Add holiday',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _isDateSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],

        if (!_showHolidayForm) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showAddHolidayForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5E5EA),
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add another holiday',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHolidayChip(String holiday) {
    final isSelected = holiday == _selectedHoliday;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHoliday = holiday;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            holiday,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: '4: ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              const TextSpan(
                text: 'Note ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: '(optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter text',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            filled: true,
            fillColor: const Color(0xFFE5E5EA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _updateFriend,
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
          'Save changes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<String?> _saveImagePermanently(File imageFile) async {
    try {
      // Get the app documents directory (consistent with Hive storage)
      final Directory appDir = await getApplicationDocumentsDirectory();

      // Create a subfolder for friend images if it doesn't exist
      final Directory imageDir = Directory('${appDir.path}/friend_images');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // Generate a unique filename using timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(imageFile.path);
      final String newFileName = 'friend_$timestamp$extension';

      // Copy the image to the permanent location
      final String newPath = '${imageDir.path}/$newFileName';
      await imageFile.copy(newPath);

      // Return only the filename for relative path storage
      return 'friend_images/$newFileName';
    } catch (e) {
      debugPrint('Error saving image permanently: $e');
      return null;
    }
  }

  Future<void> _updateFriend() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a friend\'s name');
      return;
    }

    try {
      // Save image permanently if a new one was selected
      String? imagePath;
      if (_selectedImage != null) {
        // Check if this is a new image (not the existing one)
        if (_selectedImage!.path != widget.friend.imagePath) {
          imagePath = await _saveImagePermanently(_selectedImage!);

          // Delete the old image if it exists
          if (widget.friend.imagePath != null && widget.friend.imagePath!.isNotEmpty) {
            try {
              File? oldFile;

              // Check if this is a relative path
              if (widget.friend.imagePath!.startsWith('friend_images/')) {
                final Directory appDocDir = await getApplicationDocumentsDirectory();
                final fullPath = '${appDocDir.path}/${widget.friend.imagePath}';
                oldFile = File(fullPath);
              } else {
                // Absolute path
                oldFile = File(widget.friend.imagePath!);
              }

              if (await oldFile.exists()) {
                await oldFile.delete();
                debugPrint('Deleted old image: ${oldFile.path}');
              }
            } catch (e) {
              debugPrint('Error deleting old image: $e');
            }
          }
        } else {
          // Keep the existing path if it hasn't changed
          imagePath = widget.friend.imagePath;
        }
      }

      List<Holiday> holidays = _addedHolidays.map((holidayMap) {
        return Holiday.create(
          type: holidayMap['type'],
          day: holidayMap['day'],
          month: holidayMap['month'],
        );
      }).toList();

      widget.friend.updateName(_nameController.text.trim());
      widget.friend.updateImagePath(imagePath);
      widget.friend.updateNote(_noteController.text.trim().isEmpty ? null : _noteController.text.trim());

      widget.friend.holidays.clear();
      widget.friend.holidays.addAll(holidays);
      await widget.friend.save();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Friend updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorDialog('Failed to update friend. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showIOSDatePicker(BuildContext context) {
    int tempDay = _selectedDay;
    String tempMonth = _selectedMonth;
    int tempDayIndex = _selectedDay - 1;
    int tempMonthIndex = months.indexOf(_selectedMonth);

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 250,
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: tempDayIndex,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (int index) {
                          tempDay = index + 1;
                          tempDayIndex = index;
                        },
                        children: List<Widget>.generate(31, (int index) {
                          return Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(fontSize: 20),
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: tempMonthIndex,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (int index) {
                          tempMonth = months[index];
                          tempMonthIndex = index;
                        },
                        children: months.map((String month) {
                          return Center(
                            child: Text(
                              month,
                              style: const TextStyle(fontSize: 20),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _selectedDay = tempDay;
                            _selectedMonth = tempMonth;
                            _isDateSelected = true;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Select',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: Colors.white,
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}