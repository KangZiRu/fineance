import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;


class NetworkService {

  static JsonDecoder _decoder = new JsonDecoder();

  static Map<String, String> headers = {};
  static Map<String, String> cookies = {};

  static void _updateCookie(http.Response response) {
    String allSetCookie = response.headers['set-cookie'];

    if (allSetCookie != null) {

      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');

        for (var cookie in cookies) {
          _setCookie(cookie);
        }
      }

      headers['cookie'] = _generateCookieHeader();
    }
  }

  static void _setCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];

        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires')
          return;

        cookies[key] = value;
      }
    }
  }

  static String _generateCookieHeader() {
    String cookie = "";

    for (var key in cookies.keys) {
      if (cookie.length > 0)
        cookie += ";";
      cookie += key + "=" + cookies[key];
    }

    return cookie;
  }

  static void get(String url, {Function success, Function always, Function error}) {
    http.get(url, headers: headers).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);

      if (statusCode < 200 || statusCode > 400 || json == null) {
        if (error != null) {
          error(response);
        }
        if (always != null) {
          always(false);
        }
      } else {
        if (success != null) {
          debugPrint(res);
          success(_decoder.convert(res));
        }
        if (always != null) {
          always(true);
        }
      }
    });
  }

  static void post(String url, {body, encoding, Function success, Function always, Function error}) {
    http
        .post(url, body: body, headers: headers, encoding: encoding)
        .then((http.Response response) {
          final String res = response.body;
          final int statusCode = response.statusCode;

          _updateCookie(response);

          if (statusCode < 200 || statusCode > 400 || json == null) {
            if (error != null) {
              error(response);
            }
            if (always != null) {
              always(false);
            }
          } else {
            if (success != null) {
              debugPrint(res);
              success(_decoder.convert(res));
            }
            if (always != null) {
              always(true);
            }
          }
          
        });
  }
}