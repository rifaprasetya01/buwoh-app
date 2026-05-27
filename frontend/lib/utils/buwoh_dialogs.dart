import 'package:flutter/material.dart';

class BuwohDialogs {
  static const Color _primary = Color(0xFF134231);
  static const Color _onSurface = Color(0xFF191C1B);
  static const Color _onSurfaceVariant = Color(0xFF414944);

  static Future<void> showSuccess(BuildContext context, String message) {
    return _showDialog(
      context: context,
      title: 'Berhasil',
      message: message,
      icon: Icons.check_circle_outline,
      iconColor: _primary,
      buttonText: 'Tutup',
    );
  }

  static Future<void> showError(BuildContext context, String message) {
    return _showDialog(
      context: context,
      title: 'Gagal',
      message: message,
      icon: Icons.error_outline,
      iconColor: Colors.red,
      buttonText: 'Tutup',
    );
  }

  static Future<void> showWarning(BuildContext context, String message) {
    return _showDialog(
      context: context,
      title: 'Peringatan',
      message: message,
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFD97706), // Amber
      buttonText: 'Mengerti',
    );
  }

  static Future<void> _showDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required String buttonText,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48.0,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w800,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: _onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
