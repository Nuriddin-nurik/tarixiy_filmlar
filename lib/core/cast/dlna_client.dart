import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

class DlnaDevice {
  final String id;
  final String name;
  final String model;
  final Uri controlUrl;
  final String serviceType;

  const DlnaDevice({
    required this.id,
    required this.name,
    required this.model,
    required this.controlUrl,
    required this.serviceType,
  });
}

class DlnaStatus {
  final String state;
  final Duration position;
  final Duration duration;

  const DlnaStatus(this.state, this.position, this.duration);

  bool get playing => state == 'PLAYING';
  bool get loading => state == 'TRANSITIONING';
  bool get stopped => state == 'STOPPED' || state == 'NO_MEDIA_PRESENT';
}

class DlnaClient {
  static final _ssdpAddress = InternetAddress('239.255.255.250');
  static const _ssdpPort = 1900;
  static const _targets = [
    'urn:schemas-upnp-org:device:MediaRenderer:1',
    'urn:schemas-upnp-org:service:AVTransport:1',
  ];

  final _http = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 4),
    sendTimeout: const Duration(seconds: 4),
    receiveTimeout: const Duration(seconds: 6),
    responseType: ResponseType.plain,
    validateStatus: (_) => true,
  ));

  Future<void> search(void Function(DlnaDevice device) onFound, {Duration duration = const Duration(seconds: 5)}) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    final seen = <String>{};
    final sub = socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final packet = socket.receive();
      if (packet == null) return;
      final location = _header(utf8.decode(packet.data, allowMalformed: true), 'location');
      if (location == null || !seen.add(location)) return;
      _describe(Uri.parse(location)).then((d) {
        if (d != null) onFound(d);
      });
    });
    try {
      for (var i = 0; i < 3; i++) {
        for (final st in _targets) {
          final msg = 'M-SEARCH * HTTP/1.1\r\n'
              'HOST: 239.255.255.250:1900\r\n'
              'MAN: "ssdp:discover"\r\n'
              'MX: 2\r\n'
              'ST: $st\r\n\r\n';
          socket.send(utf8.encode(msg), _ssdpAddress, _ssdpPort);
        }
        await Future.delayed(const Duration(milliseconds: 700));
      }
      await Future.delayed(duration - const Duration(milliseconds: 2100));
    } finally {
      await sub.cancel();
      socket.close();
    }
  }

  String? _header(String response, String name) {
    for (final line in response.split('\r\n')) {
      final i = line.indexOf(':');
      if (i > 0 && line.substring(0, i).trim().toLowerCase() == name) return line.substring(i + 1).trim();
    }
    return null;
  }

  String? _tag(String xml, String tag) {
    final m = RegExp('<(?:\\w+:)?$tag[^>]*>([\\s\\S]*?)</(?:\\w+:)?$tag>').firstMatch(xml);
    return m == null ? null : _unescape(m.group(1)!.trim());
  }

  Future<DlnaDevice?> _describe(Uri location) async {
    try {
      final res = await _http.getUri<String>(location);
      final xml = res.data ?? '';
      for (final m in RegExp(r'<service>([\s\S]*?)</service>').allMatches(xml)) {
        final block = m.group(1)!;
        final type = _tag(block, 'serviceType') ?? '';
        if (!type.contains(':service:AVTransport:')) continue;
        final control = _tag(block, 'controlURL');
        if (control == null) continue;
        final base = _tag(xml, 'URLBase');
        final baseUri = base != null && base.isNotEmpty ? Uri.parse(base) : location;
        return DlnaDevice(
          id: _tag(xml, 'UDN') ?? location.toString(),
          name: _tag(xml, 'friendlyName') ?? location.host,
          model: [_tag(xml, 'manufacturer'), _tag(xml, 'modelName')].whereType<String>().join(' '),
          controlUrl: baseUri.resolve(control),
          serviceType: type,
        );
      }
    } catch (_) {
    }
    return null;
  }

  static String _escape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  static String _unescape(String s) => s
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&');

  Future<String> _soap(DlnaDevice d, String action, Map<String, String> args) async {
    final body = StringBuffer()
      ..write('<?xml version="1.0" encoding="utf-8"?>')
      ..write('<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" '
          's:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body>')
      ..write('<u:$action xmlns:u="${d.serviceType}">');
    args.forEach((k, v) => body.write('<$k>${_escape(v)}</$k>'));
    body.write('</u:$action></s:Body></s:Envelope>');
    final res = await _http.postUri<String>(
      d.controlUrl,
      data: utf8.encode(body.toString()),
      options: Options(headers: {
        'Content-Type': 'text/xml; charset="utf-8"',
        'SOAPACTION': '"${d.serviceType}#$action"',
      }),
    );
    final text = res.data ?? '';
    if ((res.statusCode ?? 500) >= 300) {
      throw Exception('$action ${res.statusCode} ${_tag(text, 'errorDescription') ?? ''}');
    }
    return text;
  }

  static String _clock(Duration d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.inHours}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  static Duration _parseClock(String? s) {
    if (s == null) return Duration.zero;
    final parts = s.split('.').first.split(':');
    if (parts.length != 3) return Duration.zero;
    final v = parts.map((p) => int.tryParse(p) ?? 0).toList();
    return Duration(hours: v[0], minutes: v[1], seconds: v[2]);
  }

  Future<void> load(DlnaDevice d, {required String url, required String title, String? thumbnail, Duration? duration}) async {
    const mime = 'application/vnd.apple.mpegurl';
    final didl = StringBuffer()
      ..write('<DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" '
          'xmlns:dc="http://purl.org/dc/elements/1.1/" '
          'xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/">')
      ..write('<item id="1" parentID="0" restricted="1">')
      ..write('<dc:title>${_escape(title)}</dc:title>')
      ..write('<upnp:class>object.item.videoItem</upnp:class>');
    if (thumbnail != null) didl.write('<upnp:albumArtURI>${_escape(thumbnail)}</upnp:albumArtURI>');
    final dur = duration != null && duration > Duration.zero ? ' duration="${_clock(duration)}.000"' : '';
    didl
      ..write('<res protocolInfo="http-get:*:$mime:*"$dur>${_escape(url)}</res>')
      ..write('</item></DIDL-Lite>');
    try {
      await _soap(d, 'Stop', {'InstanceID': '0'});
    } catch (_) {
    }
    await _soap(d, 'SetAVTransportURI', {
      'InstanceID': '0',
      'CurrentURI': url,
      'CurrentURIMetaData': didl.toString(),
    });
  }

  Future<void> play(DlnaDevice d) => _soap(d, 'Play', {'InstanceID': '0', 'Speed': '1'});

  Future<void> pause(DlnaDevice d) => _soap(d, 'Pause', {'InstanceID': '0'});

  Future<void> stop(DlnaDevice d) => _soap(d, 'Stop', {'InstanceID': '0'});

  Future<void> seek(DlnaDevice d, Duration position) =>
      _soap(d, 'Seek', {'InstanceID': '0', 'Unit': 'REL_TIME', 'Target': _clock(position)});

  Future<DlnaStatus> status(DlnaDevice d) async {
    final transport = await _soap(d, 'GetTransportInfo', {'InstanceID': '0'});
    final position = await _soap(d, 'GetPositionInfo', {'InstanceID': '0'});
    return DlnaStatus(
      _tag(transport, 'CurrentTransportState') ?? 'STOPPED',
      _parseClock(_tag(position, 'RelTime')),
      _parseClock(_tag(position, 'TrackDuration')),
    );
  }
}
