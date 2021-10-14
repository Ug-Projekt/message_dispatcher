import 'package:event_dispatcher/LightTree.dart';
import 'package:event_dispatcher/Messages/InternalMessages.dart';
import 'package:event_dispatcher/Schema/MessageSchema.dart';
import 'package:uuid/uuid.dart';
// import 'dart:developer' as Developer;

/**
 * @author Dream-Lab software technologies muhtarjan mahmood(مۇختەرجان مەخمۇت)
 * @email ug-project@outlook.com
 * @create date 2021-10-05 17:40:06
 * @modify date 2021-10-05 17:40:06
 * @desc [description]
 */
class MetaData {
  MetaData({required String uuid, required String name, required String author}){
    this.data["name"] = name;
    this.data["author"] = author;
    this.data["uuid"] = uuid;
  }
  String get name => this.data["name"];
  String get uuid => this.data["uuid"];
  String get author => this.data["author"];
  final data = <String, dynamic>{};
  @override
  String toString() => "$name";

  factory MetaData.fromMap(Map<String, dynamic> map) {
    return MetaData(uuid: map["uuid"], name: map["name"], author: map["author"]);
  }
}

class MessageDefinition {
  final ObjectSchema schema;
  final String name;
  final double version;
  MessageDefinition({required this.name, required this.version, required this.schema});
}
2
class RawMessage {
  final String id;
  final MessageDefinition definition;
  final String messageKey;
  MetaData? sender;
  final Map<String, dynamic> data = {};
  RawMessage({required this.messageKey, required this.definition, String? id}) : id = id ?? Uuid().v4();
  RawMessage cloneSelf() {
    final copyed = RawMessage(messageKey: messageKey, definition: definition, id: id);
    final cloned = this.data.deepClone();
    copyed.data.addAll(cloned);
    return copyed;
  }
}

abstract class MessageNode {
  final MetaData metaData;
  final Map<String, MessageDefinition> sendMessageKeys;
  final Map<String, MessageDefinition> receiveMessageKeys;
  MessageDispatcher? get dispatcher => connection?.dispatcher;
  MessageNodeConnectionTicket? connection;
  MessageNode(this.metaData, this.sendMessageKeys, this.receiveMessageKeys) {}
  void handle(RawMessage message);
  void dispatch({required RawMessage message}) {
    if (this.dispatcher == null) throw Exception("Message node '${this.metaData}' is not connected to any message dispatcher, please connect to message dispatcher before using it please.");
    this.dispatcher!.dispatch(this, message: message);
  }
  void onConnected() {}
  void onDisconnected() {}
}

abstract class BridgeNode extends MessageNode {
  BridgeNode(MetaData metaData) : super(metaData, {}, {
    "*.*.*": MessageDefinition(name: "Bridged message", version: 0.1, schema: CustomObjectSchema(false, {})),
  });
}

class MessageNodeConnectionTicket {
  final MessageDispatcher dispatcher;
  final String connectionId;
  MessageNodeConnectionTicket(this.dispatcher, this.connectionId);
  void disconnect() {
    this.dispatcher.disconnect(this.connectionId);
  }
}
class ConnectionDeniedException {
  final String message;
  ConnectionDeniedException(this.message);
  @override
  String toString() => this.message;
}

class MessageValidationException {
  final String message;
  MessageValidationException(this.message);
  @override
  String toString() => this.message;
}

abstract class MessageDispatcher {
  final MetaData metaData;
  final _nodes = <String, MessageNode>{};
  late _DispatcherInternalNode _internalNode;
  // final TreeNodeBase _messageNodeReceiveKeysIndex = TreeNodeBase("");
  MessageDispatcher(this.metaData) {
    this._internalNode = _DispatcherInternalNode(MetaData(uuid: "c8919840-28e8-11ec-8bac-272b545b72a5", name: "Internal node of '${this.metaData.name}'", author: this.metaData.author));
    this.connect(this._internalNode);
  }
  ///For speed up dispatch event, we will index all [MessageNode]'s receive keys as a tree so we can fast access corresponding destination [MessageNode] of message key
  // void reCreateMessageReceiverIndex() {
  //   this._messageNodeReceiveKeysIndex.children.clear();
  //   TreeNodeBase _createTreeNodeByKey(TreeNodeBase parentTree, List<String> keys, int currentIndex, MessageNode node) {
  //     if (currentIndex == keys.length) {
  //       TreeDataNode("", parentTree, node);
  //       return parentTree;
  //     }
  //     final key = keys[currentIndex];
  //     var childNodes = parentTree.children.where((element) => element.key == key).toList();
  //     if (childNodes.isEmpty) {
  //       childNodes.add(TreeIndexNode(key, parentTree));
  //     }
  //     return _createTreeNodeByKey(childNodes.first, keys, currentIndex + 1, node);
  //   }
  //   this._nodes.forEach((_, messageNode) { 
  //     messageNode.receiveMessageKeys.forEach((messageKey, messageDefinition) {
  //       final keys = messageKey.split(".").where((element) => element.isNotEmpty).toList();
  //       _createTreeNodeByKey(this._messageNodeReceiveKeysIndex, keys, 0, messageNode) as TreeDataNode;
  //     });
  //   });
  // }

