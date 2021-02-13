import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// TODO This need furthur improvements
class LoadingOverlay {
  BuildContext _context;

  void hide() {
    Navigator.of(_context).pop();
  }

  void show() {
    showDialog(
        context: _context,
        barrierDismissible: false,
        child: _FullScreenLoader());
  }

  Future<T> during<T>(Future<T> future) {
    show();
    return future.whenComplete(() => hide());
  }

  LoadingOverlay._create(this._context);

  factory LoadingOverlay.of(BuildContext context) {
    return LoadingOverlay._create(context);
  }
}

class _FullScreenLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.2)),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(
            5.sp,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(5.sp),
            ),
          ),
          // height: 140.w,
          // width: 140.w,
          child: Image.asset(
            'assets/images/loading.gif',
            fit: BoxFit.fitWidth,
            width: 120.sp,
          ),
          //  Text(
          //   "Please wait ...",
          //   style: TextStyle(
          //     decoration: TextDecoration.none,
          //     color: CustomColors.textNormal,
          //     fontSize: 18.sp,
          //   ),
          // ),
          // Image.asset('assets/images/loading.gif', fit: BoxFit.fitWidth),
        ),
      ),
    );
  }
}
