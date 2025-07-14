import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_drawer.dart';
import 'making_screen2.dart';
import '../models/candle_data.dart';
import 'login_screen.dart';

class MakingScreen extends StatefulWidget {
  const MakingScreen({super.key});

  @override
  State<MakingScreen> createState() => _MakingScreenState();
}

class _MakingScreenState extends State<MakingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _candleData = CandleData();
  final _sampleNameController = TextEditingController();
  final _newWaxTypeController = TextEditingController();

  // Available wax types (can be modified)
  List<String> availableWaxTypes = ['Soy', 'Coconut', 'Beeswax', 'Parap'];

  // Stream for updating date and time every minute
  Stream<DateTime> _dateTimeStream() async* {
    while (true) {
      yield DateTime.now();
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  @override
  void initState() {
    super.initState();
    // Set userId when initializing CandleData
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _candleData.userId = user.uid;
    }
  }

  @override
  void dispose() {
    _sampleNameController.dispose();
    _newWaxTypeController.dispose();
    super.dispose();
  }

  // Method to add new wax type
  void _addNewWaxType() {
    if (_newWaxTypeController.text.isNotEmpty) {
      setState(() {
        String newWaxType = _newWaxTypeController.text.trim();
        if (!availableWaxTypes.contains(newWaxType)) {
          availableWaxTypes.add(newWaxType);
          _newWaxTypeController.clear();
        }
      });
    }
  }

  // Method to delete wax type
  void _deleteWaxType(String waxType) {
    setState(() {
      availableWaxTypes.remove(waxType);
      _candleData.waxTypes.remove(waxType);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige background
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548), // Brown
        title: const Text(
          'Making',
          style: TextStyle(fontFamily: 'Georgia', color: Colors.white),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          StreamBuilder<DateTime>(
            stream: _dateTimeStream(),
            builder: (context, snapshot) {
              final now = snapshot.data ?? DateTime.now();
              final dateFormatter = DateFormat('MMM d, yyyy');
              final timeFormatter = DateFormat('h:mm a');
              final formattedDate = dateFormatter.format(now);
              final formattedTime = timeFormatter.format(now);

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(currentRoute: '/making'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(12.0),
                  color: const Color(0xFF5D4037).withOpacity(0.1),
                  child: TextFormField(
                    controller: _sampleNameController,
                    decoration: const InputDecoration(
                      labelText: 'Sample Name',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Georgia',
                      color: Color(0xFF5D4037),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a sample name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _candleData.sampleName = value;
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                // Candle Type
                const Text(
                  'Candle Type',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                    color: Color(0xFF5D4037),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _candleData.candleType,
                  hint: const Text('Select Candle Type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Container',
                      child: Text('Container'),
                    ),
                    DropdownMenuItem(value: 'Pillar', child: Text('Pillar')),
                    DropdownMenuItem(value: 'Mould', child: Text('Mould')),
                    DropdownMenuItem(
                      value: 'Free pour',
                      child: Text('Free pour'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _candleData.candleType = value;
                      // Set default wick status based on candle type
                      if (value == 'Container' || value == 'Pillar') {
                        _candleData.isWicked = true;
                      } else {
                        _candleData.isWicked = null;
                      }
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a candle type' : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20.0),
                // Wax Used (Multi-select with Add/Delete functionality)
                const Text(
                  'Wax Used',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 10.0),
                // Add new wax type section
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newWaxTypeController,
                          decoration: const InputDecoration(
                            hintText: 'Add new wax type...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Georgia',
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _addNewWaxType,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF795548),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15.0),
                // Wax types list with checkboxes and delete buttons
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: availableWaxTypes.map((wax) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: Text(
                                  wax,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontFamily: 'Georgia',
                                    color: Color(0xFF5D4037),
                                  ),
                                ),
                                value: _candleData.waxTypes.contains(wax),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      if (!_candleData.waxTypes.contains(wax)) {
                                        _candleData.waxTypes.add(wax);
                                      }
                                    } else {
                                      _candleData.waxTypes.remove(wax);
                                    }
                                  });
                                },
                                activeColor: const Color(0xFF795548),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Show confirmation dialog before deleting
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Delete Wax Type',
                                        style: TextStyle(
                                          fontFamily: 'Georgia',
                                          color: Color(0xFF5D4037),
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to delete "$wax"?',
                                        style: const TextStyle(
                                          fontFamily: 'Georgia',
                                          color: Color(0xFF5D4037),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              fontFamily: 'Georgia',
                                              color: Color(0xFF795548),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _deleteWaxType(wax);
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontFamily: 'Georgia',
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20.0,
                              ),
                              tooltip: 'Delete $wax',
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20.0),
                // Wicked
                if (_candleData.candleType == 'Mould' ||
                    _candleData.candleType == 'Free pour')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wicked',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia',
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      RadioListTile<bool>(
                        title: const Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Georgia',
                            color: Color(0xFF5D4037),
                          ),
                        ),
                        value: true,
                        groupValue: _candleData.isWicked,
                        onChanged: (value) {
                          setState(() {
                            _candleData.isWicked = value;
                          });
                        },
                        activeColor: const Color(0xFF795548),
                      ),
                      RadioListTile<bool>(
                        title: const Text(
                          'No',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Georgia',
                            color: Color(0xFF5D4037),
                          ),
                        ),
                        value: false,
                        groupValue: _candleData.isWicked,
                        onChanged: (value) {
                          setState(() {
                            _candleData.isWicked = value;
                          });
                        },
                        activeColor: const Color(0xFF795548),
                      ),
                    ],
                  )
                else if (_candleData.candleType != null)
                  Text(
                    'Wicked: Yes (Auto)',
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Georgia',
                      color: Color(0xFF5D4037),
                    ),
                  ),
                const SizedBox(height: 20.0),
                // Scented
                const Text(
                  'Scented',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                    color: Color(0xFF5D4037),
                  ),
                ),
                RadioListTile<bool>(
                  title: const Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Georgia',
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  value: true,
                  groupValue: _candleData.isScented,
                  onChanged: (value) {
                    setState(() {
                      _candleData.isScented = value!;
                    });
                  },
                  activeColor: const Color(0xFF795548),
                ),
                RadioListTile<bool>(
                  title: const Text(
                    'No',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Georgia',
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  value: false,
                  groupValue: _candleData.isScented,
                  onChanged: (value) {
                    setState(() {
                      _candleData.isScented = value!;
                    });
                  },
                  activeColor: const Color(0xFF795548),
                ),
                const SizedBox(height: 20.0),
                // Coloured
                const Text(
                  'Coloured',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                    color: Color(0xFF5D4037),
                  ),
                ),
                RadioListTile<bool>(
                  title: const Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Georgia',
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  value: true,
                  groupValue: _candleData.isColoured,
                  onChanged: (value) {
                    setState(() {
                      _candleData.isColoured = value!;
                    });
                  },
                  activeColor: const Color(0xFF795548),
                ),
                RadioListTile<bool>(
                  title: const Text(
                    'No',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Georgia',
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  value: false,
                  groupValue: _candleData.isColoured,
                  onChanged: (value) {
                    setState(() {
                      _candleData.isColoured = value!;
                    });
                  },
                  activeColor: const Color(0xFF795548),
                ),
                const SizedBox(height: 20.0),
                // Next Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _candleData.waxTypes.isNotEmpty &&
                          (_candleData.isWicked != null ||
                              _candleData.candleType == 'Container' ||
                              _candleData.candleType == 'Pillar') &&
                          _candleData.sampleName != null &&
                          _candleData.sampleName!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MakingScreen2(candleData: _candleData),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please complete all fields'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF795548),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: 16.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: const Size.fromHeight(50.0),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
