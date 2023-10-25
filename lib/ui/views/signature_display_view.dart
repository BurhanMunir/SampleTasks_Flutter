import 'dart:typed_data';

import 'package:flutter/material.dart';

class SignatureDisplayPage extends StatelessWidget {
  final Uint8List? signatureBytes;

  SignatureDisplayPage({this.signatureBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Signature Display"),
      ),
      body: Center(
        child: Container(
          height: 300,
          width: 300,
          color: Colors.grey,
          child: signatureBytes != null
              ? Image.memory(
                  signatureBytes!,
                )
              : const Text("No Signatures"),
        ),
      ),
    );
  }
}
