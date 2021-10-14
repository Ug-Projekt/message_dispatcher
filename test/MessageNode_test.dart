



import 'package:event_dispatcher/EventDispatcher.dart';
import 'package:event_dispatcher/Schema/MessageSchema.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _TestMessage extends RawMessage {
  final int value;
  static final DEFINITION = MessageDefinition(name: "Test message", version: 0.1, schema: CustomObjectSchema(false, {
    "value": IntegerSchema(false, 0xffffffff, 0),
  }));
  _TestMessage(String messageKey, this.value) : super(messageKey: messageKey, definition: DEFINITION) {
    this.data["value"] = this.value;
  }
  factory _TestMessage.fromRawMessage(RawMessage message) => _TestMessage(message.messageKey, message.data["value"]);
}

class NodeA extends MessageNode {
  var counter = 0;
  var value = -1;
  NodeA() : super(MetaData(uuid: "d5e9be78-2a96-11ec-8c46-1312bed55ca8", name: "Node A", author: "Dream lab software technologies"), {
    "xxx.yyy.aaa": _TestMessage.DEFINITION,
  }, {
    "xxx.yyy.aaa": _TestMessage.DEFINITION,
  });
  @override
  void handle(RawMessage message) {
    if (message.sender!.uuid == this.metaData.uuid) return;
    if (message.messageKey == "xxx.yyy.aaa") {
      final _message = _TestMessage.fromRawMessage(message);
      this.counter++;
      this.value = _message.value;
    }
  }
}

