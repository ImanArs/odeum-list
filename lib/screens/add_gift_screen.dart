import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/gift.dart';
import '../models/friend.dart';
import '../services/storage_service.dart';

class AddGiftScreen extends StatefulWidget {
  final Friend friend;

  const AddGiftScreen({super.key, required this.friend});

  @override
  State<AddGiftScreen> createState() => _AddGiftScreenState();
}

class _AddGiftScreenState extends State<AddGiftScreen> {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  File? _selectedImage;
  String? _selectedHolidayTag;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _linkController.dispose();
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
      _showErrorDialog('Could not select image. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
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

  Future<void> _saveGift() async {
    // Validation - at least image or link is required
    if (_selectedImage == null && _linkController.text.trim().isEmpty) {
      _showErrorDialog('Please add a photo or provide a link to the store.');
      return;
    }

    // Validation - holiday tag is required
    if (_selectedHolidayTag == null) {
      _showErrorDialog('Please select a tag for the holiday.');
      return;
    }

    try {
      // Save image if selected
      String? imagePath;
      if (_selectedImage != null) {
        // Get the app documents directory (consistent with friend images)
        final Directory appDir = await getApplicationDocumentsDirectory();
        final directory = Directory('${appDir.path}/gift_images');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        final fileName =
            'gift_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final newFile = await _selectedImage!.copy('${directory.path}/$fileName');
        debugPrint('Saved gift image to: ${newFile.path}');
        debugPrint('File exists: ${newFile.existsSync()}');
        // Store relative path for portability
        imagePath = 'gift_images/$fileName';
        debugPrint('Storing relative path: $imagePath');
      }

      // Create gift
      final gift = Gift.create(
        title: 'Gift for ${widget.friend.name}',
        description: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
        recipientName: widget.friend.name,
        imageUrl: _linkController.text.trim().isNotEmpty
            ? _linkController.text.trim()
            : imagePath,
        friendId: widget.friend.id,
        holidayTag: _selectedHolidayTag,
      );

      debugPrint('Created gift with imageUrl: ${gift.imageUrl}');
      debugPrint('Gift has link: ${_linkController.text.trim().isNotEmpty}');
      debugPrint('Gift has image: ${imagePath != null}');

      // Save to storage
      await StorageService.addGift(gift);

      // Show success and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gift added for ${widget.friend.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorDialog('Failed to add gift. Please try again.');
    }
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
          'Gift adding',
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
                _buildLinkSection(),
                const SizedBox(height: 32),
                _buildHolidayTagSection(),
                const SizedBox(height: 32),
                _buildNoteSection(),
                const SizedBox(height: 40),
                _buildAddGiftButton(),
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
                text: 'Select a gift photo from the Gallery',
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
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLinkSection() {
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
                text: 'Specify the link to the store ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: '(optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _linkController,
          decoration: InputDecoration(
            hintText: 'Insert link',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFE5E5EA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildHolidayTagSection() {
    final hasOneHoliday = widget.friend.holidays.length == 1;

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
                text: 'Choose a tag for the holiday',
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
        if (widget.friend.holidays.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'This friend has no holidays added yet.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          )
        else if (hasOneHoliday)
          // Single tag - full width
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedHolidayTag = widget.friend.holidays.first.type;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _selectedHolidayTag == widget.friend.holidays.first.type
                    ? Colors.blue
                    : const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.friend.holidays.first.type,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _selectedHolidayTag == widget.friend.holidays.first.type
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          )
        else
          // Multiple tags - wrap layout
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.friend.holidays.map((holiday) {
              final isSelected = _selectedHolidayTag == holiday.type;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedHolidayTag = holiday.type;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    holiday.type,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '4: ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              TextSpan(
                text: 'Note about gift',
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
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter text',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFE5E5EA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAddGiftButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveGift,
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
    );
  }
}
