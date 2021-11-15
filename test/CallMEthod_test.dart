
import 'package:event_dispatcher/MethodCall/method_call.dart';
import 'package:event_dispatcher/event_dispatcher.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

class _MyDispatcher extends MessageDispatcher {
  _MyDispatcher() : super(MetaData(uuid: "47753420-42cd-11ec-b0e3-5ffe43506a83", name: "MyDispatcher", author: "Dream-LAb software technologies"));
}

Future<void> main() async {
  final dispatcher = _MyDispatcher();
  
  group("Test method call", (){
    final methodCallerA = MethodCallBridge(MetaData(uuid: "6b644eb6-42cd-11ec-a581-cb31a87005eb", name: "MyBridge", author: "Dream-Lab software technologies"), {
    "hello": (bridge, args)async {
      return {
        "result": await bridge.callMethod("hi", {"message": args["helloMessage"]})
      };
    }
  });
  final methodCallerB = MethodCallBridge(MetaData(uuid: "8d72f73c-42cd-11ec-ac43-3bf7b79a3bf8", name: "MyBridge", author: "Dream-Lab software technologies"), {
    "hi": (bridge, args)async {
      return {
        "result": "yes",
        "replayMessage": "Hi ${args["message"]}"
      };
    }
  });

  dispatcher.connect(methodCallerB);
  dispatcher.connect(methodCallerA);
    test("Main test", () async {
      final result = await methodCallerB.callMethod("hello", {"helloMessage": "Dream-Lab"});
      expect(result["result"]["result"], "yes");
      expect(result["result"]["replayMessage"], "Hi Dream-Lab");
    });
  });
}

