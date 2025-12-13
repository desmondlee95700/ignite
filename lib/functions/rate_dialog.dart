import 'package:flutter/material.dart';
// import 'package:store_redirect/store_redirect.dart';

class RateAppDialog extends StatelessWidget {
  const RateAppDialog({super.key});


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Our App', style: TextStyle(fontSize: 16)),
      content: const Text(
          'If you enjoy using this app, please consider giving us a rating!'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () {
            // StoreRedirect.redirect(androidAppId: "com.karangkraf.sinardaily",
            //         iOSAppId: "id1630307720"); // Open store for rating
          },
          child: const Text('Rate Now'),
        ),
      ],
    );
  }
}