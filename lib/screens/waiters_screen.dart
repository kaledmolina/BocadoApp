import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/waiters_provider.dart';
import '../models/waiter_model.dart';
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

  void _showRateWaiterModal(BuildContext context, WaiterModel waiter) {
    int selectedRating = 0;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Finalizar Contrato', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vas a desvincular a ${waiter.name} de tu restaurante. Califícalo para guardar su historial de experiencia laboral.', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 16),
                    const Text('CALIFICACIÓN (1 - 5 ESTRELLAS)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    const Text('COMENTARIO / RESEÑA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Ej. Excelente mesero, puntual y muy amable con los clientes...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                  onPressed: () async {
                    if (selectedRating == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, asigna una calificación')));
                      return;
                    }
                    final success = await context.read<WaitersProvider>().rateWaiter(
                      waiter.id, selectedRating, commentCtrl.text
                    );
                    if (mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Contrato finalizado y calificado' : 'Error al finalizar contrato')),
                      );
                    }
                  },
                  child: const Text('Finalizar y Calificar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
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
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: SizedBox(
                            height: 48,
                            child: TextField(
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val.toLowerCase();
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Buscar mesero...',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(color: Color(0xFFF97316)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (provider.invitationLink.isNotEmpty)
                          _buildInviteLinkCard(provider.invitationLink),
                        
                        // TabBar
                        TabBar(
                          labelColor: const Color(0xFFEA580C),
                          unselectedLabelColor: const Color(0xFF94A3B8),
                          indicatorColor: const Color(0xFFEA580C),
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          indicatorWeight: 2,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCE1D1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enlace de Invitación de Meseros', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14)),
          const SizedBox(height: 6),
          const Text('Comparte este enlace para que tu personal llene sus propios datos y active su cuenta de mesero.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(link, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)), overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enlace copiado al portapapeles')));
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Icons.copy, size: 20, color: Color(0xFF64748B)),
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
            trailing: TextButton(
              onPressed: () => _showRateWaiterModal(context, waiter),
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
              child: const Text('Desvincular', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplicationsList(WaitersProvider provider) {
    final list = provider.applications.where((a) => a.user.name.toLowerCase().contains(_searchQuery) || a.user.email.toLowerCase().contains(_searchQuery)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bolsa de Empleo card
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bolsa de Empleo: Buscando Meseros', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14)),
                    const SizedBox(height: 6),
                    const Text('Si está activado, los meseros registrados sin local podrán ver tu restaurante en la bolsa de trabajo y postularse.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: provider.isHiring,
                onChanged: (val) {
                  provider.toggleHiring();
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.blue.shade400,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
              )
            ],
          ),
        ),
        
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.mail, size: 48, color: Colors.purple.shade200),
                const SizedBox(height: 20),
                const Text('No hay postulaciones pendientes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                const Text('Cuando los meseros se postulen, aparecerán aquí.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B)), textAlign: TextAlign.center),
              ],
            ),
          )
        else
          ...list.map((app) => Card(
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
          )),
      ],
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
