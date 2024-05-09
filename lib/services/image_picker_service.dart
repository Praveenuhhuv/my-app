import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:PicBlockChain/config/config.dart';
import 'package:PicBlockChain/models/user_model.dart';
import 'package:PicBlockChain/services/ipfs_servie.dart';
import 'package:PicBlockChain/upload/qr_screen.dart';
import 'package:PicBlockChain/widgets/boxes.dart';
import 'package:PicBlockChain/widgets/dialogs/progress_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ImagePickerService {
  static Future<XFile?> pickImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) {
        Fluttertoast.showToast(
          msg: 'No Image Selected',
        );
        return null;
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => const ProgressDialog(
            status: 'Uploading to Pinata',
          ),
        );

        final file = File(image.path);
        final cid = await IpfsService().uploadToIpfs(file);

        final transactionMap = UserModel()
          ..url = 'https://gateway.pinata.cloud/ipfs/$cid'
          ..date = DateFormat.yMMMd().format(DateTime.now())
          ..received = false;

        final box = Boxes.getTransactions();
        box.add(transactionMap);

        Navigator.pop(context); // Dismiss progress dialog

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrScreen(cid: cid),
          ),
        );

        return image;
      }
    } catch (e) {
      debugPrint('Error at image picker: $e');
      Fluttertoast.showToast(
        msg: 'Error at image picker: $e',
      );
      return null;
    }
  }
}
