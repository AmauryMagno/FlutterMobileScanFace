import 'package:flutter/material.dart';
import 'package:mobile_scanface/pages/register_face.dart';
import 'package:mobile_scanface/pages/scan_face.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const ScanFace(title: 'ScanFace', color: Colors.blue),
    const RegisterFace(title: 'RegisterFace', color: Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Face'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Cabeçalho do Drawer
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'João Silva',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'joao@email.com',
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Itens do menu
              _buildDrawerItem(icon: Icons.login, title: 'ScanFace', index: 0),
              _buildDrawerItem(
                icon: Icons.create,
                title: 'RegisterFace',
                index: 1,
              ),
              const Divider(),
              _buildDrawerItem(
                icon: Icons.help,
                title: 'Help',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abrindo tela de Ajuda')),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Exit',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saindo do aplicativo...')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: _screens[_currentIndex],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    int? index,
    VoidCallback? onTap,
  }) {
    final bool isSelected = index != null && index == _currentIndex;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap:
          onTap ??
          () {
            if (index != null) {
              setState(() {
                _currentIndex = index;
              });
            }
            Navigator.pop(context);
          },
      selected: isSelected,
      selectedTileColor: Colors.blue.withAlpha(25),
    );
  }
}
