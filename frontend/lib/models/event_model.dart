import 'package:flutter/material.dart';

class EventModel {
  final String id;
  final String title;
  final String locationName;
  final String startDatetime;
  final String endDatetime;
  
  // UI Fields mapping (backend follows frontend)
  final String jenis;
  final Color jenisColor;
  final String nama;
  final String host;
  final String tanggal;
  final String waktu;
  final String lokasi;
  final String lokasiDisplay;
  final String imageUrl;
  final bool isBalasBudi;
  final String tag;

  EventModel({
    required this.id,
    required this.title,
    required this.locationName,
    required this.startDatetime,
    required this.endDatetime,
    
    // UI mapping
    required this.jenis,
    required this.jenisColor,
    required this.nama,
    required this.host,
    required this.tanggal,
    required this.waktu,
    required this.lokasi,
    required this.lokasiDisplay,
    required this.imageUrl,
    required this.isBalasBudi,
    required this.tag,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // UI object provided by backend
    final ui = json['ui'] ?? {};
    
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      locationName: json['locationName'] ?? '',
      startDatetime: json['startDatetime'] ?? '',
      endDatetime: json['endDatetime'] ?? '',
      
      jenis: ui['jenis'] ?? 'Acara',
      jenisColor: Color(ui['jenisColor'] ?? 0xFF134231),
      nama: ui['nama'] ?? json['title'] ?? 'Acara',
      host: ui['host'] ?? 'Tuan Rumah',
      tanggal: ui['tanggal'] ?? '',
      waktu: ui['waktu'] ?? '',
      lokasi: ui['lokasi'] ?? json['locationName'] ?? '',
      lokasiDisplay: ui['lokasiDisplay'] ?? json['locationName'] ?? '',
      imageUrl: ui['imageUrl'] ?? '',
      isBalasBudi: ui['isBalasBudi'] ?? false,
      tag: ui['tag'] ?? 'Lainnya',
    );
  }
}
