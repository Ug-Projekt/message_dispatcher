import 'dart:io';

import 'package:event_dispatcher/EventDispatcher.dart';
import 'package:event_dispatcher/Schema/MessageSchema.dart';

/**
 * @author Dream-Lab software technologies muhtarjan mahmood(مۇختەرجان مەخمۇت)
 * @email ug-project@outlook.com
 * @create date 2021-10-05 17:28:36
 * @modify date 2021-10-05 17:28:36
 * @desc [description]
 */

Future<void> main() async {
  final server = await HttpServer.bind("0.0.0.0", 8000);
  
  var index = 0;
  await for (final request in server) {
    request.response.write("Index is: ${index++}");
    await request.response.close();
  }
}