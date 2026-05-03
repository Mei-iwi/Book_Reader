import 'package:book_reader/presentation/pages/home/home.dart';
import 'package:book_reader/presentation/pages/profile/myprofile.dart';
import 'package:book_reader/presentation/state/category/category_page.dart';
import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<StatefulWidget> createState() => _Homescreen();
}

class _Homescreen extends State<Homescreen> {
  final search = TextEditingController();
  int _index = 0;
  final List<Widget> _pages = [
    Home(),
    CategoryPage(),
    Scaffold(body: Center(child: Text("Đang phát triển "))),
    Myprofile(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.local_library), label: 'Library'),
    BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Communicate'),
    BottomNavigationBarItem(
      icon: Icon(Icons.people_alt_sharp),
      label: 'Profile',
    ),
  ];

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(children: [ListTile(title: Text("Menu"))]),
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() {
          _index = i;
        }),
        items: _navItems,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
