import 'package:flutter/material.dart';

class FiltersMain extends StatefulWidget {
  const FiltersMain({super.key});

  @override
  State<FiltersMain> createState() => _FiltersMainState();
}

class _FiltersMainState extends State<FiltersMain> {
  String selectedTag = 'Birthday';
  String selectedSort = 'nearest first';
  bool isExpanded = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  final List<String> tags = [
    'Christmas',
    'Birthday',
    'Anniversary',
    'Child\'s birthday',
    'Graduation',
    'Easter',
    'Other',
  ];

  final Map<String, List<String>> sortOptions = {
    'Christmas': ['nearest first', 'farthest first', 'A to Z', 'Z to A'],
    'Birthday': ['nearest first', 'farthest first', 'A to Z', 'Z to A'],
    'Anniversary': ['nearest first', 'farthest first', 'A to Z', 'Z to A'],
    'Child\'s birthday': [
      'nearest first',
      'farthest first',
      'A to Z',
      'Z to A',
    ],
    'Graduation': ['nearest first', 'farthest first', 'A to Z', 'Z to A'],
    'Easter': ['nearest first', 'farthest first', 'A to Z', 'Z to A'],
    'Other': ['A to Z', 'Z to A'],
  };

  void _showOverlay() {
    final RenderBox renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildOverlayContent(position, buttonSize),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  Widget _buildOverlayContent(Offset position, Size buttonSize) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isExpanded = false;
          });
          _hideOverlay();
        },
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                left: position.dx,
                top: position.dy,
                width: buttonSize.width,
                child: Material(
                  elevation: 12,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Главная кнопка
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpanded = false;
                            });
                            _hideOverlay();
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.cake_outlined,
                                color: Colors.blue,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '$selectedTag: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: selectedSort,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.grey[600],
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Опции
                        ...sortOptions[selectedTag]!.map((option) {
                          final isSelected = selectedSort == option;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedSort = option;
                                  isExpanded = false;
                                });
                                _hideOverlay();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.grey[300],
                                      ),
                                      child: isSelected
                                          ? const Center(
                                              child: Icon(
                                                Icons.circle,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '$selectedTag: ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[500],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            TextSpan(
                                              text: option,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Горизонтальная прокрутка тегов
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tags.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _buildTagChip(tags[index]),
          ),
        ),
        const SizedBox(height: 20),
        // Кнопка фильтра с overlay
        GestureDetector(
          key: _buttonKey,
          onTap: () {
            if (isExpanded) {
              setState(() {
                isExpanded = false;
              });
              _hideOverlay();
            } else {
              setState(() {
                isExpanded = true;
              });
              _showOverlay();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cake_outlined,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$selectedTag: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: selectedSort,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    final isSelected = tag == selectedTag;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTag = tag;
          selectedSort = sortOptions[tag]!.first;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            tag,
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
}
