import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool textScanning = false;
  XFile? imageFile;

  String scannedText = '';

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognizedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      setState(() {});
      scannedText = "Error while scanning";
    }
  }

  void getRecognizedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = '$scannedText${line.text}\n';
      }
    }
    textScanning = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Recognition"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (textScanning) const CircularProgressIndicator(),
              (!textScanning && imageFile == null)
                  ? Container(
                      width: 300,
                      height: 300,
                      color: Colors.grey,
                    )
                  : Image.file(File(imageFile!.path)),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconWidget(
                    onTap: () {
                      getImage(ImageSource.gallery);
                    },
                    iconData: Icons.photo_size_select_actual_rounded,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  IconWidget(
                    onTap: () {
                      getImage(ImageSource.camera);
                    },
                    iconData: Icons.camera_alt,
                  ),
                ],
              ),
              Text(scannedText)
            ],
          ),
        ),
      ),
    );
  }
}

class IconWidget extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onTap;
  const IconWidget({super.key, required this.iconData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Icon(
            iconData,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
