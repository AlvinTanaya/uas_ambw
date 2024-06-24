import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uas_ambw/services/pin_handler.dart';

import 'home_page.dart';
import 'pin_setup.dart';

class PinLogin extends StatefulWidget {
  @override
  _PinLoginState createState() => _PinLoginState();
}

class _PinLoginState extends State<PinLogin> {
  final List<String> _pin = [];
  final int _pinLength = 6;
  String? _storedPin;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    String? pin = await PinHandler.getPin();
    setState(() {
      _storedPin = pin;
    });
  }

  void _onKeyPress(String value) {
    setState(() {
      if (value == 'delete') {
        if (_pin.isNotEmpty) {
          _pin.removeLast();
        }
      } else if (_pin.length < _pinLength) {
        _pin.add(value);
        if (_pin.length == _pinLength) {
          _verifyPin();
        }
      }
    });
  }

  void _verifyPin() async {
    String enteredPin = _pin.join('');
    bool isValid = await PinHandler.verifyPin(enteredPin);
    if (isValid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid PIN'),
      ));
      setState(() {
        _pin.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812), minTextAdapt: true);

    if (_storedPin == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_storedPin!.isEmpty) {
      return PinSetup();
    }

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome back!',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Text(
              "Let's unlock your data.",
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
            SizedBox(height: 30.h),
            Text(
              'Enter PIN code',
              style: TextStyle(fontSize: 18.sp),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length
                        ? Colors.purpleAccent.shade200
                        : Colors.grey[300],
                  ),
                );
              }),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) {
                    return SizedBox.shrink();
                  } else if (index == 10) {
                    return _buildNumberButton('0');
                  } else if (index == 11) {
                    return _buildNumberButton('delete', isDelete: true);
                  } else {
                    return _buildNumberButton('${index + 1}');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number, {bool isDelete = false}) {
    return GestureDetector(
      onTap: () => _onKeyPress(number),
      child: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: Center(
          child: isDelete
              ? Icon(Icons.backspace_outlined, size: 24.w)
              : Text(
                  number,
                  style:
                      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
