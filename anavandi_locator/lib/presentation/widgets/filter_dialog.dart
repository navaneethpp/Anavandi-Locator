import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final bool showOnlyArrivingBuses;
  final Function(bool) onShowOnlyArrivingBusesChanged;

  const FilterDialog({
    Key? key,
    required this.showOnlyArrivingBuses,
    required this.onShowOnlyArrivingBusesChanged,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late bool _showOnlyArrivingBuses;

  @override
  void initState() {
    super.initState();
    _showOnlyArrivingBuses = widget.showOnlyArrivingBuses;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.filter_list),
          SizedBox(width: 8),
          Text('Filter Options'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _showOnlyArrivingBuses,
                onChanged: (value) {
                  setState(() {
                    _showOnlyArrivingBuses = value ?? false;
                  });
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showOnlyArrivingBuses = !_showOnlyArrivingBuses;
                    });
                  },
                  child: const Text(
                    'Show only buses arriving at my starting point',
                  ),
                ),
              ),
            ],
          ),
          // You can add more filter options here
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onShowOnlyArrivingBusesChanged(_showOnlyArrivingBuses);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
