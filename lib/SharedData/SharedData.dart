import 'package:event_dispatcher/EventDispatcher.dart';
import 'package:event_dispatcher/Schema/MessageSchema.dart';

/**
 * @author Dream-Lab software technologies muhtarjan mahmood(مۇختەرجان مەخمۇت)
 * @email ug-project@outlook.com
 * @create date 2021-10-09 17:51:17
 * @modify date 2021-10-09 17:51:17
 * @desc [description]
 */

class SharedDataSyncMessage extends RawMessage {
  // final Map<String, dynamic> created;
  // final Map<String, dynamic> updated;
  // final Map<String, dynamic> deleted;
  final Map<String, dynamic> sharedData;
  final int dataVersion;
  static final DEFINITION = MessageDefinition(name: "Shared data sync message", version: 0.1, schema: CustomObjectSchema(false, {
    // "created": CustomObjectSchema(false, {}),
    // "updated": CustomObjectSchema(false, {}),
    // "deleted": CustomObjectSchema(false, {}),
    "version": IntegerSchema(false, 999999999, 0),
    "data": CustomObjectSchema(false, {}),
  }));
  SharedDataSyncMessage(String messageKey, this.sharedData, this.dataVersion) : super(messageKey: messageKey, definition: DEFINITION) {
    this.data["data"] = this.sharedData;
    this.data["version"] = this.dataVersion;
  }
  factory SharedDataSyncMessage.fromRawMessage(RawMessage message) {
    final result = SharedDataSyncMessage(message.messageKey, message.data["data"], message.data["version"]);
    result.sender = message.sender;
    return result;
  }
}

class SharedDataRequestDataMessage extends RawMessage {
  static final DEFINITION = MessageDefinition(name: "Shared data request message", version: 0.1, schema: CustomObjectSchema(false, {}));
  SharedDataRequestDataMessage(String messageKey) : super(messageKey: messageKey, definition: DEFINITION);
}

abstract class SharedDataNode extends MessageNode {
  final String key;
  final Map<String, dynamic> data = {};
  int dataVersion = 0;
  SharedDataNode(this.key, MetaData metaData) : assert(!key.contains(".") || !key.contains("*")), super(metaData, {
    "shared-data.$key.changed": SharedDataSyncMessage.DEFINITION,
    "shared-data.$key.ready": SharedDataSyncMessage.DEFINITION,
    "shared-data.$key.request-data": SharedDataRequestDataMessage.DEFINITION,
  }, {
    "shared-data.$key.ready": SharedDataSyncMessage.DEFINITION,
    "shared-data.$key.changed": SharedDataSyncMessage.DEFINITION,
    "shared-data.$key.request-data": SharedDataRequestDataMessage.DEFINITION,
  });

  @override
  void handle(RawMessage message) {
    if (message.sender!.uuid == this.metaData.uuid) return;
    if (message.messageKey == "shared-data.$key.changed" || message.messageKey == "shared-data.$key.ready") {
      final changeMessage = SharedDataSyncMessage.fromRawMessage(message);
      if (changeMessage.dataVersion == this.dataVersion) return;
      if (changeMessage.dataVersion < this.dataVersion) {
        this._notifySync();
        return;
      }
      this.data.clear();
      this.data.addAll(changeMessage.sharedData);
      this.dataVersion = changeMessage.dataVersion;
      onSyncCompleted();
    }
    final isRequestDataMessage = message.messageKey == "shared-data.$key.request-data";
    if (isRequestDataMessage) {
      this.dispatch(message: SharedDataSyncMessage("shared-data.$key.ready", data, dataVersion));
    }
  }
  void applyChanges(void Function(Map<String, dynamic>) modifier) {
    modifier.call(data);
    _notifySync();
  }
  void _notifySync(){
    dataVersion++;
    final message = SharedDataSyncMessage("shared-data.$key.changed", data, dataVersion);
    this.dispatch(message: message);
  }
  void onSyncCompleted();
  @override
  void onConnected() {
    this.dispatch(message: SharedDataRequestDataMessage("shared-data.$key.request-data"));
    super.onConnected();
  }
}
