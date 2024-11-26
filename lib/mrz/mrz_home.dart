import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk/flutter_ocr_sdk_platform_interface.dart';
import 'package:flutter_ocr_sdk/mrz_line.dart';
import 'package:flutter_ocr_sdk/mrz_parser.dart';
import 'package:flutter_ocr_sdk/mrz_result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr/global.dart';
import 'package:ocr/mrz/result_page.dart';

class MrzHome extends StatefulWidget {
  const MrzHome({Key? key}) : super(key: key);

  @override
  State<MrzHome> createState() => _MrzHomeState();
}

class _MrzHomeState extends State<MrzHome> {

  Future<void> pickerImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(image.name),
      ));
    }
  }

  void scanImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? photo = await picker.pickImage(source: ImageSource.gallery);

    if (photo == null) {
      return;
    }

    // if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    //   File rotatedImage =
    //   await FlutterExifRotation.rotateImage(path: photo.path);
    //   photo = XFile(rotatedImage.path);
    // }

    Uint8List fileBytes = await photo.readAsBytes();

    ui.Image image = await decodeImageFromList(fileBytes);

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData != null) {
      List<List<MrzLine>>? results =
          await mrzDetector.recognizeByBuffer(byteData.buffer.asUint8List(), image.width, image.height, byteData.lengthInBytes ~/ image.height, ImagePixelFormat.IPF_ARGB_8888.index);
      List<MrzLine>? finalArea;
      MrzResult? information;
      if (results != null && results.isNotEmpty) {
        for (List<MrzLine> area in results) {
          if (area.length == 2) {
            finalArea = area;
            information = MRZ.parseTwoLines(area[0].text, area[1].text);
            information.lines = '${area[0].text}\n${area[1].text}';
            break;
          } else if (area.length == 3) {
            finalArea = area;
            information = MRZ.parseThreeLines(area[0].text, area[1].text, area[2].text);
            information.lines = '${area[0].text}\n${area[1].text}\n${area[2].text}';
            break;
          }
        }
      }
      if (finalArea != null) {
        openResultPage(information!);
      }
    }
  }

  void openResultPage(MrzResult information) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(information: information),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        body: Column(
          children: [
            Row(
              children: [
                Container(
                    padding: const EdgeInsets.only(
                      top: 30,
                      left: 33,
                    ),
                    child: const Text('MRZ SCANNER',
                        style: TextStyle(
                          fontSize: 36,
                        )))
              ],
            ),
            Row(
              children: [
                Container(
                    padding: const EdgeInsets.only(top: 6, left: 33, bottom: 44),
                    child: const SizedBox(
                      width: 271,
                      child: Text('Recognizes MRZ code & extracts data from 1D-codes, passports, and visas.',
                          style: TextStyle(
                            fontSize: 18,
                          )),
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      // if (!kIsWeb && Platform.isLinux) {
                      //   showAlert(context, "Warning", "${Platform.operatingSystem} is not supported");
                      //   return;
                      // }
                      //
                      // Navigator.push(context, MaterialPageRoute(builder: (context) {
                      //   return const CameraPage();
                      // }));
                    },
                    child: Container(
                      width: 150,
                      height: 125,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.camera),
                          Text(
                            "Camera Scan",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          )
                        ],
                      ),
                    )),
                GestureDetector(
                  onTap: () {
                    // pickerImage();
                    scanImage();
                  },
                  child: Container(
                    width: 150,
                    height: 125,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.scanner),
                        Text(
                          "Image Scan",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}
