package dev.billie.billie

import android.os.Bundle
import dev.billie.billie.modelProviders.MessageProvider
import dev.billie.billie.pathSettings.PathProvider
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {

    private val CHANNEL = "dev.billie.billie/sms"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        val messageProvider = MessageProvider(this)

        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSmsMessages" ->
                    result.success(messageProvider.getSms())
                "backupMessages" ->
                    result.success(PathProvider(this).writeMessages(messageProvider.getSms()))
            }
        }
    }
}

