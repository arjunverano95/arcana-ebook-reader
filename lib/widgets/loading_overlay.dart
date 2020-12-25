import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(
            25.sp,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.all(
            //   Radius.circular(10.sp),
            // ),
          ),
          // height: 140.w,
          // width: 140.w,
          child: Text(
            "Please wait ...",
            style: TextStyle(
              color: CustomColors.textNormal,
              fontSize: 18.sp,
            ),
          ),
          // Image.asset('assets/images/loading.gif', fit: BoxFit.fitWidth),
        ),
      ),
    );
  }
}
