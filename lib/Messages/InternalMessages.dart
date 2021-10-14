import 'package:event_dispatcher/Schema/MessageSchema.dart';
import '../EventDispatcher.dart';

/**
 * @author Dream-Lab software technologies muhtarjan mahmood(مۇختەرجان مەخمۇت)
 * @email ug-project@outlook.com
 * @create date 2021-10-09 16:01:08
 * @modify date 2021-10-09 16:01:08
 * @desc [description]
 */
class NodeChangedMessage extends RawMessage {
  final MetaData node;
  final MetaData dispatcher;
  static final MessageDefinition DEFINITION =  MessageDefinition(name: "Node connected message", version: 0.1, schema: CustomObjectSchema(false, {
    "node": CustomObjectSchema(false, {
      "name": StringSchema(false, 1, 255),
      "uuid": StringSchema(false, 32, 255),
      "author": StringSchema(false, 1, 255),
    }),
    "dispatcher": CustomObjectSchema(false, {
      "name": StringSchema(false, 1, 255),
      "uuid": StringSchema(false, 32, 255),
      "author": StringSchema(false, 1, 255),
    })
  }));
  NodeChangedMessage(this.node, this.dispatcher, String messageKey) : super(messageKey: messageKey, definition: DEFINITION) {
    this.data["node"] = this.node.data;
    this.data["dispatcher"] = this.dispatcher.data;
  }
}

class NodeErrorMessage extends RawMessage {
  static final DEFINITION = MessageDefinition(name: "Node error message", version: 0.1, schema: CustomObjectSchema(false, {
    "node": (NodeChangedMessage.DEFINITION.schema as CustomObjectSchema).properties["node"]!,
    "dispatcher": (NodeChangedMessage.DEFINITION.schema as CustomObjectSchema).properties["dispatcher"]!,
    "errorMessage": StringSchema(false, 1, 255),
  }));
  final MetaData node;
  final MetaData dispatcher;
  final String errorMessage;
  final String stackTrace;
  NodeErrorMessage(this.node, this.dispatcher, this.errorMessage, this.stackTrace, String messageKey) : super(messageKey: messageKey, definition: DEFINITION) {
    this.data["node"] = this.node.data;
    this.data["dispatcher"] = this.dispatcher.data;
    this.data["errorMessage"] = this.errorMessage;
    this.data["stackTrace"] = this.stackTrace;
  }
  @override
  RawMessage cloneSelf() => NodeErrorMessage(node, dispatcher, errorMessage, stackTrace, messageKey);

  factory NodeErrorMessage.fromRawMessage(RawMessage message) {
    final value = NodeErrorMessage(MetaData.fromMap(message.data["node"]), MetaData.fromMap(message.data["dispatcher"]), message.data["errorMessage"], message.data["stackTrace"], message.messageKey);
    value.sender = message.sender;
    return value;
  }
}
