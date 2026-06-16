import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/custom_drawer.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isDemoUser = user != null && 
      ['owner@rinconcito.com', 'pedro@rinconcito.com', 'maria@rinconcito.com'].contains(user.email);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Panel de Control',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<DashboardProvider>().fetchDashboard();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Alerts Section
              _buildAlertCard(),
              const SizedBox(height: 24),

              // Metrics Grid (2x2)
              _buildDashboardMetrics(),
              const SizedBox(height: 24),

              // Active Tables
              _buildActiveTablesSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: isDemoUser ? FloatingActionButton.extended(
        onPressed: () async {
          await context.read<AuthProvider>().logout();
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        backgroundColor: Colors.orange.shade600,
        icon: const Icon(Icons.autorenew, color: Colors.white),
        label: const Text(
          'Cambiar Rol Demo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ) : null,
    );
  }

  Widget _buildAlertCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('📢', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ALERTAS EN TIEMPO REAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Las solicitudes se actualizan automáticamente.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardMetrics() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.metrics == null) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.errorMessage != null && provider.metrics == null) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Error: ${provider.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final metrics = provider.metrics ?? {};
        final salesCount = metrics['totalSalesCount']?.toString() ?? '0';
        final totalIncome = metrics['totalIncome']?.toStringAsFixed(2) ?? '0.00';
        final avgTicket = metrics['averageTicket']?.toStringAsFixed(2) ?? '0.00';
        final occupied = metrics['tablesOccupied']?.toString() ?? '0';
        final totalTables = metrics['tablesTotal']?.toString() ?? '0';
        final freeTables = metrics['tablesFree']?.toString() ?? '0';

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildExactMetricCard(
                    title: 'VENTAS\nTOTALES',
                    value: salesCount,
                    subtitle: 'Pedidos cobrados',
                    icon: Icons.trending_up,
                    iconColor: Colors.orange.shade700,
                    bgColor: Colors.orange.shade50,
                    subtitleColor: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildExactMetricCard(
                    title: 'INGRESO\nTOTAL',
                    value: '\$$totalIncome',
                    subtitle: '✅ Facturado',
                    icon: Icons.attach_money,
                    iconColor: Colors.green.shade600,
                    bgColor: Colors.green.shade50,
                    subtitleColor: Colors.green.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildExactMetricCard(
                    title: 'TICKET\nPROMEDIO',
                    value: '\$$avgTicket',
                    subtitle: 'Por cada mesa',
                    icon: Icons.emoji_events_outlined,
                    iconColor: Colors.purple.shade500,
                    bgColor: Colors.purple.shade50,
                    subtitleColor: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildExactMetricCard(
                    title: 'OCUPACIÓN\n',
                    value: '$occupied / $totalTables',
                    subtitle: '$freeTables libres',
                    icon: Icons.restaurant,
                    iconColor: Colors.blue.shade500,
                    bgColor: Colors.blue.shade50,
                    subtitleColor: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildExactMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 12),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTablesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.deck, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Monitoreo de Mesas Activas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.pendingTables == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final tables = provider.pendingTables ?? [];

            if (tables.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Text('🎉', style: TextStyle(fontSize: 32)),
                      SizedBox(height: 8),
                      Text(
                        '¡Todas las mesas están libres!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'No hay pedidos pendientes de cobro.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: tables.map((table) {
                // Determine status and color
                String statusStr = 'Ocupada';
                Color statusColor = Colors.amber;
                
                if (table['status'] == 'payment_pending') {
                  statusStr = 'Por Cobrar';
                  statusColor = Colors.redAccent;
                } else if (table['cart_data'] != null && table['active_order'] == null) {
                  statusStr = 'Solicitud de Pedido';
                  statusColor = Colors.blue;
                }

                String waiterName = table['active_order']?['waiter']?['name'] ?? 'Desconocido';
                String total = (table['active_order']?['total_amount'] ?? 0).toString();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTableCard(
                    table['number'], 
                    statusStr, 
                    waiterName, 
                    '\$$total', 
                    statusColor
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTableCard(String tableName, String status, String waiterName, String total, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tableName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Mesero: $waiterName',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total acumulado:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                total,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.receipt_long, size: 16, color: Colors.grey.shade700),
                  label: Text('Detalles', style: TextStyle(color: Colors.grey.shade700)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.credit_card, size: 16, color: Colors.white),
                  label: const Text('Cobrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
