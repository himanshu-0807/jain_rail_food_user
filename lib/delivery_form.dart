import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:googleapis/authorizedbuyersmarketplace/v1.dart' hide TimeOfDay;

import 'package:railway_food_delivery/notification_services.dart';

class DeliveryForm extends StatefulWidget {
  @override
  _DeliveryFormState createState() => _DeliveryFormState();
}

class _DeliveryFormState extends State<DeliveryForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _trainNumberController = TextEditingController();
  final TextEditingController _compartmentController = TextEditingController();
  final TextEditingController _seatNumberController = TextEditingController();
  final TextEditingController _specialRequestController =
      TextEditingController();

  String _specialRequest = '';

  TimeOfDay? _arrivalTime;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  List<Map<String, dynamic>> selectedItems = [];
  List<Map<String, dynamic>> products = [];
  String selectedStation = 'Solapur'; // Default station selection

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Get the token for this device
    _firebaseMessaging.getToken().then((token) {
      print("Firebase Token: $token");
    }); // Fetch products on initialization
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Show an alert dialog when a notification is received in the foreground
      if (message.notification != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(message.notification!.title ?? 'New Notification'),
              content: Text(message.notification!.body ?? 'No message content'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked!');
      // Handle app navigation or other actions when the user clicks on the notification
    });
  }

  Future<void> fetchProducts() async {
    // Fetch products from the Firestore 'todays_menu' collection
    CollectionReference menuCollection =
        FirebaseFirestore.instance.collection('todays_menu');
    QuerySnapshot querySnapshot = await menuCollection.get();

    setState(() {
      products = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'description': doc['description'],
              })
          .toList();
    });
  }

  Future<void> _selectArrivalTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _arrivalTime) {
      setState(() {
        _arrivalTime = picked;
      });
    }
  }

  void _validateArrivalTime() {
    final now = DateTime.now();
    final selectedTime = DateTime(
      now.year,
      now.month,
      now.day,
      _arrivalTime!.hour,
      _arrivalTime!.minute,
    );

    if (selectedTime.isBefore(now.add(Duration(minutes: 2)))) {
      IconSnackBar.show(context,
          label: 'Arrival time must be at least 1 hour from now',
          snackBarType: SnackBarType.fail);
    } else {
      _submitDeliveryDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Information'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150'), // Replace with user image
                  ),
                  SizedBox(height: 10.h),
                  Text('User Name',
                      style: TextStyle(fontSize: 18.sp, color: Colors.white)),
                  Text('useremail@example.com',
                      style: TextStyle(fontSize: 14.sp, color: Colors.white70)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.person, 'Profile', () {
              // Navigate to profile page
            }),
            _buildDrawerItem(Icons.notification_add_sharp, 'Notifications', () {
              // Navigate to notifications page
            }),
            _buildDrawerItem(Icons.history, 'History', () {
              // Navigate to history page
            }),
            _buildDrawerItem(Icons.policy, 'Policy', () {
              // Navigate to policy page
            }),
            _buildDrawerItem(Icons.help, 'Help', () {
              // Navigate to help page
            }),
            _buildDrawerItem(Icons.feedback, 'Feedback', () {
              // Navigate to feedback page
            }),
            _buildDrawerItem(Icons.logout, 'Logout', () {
              // Handle logout functionality
            }),

            // Add a spacer to push the footer to the bottom
            SizedBox(height: 100.h),

            // Footer text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Aligns text in the center
                children: [
                  Text(
                    "Developed by Developer's Squad",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold, // Makes this text bold
                      color: Colors
                          .grey[700], // Slightly darker gray for visibility
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5.h), // Adds spacing between the two texts
                  Text(
                    "developerssquad23@gmail.com",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey, // Lighter gray for the email
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: 30.h,
                ),
                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  icon: Icons.person,
                ),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  controller: _trainNumberController,
                  label: 'Train Number',
                  icon: Icons.train,
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  controller: _compartmentController,
                  label: 'Compartment',
                  icon: Icons.directions_bus,
                ),
                _buildTextField(
                  controller: _seatNumberController,
                  label: 'Seat Number',
                  icon: Icons.chair,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Station',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.h, horizontal: 12.w),
                    ),
                    value: selectedStation,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStation = newValue!;
                      });
                    },
                    items: <String>['Solapur', 'Gulbarga']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () => _selectArrivalTime(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Arrival Time',
                          prefixIcon:
                              Icon(Icons.access_time, color: Colors.orange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.h, horizontal: 12.w),
                        ),
                        validator: (value) {
                          if (_arrivalTime == null) {
                            return 'Please select arrival time';
                          }
                          return null;
                        },
                        controller: TextEditingController(
                          text: _arrivalTime == null
                              ? ''
                              : _arrivalTime!.format(context),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Select Food and Quantities',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                for (Map<String, dynamic> product in products)
                  ListTile(
                    title:
                        Text("${product['name']} - ${product['description']}"),
                    trailing: SizedBox(
                      width: 150.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                int index = selectedItems.indexWhere(
                                    (item) => item['id'] == product['id']);
                                if (index >= 0 &&
                                    selectedItems[index]['quantity'] > 0) {
                                  selectedItems[index]['quantity']--;
                                }
                              });
                            },
                          ),
                          Text(
                            selectedItems
                                .firstWhere(
                                  (item) => item['id'] == product['id'],
                                  orElse: () => {'quantity': 0},
                                )['quantity']
                                .toString(),
                            style: TextStyle(fontSize: 18.sp),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              setState(() {
                                int index = selectedItems.indexWhere(
                                    (item) => item['id'] == product['id']);
                                if (index >= 0) {
                                  selectedItems[index]['quantity']++;
                                } else {
                                  selectedItems.add({
                                    'id': product['id'],
                                    'name': product['name'],
                                    'quantity': 1,
                                  });
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                TextFormField(
                  controller: _specialRequestController,
                  decoration: InputDecoration(
                    labelText: 'Special Request (Optional)',
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: 200, // Reduce the width as needed
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _validateArrivalTime();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                    ),
                    child: Text(
                      'Request',
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.h, horizontal: 12.w),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  void _submitDeliveryDetails() async {
    if (_formKey.currentState!.validate()) {
      // Prepare the form data
      final String name = _nameController.text;
      final String phone = _phoneController.text;
      final String trainNumber = _trainNumberController.text;
      final String compartment = _compartmentController.text;
      final String seatNumber = _seatNumberController.text;

      // Ensure arrival time is selected before submitting
      if (_arrivalTime == null) {
        IconSnackBar.show(context,
            label: 'Please select an arrival time.',
            snackBarType: SnackBarType.alert);
        return;
      }

      // Format the selected time
      String formattedArrivalTime =
          "${_arrivalTime!.hourOfPeriod}:${_arrivalTime!.minute.toString().padLeft(2, '0')} ${_arrivalTime!.period == DayPeriod.am ? 'AM' : 'PM'}";

      // Generate a unique request ID
      String requestId =
          FirebaseFirestore.instance.collection('requests').doc().id;

      String? deviceToken = await FirebaseMessaging.instance.getToken();

      // Create the document data
      Map<String, dynamic> requestData = {
        'name': name,
        'phone': phone,
        'trainNumber': trainNumber,
        'compartment': compartment,
        'seatNumber': seatNumber,
        'station': selectedStation, // Include selected station
        'selectedItems':
            selectedItems, // Include selected products with quantities
        'timestamp':
            FieldValue.serverTimestamp(), // Add timestamp for order tracking
        'requestId': requestId,
        'deviceToken': deviceToken,
        'status': 'Pending...',
        'specialRequest': _specialRequestController.text,
        'arrivalTime': formattedArrivalTime // Save the arrival time
      };

      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('todays_shifts')
          .doc('shifts')
          .get();

      if (snap.exists) {
        Map<String, dynamic>? data = snap.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('active_facilitator')) {
          String? facilitatorToken = data['active_facilitator']['deviceToken'];
          if (facilitatorToken != null) {
            print(facilitatorToken);
            NotificationServices.sendNotificationToSelectedDriver(
                facilitatorToken, context);
          } else {
            print('Facilitator Token not found');
          }
        } else {
          print('Active Facilitator data not found');
        }
      } else {
        print('Document does not exist');
      }

      try {
        // Save the data to Firestore
        await FirebaseFirestore.instance
            .collection('requests')
            .doc(requestId)
            .set(requestData);

        // Show success message
        IconSnackBar.show(context,
            label: 'Delivery details and selected items submitted!',
            snackBarType: SnackBarType.success);

        // Clear form after submission
        _nameController.clear();
        _phoneController.clear();
        _trainNumberController.clear();
        _compartmentController.clear();
        _seatNumberController.clear();

        _specialRequestController.clear();
        setState(() {
          selectedItems = [];
          _arrivalTime = null; // Clear arrival time after submission
          selectedStation = 'Solapur';
        });
      } catch (e) {
        // Show error message if submission fails
        IconSnackBar.show(context,
            label: 'Failed to submit: $e', snackBarType: SnackBarType.fail);
      }
    }
  }

  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: TextStyle(fontSize: 16.sp)),
      onTap: onTap,
    );
  }
}
