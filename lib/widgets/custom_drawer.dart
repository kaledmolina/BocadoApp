import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/tables_screen.dart';
import '../screens/waiters_screen.dart';

class CustomDrawer extends StatefulWidget {
  final String currentRoute;
  const CustomDrawer({super.key, this.currentRoute = 'home'});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isDarkMode = false;
  bool _isWaiterView = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.role == 'admin';

    // Apply colors based on mock dark mode state
    final bgColor = _isDarkMode ? const Color(0xFF111827) : Colors.white; // gray-900
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final cardColor = _isDarkMode ? const Color(0xFF1F2937) : Colors.white; // gray-800
    final borderColor = _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.amber],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'b!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'bocado!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        isAdmin ? 'ADMINISTRACIÓN' : 'MESERO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: subTextColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: [
                  _buildDrawerItem(Icons.dashboard, 'Dashboard', widget.currentRoute == 'home', textColor, () {
                    if (widget.currentRoute == 'home') return Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  }),
                  if (isAdmin) ...[
                    _buildDrawerItem(Icons.restaurant_menu, 'Menú / Platos', widget.currentRoute == 'menu', subTextColor, () {
                      if (widget.currentRoute == 'menu') return Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const MenuScreen()),
                      );
                    }),
                    _buildDrawerItem(Icons.qr_code, 'Mesas & QRs', widget.currentRoute == 'tables', subTextColor, () {
                      if (widget.currentRoute == 'tables') return Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const TablesScreen()),
                      );
                    }),
                    _buildDrawerItem(Icons.people, 'Meseros', widget.currentRoute == 'waiters', subTextColor, null),
                  ],
                  _buildDrawerItem(Icons.list_alt, 'Pedidos', false, subTextColor, null),
                  if (isAdmin) ...[
                    _buildDrawerItem(Icons.attach_money, 'Caja', false, subTextColor, null),
                    _buildDrawerItem(Icons.settings, 'Configuración', false, subTextColor, null),
                  ],
                ],
              ),
            ),

            Divider(height: 1, color: borderColor),

            // Bottom Actions (Theme, Role Toggle & Profile)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Theme Toggle
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isDarkMode = !_isDarkMode;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Modo oscuro UI mock toggle (Requiere ThemeProvider global)'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: cardColor,
                      side: BorderSide(color: borderColor),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Modo ${_isDarkMode ? "Claro" : "Oscuro"}',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Icon(
                          _isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                          size: 16,
                          color: _isDarkMode ? Colors.amber : Colors.indigoAccent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // User Profile Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (!_isDarkMode)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [Colors.orangeAccent, Colors.orange],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  user?.name.substring(0, 2).toUpperCase() ?? 'NA',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? 'Usuario',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: textColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    user?.email ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                      color: subTextColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Admin toggle waiter view
                        if (isAdmin) ...[
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isWaiterView = !_isWaiterView;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isDarkMode ? Colors.orange.shade900.withOpacity(0.2) : Colors.orange.shade50,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: _isDarkMode ? Colors.orange.shade900.withOpacity(0.5) : Colors.orange.shade200.withOpacity(0.5)
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _isWaiterView ? '🧑‍🍳 Volver a Admin' : '🧑‍🍳 Vista Mesero',
                                  style: TextStyle(
                                    color: _isDarkMode ? Colors.orange.shade400 : Colors.orange.shade700,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade600,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'ADMIN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        ElevatedButton.icon(
                          onPressed: () async {
                            await context.read<AuthProvider>().logout();
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            }
                          },
                          icon: const Icon(Icons.logout, size: 16, color: Colors.redAccent),
                          label: const Text(
                            'Cerrar Sesión',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isDarkMode ? Colors.red.shade900.withOpacity(0.2) : Colors.red.shade50,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isActive, Color textColor, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive ? Colors.orange.withOpacity(0.1) : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.orange : textColor,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            color: isActive ? Colors.orange.shade700 : textColor,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
