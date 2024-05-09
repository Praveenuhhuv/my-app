import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:PicBlockChain/models/user_model.dart';
import 'package:PicBlockChain/services/ipfs_servie.dart';
import 'package:PicBlockChain/upload/qr_screen.dart';
import 'package:PicBlockChain/widgets/boxes.dart';
import 'package:PicBlockChain/widgets/dialogs/progress_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class VideoPickerService {
  static Future<XFile?> pickVideo(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video == null) {
        Fluttertoast.showToast(
          msg: 'No Video Selected',
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

        final file = File(video.path);
        final cid = await IpfsService().uploadToIpfs(file);

        final transactionMap = UserModel()
          ..url = 'https://gateway.pinata.cloud/ipfs/$cid'
          ..date = DateFormat.yMMMd().format(DateTime.now())
          ..received = false;

        final box = Boxes.getTransactions();
        box.add(transactionMap);

        Navigator.pop(context); // Dismiss the ProgressDialog

        // Navigate to QrScreen using Navigator
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrScreen(cid: cid),
          ),
        );

        return video;
      }
    } catch (e) {
      debugPrint('Error at video picker: $e');
      Fluttertoast.showToast(
        msg: 'Error at video picker: $e',
      );
      return null;
    }
  }
}
