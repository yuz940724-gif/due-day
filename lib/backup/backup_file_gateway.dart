import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'local_backup.dart';

const maxLocalBackupBytes = 10 * 1024 * 1024;

abstract interface class BackupFileGateway {
  Future<void> shareJson({required String fileName, required Uint8List bytes});
  Future<PickedBackupFile?> pickJson();
}

class PickedBackupFile {
  const PickedBackupFile({required this.name, required this.bytes});
  final String name;
  final Uint8List bytes;
}

class PlatformBackupFileGateway implements BackupFileGateway {
  @override
  Future<void> shareJson({required String fileName, required Uint8List bytes}) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    try {
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json', name: fileName)],
          title: fileName,
        ),
      );
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Future<PickedBackupFile?> pickJson() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    if (file.size > maxLocalBackupBytes) {
      throw LocalBackupException('备份文件超过 10 MiB 大小限制');
    }
    final path = file.path;
    if (path == null) throw const LocalBackupException('无法读取所选备份文件');
    final bytes = await File(path).readAsBytes();
    if (bytes.length > maxLocalBackupBytes) {
      throw LocalBackupException('备份文件超过 10 MiB 大小限制');
    }
    return PickedBackupFile(name: file.name, bytes: bytes);
  }
}
