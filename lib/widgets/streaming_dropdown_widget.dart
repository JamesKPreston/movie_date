import 'package:flutter/material.dart';
import 'package:movie_date/utils/constants.dart';

class StreamingDropDownWidget extends StatefulWidget {
  final Function(List<String>) onSelectionChanged;
  final List<String> initialSelectedItems;

  StreamingDropDownWidget({
    required this.onSelectionChanged,
    this.initialSelectedItems = const [],
  });

  @override
  _StreamingDropDownWidgetState createState() => _StreamingDropDownWidgetState();
}

class _StreamingDropDownWidgetState extends State<StreamingDropDownWidget> {
  late List<String> selectedItems = [];

  @override
  void initState() {
    super.initState();
    selectedItems = List.from(widget.initialSelectedItems); // Initialize with initial items
  }

  @override
  void didUpdateWidget(StreamingDropDownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the initialSelectedItems has changed
    if (oldWidget.initialSelectedItems != widget.initialSelectedItems) {
      setState(() {
        selectedItems = List.from(widget.initialSelectedItems); // Update selectedItems if new data is passed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (!selectedItems.contains(value)) {
                  selectedItems.add(value); // Add the selected item
                }
              });
              widget.onSelectionChanged(selectedItems); // Notify parent about the change
            },
            itemBuilder: (context) {
              return services.map((service) {
                return PopupMenuItem<String>(
                  value: service["id"],
                  child: Row(
                    children: [
                      Image.asset(service["image"], width: 24, height: 24),
                      SizedBox(width: 8),
                      Text(service["label"]),
                    ],
                  ),
                );
              }).toList();
            },
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                children: [
                  Icon(Icons.tv, size: 24),
                  SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: selectedItems.map((item) {
                        String imagePath = services.firstWhere((service) => service["id"] == item)["image"];
                        String label = services.firstWhere((service) => service["id"] == item)["label"];

                        return Chip(
                          avatar: Container(
                            width: 36,
                            height: 36,
                            child: Image.asset(imagePath),
                          ),
                          label: Text(label),
                          deleteIcon: Icon(Icons.cancel, color: Colors.red),
                          onDeleted: () {
                            setState(() {
                              selectedItems.remove(item); // Remove item from selection
                            });
                            widget.onSelectionChanged(selectedItems); // Notify parent about the change
                          },
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          labelPadding: EdgeInsets.symmetric(horizontal: 4),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
