import 'package:flutter/material.dart';

class BasitWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Basit'),
      ),
      body: Center(
        child: Text('Flutter bileşeni oluşturuldu.'),
      ),
    );
  }
}
