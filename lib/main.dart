import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_pdf/pdf_viewer_screen.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  File? _pdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            if (_image != null) Image.file(_image!),
            const SizedBox(
              height: 24,
            ),
            if (_pdf != null)
              Material(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onTap: _pdfView,
                  child: const SizedBox(
                    height: 100,
                    width: 100,
                    child: Icon(
                      Icons.image,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'image',
            onPressed: _pickImage,
            tooltip: 'Image',
            child: const Icon(Icons.add),
          ),
          const SizedBox(
            width: 24,
          ),
          FloatingActionButton(
            heroTag: 'pdf',
            onPressed: _toPdf,
            tooltip: 'Pdf',
            child: const Icon(Icons.image),
          ),
        ],
      ),
    );
  }

  void _pdfView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PDFScreen(
            path: _pdf!.path,
          );
        },
      ),
    );
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  void _toPdf() async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(_image!.readAsBytesSync());
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(
        child: pw.Image(image),
      );
    }));

    final file = File('${_image!.path}.pdf');
    final pdfLocal = await file.writeAsBytes(await pdf.save());
    setState(() {
      _pdf = pdfLocal;
    });
  }
}
