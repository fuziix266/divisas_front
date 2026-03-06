import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de sincronización de imágenes del splash.
/// Descarga todas las imágenes de la carpeta remota,
/// compara por fecha de modificación, y elimina las que
/// ya no existen en el servidor.
class ImageSyncService {
  static const String _remoteEndpoint =
      'https://www.conari.cl/retrobox/divisas/images.php';
  static const String _prefKeyImagesMeta = 'splash_images_meta';
  static const String _localFolderName = 'splash_images';

  /// Directorio local donde se guardan las imágenes
  static Future<Directory> _getLocalDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_localFolderName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Sincroniza las imágenes con el servidor remoto.
  /// - Descarga nuevas imágenes
  /// - Re-descarga imágenes que cambiaron (por fecha de modificación)
  /// - Elimina imágenes locales que ya no existen en el servidor
  /// Retorna silenciosamente si no hay internet.
  static Future<void> sincronizar() async {
    try {
      // 1. Obtener lista remota
      final response = await http
          .get(Uri.parse(_remoteEndpoint))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      final List<dynamic> remoteImages = data['images'] ?? [];

      if (remoteImages.isEmpty) return;

      // 2. Obtener metadata local guardada
      final prefs = await SharedPreferences.getInstance();
      final localMetaJson = prefs.getString(_prefKeyImagesMeta) ?? '{}';
      final Map<String, dynamic> localMeta = jsonDecode(localMetaJson);

      final localDir = await _getLocalDir();

      // 3. Construir set de nombres remotos para detectar eliminaciones
      final Set<String> remoteNames = {};

      for (final img in remoteImages) {
        final String name = img['name'];
        final int remoteModified = img['modified'];
        final String url = img['url'];

        remoteNames.add(name);

        // Verificar si necesitamos descargar
        final localFile = File('${localDir.path}/$name');
        final int localModified = localMeta[name] ?? 0;

        final bool needsDownload =
            !await localFile.exists() || localModified != remoteModified;

        if (needsDownload) {
          try {
            debugPrint('📥 Descargando imagen: $name');
            final imgResponse = await http
                .get(Uri.parse(url))
                .timeout(const Duration(seconds: 15));

            if (imgResponse.statusCode == 200) {
              await localFile.writeAsBytes(imgResponse.bodyBytes);
              localMeta[name] = remoteModified;
              debugPrint('✅ Imagen guardada: $name');
            }
          } catch (e) {
            debugPrint('⚠️ Error descargando $name: $e');
          }
        }
      }

      // 4. Eliminar imágenes locales que ya no existen en el servidor
      final localFiles = await localDir.list().toList();
      for (final entity in localFiles) {
        if (entity is File) {
          final fileName = entity.path.split(Platform.pathSeparator).last;
          if (!remoteNames.contains(fileName)) {
            debugPrint('🗑️ Eliminando imagen local: $fileName');
            await entity.delete();
            localMeta.remove(fileName);
          }
        }
      }

      // 5. Guardar metadata actualizada
      await prefs.setString(_prefKeyImagesMeta, jsonEncode(localMeta));
      debugPrint(
        '🔄 Sincronización completada: ${remoteNames.length} imágenes',
      );
    } catch (e) {
      // Sin internet o error de red → silencioso
      debugPrint('📡 Sin conexión para sincronizar imágenes: $e');
    }
  }

  /// Obtiene una imagen aleatoria local para el splash.
  /// Si no hay imágenes locales, retorna null.
  static Future<File?> obtenerImagenAleatoria() async {
    try {
      final localDir = await _getLocalDir();
      if (!await localDir.exists()) return null;

      final files = await localDir
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .where((file) {
            final ext = file.path.split('.').last.toLowerCase();
            return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(ext);
          })
          .toList();

      if (files.isEmpty) return null;

      final random = Random();
      return files[random.nextInt(files.length)];
    } catch (e) {
      return null;
    }
  }

  /// Obtiene la lista de todas las imágenes locales.
  static Future<List<File>> obtenerImagenesLocales() async {
    try {
      final localDir = await _getLocalDir();
      if (!await localDir.exists()) return [];

      final files = await localDir
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .where((file) {
            final ext = file.path.split('.').last.toLowerCase();
            return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(ext);
          })
          .toList();

      return files;
    } catch (e) {
      return [];
    }
  }
}
