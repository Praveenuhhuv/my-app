import 'package:PicBlockChain/models/user_model.dart';
import 'package:hive/hive.dart';

class Boxes {
  static late Box<UserModel> _transactionsBox;

  static Future<void> init() async {
    await Hive.openBox<UserModel>('user_model').then((box) {
      _transactionsBox = box;
    });
  }

  static Box<UserModel> getTransactions() {
    // ignore: unnecessary_null_comparison
    if (_transactionsBox == null) {
      throw HiveError('Box not initialized. Call Boxes.init() first.');
    }
    return _transactionsBox;
  }
}
