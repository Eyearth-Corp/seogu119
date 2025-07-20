import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seogu119/page/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    print(width);
    print(height);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '서구 골목',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: GoogleFonts.notoSansKr().fontFamily,
      ),
      home: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 2560,
          height: 1440,
          child:  HomePage()
        ),
      ),
    );
  }
}

