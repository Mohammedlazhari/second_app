import 'package:app_chef/HomePage.dart';
// import 'package:firebase_database/ui/firebase_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class List_dishes extends StatefulWidget {
  const List_dishes({Key? key});

  @override
  State<List_dishes> createState() => _List_dishesState();
}

class _List_dishesState extends State<List_dishes> {
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _priceController;
  late TextEditingController _availabilityController;
  bool _isAddingDish = false;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController();
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _priceController = TextEditingController();
    _availabilityController = TextEditingController();
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    _priceController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('List Dishes'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _isAddingDish = true;
              });
            },
          ),
        ],
      ),
      floatingActionButton: null,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Dishes').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final dishes = snapshot.data!.docs;

          final List<String> dishNames =
              dishes.map((document) => document['name'] as String).toList();
          final List<String> dishCodes =
              dishes.map((document) => document['code'] as String).toList();
          final List<int> dishPrices =
              dishes.map((document) => document['price'] as int).toList();
          final List<String> dishAvailability = dishes
              .map((document) => document['available'] as String)
              .toList();

          final List<String> dishIds =
              dishes.map((document) => document.id).toList();

          return  ListView.builder(
            itemCount:
                _isAddingDish ? dishNames.length + 2 : dishNames.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                // Display the header row with text labels
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 35,
                        child: Text(
                          'ID',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('Name',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Text('Code',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Text('Price',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Text('Available',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              } else if (index == 1 && _isAddingDish) {
                // Display the form to add a new dish
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add a Dish',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _idController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'ID',
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: 'Code',
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price',
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _availabilityController,
                        decoration: InputDecoration(
                          labelText: 'Availability',
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final dishId = _idController.text;
                          final dishName = _nameController.text;
                          final dishCode = _codeController.text;
                          final dishPrice =
                              int.tryParse(_priceController.text) ?? 0;
                          final dishAvailability = _availabilityController.text;

                          if (dishId.isNotEmpty &&
                              dishName.isNotEmpty &&
                              dishCode.isNotEmpty &&
                              dishPrice > 0 &&
                              dishAvailability.isNotEmpty) {
                            FirebaseFirestore.instance
                                .collection('Dishes')
                                .doc(dishId)
                                .set({
                              'id': dishId,
                              'name': dishName,
                              'code': dishCode,
                              'price': dishPrice,
                              'available': dishAvailability,
                            });

                            setState(() {
                              _isAddingDish = false;
                            });
                          }
                        },
                        child: Text('Add Dish'),
                      ),
                    ],
                  ),
                );
              }

              final dishIndex = _isAddingDish ? index - 2 : index - 1;

              final dishId = dishIds[dishIndex];
              final dishName = dishNames[dishIndex];
              final dishCode = dishCodes[dishIndex];
              final dishPrice = dishPrices[dishIndex];
              final dishAvailable = dishAvailability[dishIndex];
               //delete
              return Dismissible(
                key: Key(dishId),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Confirm'),
                        content:
                            Text('Are you sure you want to delete this dish?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  FirebaseFirestore.instance
                      .collection('Dishes')
                      .doc(dishId)
                      .delete();
                },
                background: Container(
                  color: Colors.red,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 16.0),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 35,
                        child: Text(
                          dishId,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Text(dishName)),
                      Expanded(child: Text(dishCode)),
                      Expanded(child: Text(dishPrice.toString())),
                      Expanded(child: Text(dishAvailable.toString())),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
