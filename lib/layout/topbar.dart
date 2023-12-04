import 'package:flutter/material.dart';

import '../modules/calc/screens/calc.dart';
import '../modules/home/screens/home.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Top Navigation"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.calculate)),
              Tab(icon: Icon(Icons.photo_album))
            ]
          )
        ),
        body: TabBarView(
          children: [
            const Home(),
            const Calc(),
            Container(child: const Text("Em Construção"))
          ],
        )
      )
    );
  }

  
}