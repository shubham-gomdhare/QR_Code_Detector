import 'package:flutter/material.dart';
import 'qr_barcode_screen.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Detector',
      home: QRBarcodeScreen(),
    );
  }
}