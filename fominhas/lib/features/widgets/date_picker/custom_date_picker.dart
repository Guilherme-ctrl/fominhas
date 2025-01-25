import 'package:flutter/material.dart';
import 'package:date_picker_plus/date_picker_plus.dart';

class CustomDatePickerPopup extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const CustomDatePickerPopup({super.key, required this.onDateSelected});

  @override
  _CustomDatePickerPopupState createState() => _CustomDatePickerPopupState();
}

class _CustomDatePickerPopupState extends State<CustomDatePickerPopup> {
  DateTime? _selectedDate;

  Future<void> _openDatePicker() async {
    final date = await showDatePickerDialog(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      minDate: DateTime(2020, 10, 10),
      maxDate: DateTime(2040, 10, 30),
      width: 300,
      height: 300,
      currentDate: DateTime.now(),
      selectedDate: _selectedDate ?? DateTime.now(),
      currentDateDecoration: BoxDecoration(
        color: Color(0xff018055).withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      currentDateTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xff018055),
      ),
      daysOfTheWeekTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
      ),
      disabledCellsDecoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      disabledCellsTextStyle: TextStyle(
        color: Colors.grey.shade600,
      ),
      enabledCellsDecoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      enabledCellsTextStyle: TextStyle(
        color: Colors.black,
      ),
      initialPickerType: PickerType.days,
      selectedCellDecoration: BoxDecoration(
        color: Color(0xff018055),
        shape: BoxShape.circle,
      ),
      selectedCellTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      leadingDateTextStyle: TextStyle(
        fontSize: 18,
        color: Color(0xff018055),
        fontWeight: FontWeight.bold,
      ),
      slidersColor: Color(0xff018055),
      highlightColor: Colors.redAccent,
      slidersSize: 20,
      splashColor: Colors.lightBlueAccent,
      splashRadius: 40,
      centerLeadingDate: true,
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      widget.onDateSelected(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openDatePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xff018055), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate != null
                  ? "${_selectedDate!.day.toString().padLeft(2, '0')}/"
                      "${_selectedDate!.month.toString().padLeft(2, '0')}/"
                      "${_selectedDate!.year}"
                  : "Selecionar data",
              style: TextStyle(
                fontSize: 16,
                color: _selectedDate != null ? Colors.black : Colors.grey.shade600,
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: Color(0xff018055),
            ),
          ],
        ),
      ),
    );
  }
}
