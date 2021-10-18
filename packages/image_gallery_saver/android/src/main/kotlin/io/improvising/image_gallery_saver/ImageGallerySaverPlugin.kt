package io.improvising.image_gallery_saver

import java.io.File
import java.io.FileOutputStream
import java.io.IOException

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Environment
import androidx.core.app.ActivityCompat

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry

class ImageGallerySaverPlugin(): FlutterPlugin, ActivityAware,
  MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  private var activity: Activity? = null
  private var _result: Result? = null

  private var currentImageBytes: ByteArray? = null
  private var currentImageQuality: Int? = null
  private var currentImageName: String? = null
  private var currentFilePath: String? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getBinaryMessenger(), "rhythm_native/image_gallery_saver")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.getApplicationContext()
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onRequestPermissionsResult(
    requestCode: Int, 
    permissions: Array<out String>?, 
    grantResults: IntArray?
  ): Boolean {
    when (requestCode) {
      225 -> {
        if (
          null != grantResults &&
          grantResults.isNotEmpty() &&
          grantResults.get(0) == PackageManager.PERMISSION_GRANTED
        ) {
          _result!!.success(saveImageToGallery(
            BitmapFactory.decodeByteArray(currentImageBytes!!, 0, currentImageBytes!!.size),
            currentImageQuality!!,
            currentImageName
          ))

          return true
        } else {
          _result!!.success(SaveResultModel(false, null, "permission denied").toHashMap())
        }
      }
      226 -> {
        if (
          null != grantResults &&
          grantResults.isNotEmpty() &&
          grantResults.get(0) == PackageManager.PERMISSION_GRANTED
        ) {
          _result!!.success(saveFileToGallery(currentFilePath!!))
          return true
        } else {
          _result!!.success(SaveResultModel(false, null, "permission denied").toHashMap())
        }
      }
    }
  
    return false
  }

  private fun hasPermission(): Boolean {
    return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || 
      (
        activity!!.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED &&
        activity!!.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
      )
  }

  override fun onMethodCall(call: MethodCall, result: Result): Unit {
    _result = result

    when {
      call.method == "saveImageToGallery" -> {
        val image = call.argument<ByteArray>("imageBytes") ?: return
        val quality = call.argument<Int>("quality") ?: return
        val name = call.argument<String>("name")

        if (!hasPermission()) {
          currentImageBytes = image
          currentImageQuality = quality
          currentImageName = name

          ActivityCompat.requestPermissions(activity!!,
            arrayOf(
              Manifest.permission.WRITE_EXTERNAL_STORAGE,
              Manifest.permission.READ_EXTERNAL_STORAGE
            ),   
            225
          )
        } else {
          result.success(saveImageToGallery(BitmapFactory.decodeByteArray(image, 0, image.size), quality, name))
        }
      }
      call.method == "saveFileToGallery" -> {
        val path = call.argument<String>("file") ?: return

        if (!hasPermission()) {
          currentFilePath = path

          ActivityCompat.requestPermissions(activity!!,
            arrayOf(
              Manifest.permission.WRITE_EXTERNAL_STORAGE,
              Manifest.permission.READ_EXTERNAL_STORAGE
            ),   
            226
          )
        } else {
          result.success(saveFileToGallery(path))
        }
      }
      else -> result.notImplemented()
    }
  }

  private fun generateFile(extension: String = "", name: String? = null): File {
    val storePath = Environment.getExternalStorageDirectory().absolutePath + File.separator + Environment.DIRECTORY_PICTURES

    val appDir = File(storePath)

    if (!appDir.exists()) {
      appDir.mkdir()
    }

    var fileName = name?:System.currentTimeMillis().toString()

    if (extension.isNotEmpty()) {
      fileName += (".$extension")
    }

    return File(appDir, fileName)
  }

  private fun saveImageToGallery(bmp: Bitmap, quality: Int, name: String?): HashMap<String, Any?> {
    val file = generateFile("jpg", name = name)

    return try {
      val fos = FileOutputStream(file)
      bmp.compress(Bitmap.CompressFormat.JPEG, quality, fos)
      fos.flush()
      fos.close()

      val uri = Uri.fromFile(file)
      context.sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri))
      bmp.recycle()

      SaveResultModel(uri.toString().isNotEmpty(), uri.toString(), null).toHashMap()
    } catch (e: IOException) {
      SaveResultModel(false, null, e.toString()).toHashMap()
    }
  }

  private fun saveFileToGallery(filePath: String): HashMap<String, Any?> {
    return try {
      val originalFile = File(filePath)
      val file = generateFile(originalFile.extension)
      originalFile.copyTo(file)

      val uri = Uri.fromFile(file)
      context.sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri))

      SaveResultModel(uri.toString().isNotEmpty(), uri.toString(), null).toHashMap()
    } catch (e: IOException) {
      SaveResultModel(false, null, e.toString()).toHashMap()
    }
  }

  private fun getApplicationName(): String {
    var ai: ApplicationInfo? = null

    try {
        ai = context.packageManager.getApplicationInfo(context.packageName, 0)
    } catch (e: PackageManager.NameNotFoundException) {}
  
    var appName: String

    appName = if (ai != null) {
      val charSequence = context.packageManager.getApplicationLabel(ai)
      StringBuilder(charSequence.length).append(charSequence).toString()
    } else {
      "image_gallery_saver"
    }

    return appName
  }
}

class SaveResultModel(
  var isSuccess: Boolean,
  var filePath: String? = null,
  var errorMessage: String? = null
) {
  fun toHashMap(): HashMap<String, Any?> {
    val hashMap = HashMap<String, Any?>()
    hashMap["isSuccess"] = isSuccess
    hashMap["filePath"] = filePath
    hashMap["errorMessage"] = errorMessage
    return hashMap
  }
}
