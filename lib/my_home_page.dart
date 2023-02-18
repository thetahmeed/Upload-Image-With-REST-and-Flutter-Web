import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<int>? _selectedFile;
  Uint8List? _bytesData;

  pickImageByHTML() {
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

  pickImageByImagePicker() async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1000,
      maxWidth: 1000,
    );

    Uint8List imageData = await XFile(image!.path).readAsBytes();

    setState(() {
      _bytesData = imageData;
    });

    uploadImage();
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
          pickImageByImagePicker();
        },
        tooltip: 'Upload Image',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future uploadImage2() async {
    var url = Uri.parse("http://localhost:3000/upload");

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

  void uploadImage() async {
    // Set up the API endpoint URL and create a new multipart request
    final url = Uri.parse('http://localhost:3000/upload');
    final request = http.MultipartRequest('POST', url);
    // Add the image file to the request
    final imageFile = http.MultipartFile.fromBytes(
      'file',
      _bytesData!,
      filename: 'image.jpg',
    );
    request.files.add(imageFile);
    // Send the request and wait for the response
    final response = await request.send();
    // Check the response status and print the response body
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      print('Image upload failed with status code: ${response.statusCode}');
    }
  }
}
