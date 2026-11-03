import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _idFront, _idBack, _video;

  Future<File> _persistPickedFile(XFile pickedFile, String prefix) async {
    final source = File(pickedFile.path);
    if (!await source.exists()) {
      throw FileSystemException(
        'ملف الوسائط المؤقت غير موجود. أعد التقاط الملف.',
        source.path,
      );
    }

    final supportDirectory = await getApplicationSupportDirectory();
    final mediaDirectory =
        Directory('${supportDirectory.path}/theft_inspection_media');
    await mediaDirectory.create(recursive: true);
    final extension = pickedFile.path.contains('.')
        ? pickedFile.path.substring(pickedFile.path.lastIndexOf('.'))
        : '';
    final destination = File(
      '${mediaDirectory.path}/${prefix}_${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    return source.copy(destination.path);
  }

  void _showPickError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تعذر الاحتفاظ بالملف: $error')),
    );
  }

  Future<void> _pickImage(bool isFront) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (pickedFile == null) return;

    try {
      final savedFile = await _persistPickedFile(
          pickedFile, isFront ? 'id_front' : 'id_back');
      if (!mounted) return;
      setState(() => isFront ? _idFront = savedFile : _idBack = savedFile);
    } on FileSystemException catch (error) {
      _showPickError(error);
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 3),
    );
    if (pickedFile == null) return;

    try {
      final savedFile = await _persistPickedFile(pickedFile, 'theft_video');
      if (!mounted) return;
      setState(() => _video = savedFile);
    } on FileSystemException catch (error) {
      _showPickError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
          title: const Text("توثيق الواقعة"),
          backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildCard("بطاقة (وش)", _idFront, () => _pickImage(true)),
                  _buildCard("بطاقة (ظهر)", _idBack, () => _pickImage(false)),
                  _buildCard("فيديو الواقعة", _video, _pickVideo,
                      isVideo: true),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (_idFront == null || _idBack == null || _video == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("يرجى توثيق كل الملفات")));
                  return;
                }
                Navigator.pop(context,
                    {'idFront': _idFront, 'idBack': _idBack, 'video': _video});
              },
              icon: const Icon(Icons.check, color: Colors.black),
              label: const Text("تأكيد التوثيق",
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  minimumSize: const Size(double.infinity, 55)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, File? file, VoidCallback onTap,
      {bool isVideo = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (file == null)
              const Icon(Icons.add_a_photo, color: Colors.cyanAccent, size: 40)
            else if (!isVideo)
              Image.file(file, height: 80, fit: BoxFit.cover)
            else
              const Icon(Icons.videocam, color: Colors.greenAccent, size: 40),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white)),
            if (file != null)
              const Text("✓", style: TextStyle(color: Colors.greenAccent)),
          ],
        ),
      ),
    );
  }
}
