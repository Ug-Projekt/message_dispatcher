import 'dart:async';

import 'package:event_dispatcher/EventDispatcher.dart';
import 'package:event_dispatcher/Schema/MessageSchema.dart';
import 'dart:developer' as Developer;

/**
 * @author Dream-Lab software technologies muhtarjan mahmood(مۇختەرجان مەخمۇت)
 * @email ug-project@outlook.com
 * @create date 2021-11-10 18:37:49
 * @modify date 2021-11-10 18:37:49
 * @desc [description]
 */

class MethodCallRequest extends RawMessage {
  final String methodName;
  final Map<String, dynamic> arguments;
  static final DEFINITION = MessageDefinition(name: "Method Call Request", version: 0.1, schema: CustomObjectSchema(false, {
    "functionName": StringSchema(false, 1, 255),
    "arguments": CustomObjectSchema(false, {}),
  }));
  MethodCallRequest(String messageKey, {required this.methodName, required this.arguments}) : super(messageKey: messageKey, definition: DEFINITION) {
    this.data["functionName"] = this.methodName;
    this.data["arguments"] = this.arguments;
  }
  static MethodCallRequest fromMessage(RawMessage message) {
    return MethodCallRequest(message.messageKey, methodName: message.data["functionName"], arguments: message.data["arguments"]);
  }
}
class MethodCallResponse extends RawMessage {
  final String requestId;
  final String methodName;
  final Map<String, dynamic> arguments;
  final Map<String, dynamic>? returns;
  final Object? error;
  static final DEFINITION = MessageDefinition(name: "Method Call Response", version: 0.1, schema: CustomObjectSchema(false, {
    "requestId": StringSchema(false, 1, 64),
    "functionName": StringSchema(false, 1, 255),
    "arguments": CustomObjectSchema(false, {}),
    "returns": CustomObjectSchema(true, {}),
    "error": CustomObjectSchema(true, {})
  }));
  MethodCallResponse(String messageKey, {required this.requestId, required this.methodName, required this.arguments, required this.returns, required this.error}) : super(messageKey: messageKey, definition: DEFINITION) {
    this.data["functionName"] = this.methodName;
    this.data["arguments"] = this.arguments;
    this.data["returns"] = this.returns;
    this.data["requestId"] = this.requestId;
    this.data["error"] = this.error;
  }
  static MethodCallResponse fromMessage(RawMessage message) {
    return MethodCallResponse(message.messageKey, requestId: message.data["requestId"], methodName: message.data["functionName"], arguments: message.data["arguments"], returns: message.data["returns"], error: message.data["error"]);
  }
}
typedef MethodCallHandler = Future<Map<String, dynamic>> Function(MethodCallBridge bridge, Map<String, dynamic> args);
class MethodCallBridge extends MessageNode {
  final Map<String, MethodCallHandler> _handlers = {};
  final Map<String, Completer<Map<String, dynamic>>> _request = {};
  final String key;
  MethodCallBridge(this.key, MetaData metaData, Map<String, MethodCallHandler> handlers) : super(metaData, {
    "MethodCall.${key}.Request": MethodCallRequest.DEFINITION,
    "MethodCall.${key}.Response": MethodCallResponse.DEFINITION,
  }, {
    "MethodCall.${key}.Request": MethodCallRequest.DEFINITION,
    "MethodCall.${key}.Response": MethodCallResponse.DEFINITION,
  }) {
    this._handlers.addAll(handlers);
  }
  @override
  void handle(RawMessage message) {
    if (message.sender?.uuid == this.metaData.uuid) return;
    final responseKey = "MethodCall.${key}.Response";
    final requestKey = "MethodCall.${key}.Request";
    if (message.messageKey == requestKey) {
      final request = MethodCallRequest.fromMessage(message);
      final handler = this._handlers[request.methodName];
      handler?.call(this, request.arguments).then((value) {
        this.dispatch(message: MethodCallResponse(responseKey, requestId: message.id, methodName: request.methodName, arguments: request.arguments, returns: value, error: null));
      }).catchError((error, stackTrace){
        this.dispatch(message: MethodCallResponse(responseKey, requestId: message.id, methodName: request.methodName, arguments: request.arguments, returns: null, error: {"error": error, "stackTrace": stackTrace}));
      });
      //Because the dart is only one side, another side is kotlin, mybe this method not exists on dart side but it may exists kotlin side so we cannot throw an exception if handler is not found.
      // if (handler == null) this.dispatch(message: MethodCallResponse(responseKey, requestId: message.id, methodName: request.methodName, arguments: request.arguments, returns: null, error: {"error": "handler ${request.methodName} is not found"}));
      return;
    }
    if (message.messageKey == responseKey) {
      final response = MethodCallResponse.fromMessage(message);
      final request = this._request[response.requestId];
      if (request == null) {
        Developer.log("Request ${response.requestId} is not found, maybe it is already timeout");
        return;
      }
      if (response.error != null) request.completeError(response.error!);
      else request.complete(response.returns);
      _request.remove(response.requestId);
      return;
    }
  }
  Future<Map<String, dynamic>> callMethod(String name, Map<String, dynamic> argument, {Duration? timeout = null}) async {
    timeout ??= Duration(seconds: 10);
    final message = MethodCallRequest("MethodCall.${this.key}.Request", methodName: name, arguments: argument);
    this.dispatch(message: message);
    this._request[message.id] = Completer();
    return await this._request[message.id]!.future.timeout(timeout).catchError((error, stackTrace){
      this._request.remove(message.id);
      throw error;
    });
  }
}


