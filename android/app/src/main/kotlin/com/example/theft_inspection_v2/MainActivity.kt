package com.example.theft_inspection_v2

import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.example.theft_inspection_v2/downloads"
        private const val REQUEST_DOWNLOADS_TREE = 4107
        private const val PREFS_NAME = "theft_inspection_storage"
        private const val TREE_URI_KEY = "downloads_tree_uri"
    }

    private var methodChannel: MethodChannel? = null
    private var pendingFolderResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDownloadsFolder" -> {
                        val savedUri = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
                            .getString(TREE_URI_KEY, null)
                        val isGranted = savedUri != null &&
                            contentResolver.persistedUriPermissions.any {
                                it.uri.toString() == savedUri && it.isWritePermission
                            }
                        if (savedUri != null && !isGranted) {
                            getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit()
                                .remove(TREE_URI_KEY)
                                .apply()
                        }
                        result.success(if (isGranted) savedUri else null)
                    }
                    "selectDownloadsFolder" -> selectDownloadsFolder(result)
                    "writeCaseFiles" -> writeCaseFiles(call.arguments, result)
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun selectDownloadsFolder(result: MethodChannel.Result) {
        if (pendingFolderResult != null) {
            result.error("selection_in_progress", "محدد مجلد التنزيلات مفتوح بالفعل", null)
            return
        }

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
            )
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                putExtra(
                    DocumentsContract.EXTRA_INITIAL_URI,
                    DocumentsContract.buildDocumentUri(
                        "com.android.externalstorage.documents",
                        "primary:Download"
                    )
                )
            }
        }

        pendingFolderResult = result
        try {
            startActivityForResult(intent, REQUEST_DOWNLOADS_TREE)
        } catch (error: Exception) {
            pendingFolderResult = null
            result.error("folder_picker_failed", error.message, null)
        }
    }

    @Deprecated("Deprecated in Android, retained for FlutterActivity result handling")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_DOWNLOADS_TREE) return

        val result = pendingFolderResult ?: return
        pendingFolderResult = null
        if (resultCode != RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }

        val treeUri = data.data!!
        try {
            val documentId = DocumentsContract.getTreeDocumentId(treeUri)
            if (!documentId.equals("primary:Download", ignoreCase = true) &&
                !documentId.startsWith("primary:Download/", ignoreCase = true)
            ) {
                result.error(
                    "not_downloads_folder",
                    "اختر مجلد Download أو مجلدًا بداخله",
                    null
                )
                return
            }

            val permissionFlags = data.flags and
                (Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            contentResolver.takePersistableUriPermission(treeUri, permissionFlags)
            getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit()
                .putString(TREE_URI_KEY, treeUri.toString())
                .apply()
            result.success(treeUri.toString())
        } catch (error: Exception) {
            result.error("folder_access_failed", error.message, null)
        }
    }

    private fun writeCaseFiles(arguments: Any?, result: MethodChannel.Result) {
        var caseDirectoryUri: Uri? = null
        val createdFileUris = mutableListOf<Uri>()
        try {
            @Suppress("UNCHECKED_CAST")
            val args = arguments as? Map<String, Any?>
                ?: throw IllegalArgumentException("بيانات الحفظ غير صالحة")
            val treeUri = Uri.parse(args["treeUri"] as? String
                ?: throw IllegalArgumentException("لم يتم اختيار مجلد Download"))
            val folderName = args["folderName"] as? String
                ?: throw IllegalArgumentException("اسم مجلد المحضر غير موجود")
            @Suppress("UNCHECKED_CAST")
            val files = args["files"] as? List<Map<String, String>>
                ?: throw IllegalArgumentException("قائمة ملفات المحضر غير صالحة")

            val resolver = contentResolver
            val treeDocumentId = DocumentsContract.getTreeDocumentId(treeUri)
            val rootUri = DocumentsContract.buildDocumentUriUsingTree(
                treeUri,
                treeDocumentId
            )
            val createdCaseDirectoryUri = DocumentsContract.createDocument(
                resolver,
                rootUri,
                DocumentsContract.Document.MIME_TYPE_DIR,
                folderName
            ) ?: throw IOException("تعذر إنشاء مجلد المحضر داخل Download")
            caseDirectoryUri = createdCaseDirectoryUri

            for (file in files) {
                val fileName = file["name"]
                    ?: throw IllegalArgumentException("اسم الملف غير موجود")
                val mimeType = file["mimeType"]
                    ?: throw IllegalArgumentException("نوع الملف غير موجود")
                val sourcePath = file["path"]
                    ?: throw IllegalArgumentException("مسار الملف غير موجود")
                val source = File(sourcePath)
                if (!source.isFile) {
                    throw IOException("الملف المطلوب غير موجود: $fileName")
                }
                val destinationUri = DocumentsContract.createDocument(
                    resolver,
                    createdCaseDirectoryUri,
                    mimeType,
                    fileName
                ) ?: throw IOException("تعذر إنشاء الملف: $fileName")
                createdFileUris.add(destinationUri)

                val output = resolver.openOutputStream(destinationUri, "w")
                    ?: throw IOException("تعذر فتح الملف للكتابة: $fileName")
                FileInputStream(source).use { input ->
                    output.use { input.copyTo(it) }
                }
            }

            val selectedFolder = treeDocumentId.removePrefix("primary:")
            result.success("$selectedFolder/$folderName")
        } catch (error: Exception) {
            createdFileUris.asReversed().forEach { uri ->
                try {
                    DocumentsContract.deleteDocument(contentResolver, uri)
                } catch (_: Exception) {
                    // Preserve the original export error.
                }
            }
            caseDirectoryUri?.let { uri ->
                try {
                    DocumentsContract.deleteDocument(contentResolver, uri)
                } catch (_: Exception) {
                    // Preserve the original export error.
                }
            }
            result.error("case_export_failed", error.message, null)
        }
    }
}
