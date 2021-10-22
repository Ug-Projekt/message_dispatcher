import 'package:event_dispatcher/EventDispatcher.dart';
import 'package:event_dispatcher/SharedData/SharedData.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

/**
 * @author Dream-Lab software technologies muhtarjan mahmood(مۇختەرجان مەخمۇت)
 * @email ug-project@outlook.com
 * @create date 2021-10-10 00:02:01
 * @modify date 2021-10-10 00:02:01
 * @desc [description]
 */



class DataNodeA extends SharedDataNode {
  DataNodeA() : super("AppData", MetaData(uuid: "424f64a4-292b-11ec-baac-43b4c3887f35", name: "Data node A", author: "Dream lab software technologies"));
  @override
  void onSyncCompleted() {
    // print("Sync completed in A");
  }
}
class DataNodeB extends SharedDataNode {
  DataNodeB() : super("AppData", MetaData(uuid: "6478add8-292b-11ec-8691-23b054478435", name: "Data node B", author: "Dream lab software technologies"));
  @override
  void onSyncCompleted() {
    // print("Sync completed in B");
  }
}
class DataNodeC extends SharedDataNode {
  DataNodeC() : super("AppData", MetaData(uuid: "64beba08-292b-11ec-8baf-474e0272e1dc", name: "Data node C", author: "Dream lab software technologies"));
  @override
  void onSyncCompleted() {
    // print("Sync completed in C");
  }
}

class DataNodeD extends SharedDataNode {
  DataNodeD() : super("AppData", MetaData(uuid: "a712773e-292e-11ec-88d4-d789edcc9266", name: "Data node D", author: "Dream lab software technologies"));
  @override
  void onSyncCompleted() {
    // print("Sync completed in D");
  }
}


class _TestMessageDispatcherA extends MessageDispatcher {
  _TestMessageDispatcherA() : super(MetaData(uuid: "ef7b46a4-2a96-11ec-a878-7b0bb0c8faaa", name: "Message dispatcher A", author: "Dream lab software technologies"));
}
class _TestMessageDispatcherB extends MessageDispatcher {
  _TestMessageDispatcherB() : super(MetaData(uuid: "f51ef3f8-2a96-11ec-81d0-5734c7a638ed", name: "Message dispatcher B", author: "Dream lab software technologies"));
}
class _TestMessageDispatcherC extends MessageDispatcher {
  _TestMessageDispatcherC() : super(MetaData(uuid: "005d8c52-2b32-11ec-b415-1724107572ce", name: "Message dispatcher C", author: "Dream lab software technologies"));
}
class _BridgeA extends BridgeNode {
  _BridgeB? b;
  _BridgeA() : super(MetaData(uuid: "0237fed6-2a97-11ec-98ca-5f18f9268373", name: "Bridge A", author: "Dream-Lab software technologies"));

  @override
  void handle(RawMessage message) {
    if (message.sender!.uuid == this.metaData.uuid) return;
    b?.dispatch(message: message);
  }
}
class _BridgeB extends BridgeNode {
  _BridgeA? a;
  _BridgeB() : super(MetaData(uuid: "30466696-2a92-11ec-a5cf-0b932ee29b77", name: "Bridge B", author: "Dream-Lab software technologies"));

  @override
  void handle(RawMessage message) {
    if (message.sender!.uuid == this.metaData.uuid) return;
    a?.dispatch(message: message);
  }
}
class _BridgeC extends BridgeNode {
  _BridgeD? d;
  _BridgeC() : super(MetaData(uuid: "fc167a7a-2b25-11ec-b30e-a7033bf53095", name: "Bridge C", author: "Dream-Lab software technologies"));
  @override
  void handle(RawMessage message) {
    if (message.sender!.uuid == this.metaData.uuid) return;
    d?.dispatch(message: message);
  }
}
class _BridgeD extends BridgeNode {
  _BridgeC? c;
  _BridgeD() : super(MetaData(uuid: "a73a2d0a-2b32-11ec-b7ae-cbe366c603d6", name: "Bridge D", author: "Dream-Lab software technologies"));
  @override
  void handle(RawMessage message) {
    if (message.sender!.uuid == this.metaData.uuid) return;
    c?.dispatch(message: message);
  }
}

void main() {
  test("Shared data test", (){
    ///Create threee dispatcher
    final dispatcherA = _TestMessageDispatcherA();
    final dispatcherB = _TestMessageDispatcherB();
    final dispatcherC = _TestMessageDispatcherC();

    ///And create their bridges
    final bridgeA = _BridgeA();
    final bridgeB = _BridgeB();
    final bridgeC = _BridgeC();
    final bridgeD = _BridgeD();

    ///and connect it's dispatchers
    dispatcherA.connect(bridgeA);
    dispatcherB.connect(bridgeB);
    dispatcherB.connect(bridgeC);
    dispatcherC.connect(bridgeD);

    ///connect together
    bridgeA.b = bridgeB;
    bridgeB.a = bridgeA;
    bridgeC.d = bridgeD;
    bridgeD.c = bridgeC;

    final dataNodeA = DataNodeA();
    final dataNodeB = DataNodeB();
    final dataNodeC = DataNodeC();
    final dataNodeD = DataNodeD();
    dispatcherA.connect(dataNodeA);
    dispatcherB.connect(dataNodeB);
    dispatcherC.connect(dataNodeC);

    dataNodeA.data["name"] = "Hello";
    dataNodeA.applyChanges();
    expect(dataNodeC.data["name"], "Hello");
    expect(dataNodeB.data["name"], "Hello");
    dataNodeB
    ..data["name"] = "changed"
    ..applyChanges();
    expect(dataNodeC.data["name"], "changed");
    expect(dataNodeA.data["name"], "changed");
    final connectionD = dispatcherA.connect(dataNodeD);
    expect(dataNodeD.data["name"], "changed");
    connectionD.disconnect();
    dataNodeC
    ..data["name"] = "Changed to C"
    ..applyChanges();
    dispatcherB.connect(dataNodeD);
    expect(dataNodeD.data["name"], "Changed to C");
  });
}

