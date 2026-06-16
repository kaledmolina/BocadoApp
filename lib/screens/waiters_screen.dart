import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/waiters_provider.dart';
import '../widgets/custom_drawer.dart';

class WaitersScreen extends StatefulWidget {
  const WaitersScreen({super.key});

  @override
  State<WaitersScreen> createState() => _WaitersScreenState();
}

class _WaitersScreenState extends State<WaitersScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaitersProvider>().fetchWaitersData();
    });
  }



  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WaitersProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        drawer: const CustomDrawer(currentRoute: 'waiters'),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: const Text(
            'Gestión de Meseros',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
          ),
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            'Gestiona las cuentas de tu personal de mesa, monitorea sus turnos y procesa las nuevas postulaciones.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Buscar mesero...',
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Colors.orange),
                              ),
                            ),
                          ),
                        ),
                        if (provider.invitationLink.isNotEmpty)
                          _buildInviteLinkCard(provider.invitationLink),
                        
                        // TabBar
                        TabBar(
                          labelColor: Colors.orange,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.orange,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          indicatorWeight: 3,
                          tabs: [
                            Tab(text: 'Meseros\nActivos (${provider.waiters.length})'),
                            Tab(text: 'Solicitudes de\nVinculación (${provider.applications.length})'),
                            Tab(text: 'Bolsa de\nTalentos (${provider.availableWaiters.length})'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildWaitersList(provider),
                        _buildApplicationsList(provider),
                        _buildTalentsList(provider),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInviteLinkCard(String link) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enlace de Invitación de Meseros', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('Comparte este enlace para que tu personal llene sus propios datos y active su cuenta de mesero.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(link, style: const TextStyle(fontSize: 12, color: Colors.black87), overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: IconButton(
                  icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: link));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enlace copiado al portapapeles')));
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWaitersList(WaitersProvider provider) {
    final list = provider.waiters.where((w) => w.name.toLowerCase().contains(_searchQuery) || w.email.toLowerCase().contains(_searchQuery)).toList();

    if (list.isEmpty) {
      return const Center(child: Text('No se encontraron meseros', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final waiter = list[i];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Text(waiter.name.substring(0, 2).toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
            title: Text(waiter.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(waiter.email, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                    const SizedBox(width: 4),
                    Text('${waiter.averageRating} (${waiter.experienceHours}h)', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                if (waiter.isShiftActive)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
                    child: const Text('En Turno', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: waiter.isActive,
                  activeColor: Colors.orange,
                  onChanged: (val) {
                    provider.toggleWaiterStatus(waiter.id);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    provider.deleteWaiter(waiter.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplicationsList(WaitersProvider provider) {
    final list = provider.applications.where((a) => a.user.name.toLowerCase().contains(_searchQuery) || a.user.email.toLowerCase().contains(_searchQuery)).toList();

    if (list.isEmpty) {
      return const Center(child: Text('No hay solicitudes pendientes', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final app = list[i];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Text(app.user.name.substring(0, 2).toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app.user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(app.user.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () => provider.processApplication(app.id, 'rejected'),
                        child: const Text('Rechazar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        onPressed: () => provider.processApplication(app.id, 'approved'),
                        child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTalentsList(WaitersProvider provider) {
    final list = provider.availableWaiters.where((w) => w.name.toLowerCase().contains(_searchQuery) || w.email.toLowerCase().contains(_searchQuery)).toList();

    if (list.isEmpty) {
      return const Center(child: Text('No hay meseros disponibles', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final talent = list[i];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(talent.name.substring(0, 2).toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(talent.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(talent.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                              const SizedBox(width: 4),
                              Text('${talent.averageRating} (${talent.experienceHours}h)', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (talent.status == 'invited')
                      const Text('Invitado', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12))
                    else if (talent.status == 'pending')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => provider.hireWaiter(talent.id),
                        child: const Text('Aceptar', style: TextStyle(color: Colors.white, fontSize: 12)),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        onPressed: () => provider.hireWaiter(talent.id),
                        child: const Text('Contratar', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
