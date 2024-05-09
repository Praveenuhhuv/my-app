// ignore_for_file: prefer_const_constructors

import 'dart:io'; // Add this import statement

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:PicBlockChain/config/config.dart';
import 'package:PicBlockChain/models/user_model.dart';
import 'package:PicBlockChain/services/ipfs_servie.dart';
import 'package:PicBlockChain/upload/qr_screen.dart';
import 'package:PicBlockChain/widgets/boxes.dart';
import 'package:PicBlockChain/widgets/dialogs/progress_dialog.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class FilePickerService {
  @protected
  @mustCallSuper
  void dispose() {
    Hive.close();
  }

  //PICKER
  static Future<FilePickerResult?> pickFile(BuildContext context) async {
    final FilePicker _picker = FilePicker.platform;

    try {
      // Pick a file
      FilePickerResult? file = await _picker.pickFiles();

      //Nothing picked
      if (file == null) {
        Fluttertoast.showToast(
          msg: 'No File Selected',
        );
        return null;
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => ProgressDialog(
            status: 'Uploading to Pinata',
          ),
        );

        // Upload file to IPFS
        final fileBytes = File(file.files.single.path!);
        final cid = await IpfsService().uploadToIpfs(fileBytes);

        // Saving the transaction to database
        final transactionMap = UserModel()
          ..url = 'https://gateway.pinata.cloud/ipfs/$cid'
          ..date = DateFormat.yMMMd().format(DateTime.now())
          ..received = false;

        final box = Boxes.getTransactions();
        box.add(transactionMap);

        // Popping out the dialog box
        Navigator.pop(context);

        // Take to QrScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrScreen(cid: cid),
          ),
        );

        //Return Path
        return file;
      }
    } catch (e) {
      debugPrint('Error at file picker: $e');
      SnackBar(
        content: Text(
          'Error at file picker: $e',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
      );
      return null;
    }
  }
}
