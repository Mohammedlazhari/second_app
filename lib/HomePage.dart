import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



import 'Order.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    return Scaffold(
      body: ListView(
        children: [
          // App Bar
          // Container(height: kToolbarHeight, child: AppBar1()),

          // Order List
          Container(
            height: MediaQuery.of(context).size.height,
            // Set the height of the order list
            child: GetOrder(),
          ),
        ],
      ),
      // drawer: const NavigationDrawer(),
    );
  }
}

// class NavigationDrawer extends StatelessWidget {
//   const NavigationDrawer({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) => Drawer(
//       child: SingleChildScrollView(
//           child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[]) // <Widget>[]
//           ));
// }
