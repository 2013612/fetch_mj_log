import 'package:fetch_mj_log/fetch_mj_log.dart' as fetch_mj_log;

void main(List<String> arguments) {
  if (arguments.length != 2) {
    print(
        "incorrect arguments, correct format 'dart run fetch_mj_log path_to_csv path_to_save_logs'");
    return;
  }
  // read csv
  final csv = fetch_mj_log.readCsv(arguments[0]);
  // get url list from csv
  final urls = fetch_mj_log.filterUrls(csv);
  // transform url to id and pos
  final logs = fetch_mj_log.transformUrls(urls);
  final groupedLogs = fetch_mj_log.groupIds(logs);
  // create folders
  final rootPath =
      fetch_mj_log.createFolders(arguments[1], groupedLogs.keys.toList());
  // download files
  fetch_mj_log.downloadAllFiles(rootPath, groupedLogs);
}
