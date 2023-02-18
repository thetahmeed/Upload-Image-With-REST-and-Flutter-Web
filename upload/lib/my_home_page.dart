import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late File filePath;

  List<int>? _selectedFile;
  Uint8List? _bytesData;

  startWebFilePicker() {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.draggable = true;
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      final file = files![0];
      final reader = html.FileReader();

      reader.onLoadEnd.listen((event) {
        setState(() {
          _bytesData = const Base64Decoder()
              .convert(reader.result.toString().split(",").last);
          _selectedFile = _bytesData;
        });

        uploadImage();
      });

      reader.readAsDataUrl(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A child of Tahmeed\'s Lab'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Upload image to cPanel using Flutter',
            ),
            const SizedBox(height: 18),
            _bytesData != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _bytesData!,
                      width: 420,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Text('No image selected!'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          startWebFilePicker();
        },
        tooltip: 'Upload Image',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future uploadImage() async {
    var url = Uri.parse("https://demo.tahmeedul.com/image_upload.php");

    var request = http.MultipartRequest("POST", url);
    request.files.add(http.MultipartFile.fromBytes('file', _selectedFile!,
        contentType: MediaType('application', 'json'), filename: "AnyName"));

    request.send().then((response) {
      if (response.statusCode == 200) {
        print('File uploaded successfully');
      } else {
        print('File upload not successfull');
      }
    });
  }
}
