import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'theme.dart' as Theme;





class QRBarcodeScreen extends StatefulWidget {
  QRBarcodeScreen({Key key}) : super(key: key);

  @override
  _QrBarcodeState createState() => new _QrBarcodeState();
}

class _QrBarcodeState extends State<QRBarcodeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FocusNode mFocusNodeQrValue = FocusNode();
  TextEditingController qrController = new TextEditingController();
  PageController _pageController;
  Color left = Colors.black;
  Color right = Colors.white;
  GlobalKey globalKey = new GlobalKey();
  Directory directory;
  String _dataString = "NULL";
  String _path ;
  int i = 1;
  final TextEditingController _textController = TextEditingController();
  String _qrInfo = 'Scan a QR/Bar code';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  Theme.Colors.loginGradientStart,
                  Theme.Colors.loginGradientEnd
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) {
                    if (i == 0) {
                      setState(() {
                        right = Colors.black;
                        left = Colors.white;
                      });
                    } else if (i == 1) {
                      setState(() {
                        right = Colors.white;
                        left = Colors.black;
                      });
                    }
                  },
                  children: <Widget>[
                    _buildScan(context),
                    _buildGen(context),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 1.0, bottom: 50),
                child: _buildMenuBar(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    mFocusNodeQrValue.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        //painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

              FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onScanButtonPress,
                child: Text(
                  "Sacn",
                  style: TextStyle(
                    color: left,
                    fontSize: 16.0,
                  ),
                ),
              ),

            //Container(height: 33.0, width: 1.0, color: Colors.white),

              FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onGenerateButtonPress,
                child: Text(
                  "Generate",
                  style: TextStyle(
                    color: right,
                    fontSize: 16.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenButton(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            _dataString = _textController.text;
          });
        },
        child: Container(
          width: 150.0,
          height: 50.0,
          decoration: BoxDecoration(
            color: Theme.Colors.loginGradientEnd,
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          child: Center(
            child: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ));
  }

  _qrCallback(String code) {
    setState(() {
      _qrInfo = code;
    });
  }

  Widget _buildScan(BuildContext context) {
    return Center(
      child: Card(
          elevation: 2.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            width: 300,
            height: 500,
            child: Column(
              children: <Widget>[
                Container(

                  height: 300,
                  width: 280,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: QRBarScannerCamera(
                    onError: (context, error) => Text(
                      error.toString(),
                      style: TextStyle(color: Colors.red),
                    ),
                    qrCodeCallback: (code) {
                      _qrCallback(code);
                    },
                  ),
                ),
                Text(
                  _qrInfo,
                  style: TextStyle(color: Colors.black26),
                ),
              ],
            ),
          )),
    );
  }



  Widget _dlbtn(BuildContext context){
    return Center(
      child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: Icon(Icons.download_sharp),
            onPressed:
              _captureAndSharePng
              //Scaffold.of(context).showSnackBar(SnackBar(content: Text('$directory'),))
        ),
       /* IconButton(
            icon: Icon(Icons.share_sharp),
            onPressed: _share,
        )*/
      ],
     )
    );
  }

  Future<void> _snack() async{
    SnackBar snackBar = new SnackBar(content: Text ("Downloaded to: $_path"));
    _scaffoldKey.currentState.showSnackBar(snackBar);

  }

  Future<void> _captureAndSharePng() async {
    try {
      directory = await getExternalStorageDirectory();
      _path = directory.path;
      RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      _saveImage(pngBytes, directory.path+'/qr_codes', "_$i.png");
      i++;
      _snack();
      print(directory.path);
    //  Scaffold.of(context).showSnackBar(SnackBar(content: Text('$directory'),));
    } catch(e) {
      print(e.toString());
    }
  }
  Future<void> _share() async {
    RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    final channel = const MethodChannel('channel:com.sghost.ml_detector/share');
    channel.invokeMethod('shareFile', 'image.png');

  }
  void _saveImage(Uint8List uint8List, String dir, String fileName,
      {Function success, Function fail}) async {
    bool isDirExist = await Directory(dir).exists();
    if (!isDirExist) Directory(dir).create();
    String tempPath = '$dir$fileName';
    File image = File(tempPath);
    bool isExist = await image.exists();
    if (isExist) await image.delete();
    File file = new File(tempPath);
    await file.writeAsBytes(uint8List);
  }

  Widget _buildGen(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Center(
      child: Card(
        elevation: 2.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Container(
          width: 300,
          height: 600,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Container(
                height: 300,
                width: 280,
                child: RepaintBoundary(
                  key: globalKey,
                  child: QrImage(data: _dataString, size: 0.5 * bodyHeight, backgroundColor: Colors.white, foregroundColor: Colors.black,),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                child: TextFormField(
                  focusNode: mFocusNodeQrValue,
                  controller: _textController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter Text",
                    hintStyle: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
              _buildGenButton(context),
              _dlbtn(context)
            ],
          ),
        ),
      ),
    );
  }

  void _onScanButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onGenerateButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }
}