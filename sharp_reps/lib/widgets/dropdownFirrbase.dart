import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDropdownWidget extends StatefulWidget {
  @override
  _FirebaseDropdownWidgetState createState() => _FirebaseDropdownWidgetState();
}

class _FirebaseDropdownWidgetState extends State<FirebaseDropdownWidget> {
  final firestore = FirebaseFirestore.instance;
  List<String> dropdownItems = [];
  String? selectedDropdownItem;
  List<String> fetchedData = [];

  @override
  void initState() {
    super.initState();
    fetchDataForDropdown();
  }

  void fetchDataForDropdown() {
    firestore.collection('workouts').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        dropdownItems.add(doc.id);
      });
      setState(() {});
    });
  }

  void fetchDataForSelectedItem() {
    firestore
        .collection('items')
        .doc(selectedDropdownItem)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        fetchedData = data.values.map((value) => value.toString()).toList();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DropdownButton<String>(
          // Specify the generic type for DropdownButton
          value: selectedDropdownItem,
          items: dropdownItems.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? newValue) {
            // Make the argument nullable
            setState(() {
              selectedDropdownItem = newValue;
              fetchDataForSelectedItem();
            });
          },
        ),
        SizedBox(height: 20),
        Text(
          'Selected Item: ${selectedDropdownItem ?? ""}',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20),
        Text(
          'Fetched Data:',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: fetchedData.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(fetchedData[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
