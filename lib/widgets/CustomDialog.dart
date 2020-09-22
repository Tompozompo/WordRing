import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Widget child;

  CustomDialog({@required this.child, });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
            ),
            insetPadding: EdgeInsets.symmetric(vertical: 100, horizontal: 50),
            child: Container(
                height: double.infinity,
                width: double.infinity,
                child: this.child
            )
        )
    );
  }
}