import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/events_provider.dart';
import '../../config/api_config.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../events/manage_guests_screen.dart';
import '../events/recap_screen.dart';
import '../../models/event_model.dart';

class DashboardScreen extends StatefulWidget {
  final String nama;
  final String? fotoPath;

  const DashboardScreen({super.key, required this.nama, this.fotoPath});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.82),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Acara Saya',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<EventsProvider>(context, listen: false).fetchHostedEvents(),
        child: Consumer<EventsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<EventModel> sortedEvents = List<EventModel>.from(provider.hostedEvents);
            sortedEvents.sort((a, b) {
              // Priority 1: Status (active comes before completed)
              if (a.status == 'active' && b.status != 'active') return -1;
              if (a.status != 'active' && b.status == 'active') return 1;
              
              // Priority 2: Date (descending - newest/latest first)
              return b.date.compareTo(a.date);
            });

            if (sortedEvents.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height - 150,
                  alignment: Alignment.center,
                  child: const Text(
                    "Belum ada acara yang dibuat.",
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              itemCount: sortedEvents.length,
              itemBuilder: (context, index) {
                final event = sortedEvents[index];
                
                if (event.status == 'active') {
                  final String finalImageUrl = (event.imageUrl != null)
                    ? (event.imageUrl!.startsWith('http') 
                        ? event.imageUrl! 
                        : '${ApiConfig.baseUrl.replaceAll('/api/v1', '')}${event.imageUrl}')
                    : "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800";

                  String calculatedStatus = 'Berlangsung';
                  String countdownText = '';
                  String formattedDate = event.date;

                  try {
                    final DateTime eventDate = DateTime.parse(event.date);
                    final DateTime today = DateTime.now();
                    final DateTime todayDate = DateTime(today.year, today.month, today.day);
                    final DateTime eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);
                    
                    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
                    formattedDate = '${eventDate.day} ${months[eventDate.month - 1]} ${eventDate.year}';

                    if (eventDateOnly.isAfter(todayDate)) {
                      calculatedStatus = 'Segera hadir';
                      final int diffDays = eventDateOnly.difference(todayDate).inDays;
                      countdownText = 'H-$diffDays';
                    } else if (eventDateOnly.isBefore(todayDate)) {
                      calculatedStatus = 'Selesai';
                    } else {
                      countdownText = 'Hari Ini';
                    }
                  } catch (_) {}

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: BuwohEventCard(
                      nama: event.title,
                      lokasi: event.locationName,
                      isPrioritas: event.isPriority,
                      tamu: '${event.guestsAttended ?? 0}/${event.guestsExpected ?? 0}',
                      waktu: '${event.startTime ?? '--:--'} - ${event.endTime ?? '--:--'}',
                      tanggal: formattedDate,
                      countdown: countdownText,
                      imageUrl: finalImageUrl,
                      status: calculatedStatus,
                      onManage: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageGuestsScreen(
                              eventId: event.id,
                              namaAcara: event.title,
                              imageUrl: finalImageUrl,
                              eventDate: event.date,
                            ),
                          ),
                        );
                        if (context.mounted) {
                          Provider.of<EventsProvider>(context, listen: false).fetchHostedEvents();
                        }
                      },
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BuwohCompletedEventItem(
                      nama: event.title,
                      info: '${event.date} • ${event.guestsTotal ?? 0} Tamu',
                      total: 'Lihat Rekap',
                      status: 'Selesai',
                      onRecapTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecapScreen(eventId: event.id),
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
