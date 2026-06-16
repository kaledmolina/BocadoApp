import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tables_provider.dart';
import '../models/table_model.dart';
import '../widgets/custom_drawer.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TablesProvider>().fetchTables();
    });
  }

  void _showCreateTableDialog() {
    String newTableNumber = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Agregar Nueva Mesa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Ej: Mesa 1, Barra 2',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: (val) => newTableNumber = val,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newTableNumber.trim().isNotEmpty) {
                final success = await context.read<TablesProvider>().createTable(newTableNumber);
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Mesa creada exitosamente' : 'Error al crear la mesa'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Crear Mesa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(TableModel table) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar Mesa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('¿Estás seguro de que deseas eliminar la ${table.number}? Se perderán todos sus códigos QR activos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<TablesProvider>().deleteTable(table.id);
              if (mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Mesa eliminada' : 'Error al eliminar la mesa'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TablesProvider>();
    final tables = provider.tables.where((t) {
      if (_selectedStatus == 'All') return true;
      return t.status == _selectedStatus;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Mesas & QRs',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
        ),
      ),
      drawer: const CustomDrawer(),
      body: provider.isLoading && provider.tables.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Column(
              children: [
                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildFilterChip('Todas', 'All', Colors.orange),
                      const SizedBox(width: 8),
                      _buildFilterChip('Libres', 'free', Colors.green),
                      const SizedBox(width: 8),
                      _buildFilterChip('Ocupadas', 'occupied', Colors.amber),
                      const SizedBox(width: 8),
                      _buildFilterChip('Por Cobrar', 'payment_pending', Colors.red),
                    ],
                  ),
                ),

                // Grid
                Expanded(
                  child: tables.isEmpty
                      ? const Center(child: Text('No se encontraron mesas', style: TextStyle(color: Colors.grey, fontSize: 16)))
                      : RefreshIndicator(
                          color: Colors.orange,
                          onRefresh: () => provider.fetchTables(),
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: tables.length,
                            itemBuilder: (context, index) {
                              final table = tables[index];
                              return _buildTableCard(table);
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTableDialog,
        backgroundColor: Colors.orange.shade600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agregar Mesa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterChip(String label, String status, Color activeColor) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? activeColor : Colors.grey.shade300),
          boxShadow: isSelected ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCard(TableModel table) {
    Color statusColor;
    String statusText;
    switch (table.status) {
      case 'occupied':
        statusColor = Colors.amber;
        statusText = 'Ocupada';
        break;
      case 'payment_pending':
        statusColor = Colors.red;
        statusText = 'Por Cobrar';
        break;
      default:
        statusColor = Colors.green;
        statusText = 'Libre';
    }

    final qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=https://bocado.app/tables/${table.qrCodeToken}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        table.number,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // QR Code
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        qrUrl,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Icon(Icons.qr_code, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          // Delete button
          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () => _confirmDelete(table),
            ),
          ),
        ],
      ),
    );
  }
}
