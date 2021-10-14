// import 'package:event_dispatcher/EventDispatcher.dart';
// import 'package:event_dispatcher/Schema/MessageSchema.dart';

// /**
//  * @author Dream-Lab software technologies muhtarjan mahmood(مۇختەرجان مەخمۇت)
//  * @email ug-project@outlook.com
//  * @create date 2021-10-09 17:51:17
//  * @modify date 2021-10-09 17:51:17
//  * @desc [description]
//  */

// class SharedDataSyncMessage extends RawMessage {
//   final Map<String, dynamic> created;
//   final Map<String, dynamic> updated;
//   final Map<String, dynamic> deleted;
//   final int dataVersion;
//   static final DEFINITION = MessageDefinition(name: "Shared data sync message", version: 0.1, schema: CustomObjectSchema(false, {
//     "created": CustomObjectSchema(false, {}),
//     "updated": CustomObjectSchema(false, {}),
//     "deleted": CustomObjectSchema(false, {}),
//     "version": IntegerSchema(false, 999999999, 0),
//     // "data": CustomObjectSchema(false, {}),
//   }));
//   SharedDataSyncMessage(String messageKey, this.created, this.deleted, this.updated, this.dataVersion) : super(messageKey: messageKey, definition: DEFINITION) {
//     this.data["created"] = this.created;
//     this.data["updated"] = this.updated;
//     this.data["deleted"] = this.deleted;
//     this.data["created"] = this.created;
//     this.data["version"] = this.dataVersion;
//   }
//   factory SharedDataSyncMessage.fromRawMessage(RawMessage message) {
//     final result = SharedDataSyncMessage(message.messageKey, message.data["created"], message.data["deleted"], message.data["updated"], message.data["dataVersion"]);
//     result.sender = message.sender;
//     return result;
//   }
// }

// class SharedDataRequestDataMessage extends RawMessage {
//   static final DEFINITION = MessageDefinition(name: "Shared data request message", version: 0.1, schema: CustomObjectSchema(false, {}));
//   SharedDataRequestDataMessage(String messageKey) : super(messageKey: messageKey, definition: DEFINITION);
// }

// abstract class SharedDataNode extends MessageNode {
//   final String key;
//   final Map<String, dynamic> data = {};
//   int dataVersion = 0;
//   var _extraMap = Map<String, dynamic>();
//   SharedDataNode(this.key, MetaData metaData) : assert(!key.contains(".") || !key.contains("*")), super(metaData, {
//     "shared-data.$key.changed": SharedDataSyncMessage.DEFINITION,
//     "shared-data.$key.ready": SharedDataSyncMessage.DEFINITION,
//     "shared-data.$key.request-data": SharedDataRequestDataMessage.DEFINITION,
//   }, {
//     "shared-data.$key.ready": SharedDataSyncMessage.DEFINITION,
//     "shared-data.$key.changed": SharedDataSyncMessage.DEFINITION,
//     "shared-data.$key.request-data": SharedDataRequestDataMessage.DEFINITION,
//   });

//   @override
//   void handle(RawMessage message) {
//     if (message.sender!.uuid == this.metaData.uuid) return;
//     if (message.messageKey == "shared-data.$key.changed" || message.messageKey == "shared-data.$key.ready") {
//       final changeMessage = SharedDataSyncMessage.fromRawMessage(message);
//       final shouldBeSync = changeMessage.dataVersion > this.dataVersion;
//       if (!shouldBeSync) return;
//       this.data.clear();
//       this.data.addAll(changeMessage.sharedData);
//       this.dataVersion = changeMessage.dataVersion;
//       onSyncCompleted();
//     }
//     final isRequestDataMessage = message.messageKey == "shared-data.$key.request-data";
//     if (isRequestDataMessage) {
//       this.dispatch(message: SharedDataSyncMessage("shared-data.$key.ready", data, dataVersion));
//     }
//   }
//   void beginUpdate(){
//     this._extraMap = this.data.deepClone();
//   }
//   void commitUpdate() {}
//   // void notifySync(){
//   //   dataVersion++;
//   //   this.dispatch(message: SharedDataSyncMessage("shared-data.$key.changed", data, dataVersion));
//   // }
//   void onSyncCompleted();
//   @override
//   void onConnected() {
//     this.dispatch(message: SharedDataRequestDataMessage("shared-data.$key.request-data"));
//     super.onConnected();
//   }
// }

// class CompareResult {
//   final Map<String, dynamic> created = {};
//   final Map<String, dynamic> updated = {};
//   final Map<String, dynamic> deleted = {};
// }
// extension MapComparisonExtension on Map<String, dynamic> {
  
// }