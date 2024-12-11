import 'package:flutter/material.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';

class CalendarWidget extends StatelessWidget {
  final Function(DateTime) onConfirm;

  const CalendarWidget({Key? key, required this.onConfirm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    DateTime minimumDate = DateTime(1900);
    DateTime maximumDate = DateTime(2100);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Select a Date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        SizedBox(
          height: 200, // Adjust height as needed
          child: ScrollDatePicker(
            selectedDate: selectedDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            locale: const Locale('en'),
            onDateTimeChanged: (date) {
              selectedDate = date; // Updates the selected date
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              onConfirm(selectedDate); // Passes the selected date back
              Navigator.pop(context); // Closes the modal
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: const Text('Confirm Date'),
          ),
        ),
      ],
    );
  }
}
