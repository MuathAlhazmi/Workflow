import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workflow/helpers/responsive.dart';
import 'package:workflow/theme/colors.dart';

class TodoFile extends StatelessWidget {
  final String name;
  final int size;
  final String author;
  final String uri;

  const TodoFile(
      {Key? key,
      required this.name,
      required this.size,
      required this.author,
      required this.uri})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.9
          : MediaQuery.of(context).size.width * 0.6,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
      decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemFill,
          borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: fillColor.withOpacity(.2),
                borderRadius: BorderRadius.circular(21),
              ),
              height: 42,
              width: 42,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                      onPressed: () async {
                        var localPath = uri;

                        if (uri.startsWith('http')) {
                          final client = http.Client();
                          final request = await client.get(Uri.parse(uri));
                          final bytes = request.bodyBytes;
                          final documentsDir =
                              (await getApplicationDocumentsDirectory()).path;
                          localPath = '$documentsDir/$name';

                          if (!File(localPath).existsSync()) {
                            final file = File(localPath);
                            await file.writeAsBytes(bytes);
                          }
                        }

                        await OpenFile.open(localPath);
                      },
                      icon: Icon(CupertinoIcons.cloud_download))
                ],
              ),
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.all(5),
                margin: const EdgeInsetsDirectional.only(
                  start: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 4,
                      ),
                      child: Text(
                        formatBytes(size.truncate()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
