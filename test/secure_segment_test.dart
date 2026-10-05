import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tarixiy_filimlar/core/secure_video/secure_hls_downloader.dart';

/// Yuklangan bo'laklar HLS AES-128 standartiga mos shifrlanganini tekshiradi:
/// IV = bo'lak tartib raqami (big-endian), PKCS7 — openssl bilan bir xil natija berishi kerak.
void main() {
  test('encryptSegment openssl aes-128-cbc bilan mos', () async {
    final key = Uint8List.fromList(List.generate(16, (i) => i * 7 + 3));
    final data = Uint8List.fromList(List.generate(1000, (i) => (i * 31) % 256));
    const sequence = 258; // IV = 00..0102

    final ours = SecureHlsDownloader.encryptSegment(data, key, sequence);

    final dir = await Directory.systemTemp.createTemp('seg');
    final input = File('${dir.path}/in.bin')..writeAsBytesSync(data);
    String hex(List<int> b) => b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    final iv = Uint8List(16)
      ..[14] = 1
      ..[15] = 2;
    final r = await Process.run(
      'openssl',
      ['enc', '-aes-128-cbc', '-K', hex(key), '-iv', hex(iv), '-in', input.path, '-out', '${dir.path}/out.bin'],
    );
    expect(r.exitCode, 0, reason: r.stderr.toString());
    final expected = File('${dir.path}/out.bin').readAsBytesSync();

    expect(ours, expected);
    await dir.delete(recursive: true);
  });
}
