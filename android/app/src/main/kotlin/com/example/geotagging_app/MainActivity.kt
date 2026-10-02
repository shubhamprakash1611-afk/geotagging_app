package com.geotagging.app

import android.content.ContentValues
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint
import android.media.ExifInterface
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.geotagging.app/image_compositor"
        private const val LOG_TAG = "GeoTagImage"

        // Two workers keep burst captures responsive without holding three or
        // more full-resolution bitmaps in memory at the same time.
        private val imageWorkers = Executors.newFixedThreadPool(2)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method != "saveComposite") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val cameraPath = call.argument<String>("cameraPath")
            if (cameraPath.isNullOrBlank()) {
                result.error("INVALID_ARGUMENT", "cameraPath is required", null)
                return@setMethodCallHandler
            }

            imageWorkers.execute {
                val startedAt = System.currentTimeMillis()
                try {
                    val savedUri = saveComposite(call, cameraPath)
                    val elapsedMs = System.currentTimeMillis() - startedAt
                    Log.i(LOG_TAG, "Saved $savedUri in ${elapsedMs}ms")
                    runOnUiThread {
                        result.success(
                            mapOf(
                                "success" to true,
                                "uri" to savedUri.toString(),
                                "elapsedMs" to elapsedMs,
                            ),
                        )
                    }
                } catch (error: Throwable) {
                    val elapsedMs = System.currentTimeMillis() - startedAt
                    Log.e(LOG_TAG, "Save failed after ${elapsedMs}ms", error)
                    runOnUiThread {
                        result.error(
                            "SAVE_FAILED",
                            error.message ?: "Unable to save photo",
                            mapOf("elapsedMs" to elapsedMs),
                        )
                    }
                }
            }
        }
    }

    private fun saveComposite(call: MethodCall, cameraPath: String): Uri {
        val overlayBytes = call.argument<ByteArray>("overlayBytes")
        val placement = call.argument<String>("placement") ?: "bottom"
        val directory = sanitizeDirectory(
            call.argument<String>("directory") ?: "GeoTagCamera",
        )
        val jpegQuality =
            (call.argument<Int>("jpegQuality") ?: 94).coerceIn(80, 100)

        val decodeOptions = BitmapFactory.Options().apply {
            inPreferredConfig = Bitmap.Config.ARGB_8888
            inMutable = true
        }
        val decoded = BitmapFactory.decodeFile(cameraPath, decodeOptions)
            ?: error("Unable to decode camera image")
        val oriented = applyExifOrientation(decoded, cameraPath)

        var workingBitmap = oriented
        if (!workingBitmap.isMutable) {
            workingBitmap = oriented.copy(Bitmap.Config.ARGB_8888, true)
                ?: error("Unable to create mutable image")
            if (oriented !== decoded) oriented.recycle()
        }
        if (decoded !== workingBitmap && decoded !== oriented) decoded.recycle()

        try {
            if (overlayBytes != null && overlayBytes.isNotEmpty()) {
                val overlay = BitmapFactory.decodeByteArray(
                    overlayBytes,
                    0,
                    overlayBytes.size,
                ) ?: error("Unable to decode GeoTag overlay")

                try {
                    drawOverlay(workingBitmap, overlay, placement)
                } finally {
                    overlay.recycle()
                }
            }

            return publishJpeg(workingBitmap, directory, jpegQuality)
        } finally {
            workingBitmap.recycle()
            if (decoded !== workingBitmap && !decoded.isRecycled) {
                decoded.recycle()
            }
        }
    }

    private fun applyExifOrientation(source: Bitmap, path: String): Bitmap {
        val orientation = try {
            ExifInterface(path).getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_NORMAL,
            )
        } catch (_: Exception) {
            ExifInterface.ORIENTATION_NORMAL
        }

        val matrix = Matrix()
        when (orientation) {
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL ->
                matrix.setScale(-1f, 1f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.setRotate(180f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> {
                matrix.setRotate(180f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.setRotate(90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.setRotate(90f)
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.setRotate(-90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.setRotate(-90f)
            else -> return source
        }

        return Bitmap.createBitmap(
            source,
            0,
            0,
            source.width,
            source.height,
            matrix,
            true,
        )
    }

    private fun drawOverlay(target: Bitmap, overlay: Bitmap, placement: String) {
        val targetWidth = target.width * 0.95f
        val scale = targetWidth / overlay.width
        val targetHeight = overlay.height * scale
        val left = (target.width - targetWidth) / 2f
        val margin = target.height * 0.03f
        val top = if (placement == "top") {
            margin
        } else {
            target.height - targetHeight - margin
        }

        val destination = android.graphics.RectF(
            left,
            top,
            left + targetWidth,
            top + targetHeight,
        )
        val paint = Paint(
            Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG,
        ).apply {
            isDither = true
        }
        Canvas(target).drawBitmap(overlay, null, destination, paint)
    }

    private fun publishJpeg(
        bitmap: Bitmap,
        directory: String,
        quality: Int,
    ): Uri {
        val timestamp = System.currentTimeMillis()
        val displayName = "GeoTag_$timestamp.jpg"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, displayName)
                put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                put(MediaStore.Images.Media.DATE_TAKEN, timestamp)
                put(
                    MediaStore.Images.Media.RELATIVE_PATH,
                    "${Environment.DIRECTORY_PICTURES}/$directory",
                )
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }

            val resolver = contentResolver
            val uri = resolver.insert(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                values,
            ) ?: error("Unable to create gallery entry")

            try {
                resolver.openOutputStream(uri, "w").use { stream ->
                    requireNotNull(stream) { "Unable to open gallery output" }
                    check(
                        bitmap.compress(
                            Bitmap.CompressFormat.JPEG,
                            quality,
                            stream,
                        ),
                    ) {
                        "JPEG compression failed"
                    }
                }

                values.clear()
                values.put(MediaStore.Images.Media.IS_PENDING, 0)
                resolver.update(uri, values, null, null)
                return uri
            } catch (error: Throwable) {
                resolver.delete(uri, null, null)
                throw error
            }
        }

        @Suppress("DEPRECATION")
        val pictures = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_PICTURES,
        )
        val outputDirectory = File(pictures, directory)
        check(outputDirectory.exists() || outputDirectory.mkdirs()) {
            "Unable to create gallery directory"
        }
        val outputFile = File(outputDirectory, displayName)
        FileOutputStream(outputFile).use { stream ->
            check(
                bitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream),
            ) {
                "JPEG compression failed"
            }
        }
        MediaScannerConnection.scanFile(
            this,
            arrayOf(outputFile.absolutePath),
            arrayOf("image/jpeg"),
            null,
        )
        return Uri.fromFile(outputFile)
    }

    private fun sanitizeDirectory(value: String): String {
        val safe = value
            .replace(Regex("[^A-Za-z0-9 _-]"), "")
            .trim()
            .take(48)
        return safe.ifEmpty { "GeoTagCamera" }
    }
}
