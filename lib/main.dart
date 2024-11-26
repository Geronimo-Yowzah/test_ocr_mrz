import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ocr/global.dart';
import 'package:ocr/mrz/mrz_home.dart';
import 'package:ocr/vision_detector_views/text_detector_view.dart';
import 'package:ocr/widget/custom_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<int> loadData() async {
    return await initMRZSDK();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tesseract Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<int>(
        future: loadData(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          Future.microtask(() {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Tesseract Demo')));
          });
          return Container();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // String _ocrText = '';
  // String _ocrHocr = '';
  // Map<String, String> tessimgs = {
  //   "kor":
  //   "https://raw.githubusercontent.com/khjde1207/tesseract_ocr/master/example/assets/test1.png",
  //   "en": "https://tesseract.projectnaptha.com/img/eng_bw.png",
  //   "ch_sim": "https://tesseract.projectnaptha.com/img/chi_sim.png",
  //   "ru": "https://tesseract.projectnaptha.com/img/rus.png",
  // };
  // var LangList = ["kor", "eng", "deu", "chi_sim"];
  // var selectList = ["eng", "kor"];
  // String path = "";
  // bool bload = false;
  //
  // bool bDownloadtessFile = false;
  // // "https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FqCviW%2FbtqGWTUaYLo%2FwD3ZE6r3ARZqi4MkUbcGm0%2Fimg.png";
  // var urlEditController = TextEditingController()
  //   ..text = "https://tesseract.projectnaptha.com/img/eng_bw.png";
  //
  // Future<void> writeToFile(ByteData data, String path) {
  //   final buffer = data.buffer;
  //   return new File(path).writeAsBytes(
  //       buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  // }
  //
  // void runFilePiker() async {
  //   // android && ios only
  //   final pickedFile =
  //   await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     _ocr(pickedFile.path);
  //   }
  // }
  //
  // void _ocr(url) async {
  //   if (selectList.length <= 0) {
  //     print("Please select language");
  //     return;
  //   }
  //   path = url;
  //   if (kIsWeb == false &&
  //       (url.indexOf("http://") == 0 || url.indexOf("https://") == 0)) {
  //     Directory tempDir = await getTemporaryDirectory();
  //     HttpClient httpClient = new HttpClient();
  //     HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
  //     HttpClientResponse response = await request.close();
  //     Uint8List bytes = await consolidateHttpClientResponseBytes(response);
  //     String dir = tempDir.path;
  //     print('$dir/test.jpg');
  //     File file = new File('$dir/test.jpg');
  //     await file.writeAsBytes(bytes);
  //     url = file.path;
  //   }
  //   var langs = selectList.join("+");
  //
  //   bload = true;
  //   setState(() {});
  //
  //   _ocrText =
  //   await FlutterTesseractOcr.extractText(url, language: langs, args: {
  //     "preserve_interword_spaces": "1",
  //   });
  //   //  ========== Test performance  ==========
  //   // DateTime before1 = DateTime.now();
  //   // print('init : start');
  //   // for (var i = 0; i < 10; i++) {
  //   //   _ocrText =
  //   //       await FlutterTesseractOcr.extractText(url, language: langs, args: {
  //   //     "preserve_interword_spaces": "1",
  //   //   });
  //   // }
  //   // DateTime after1 = DateTime.now();
  //   // print('init : ${after1.difference(before1).inMilliseconds}');
  //   //  ========== Test performance  ==========
  //
  //   // _ocrHocr =
  //   //     await FlutterTesseractOcr.extractHocr(url, language: langs, args: {
  //   //   "preserve_interword_spaces": "1",
  //   // });
  //   // print(_ocrText);
  //   // print(_ocrText);
  //
  //   // === web console test code ===
  //   // var worker = Tesseract.createWorker();
  //   // await worker.load();
  //   // await worker.loadLanguage("eng");
  //   // await worker.initialize("eng");
  //   // // await worker.setParameters({ "tessjs_create_hocr": "1"});
  //   // var rtn = worker.recognize("https://tesseract.projectnaptha.com/img/eng_bw.png");
  //   // console.log(rtn.data);
  //   // await worker.terminate();
  //   // === web console test code ===
  //
  //   bload = false;
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google ML Kit Demo App'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ExpansionTile(
                    title: const Text('Vision APIs'),
                    children: [
                      // CustomCard('Barcode Scanning', BarcodeScannerView()),
                      // CustomCard('Face Detection', FaceDetectorView()),
                      // if (Platform.isAndroid)
                      //   CustomCard(
                      //       'Face Mesh Detection', FaceMeshDetectorView()),
                      // CustomCard('Image Labeling', ImageLabelView()),
                      // CustomCard('Object Detection', ObjectDetectorView()),
                      CustomCard('Text Recognition', TextRecognizerView()),
                      const CustomCard('MRZ', MrzHome()),
                      // CustomCard('Digital Ink Recognition', DigitalInkView()),
                      // CustomCard('Pose Detection', PoseDetectorView()),
                      // CustomCard('Selfie Segmentation', SelfieSegmenterView()),
                      // if (Platform.isAndroid)
                      //   CustomCard('Document Scanner', DocumentScannerView()),
                      // if (Platform.isAndroid)
                      //   CustomCard(
                      //       'Subject Segmentation', SubjectSegmenterView())
                    ],
                  ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // ExpansionTile(
                  //   title: const Text('Natural Language APIs'),
                  //   children: [
                  //     CustomCard('Language ID', LanguageIdentifierView()),
                  //     CustomCard('On-device Translation', LanguageTranslatorView()),
                  //     CustomCard('Smart Reply', SmartReplyView()),
                  //     CustomCard('Entity Extraction', EntityExtractionView()),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