  MessageNodeConnectionTicket connect(MessageNode node) {
    bool isApproved = this.approveMessageNode(node);
    if (!isApproved) {
      this._internalNode.dispatch(message: NodeChangedMessage(node.metaData, this.metaData, "message-dispatcher.node.connection-request-denied"));
      throw ConnectionDeniedException("Connection request of ${node.metaData} is denied by ${this.metaData}");
    }
    final connection = MessageNodeConnectionTicket(this, Uuid().v4());
    node.connection = connection;
    this._nodes[connection.connectionId] = node;
    this._internalNode.dispatch(message: NodeChangedMessage(node.metaData, this.metaData, "message-dispatcher.node.connected"));
    node.onConnected();
    return connection;
  }

  void dispatch(MessageNode node, {required RawMessage message}) {
    final _sourceMessage = message;
    message = message.cloneSelf();
    message.sender = node.metaData;

    final result = message.definition.schema.validate("yourMessage", message.data);
    if (!result.passed) throw MessageValidationException("Message validation failed because your message schema should be '${result.message}'");
    final keySegments = message.messageKey.split(".").where((element) => element.isNotEmpty).toList();
    if (keySegments.any((element) => element == "*")) throw Exception("Message key cannot contain '*' matchers");
    final isBridgeNodeOrContainCorrectKey = node is BridgeNode || node.sendMessageKeys.containsKey(message.messageKey);
    if (!isBridgeNodeOrContainCorrectKey) throw Exception("Cannot dispatch your message because the message key '${message.messageKey}' is not registered in sendMessageKeys of ${node.metaData}, did you forget register it?");
    this._nodes.forEach((_, messageNode) {
      messageNode.receiveMessageKeys.forEach((key, _) {
        final nodeKeySegments = key.split(".").where((element) => element.isNotEmpty).toList();
        if (keySegments.length != nodeKeySegments.length) return;
        for (int i = 0; i < keySegments.length; i++) {
          if (nodeKeySegments[i] == "*") continue;
          if (nodeKeySegments[i] == keySegments[i]) continue;
          return;
        }
        try {
          messageNode.handle(message);
        } catch (exception, stackTrace) {
          if (message.sender!.uuid == this._internalNode.metaData.uuid) rethrow;
          this._internalNode.dispatch(message: NodeErrorMessage(node.metaData, this.metaData, exception.toString(), stackTrace.toString(), "message-dispatcher.node.error"));
        }
      });
    });
  }
  
  bool disconnect(String ticketId) {
    final node = this._nodes[ticketId];
    final value = this._nodes.remove(ticketId) != null;
    if (value) {
      this._internalNode.dispatch(message: NodeChangedMessage(node!.metaData, this.metaData, "message-dispatcher.node.disconnected"));
      node.onDisconnected();
    }
    return value;
  }
  bool approveMessageNode(MessageNode messageNode){
    return true;
  }
}

class _DispatcherInternalNode extends MessageNode {
  _DispatcherInternalNode(MetaData metaData) : super(metaData, {
    "message-dispatcher.node.connected": NodeChangedMessage.DEFINITION,
    "message-dispatcher.node.disconnected": NodeChangedMessage.DEFINITION,
    "message-dispatcher.node.connection-request-denied": NodeChangedMessage.DEFINITION,
    "message-dispatcher.node.error": NodeErrorMessage.DEFINITION,
  }, {
    "message-dispatcher.node.connected": NodeChangedMessage.DEFINITION,
    "message-dispatcher.node.disconnected": NodeChangedMessage.DEFINITION,
    "message-dispatcher.node.connection-request-denied": NodeChangedMessage.DEFINITION,
    "message-dispatcher.node.error": NodeErrorMessage.DEFINITION,
  });
  @override
  void handle(RawMessage message) {
    if (message.sender!.uuid == this.metaData.uuid) return;
    if (message.messageKey == "message-dispatcher.node.error") {
      final error = NodeErrorMessage.fromRawMessage(message);
      print("Node [${error.node}] that connected to [${error.dispatcher}] has an exception, the exception is ${error.errorMessage} and occurred here: ${error.stackTrace}]");
    }
  }
}

extension DeepCopyMapExtension<K, V> on Map<K, V> {
  Map<String, V> deepClone() {
    final _map = new Map<String, V>();
    this.forEach((key, value) {
      if (value is List) {
        _map[key.toString()] = value.deepClone() as V;
        return;
      }
      if (value is Map) {
        _map[key.toString()] = value.deepClone() as V;
        return;
      }
    _map[key.toString()] = value;
    });
    return _map;
  }
}

extension DeepCopyListExtension<T> on List<T> {
  List<T> deepClone() {
    final _list = <T>[];
    this.forEach((element) {
      if (element is List) {
        _list.add(element.deepClone() as T);
        return;
      }
      if (element is Map) {
        _list.add(element.deepClone() as T);
      }
      _list.add(element);
    });
    return _list;
  }
}