import 'package:PicBlockChain/screens/history_screen.dart';
import 'package:PicBlockChain/upload/recieve_screen.dart';
import 'package:PicBlockChain/upload/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:PicBlockChain/models/user_model.dart';
import 'package:PicBlockChain/widgets/boxes.dart';
import 'package:PicBlockChain/widgets/custom_home_button.dart';
import 'package:PicBlockChain/widgets/history_card.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'PBC SHARE',
          style: TextStyle(
            letterSpacing: 1.2,
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 130,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomHomeButton(
                          icon: Iconsax.additem,
                          text: 'Upload',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadScreen(),
                              ),
                            );
                          },
                        ),
                        CustomHomeButton(
                          icon: Iconsax.document_download,
                          text: 'Receive',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReceiveScreen(),
                              ),
                            );
                          },
                        ),
                        CustomHomeButton(
                          icon: Iconsax.share,
                          text: 'Invite',
                          onPressed: () {
                            Share.share(
                                'Download our application PBC Share from the below link https://github.com/Praveenuhhuv/my-app');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 5,
                  bottom: 15,
                  right: 10,
                ),
                child: Row(
                  children: [
                    Text(
                      'Recently Transactions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Expanded(child: Container()),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryScreen(),
                          ),
                        );
                      },
                      child: Icon(
                        Iconsax.arrow_21,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                width: double.infinity,
                child: ValueListenableBuilder<Box<UserModel>>(
                  valueListenable: Boxes.getTransactions().listenable(),
                  builder: (context, box, _) {
                    final transactions = box.values.toList().cast<UserModel>();
                    return HistoryCard(
                      transactions: transactions,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
