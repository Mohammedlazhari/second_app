import 'package:app_chef/List_dishes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class GetOrder extends StatefulWidget {
  @override
  _GetOrderState createState() => _GetOrderState();
}

class _GetOrderState extends State<GetOrder> {
  String? currentDate;
  List<Order> orders = []; // List to store orders
  List<CompletOrder> completed_order = [];
  DatabaseReference dbref =
      FirebaseDatabase.instance.reference().child('orders');
  DatabaseReference dbref2 =
      FirebaseDatabase.instance.reference().child('test');
  // List<String> upnames = [];
  // List<int> upprices = [];
  String orderKey = '';
  @override
  void initState() {
    super.initState();
    dbref.onValue.listen((event) async {
      if (event.snapshot.value != null) {
        var data = event.snapshot.value;
        if (data != null && data is Map) {
          List<Order> newOrders = [];
          data.forEach((key, value) {
            if (key.compareTo(orderKey) > 0) {
              // Compare order keys to get only the new orders
              Order order = Order(
                currentDate: value['Date of Command'],
                commandName: value['commandName'],
                tableNumber: value['tableNumber'],
                selectedItems: List<String>.from(value['selectedItems']),
                itemQuantities: List<int>.from(value['itemQuantities']),
              );
              newOrders.add(order);
              if (key.compareTo(orderKey) > 0) {
                orderKey = key; // Update the last processed order key
              }
            }
          });

          if (newOrders.isNotEmpty) {
            setState(() {
              orders.addAll(
                  newOrders); // Add new orders to the existing orders list

              // Modify and push new orders to completed_order
              for (int i = completed_order.length; i < orders.length; i++) {
                List<String> upnames = [];
                List<int> upprices = [];
                getDishData(
                  orders[i].selectedItems,
                  upnames,
                  upprices,
                );
                CompletOrder nem_order = CompletOrder(
                  currentDate: orders[i].currentDate,
                  commandName: orders[i].commandName,
                  tableNumber: orders[i].tableNumber,
                  itemQuantities: orders[i].itemQuantities,
                  Upnames: upnames,
                  Upprices: upprices,
                );
                completed_order.add(nem_order);

                print(upnames);
                print("///////////////////////////");
                print(completed_order[i].Upnames);
              }
            });
          }
        }
      }
    });
  }

  Future<void> getDishData(
    List<String> items,
    List<String> upnames,
    List<int> upprices,
  ) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Dishes').get();
    List<String> codes = [];
    List<String> names = [];
    List<int> prices = [];

    querySnapshot.docs.forEach((document) {
      Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
      if (data != null) {
        String code = data['code'] ?? '';
        String name = data['name'] ?? '';
        int price = data['price'] ?? 0;

        codes.add(code);
        names.add(name);
        prices.add(price);
      }
    });

    upnames.clear();
    upprices.clear();

    for (int i = 0; i < items.length; i++) {
      for (int j = 0; j < codes.length; j++) {
        if (items[i] == codes[j]) {
          upnames.add(names[j]);
          upprices.add(prices[j]);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              color: Colors.red.shade400,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: NetworkImage(
                      'https://cdn.vectorstock.com/i/1000x1000/70/93/restaurant-logo-diner-cafe-or-cook-chef-vector-8517093.webp',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'App Chef',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
            SizedBox(height: 15),
            ListTile(
              title: Text('List Of Dishes'),
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const List_dishes(),
                ),
              ),
            ),
            ListTile(
              title: Text('Update List Of Dishes'),
              onTap: () {
                // Handle drawer item 2 tap
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) => InkWell(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.white,
                          width: 8,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(Icons.menu_outlined),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    // Handle double-click on order
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Options'),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    // Handle send option
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Send'),
                                ),
                                SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () {
                                    // Handle print option
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Print'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 8,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(Icons.notifications),
                  ),
                ),
              ],
            ),
          ),
          Text(
            "The Orders",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                completed_order.length,
                (index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      Container(
                        width: size.width - 50,
                        height: size.height / 1.4,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 20,
                            top: 10,
                            right: 20,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "restaurantName",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "-----------------------------------",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      "Command Name: ${completed_order[index].commandName}",
                                      style: TextStyle(
                                        fontSize: 24,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Table Number: ${completed_order[index].tableNumber}",
                                      style: TextStyle(
                                        fontSize: 24,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "-----------------------------------",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: size.width / 14,
                                            ),
                                            Text(
                                              "Items",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width / 4,
                                            ),
                                            Text(
                                              "Qte",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width / 20,
                                            ),
                                            Text(
                                              "Price",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: size.width / 11,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                for (int i = 0;
                                                    i <
                                                        completed_order[index]
                                                            .Upnames
                                                            .length;
                                                    i++)
                                                  Text(
                                                    "${completed_order[index].Upnames[i]}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: size.width / 4.2,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                for (int i = 0;
                                                    i <
                                                        completed_order[index]
                                                            .itemQuantities
                                                            .length;
                                                    i++)
                                                  Text(
                                                    "* ${completed_order[index].itemQuantities[i]}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: size.width / 10,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                for (int i = 0;
                                                    i <
                                                        completed_order[index]
                                                            .Upprices
                                                            .length;
                                                    i++)
                                                  Text(
                                                    "${completed_order[index].Upprices[i].toString()}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Date of Command: ${completed_order[index].currentDate}",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(children: [
                        SizedBox(width: 5),
                        IconButton(
                            icon: Icon(Icons.print),
                            iconSize: 40,
                            color: Colors.red.shade400,
                            onPressed: () {}),
                        SizedBox(width: size.width / 1.9),
                        IconButton(
                            icon: Icon(Icons.send_rounded),
                            iconSize: 45,
                            color: Colors.red.shade400,
                            onPressed: () {}),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Order {
  final String? currentDate;
  final String? commandName;
  final String? tableNumber;
  final List<String> selectedItems;
  final List<int> itemQuantities;

  Order({
    this.currentDate,
    this.commandName,
    this.tableNumber,
    required this.selectedItems,
    required this.itemQuantities,
  });
}

class CompletOrder {
  final String? currentDate;
  final String? commandName;
  final String? tableNumber;
  // final List<String> selectedItems;
  final List<int> itemQuantities;
  final List<String> Upnames;
  final List<int> Upprices;
  CompletOrder({
    this.currentDate,
    this.commandName,
    this.tableNumber,
    // required this.selectedItems,
    required this.itemQuantities,
    required this.Upnames,
    required this.Upprices,
  });
}
