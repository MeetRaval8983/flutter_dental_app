import 'package:flutter/material.dart';
import 'package:new_dental/const.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [brightTurquoise, cerulean ],
              ),
            ),
          ),
          child!,
        ],
      ),
    );
  }
}
