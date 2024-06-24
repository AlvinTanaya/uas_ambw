import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uas_ambw/services/pin_handler.dart';

import 'home_page.dart';

class PinSetup extends StatefulWidget {
  @override
  _PinSetupState createState() => _PinSetupState();
}

class _PinSetupState extends State<PinSetup> {
  final List<String> _pin = [];
  final List<String> _confirmPin = [];
  final int _pinLength = 6;
  bool _isConfirming = false;

  void _onKeyPress(String value) {
    setState(() {
      if (value == 'delete') {
        if (_isConfirming) {
          if (_confirmPin.isNotEmpty) {
            _confirmPin.removeLast();
          }
        } else {
          if (_pin.isNotEmpty) {
            _pin.removeLast();
          }
        }
      } else {
        if (_isConfirming) {
          if (_confirmPin.length < _pinLength) {
            _confirmPin.add(value);
            if (_confirmPin.length == _pinLength) {
              _verifyPin();
            }
          }
        } else {
          if (_pin.length < _pinLength) {
            _pin.add(value);
            if (_pin.length == _pinLength) {
              setState(() {
                _isConfirming = true;
              });
            }
          }
        }
      }
    });
  }

  void _verifyPin() async {
    String enteredPin = _pin.join('');
    String enteredConfirmPin = _confirmPin.join('');
    if (enteredPin == enteredConfirmPin) {
      await PinHandler.setPin(enteredPin);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('PINs do not match'),
      ));
      setState(() {
        _pin.clear();
        _confirmPin.clear();
        _isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812), minTextAdapt: true);

    return Scaffold(
      appBar: AppBar(
          // title: Text('Setup PIN'),
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isConfirming ? 'Confirm your PIN' : 'Enter a new PIN',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Text(
              _isConfirming
                  ? 'Please confirm your new PIN.'
                  : 'Please enter a new 6-digit PIN.',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index <
                            (_isConfirming ? _confirmPin.length : _pin.length)
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