class NodeB extends MessageNode {
  var counter = 0;
  var value = -1;
  NodeB() : super(MetaData(uuid: "e0a20b86-2a96-11ec-923e-9ba7d7ac3025", name: "Node B", author: "Dream lab software technologies"), {
    "xxx.yyy.aaa": _TestMessage.DEFINITION,
    "xxx.yyy.bbb": _TestMessage.DEFINITION,
  }, {
    "xxx.yyy.aaa": _TestMessage.DEFINITION,
    "xxx.yyy.bbb": _TestMessage.DEFINITION,
  });
  @override
  void handle(RawMessage message) {
    if (message.sender!.uuid == this.metaData.uuid) return;
      if (message.messageKey == "xxx.yyy.aaa") {
      final _message = _TestMessage.fromRawMessage(message);
      this.counter++;
      this.value = _message.value;
    }
    if (message.messageKey == "xxx.yyy.bbb") {
      final _message = _TestMessage.fromRawMessage(message);
      this.counter++;
      this.value = _message.value;
    }
  }
}
class NodeC extends MessageNode {
  var counter = 0;
  var value = -1;
  NodeC() : super(MetaData(uuid: "e900542c-2a96-11ec-88f0-07b737de8092", name: "Node C", author: "Dream lab software technologies"), {
    "xxx.yyy.aaa": _TestMessage.DEFINITION,
    "xxx.yyy.bbb": _TestMessage.DEFINITION,
    "xxx.yyy.ccc": _TestMessage.DEFINITION,
  }, {
    "xxx.yyy.aaa": _TestMessage.DEFINITION,
    "xxx.yyy.bbb": _TestMessage.DEFINITION,
    "xxx.yyy.ccc": _TestMessage.DEFINITION,
  });
  @override
  void handle(RawMessage message) {

    if (message.messageKey == "xxx.yyy.aaa") {
      final _message = _TestMessage.fromRawMessage(message);
      this.counter++;
      this.value = _message.value;
    }
    if (message.messageKey == "xxx.yyy.bbb") {
      final _message = _TestMessage.fromRawMessage(message);
      this.counter++;
      this.value = _message.value;
    }
    if (message.messageKey == "xxx.yyy.ccc") {
      final _message = _TestMessage.fromRawMessage(message);
      this.counter++;
      this.value = _message.value;
    }
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
  group("Single message dispatcher test => ", (){
    final dispatcher = _TestMessageDispatcherA();
    final nodeA = NodeA();
    final nodeB = NodeB();
    final nodeC = NodeC();
    dispatcher.connect(nodeA);
    dispatcher.connect(nodeB);
    dispatcher.connect(nodeC);
    _simpleTest(nodeA, nodeB, nodeC);
  });

  group("Two message dispatcher test => ", (){
    final dispatcherA = _TestMessageDispatcherA();
    final dispatcherB = _TestMessageDispatcherB();
    final bridgeA = _BridgeA();
    final bridgeB = _BridgeB();
    dispatcherA.connect(bridgeA);
    dispatcherB.connect(bridgeB);
    bridgeA.b = bridgeB;
    bridgeB.a = bridgeA;

    final nodeA = NodeA();
    final nodeB = NodeB();
    final nodeC = NodeC();
    dispatcherA.connect(nodeA);
    dispatcherA.connect(nodeB);
    dispatcherB.connect(nodeC);
    _simpleTest(nodeA, nodeB, nodeC);
  });
  group("Three message dispatcher test => ", (){
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

    final nodeA = NodeA();
    final nodeB = NodeB();
    final nodeC = NodeC();

    dispatcherA.connect(nodeA);
    dispatcherB.connect(nodeB);
    dispatcherC.connect(nodeC);

    _simpleTest(nodeA, nodeB, nodeC);
  });
}

void _simpleTest(NodeA nodeA, NodeB nodeB, NodeC nodeC) {
  test("should throw exception with unregistered message key", (){
    _testWithEXceptions(nodeA, nodeB, nodeC);
  });
  test("single message dispatcher delivery correctness", (){
    _testWithDeliveryCorrectness(nodeA, nodeB, nodeC);
  });
}
void _testWithDeliveryCorrectness(NodeA nodeA, NodeB nodeB, NodeC nodeC) {
  int countA = 0;
  int countB = 0;
  int countC = 0;

  int valueA = -1;
  int valueB = -1;
  int valueC = -1;

  expect(nodeA.value, -1);
  expect(nodeB.value, -1);
  expect(nodeC.value, -1);

  for (var a = 1; a < 1000; a += 1) {
    nodeA.dispatch(message: _TestMessage("xxx.yyy.aaa", a));
    expect(nodeA.counter, countA);
    expect(nodeA.value, valueA);
    countB++;
    valueB = a;
    expect(nodeB.counter, countB);
    expect(nodeB.value, valueB);
    countC++;
    valueC = a;
    expect(nodeC.counter, countC);
    expect(nodeC.value, valueC);

    nodeB.dispatch(message: _TestMessage("xxx.yyy.aaa", a + 1));
    valueA = a + 1;
    countA++;
    expect(nodeA.counter, countA);
    expect(nodeA.value, valueA);
    expect(nodeB.counter, countB);
    expect(nodeB.value, valueB);
    countC++;
    valueC = a + 1;
    expect(nodeC.counter, countC);
    expect(nodeC.value, valueC);

    nodeC.dispatch(message: _TestMessage("xxx.yyy.aaa", a + 2));
    countA++;
    valueA = a + 2;
    expect(nodeA.counter, countA);
    expect(nodeA.value, valueA);
    countB++;
    valueB = a + 2;
    expect(nodeB.counter, countB);
    expect(nodeB.value, valueB);
    countC++;
    valueC = a + 2;
    expect(nodeC.counter, countC);
    expect(nodeC.value, valueC);

    nodeC.dispatch(message: _TestMessage("xxx.yyy.ccc", a + 3));
    expect(nodeA.counter, countA);
    expect(nodeA.value, valueA);
    expect(nodeB.counter, countB);
    expect(nodeB.value, valueB);
    countC++;
    valueC = a + 3;
    expect(nodeC.counter, countC);
    expect(nodeC.value, valueC);
  }
}

void _testWithEXceptions(NodeA nodeA, NodeB nodeB, NodeC nodeC) {
  expect(() => nodeA.dispatch(message: _TestMessage("xxx.yyy.zzz", 99)), throwsException);
  expect(() => nodeB.dispatch(message: _TestMessage("xxx.*.zzz", 99)), throwsException);
  expect(() => nodeC.dispatch(message: _TestMessage("xxx..zzz", 99)), throwsException);
}
