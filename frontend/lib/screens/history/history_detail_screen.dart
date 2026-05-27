import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../models/history_model.dart';
import '../invitations/edit_buwoh_screen.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String eventId;
  final String nama;
  final String host;
  final String tanggal;
  final String lokasi;
  final String jenis;
  final String status;
  final List<ContributionModel> contributions;

  const HistoryDetailScreen({
    super.key,
    required this.eventId,
    required this.nama,
    required this.host,
    required this.tanggal,
    required this.lokasi,
    required this.jenis,
    required this.status,
    required this.contributions,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  bool _isBottomNavVisible = true;

  static const _primary = Color(0xFF134231);
  static const _primaryContainer = Color(0xFF2D5A47);
  static const _onSurfaceVariant = Color(0xFF414944);
  static const _tertiary = Color(0xFF705D00);
  static const _background = Color(0xFFF8FAF8);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background.withValues(alpha: 0.82),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Riwayat',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
      ),
      bottomNavigationBar: widget.status == 'pending'
          ? AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: _isBottomNavVisible ? Offset.zero : const Offset(0, 1),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF134231).withValues(alpha: 0.06),
                      blurRadius: 40,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditBuwohScreen(
                            eventId: widget.eventId,
                            namaAcara: widget.nama,
                          ),
                        ),
                      ).then((value) {
                        if (value == true) {
                          // Ideally we should pop or reload history. Since history fetches on focus, it might be fine to just pop.
                          if (!context.mounted) return;
                          Navigator.pop(context, true);
                        }
                      });
                    },
                    icon: const Icon(Icons.edit_outlined, size: 22),
                    label: const Text(
                      'Edit Buwohan',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 4,
                      shadowColor: _primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_isBottomNavVisible) {
              setState(() => _isBottomNavVisible = false);
            }
          } else if (notification.direction == ScrollDirection.forward) {
            if (!_isBottomNavVisible) {
              setState(() => _isBottomNavVisible = true);
            }
          }
          return false;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Card ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: const Border(
                    left: BorderSide(color: _primary, width: 8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF191C1B).withValues(alpha: 0.04),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Jenis badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.jenis.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _tertiary,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.status == 'attended' || widget.status == 'validated'
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : widget.status == 'rejected' 
                                          ? Colors.red.withValues(alpha: 0.1) 
                                          : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.status == 'attended' || widget.status == 'validated'
                                      ? 'DITERIMA' 
                                      : widget.status == 'rejected' ? 'DITOLAK' : 'PENDING',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: widget.status == 'attended' || widget.status == 'validated'
                                        ? Colors.green
                                        : widget.status == 'rejected' ? Colors.red : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Nama acara
                          Text(
                            widget.nama,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: _primary,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Info rows
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            text: widget.tanggal,
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            icon: Icons.group_outlined,
                            text: widget.host,
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            text: widget.lokasi,
                          ),
                        ],
                      ),
                    ),
                    // Decorative icon
                    Positioned(
                      bottom: -16,
                      right: -16,
                      child: Icon(
                        Icons.celebration_outlined,
                        size: 100,
                        color: _primary.withValues(alpha: 0.05),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Status Badge ───────────────────────────────────────────
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: widget.status == 'attended' || widget.status == 'validated'
                        ? _primaryContainer
                        : widget.status == 'rejected' ? Colors.red : const Color(0xFFD97706),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (widget.status == 'attended' || widget.status == 'validated'
                                    ? _primaryContainer
                                    : widget.status == 'rejected' ? Colors.red : const Color(0xFFD97706))
                                .withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.status == 'attended' || widget.status == 'validated'
                            ? Icons.check_circle
                            : widget.status == 'rejected' ? Icons.cancel : Icons.pending_actions,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.status == 'attended' || widget.status == 'validated'
                            ? 'Sudah Diterima'
                            : widget.status == 'rejected' ? 'Ditolak' : 'Menunggu Verifikasi',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Rincian Buwoh ──────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 14),
                child: Text(
                  'RINCIAN BUWOH',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _onSurfaceVariant,
                    letterSpacing: 2.0,
                  ),
                ),
              ),

               Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.contributions.map((c) {
                  IconData icon = Icons.card_giftcard_outlined;
                  String label = 'BARANG';
                  if (c.type == 'uang') {
                    icon = Icons.payments_outlined;
                    label = 'UANG TUNAI';
                  } else if (c.type == 'beras') {
                    icon = Icons.inventory_2_outlined;
                    label = 'BERAS';
                  } else if (c.type == 'gula') {
                    icon = Icons.kitchen_outlined;
                    label = 'GULA';
                  }

                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 52) / 2,
                    child: _KontribusiCard(
                      icon: icon,
                      label: label,
                      value: c.value,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Info Row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF414944)),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF414944),
          ),
        ),
      ],
    );
  }
}

// ── Kontribusi Card ───────────────────────────────────────────────────────────
class _KontribusiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _KontribusiCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const _primary = Color(0xFF134231);
  static const _onSurfaceVariant = Color(0xFF414944);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primary.withValues(alpha: 0.08),
            ),
            child: Icon(icon, color: _primary, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: _onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
