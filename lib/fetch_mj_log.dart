import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

import 'log.dart';

List<List<String>> readCsv(String path) {
  File data = File(path);
  final csvString = data.readAsStringSync();
  return CsvToListConverter()
      .convert(csvString, shouldParseNumbers: false, eol: '\n');
}

List<String> filterUrls(List<List<String>> csv) {
  return csv
      .map((row) =>
          row.firstWhere((field) => field.startsWith('http'), orElse: () => ""))
      .where((element) => element.isNotEmpty)
      .toList();
}

List<Log> transformUrls(List<String> urls) {
  return urls.map((url) {
    final startPos = url.indexOf('log=') + 4;
    final endPos = url.indexOf('&tw');
    return Log(url.substring(startPos, endPos),
        int.tryParse(url[url.length - 1]) ?? 0);
  }).toList();
}

HashMap<String, List<Log>> groupIds(List<Log> logs) {
  final hashMap = HashMap<String, List<Log>>();
  for (final log in logs) {
    final key = log.id.substring(0, 6);
    if (!hashMap.containsKey(key)) {
      hashMap[key] = [];
    }
    hashMap[key]!.add(log);
  }
  return hashMap;
}

String createFolders(String path, List<String> subfolders) {
  final dirPath = "$path/tenhou/log";
  for (final name in subfolders) {
    Directory("$dirPath/$name").createSync(recursive: true);
  }
  return dirPath;
}

Future<void> downloadAllFiles(
    String rootPath, HashMap<String, List<Log>> groupedLogs) async {
  final httpClient = HttpClient();
  try {
    for (final entry in groupedLogs.entries) {
      await downloadMonthlyFiles(
          "$rootPath/${entry.key}", entry.value, httpClient);
    }
  } catch (e) {
    print(e);
  } finally {
    httpClient.close();
  }
}

Future<void> downloadMonthlyFiles(
    String path, List<Log> logs, HttpClient httpClient) async {
  for (final log in logs) {
    final request = await httpClient
        .getUrl(Uri.parse("http://tenhou.net/0/log/?${log.id}"));
    final response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    final filePath = "$path/${log.id}&tw=${log.pos}.mjlog";
    final file = File(filePath);
    file.createSync(recursive: true);
    file.writeAsBytesSync(gzip.encode(utf8.encode(stringData)));
  }
}
