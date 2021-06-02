import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BarCodePage extends StatefulWidget {
  BarCodePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _BarCodePageState createState() => _BarCodePageState();
}

class _BarCodePageState extends State<BarCodePage> {
  GlobalKey _globalKey = new GlobalKey();
  bool showBarCode = false;
  String barCodeText;
  BarCodeType barCode;
  List<BarCodeType> barCodeTypes = [
    BarCodeType('Code39', Barcode.code39()),
    BarCodeType('Code93', Barcode.code93()),
    BarCodeType('Code128', Barcode.code128()),
    BarCodeType('GS128', Barcode.gs128()),
    BarCodeType('Itf', Barcode.itf()),
    BarCodeType('CodeITF14', Barcode.itf14()),
    BarCodeType('CodeITF16', Barcode.itf16()),
    BarCodeType('CodeEAN13', Barcode.ean13()),
    BarCodeType('CodeEAN8', Barcode.ean8()),
    BarCodeType('CodeEAN5', Barcode.ean5()),
    BarCodeType('CodeEAN2', Barcode.ean2()),
    BarCodeType('CodeISBN', Barcode.isbn()),
    BarCodeType('CodeUPCA', Barcode.upcA()),
    BarCodeType('CodeUPCE', Barcode.upcE()),
    BarCodeType('Telepen', Barcode.telepen()),
    BarCodeType('Codabar', Barcode.codabar()),
    BarCodeType('Rm4scc', Barcode.rm4scc()),
    BarCodeType('QrCode', Barcode.qrCode()),
    BarCodeType('PDF417', Barcode.pdf417()),
    BarCodeType('DataMatrix', Barcode.dataMatrix()),
    BarCodeType('Aztec', Barcode.aztec()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _buildTextInputField(),
            _buildBarCodeType(),
            _buildBarCode(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  _buildTextInputField() {
    return TextField(
      onChanged: (text) {
        setState(() {
          showBarCode = false;
          barCodeText = text;
        });
      },
      decoration: InputDecoration(labelText: 'Text here'),
    );
  }

  _buildButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: !showBarCode,
            child: ElevatedButton(
              child: Text('Create Bar Code'),
              style: ElevatedButton.styleFrom(primary: Colors.blue),
              onPressed: () {
                setState(() {
                  showBarCode = true;
                });
              },
            ),
          ),
          Visibility(
            visible: showBarCode,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: Text('Clear Bar Code'),
              onPressed: () {
                setState(() {
                  showBarCode = false;
                });
              },
            ),
          ),
          Visibility(
            visible: showBarCode,
            child: Padding(
              padding: const EdgeInsets.only(left: 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: Text('Share Bar Code'),
                onPressed: () {
                  _barCodeToImage();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildBarCodeType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Bar Code Type'),
        DropdownButton<BarCodeType>(
          hint: Text("Select item"),
          value: barCode,
          onChanged: (BarCodeType Value) {
            setState(() {
              barCode = Value;
            });
          },
          items: barCodeTypes.map((BarCodeType type) {
            return DropdownMenuItem<BarCodeType>(
              value: type,
              child: Row(
                children: <Widget>[
                  Text(
                    type.barCodeTypeName,
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  _buildBarCode() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Visibility(
        visible: showBarCode,
        child: RepaintBoundary(
          key: _globalKey,
          child: Container(
            color: Colors.white,
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              // Barcode type and settings
              data: barCodeText ?? '',
              // Content
              width: 200,
              height: 200,
              errorBuilder: (context, error) {
                return Text(error);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _barCodeToImage() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      _shareBarCodeImage(pngBytes);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _shareBarCodeImage(Uint8List bytes) async {
    try {
      await Share.file('Share Via', 'BarCode.png', bytes, 'image/png',
          text: 'Bar Code');
    } catch (e) {
      print('error: $e');
    }
  }
}

class BarCodeType {
  String barCodeTypeName;
  Barcode barCodeType;

  BarCodeType(this.barCodeTypeName, this.barCodeType);
}
