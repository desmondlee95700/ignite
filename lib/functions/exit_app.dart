import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/functions/size_config.dart';

void showExit(BuildContext context) {
  showModalBottomSheet<void>(
    backgroundColor: darkThemeColor,
    showDragHandle: true,
    context: context,
    isScrollControlled: true, // Enable scrolling
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32.0),
        topRight: Radius.circular(32.0),
      ),
    ),
    builder: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height *
              0.8, // Set the desired height
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              children: [
                // const EmptyState(
                //   imageAsset: "assets/images/empty-directions.png",
                //   text: "Are you sure you want to exit the app",
                // ),
                const Text("Are you sure you want to exit the app",
                    style:
                        TextStyle(fontFamily: 'Manrope', color: Colors.white)),
                SizedBox(height: getProportionateScreenHeight(15)),
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                24.0), // Adjust the radius as needed
                          ),
                        ),
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          return kPrimaryColor;
                        }),
                      ),
                      child: const Text(
                        "OK",
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
