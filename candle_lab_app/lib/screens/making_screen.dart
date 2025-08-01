import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_drawer.dart';
import 'making_screen2.dart';
import '../models/candle_data.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';
import 'dart:async';

class MakingScreen extends StatefulWidget {
  final CandleData? initialCandleData;
  const MakingScreen({super.key, this.initialCandleData});

  @override
  State<MakingScreen> createState() => _MakingScreenState();
}

class _MakingScreenState extends State<MakingScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late CandleData _candleData;
  final _sampleNameController = TextEditingController();
  final _newWaxTypeController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isContentVisible = false;
  List<String> availableWaxTypes = ['Soy', 'Coconut', 'Beeswax', 'Parap'];
  String? _sampleNameError;

  Stream<DateTime> _dateTimeStream() async* {
    while (true) {
      yield DateTime.now();
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  @override
  void initState() {
    super.initState();
    _candleData = widget.initialCandleData ?? CandleData();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _candleData.userId = user.uid;
    }
    _sampleNameController.text = _candleData.sampleName ?? '';
    _sampleNameController.addListener(() {
      // Only check for duplicates, not empty input, during typing
      if (_sampleNameController.text.isNotEmpty) {
        _checkSampleName(_sampleNameController.text, isSubmission: false);
      } else {
        setState(() {
          _sampleNameError =
              null; // Clear error when field is empty during typing
        });
      }
    });
    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isContentVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _sampleNameController.dispose();
    _newWaxTypeController.dispose();
    super.dispose();
  }

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

  void _deleteWaxType(String waxType) {
    setState(() {
      availableWaxTypes.remove(waxType);
      _candleData.waxTypes.remove(waxType);
    });
  }

  Future<void> _clearAllData() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Clear All Data',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to clear all entered data? This action cannot be undone.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _candleData = widget.initialCandleData ?? CandleData();
                  _sampleNameController.clear();
                  _newWaxTypeController.clear();
                  _sampleNameError = null;
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    _candleData.userId = user.uid;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data has been cleared.')),
                );
              },
              child: Text(
                'Clear',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkSampleName(
    String value, {
    required bool isSubmission,
  }) async {
    if (isSubmission && value.isEmpty) {
      setState(() {
        _sampleNameError = 'Please enter a sample name';
      });
      return;
    }

    if (value.isEmpty) {
      setState(() {
        _sampleNameError = null; // No error for empty field during typing
      });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _sampleNameError = 'User not authenticated';
      });
      return;
    }

    try {
      final candles = await _firestoreService.getAllCandleData();
      final exists = candles.any(
        (candle) =>
            candle.sampleName == value &&
            candle.userId == user.uid &&
            candle.id != (widget.initialCandleData?.id ?? ''),
      );
      setState(() {
        _sampleNameError = exists ? 'Sample name already exists' : null;
        if (!exists && isSubmission) {
          _candleData.sampleName = value;
        }
      });
    } catch (e) {
      setState(() {
        _sampleNameError = 'Error checking sample name';
      });
    }
  }

  Function(String) _debounce(Function(String) callback, Duration duration) {
    Timer? timer;
    return (String value) {
      timer?.cancel();
      timer = Timer(duration, () => callback(value));
    };
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final cardDecoration = BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Making'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: StreamBuilder<int>(
              stream: NotificationService.unreadCountStream,
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                return Stack(
                  children: [
                    const Icon(Icons.menu, color: Colors.white),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
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
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
          child: AnimatedOpacity(
            opacity: _isContentVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sample Name', style: textTheme.titleLarge),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: _sampleNameController,
                          decoration: InputDecoration(
                            hintText: 'Enter a name for your sample',
                            errorText: _sampleNameError,
                            errorStyle: TextStyle(color: colorScheme.error),
                          ),
                          style: textTheme.bodyLarge,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a sample name';
                            }
                            if (_sampleNameError ==
                                'Sample name already exists') {
                              return _sampleNameError;
                            }
                            return null;
                          },
                          onChanged: _debounce(
                            (value) =>
                                _checkSampleName(value, isSubmission: false),
                            const Duration(milliseconds: 500),
                          ),
                          onFieldSubmitted: (value) {
                            _checkSampleName(value, isSubmission: true);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Candle Type', style: textTheme.titleLarge),
                        const SizedBox(height: 8.0),
                        DropdownButtonFormField<String>(
                          value: _candleData.candleType,
                          hint: const Text('Select Candle Type'),
                          items: const [
                            DropdownMenuItem(
                              value: 'Container',
                              child: Text('Container'),
                            ),
                            DropdownMenuItem(
                              value: 'Pillar',
                              child: Text('Pillar'),
                            ),
                            DropdownMenuItem(
                              value: 'Mould',
                              child: Text('Mould'),
                            ),
                            DropdownMenuItem(
                              value: 'Free pour',
                              child: Text('Free pour'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _candleData.candleType = value;
                              _candleData.isWicked =
                                  (value == 'Container' || value == 'Pillar')
                                  ? true
                                  : null;
                            });
                          },
                          validator: (value) => value == null
                              ? 'Please select a candle type'
                              : null,
                          decoration: const InputDecoration(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Wax Used', style: textTheme.titleLarge),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newWaxTypeController,
                                decoration: InputDecoration(
                                  hintText: 'Add new wax type...',
                                  hintStyle: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Color(0xFFF5F5DC),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Color(0xFF795548),
                                      width: 2.0,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Color(0xFFF5F5DC),
                                    ),
                                  ),

                                  // border: const OutlineInputBorder(),
                                  filled: false,
                                ),
                                style: textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            ElevatedButton(
                              onPressed: _addNewWaxType,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                textStyle: textTheme.bodyMedium,
                              ),
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15.0),
                        Container(
                          decoration: cardDecoration,
                          child: Column(
                            children: availableWaxTypes.map((wax) {
                              return CheckboxListTile(
                                title: Text(wax, style: textTheme.bodyLarge),
                                value: _candleData.waxTypes.contains(wax),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true)
                                      _candleData.waxTypes.add(wax);
                                    else
                                      _candleData.waxTypes.remove(wax);
                                  });
                                },
                                activeColor: colorScheme.primary,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                secondary: IconButton(
                                  onPressed: () => _deleteWaxType(wax),
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: colorScheme.error,
                                    size: 22.0,
                                  ),
                                  tooltip: 'Delete $wax',
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    child:
                        (_candleData.candleType == 'Mould' ||
                            _candleData.candleType == 'Free pour')
                        ? _buildRadioGroup(
                            key: const ValueKey('wicked_selection'),
                            title: 'Wicked',
                            groupValue: _candleData.isWicked,
                            onChanged: (value) =>
                                setState(() => _candleData.isWicked = value),
                          )
                        : (_candleData.candleType != null)
                        ? Container(
                            key: const ValueKey('wicked_auto'),
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                    text: 'Wicked: ',
                                    style: textTheme.titleLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Yes',
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme
                                          .onSurface, // Or any default
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(
                            key: const ValueKey('wicked_empty'),
                          ),
                  ),
                  const SizedBox(height: 24.0),
                  _buildRadioGroup(
                    title: 'Scented',
                    groupValue: _candleData.isScented,
                    onChanged: (value) =>
                        setState(() => _candleData.isScented = value!),
                  ),
                  const SizedBox(height: 24.0),
                  _buildRadioGroup(
                    title: 'Coloured',
                    groupValue: _candleData.isColoured,
                    onChanged: (value) =>
                        setState(() => _candleData.isColoured = value!),
                  ),
                  const SizedBox(height: 32.0),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearAllData,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.error),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          child: Text(
                            'Clear',
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await _checkSampleName(
                              _sampleNameController.text,
                              isSubmission: true,
                            );
                            if (_formKey.currentState!.validate() &&
                                _candleData.waxTypes.isNotEmpty &&
                                _candleData.isWicked != null &&
                                _sampleNameError == null) {
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
                                  content: Text(
                                    'Please complete all required fields and ensure a unique sample name.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Next'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioGroup({
    Key? key,
    required String title,
    required bool? groupValue,
    required ValueChanged<bool?> onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleLarge),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: Text('Yes', style: textTheme.bodyLarge),
                  value: true,
                  groupValue: groupValue,
                  onChanged: onChanged,
                  activeColor: colorScheme.primary,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: Text('No', style: textTheme.bodyLarge),
                  value: false,
                  groupValue: groupValue,
                  onChanged: onChanged,
                  activeColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
