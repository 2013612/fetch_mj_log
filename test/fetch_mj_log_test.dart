import 'dart:collection';
import 'dart:io';

import 'package:fetch_mj_log/log.dart';
import 'package:fetch_mj_log/fetch_mj_log.dart';
import 'package:test/test.dart';

void main() {
  test('readCsv', () {
    final testAns = [
      ["順位", "期間", "始まる時間", "ルール"],
      [
        "1位",
        "23分",
        "https://tenhou.net/3/?log=2020090300gm-00a9-0000-5cdda622&tw=3"
      ],
      [
        "4位",
        "33分",
        "htts://tenhou.net/3/?log=2020090300gm-00a9-0000-f4216197&tw=1"
      ],
      [
        "4位",
        "27分",
        "https://tenhou.net/3/?log=2020090301gm-00a9-0000-02c7320d&tw=0"
      ]
    ];

    expect(readCsv('test/test.csv'), testAns);
  });
  test('filterUrls', () {
    final testCsvData = [
      ["順位", "期間", "始まる時間", "ルール"],
      [
        "1位",
        "23分",
        "https://tenhou.net/3/?log=2020090300gm-00a9-0000-5cdda622&tw=3"
      ],
      [
        "4位",
        "23分",
        "htts://tenhou.net/3/?log=2020090300gm-00a9-0000-f4216197&tw=1"
      ],
      [
        "4位",
        "27分",
        "https://tenhou.net/3/?log=2020090301gm-00a9-0000-02c7320d&tw=0"
      ]
    ];
    final testAns = [
      "https://tenhou.net/3/?log=2020090300gm-00a9-0000-5cdda622&tw=3",
      "https://tenhou.net/3/?log=2020090301gm-00a9-0000-02c7320d&tw=0"
    ];
    expect(filterUrls(testCsvData), testAns);
  });

  test('transformUrls', () {
    final testCase = [
      "https://tenhou.net/3/?log=2020090300gm-00a9-0000-5cdda622&tw=3",
      "http://tenhou.net/3/?log=2020090301gm-00a9-0000-02c7320d&tw=0"
    ];
    final testAns = [
      Log("2020090300gm-00a9-0000-5cdda622", 3),
      Log("2020090301gm-00a9-0000-02c7320d", 0)
    ];
    expect(transformUrls(testCase), testAns);
  });

  test('groupIds', () {
    final testCase = [
      Log("2020090300gm-00a9-0000-5cdda622", 3),
      Log("2020090301gm-00a9-0000-02c7320d", 0),
      Log("2020100301gm-00a9-0000-02c7320d", 0),
      Log("2020110301gm-00a9-0000-02c7320d", 0)
    ];
    final testAns = HashMap<String, List<Log>>();
    testAns["202009"] = [
      Log("2020090300gm-00a9-0000-5cdda622", 3),
      Log("2020090301gm-00a9-0000-02c7320d", 0)
    ];
    testAns["202010"] = [Log("2020100301gm-00a9-0000-02c7320d", 0)];
    testAns["202011"] = [Log("2020110301gm-00a9-0000-02c7320d", 0)];
    expect(groupIds(testCase), testAns);
  });

  test('createFolders', () {
    final testPath = "test";
    final testSubfolders = ["test1", "test2"];
    final path = createFolders(testPath, testSubfolders);

    expect(
        testSubfolders.every(
          (name) => Directory("$path/$name").existsSync(),
        ),
        true);
    Directory("$testPath/tenhou").delete(recursive: true);
  });

  test('downloadFiles', () {
    final testAns =
        File("D:\\Download\\2020090300gm-00a9-0000-5cdda622&tw=3.xml")
            .readAsStringSync();
    final downloadFile = File(
            "C:\\tenhou\\log\\202009\\2020090300gm-00a9-0000-5cdda622&tw=3.mjlog")
        .readAsStringSync();
    expect(downloadFile, testAns);
  });
}
