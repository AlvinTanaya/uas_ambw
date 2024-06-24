import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uas_ambw/services/pin_handler.dart';

import 'home_page.dart';

class PinChange extends StatefulWidget {
  @override
  _PinChangeState createState() => _PinChangeState();
}

class _PinChangeState extends State<PinChange> {
  final List<String> _oldPin = [];
  final List<String> _newPin = [];
  final List<String> _confirmPin = [];
  final int _pinLength = 6;
  bool _isSettingNewPin = false;
  bool _isConfirmingNewPin = false;

  void _onKeyPress(String value) {
    setState(() {
      if (value == 'delete') {
        if (_isConfirmingNewPin) {
          if (_confirmPin.isNotEmpty) {
            _confirmPin.removeLast();
          }
        } else if (_isSettingNewPin) {
          if (_newPin.isNotEmpty) {
            _newPin.removeLast();
          }
        } else {
          if (_oldPin.isNotEmpty) {
            _oldPin.removeLast();
          }
        }
      } else {
        if (_isConfirmingNewPin) {
          if (_confirmPin.length < _pinLength) {
            _confirmPin.add(value);
            if (_confirmPin.length == _pinLength) {
              _verifyPin();
            }
          }
        } else if (_isSettingNewPin) {
          if (_newPin.length < _pinLength) {
            _newPin.add(value);
            if (_newPin.length == _pinLength) {
              setState(() {
                _isConfirmingNewPin = true;
              });
            }
          }
        } else {
          if (_oldPin.length < _pinLength) {
            _oldPin.add(value);
            if (_oldPin.length == _pinLength) {
              _verifyOldPin();
            }
          }
        }
      }
    });
  }

  void _verifyOldPin() async {
    String enteredOldPin = _oldPin.join('');
    bool isValid = await PinHandler.verifyPin(enteredOldPin);
    if (isValid) {
      setState(() {
        _isSettingNewPin = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid old PIN'),
      ));
      setState(() {
        _oldPin.clear();
      });
    }
  }

  void _verifyPin() async {
    String enteredNewPin = _newPin.join('');
    String enteredConfirmPin = _confirmPin.join('');
    if (enteredNewPin == enteredConfirmPin) {
      await PinHandler.setPin(enteredNewPin);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('PINs do not match'),
      ));
      setState(() {
        _newPin.clear();
        _confirmPin.clear();
        _isSettingNewPin = false;
        _isConfirmingNewPin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812), minTextAdapt: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('Change PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isConfirmingNewPin
                  ? 'Confirm your new PIN'
                  : _isSettingNewPin
                      ? 'Enter a new PIN'
                      : 'Enter your old PIN',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Text(
              _isConfirmingNewPin
                  ? 'Please confirm your new PIN.'
                  : _isSettingNewPin
                      ? 'Please enter a new 6-digit PIN.'
                      : 'Please enter your old 6-digit PIN.',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                int length = _isConfirmingNewPin
                    ? _confirmPin.length
                    : _isSettingNewPin
                        ? _newPin.length
                        : _oldPin.length;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < length
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
