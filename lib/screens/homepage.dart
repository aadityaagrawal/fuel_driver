import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  List<dynamic  > orders = [];

  Future<void> getOrders() async {
    orders.clear();
    await db.collection("orders").get().then(
      (querySnapshot) async {

        for (var docSnapshot in querySnapshot.docs) {
          final docRef = db.collection("users").doc(docSnapshot.id);
          var user;

          await docRef.get().then(
            (DocumentSnapshot doc) {
              user = doc.data() as Map<String, dynamic>;
            },
            onError: (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))),
          );

          List<dynamic> ordersData = docSnapshot.data()['orders'];

          for (int i = 0; i < ordersData.length; i++) {
            Map<String, dynamic> data = ordersData[i];
            data["name"] = user['first_name'] + " " + user["second_name"];
            data["mobile_number"] = user['phone_number'];
            orders.add(data);
          }
        }
        orders.sort((a, b) {
    DateTime dateTimeA = DateTime.parse('${a["date"]}');
    DateTime dateTimeB = DateTime.parse('${b["date"]}');
    return dateTimeB.compareTo(dateTimeA);
  });
      },
      onError: (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))),
    );
    
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Orders list"),
      centerTitle: true,
      leading: const Icon(Icons.man),
    ),
    body: FutureBuilder(
      future: getOrders(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return orders.isEmpty
              ? const Center(child: Text('No orders available.'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (BuildContext context, int index) {
                    DateTime dateTime =
                        DateTime.parse(orders[index]["date"]);
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(dateTime);
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Customer Name : ${orders[index]["name"]}"),
                            const SizedBox(height: 8,),
                            Text(
                                "Customer Contact : ${orders[index]["mobile_number"].toString()}"),
                            const SizedBox(height: 8,),
                            Text("Type of fuel : ${orders[index]["type"]}"),
                            const SizedBox(height: 8,),
                            Text("Quantity : ${orders[index]["quantity"]}"),
                            const SizedBox(height: 8,),
                            Text("Delivery date : $formattedDate"),
                            const SizedBox(height: 8,),
                            Text("Delivery time : ${orders[index]["time"]}"),
                          ],
                        ),
                      ),
                    );
                  },
                );
        }
      },
    ),
  );
}
}