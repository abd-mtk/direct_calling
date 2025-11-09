package com.direct_calling

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class DirectCallingPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, 
    PluginRegistry.RequestPermissionsResultListener {
    
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null
    private var pendingPhoneNumber: String? = null
    
    companion object {
        private const val PERMISSION_REQUEST_CODE = 1001
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "direct_calling")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "makeCall" -> {
                val phoneNumber = call.argument<String>("phoneNumber")
                if (phoneNumber.isNullOrEmpty()) {
                    result.error("INVALID_NUMBER", "Phone number cannot be empty", null)
                    return
                }
                makePhoneCall(phoneNumber, result)
            }
            "checkPermission" -> {
                result.success(hasCallPermission())
            }
            "requestPermission" -> {
                requestCallPermission(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun makePhoneCall(phoneNumber: String, result: Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        if (!hasCallPermission()) {
            pendingResult = result
            pendingPhoneNumber = phoneNumber
            requestCallPermission(result)
            return
        }

        try {
            val intent = Intent(Intent.ACTION_CALL).apply {
                data = Uri.parse("tel:$phoneNumber")
            }
            currentActivity.startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("CALL_FAILED", "Failed to make call: ${e.message}", null)
        }
    }

    private fun hasCallPermission(): Boolean {
        val currentActivity = activity ?: return false
        return ContextCompat.checkSelfPermission(
            currentActivity,
            Manifest.permission.CALL_PHONE
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestCallPermission(result: Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        if (hasCallPermission()) {
            result.success(true)
            return
        }

        ActivityCompat.requestPermissions(
            currentActivity,
            arrayOf(Manifest.permission.CALL_PHONE),
            PERMISSION_REQUEST_CODE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() && 
                         grantResults[0] == PackageManager.PERMISSION_GRANTED
            
            if (granted && pendingPhoneNumber != null) {
                makePhoneCall(pendingPhoneNumber!!, pendingResult!!)
                pendingPhoneNumber = null
                pendingResult = null
            } else if (pendingResult != null) {
                pendingResult?.success(granted)
                pendingResult = null
            }
            return true
        }
        return false
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}

