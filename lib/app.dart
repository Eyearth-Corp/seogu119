import 'package:flutter/material.dart';
import 'package:seogu119/page/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '서구 골목',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: 1920,
          height: 1080,
          child:  HomePage()
        ),
      ),
    );
  }
}

