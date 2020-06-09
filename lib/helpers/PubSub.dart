import 'package:flutter/cupertino.dart';

class EventManager {
  static final String id = DateTime.now().toIso8601String();
  static String namespace = id;
  static Map<String, Map<String, List<Function>>> _events = {
    id: new Map()
  };


  static void on(String eventName, Function handler) {
    if (!_events[namespace].containsKey(eventName)) {
      _events[namespace][eventName] = new List();
    }

    _events[namespace][eventName].add(handler);

    useBaseNamespace();
  }

  static void fire(String eventName, {data}) {
    if (!_events[namespace].containsKey(eventName)) {
      useBaseNamespace();
      debugPrint("[ERROR]: Event named " + eventName + " does not exist!");
      return;
    }

    debugPrint("[INFO]: Firing event: " + eventName + " of " + namespace);

    if (data == null) {
      _events[namespace][eventName].forEach((Function handler) {
        handler();
      });
    } else {
      _events[namespace][eventName].forEach((Function handler) {
        handler(data);
      });
    }
    
    useBaseNamespace();
  }

  static void of(String namespaceName) {
    if (namespace == id) {
      namespace = namespaceName;
    } else {
      namespace += "/" + namespaceName;
    }

    if (!_events.containsKey(namespace)) {
      _events[namespace] = new Map<String, List<Function>>();
    }
  }

  static void clearEvents() {
    _events[namespace] = new Map();

    useBaseNamespace();
  }

  static void clearAllEvents() {
    _events.keys.forEach((key) {
      _events[key] = new Map();
    });
  }

  static void useBaseNamespace() {
    namespace = id;
  }
}