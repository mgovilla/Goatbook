import 'package:flutter/cupertino.dart';

class LoadingView extends StatefulWidget {
  const LoadingView();

  @override
  _LoadingViewState createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  @override
  Widget build(BuildContext ctx) {
    return Container(
        child: Text("Loading...", textDirection: TextDirection.ltr));
  }
}
