import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/invitation_provider.dart';
import '../../utils/buwoh_dialogs.dart';

const _primary = Color(0xFF134231);
const _primaryContainer = Color(0xFF2D5A47);
const _onSurface = Color(0xFF191C1B);
const _background = Color(0xFFF8FAF8);

class EditBuwohScreen extends StatefulWidget {
  final String eventId;
  final String namaAcara;

  const EditBuwohScreen({
    super.key,
    required this.eventId,
    required this.namaAcara,
  });

  @override
  State<EditBuwohScreen> createState() => _EditBuwohScreenState();
}

class _EditBuwohScreenState extends State<EditBuwohScreen> {
  bool _uang = false;
  bool _beras = false;
  bool _gula = false;

  final TextEditingController _uangCtrl = TextEditingController();
  final TextEditingController _berasCtrl = TextEditingController();
  final TextEditingController _gulaCtrl = TextEditingController();

  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchMyBuwoh();
  }

  @override
  void dispose() {
    _uangCtrl.dispose();
    _berasCtrl.dispose();
    _gulaCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMyBuwoh() async {
    final provider = Provider.of<InvitationProvider>(context, listen: false);
    final data = await provider.getMyBuwoh(widget.eventId);
    
    if (!mounted) return;

    if (data == null) {
      setState(() {
        _isLoading = false;
        _errorMsg = "Gagal memuat data buwoh Anda.";
      });
      return;
    }

    final status = data['status'];
    final eventDateStr = data['eventDate'];
    
    // Check constraints
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final eDate = DateTime.parse(eventDateStr);
    final eDateMidnight = DateTime(eDate.year, eDate.month, eDate.day);

    if (status != 'pending') {
      setState(() {
        _isLoading = false;
        _errorMsg = "Data tidak dapat diedit karena status sudah '$status'.";
      });
      return;
    }

    if (todayMidnight.isAfter(eDateMidnight)) {
      setState(() {
        _isLoading = false;
        _errorMsg = "Data tidak dapat diedit karena acara sudah lewat.";
      });
      return;
    }

    final List<dynamic> contributions = data['contributions'] ?? [];
    for (var c in contributions) {
      final type = c['type'];
      final amount = c['amount'];
      
      if (type == 'uang') {
        _uang = true;
        _uangCtrl.text = amount.toString();
      } else if (type == 'beras') {
        _beras = true;
        _berasCtrl.text = amount.toString();
      } else if (type == 'gula') {
        _gula = true;
        _gulaCtrl.text = amount.toString();
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _simpanBuwoh() async {
    if (!_uang && !_beras && !_gula) {
      BuwohDialogs.showWarning(context, 'Pilih minimal satu jenis buwoh');
      return;
    }

    final provider = Provider.of<InvitationProvider>(context, listen: false);
    final List<Map<String, dynamic>> contributions = [];
    
    if (_uang) {
      final amt = int.tryParse(_uangCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (amt <= 0) {
        BuwohDialogs.showWarning(context, 'Masukkan nominal uang yang valid');
        return;
      }
      contributions.add({
        'type': 'uang',
        'amount': amt,
        'unit': 'rupiah',
        'notes': 'Update buwoh uang',
      });
    }
    
    if (_beras) {
      final amt = int.tryParse(_berasCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (amt <= 0) {
        BuwohDialogs.showWarning(context, 'Masukkan jumlah beras yang valid');
        return;
      }
      contributions.add({
        'type': 'beras',
        'amount': amt,
        'unit': 'kg',
        'notes': 'Update buwoh beras',
      });
    }
    
    if (_gula) {
      final amt = int.tryParse(_gulaCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (amt <= 0) {
        BuwohDialogs.showWarning(context, 'Masukkan jumlah gula yang valid');
        return;
      }
      contributions.add({
        'type': 'gula',
        'amount': amt,
        'unit': 'kg',
        'notes': 'Update buwoh gula',
      });
    }

    final success = await provider.updateBuwoh(widget.eventId, contributions);

    if (!mounted) return;

    if (success) {
      await BuwohDialogs.showSuccess(context, 'Perubahan Berhasil Disimpan');
      if (mounted) Navigator.pop(context, true); // Return true to indicate success
    } else {
      BuwohDialogs.showError(context, 'Gagal menyimpan perubahan. Silakan coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Buwohan',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
      ),
      bottomNavigationBar: _isLoading || _errorMsg != null
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 56),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF134231).withOpacity(0.06),
                    blurRadius: 40,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: Consumer<InvitationProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _simpanBuwoh,
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save_outlined, size: 22),
                      label: Text(
                        provider.isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                        style: const TextStyle(
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
                        shadowColor: _primary.withOpacity(0.2),
                      ),
                    );
                  }
                ),
              ),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _errorMsg != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          _errorMsg!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            color: _onSurface,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text('Kembali'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _primaryContainer.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: _primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Mengedit buwohan untuk acara:\n${widget.namaAcara}',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Sesuaikan Barang Bawaan',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _BuwohCheckItem(
                        icon: Icons.payments_outlined,
                        label: 'Uang',
                        value: _uang,
                        onChanged: (v) => setState(() => _uang = v),
                        controller: _uangCtrl,
                        hintText: 'Contoh: 100000',
                        unit: 'Rupiah',
                      ),
                      const SizedBox(height: 12),
                      _BuwohCheckItem(
                        icon: Icons.inventory_2_outlined,
                        label: 'Beras',
                        value: _beras,
                        onChanged: (v) => setState(() => _beras = v),
                        controller: _berasCtrl,
                        hintText: 'Contoh: 5',
                        unit: 'Kg',
                      ),
                      const SizedBox(height: 12),
                      _BuwohCheckItem(
                        icon: Icons.kitchen_outlined,
                        label: 'Gula',
                        value: _gula,
                        onChanged: (v) => setState(() => _gula = v),
                        controller: _gulaCtrl,
                        hintText: 'Contoh: 2',
                        unit: 'Kg',
                      ),
                    ],
                  ),
                ),
    );
  }
}

// Same _BuwohCheckItem implementation as in invitation_detail_screen.dart
class _BuwohCheckItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final TextEditingController controller;
  final String hintText;
  final String unit;

  const _BuwohCheckItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.controller,
    required this.hintText,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? const Color(0xFF134231) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1B).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              checkboxTheme: CheckboxThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Color(0xFF134231);
                  }
                  return Colors.transparent;
                }),
              ),
            ),
            child: CheckboxListTile(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              title: Row(
                children: [
                  Icon(icon, color: value ? const Color(0xFF134231) : Colors.grey, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: value ? FontWeight.w700 : FontWeight.w600,
                      color: value ? const Color(0xFF134231) : const Color(0xFF191C1B),
                    ),
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF134231),
            ),
          ),
          if (value)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF134231),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
