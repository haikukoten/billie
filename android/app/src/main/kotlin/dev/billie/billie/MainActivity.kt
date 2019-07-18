package dev.billie.billie

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Bundle
import android.provider.Telephony
import android.support.v4.content.ContextCompat
import android.widget.Toast
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequest
import androidx.work.WorkManager
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.util.concurrent.TimeUnit


class MainActivity: FlutterActivity() {

    private val CHANNEL = "dev.billie.billie/sms"
    private  val ZIPUPLOADWORKERTAG = "ZipUploadWorker"


    private  fun _startZipService(){
        val intent: Intent =
                Intent(this, Class.forName("dev.billie.billie.ZipService"))
        intent.putExtra("inputExtra", "Foreground Service Example in Android")
        ContextCompat.startForegroundService(this, intent)
    }

    /*private val receiver = object : BroadcastReceiver() {

        override fun onReceive(context: Context, intent: Intent) {
            val bundle = intent.extras
            if (bundle != null) {
               // val string = bundle.getString(DownloadService.FILEPATH)
                val resultCode = bundle.getInt(ZipService.RESULT)
                if (resultCode == Activity.RESULT_OK) {
                    Toast.makeText(this@MainActivity,
                            "ZipService is Done ",
                            Toast.LENGTH_LONG).show()
                } else {
                    Toast.makeText(this@MainActivity, "Download failed",
                            Toast.LENGTH_LONG).show()
                }
            }
        }
    }*/


    /*override fun onResume() {
        super.onResume()
        registerReceiver(receiver, IntentFilter(
                ZipService.NOTIFICATION))
    }

    override fun onPause() {
        super.onPause()
        unregisterReceiver(receiver)
    }*/


    override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
      //_startZipService()

        val zipUploadWorkerBuilder =
                PeriodicWorkRequest.Builder(ZipUploadWorker::class.java, 15,
                        TimeUnit.MINUTES).setInitialDelay(10000, TimeUnit.MILLISECONDS)

        val request = zipUploadWorkerBuilder.build()
        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
                ZIPUPLOADWORKERTAG, ExistingPeriodicWorkPolicy.KEEP, request)

    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->

      if (call.method == "getBatteryLevel") {
        val batteryLevel = getBatteryLevel()
        if (batteryLevel != -1) {
          result.success(batteryLevel)
        } else {
          result.error("UNAVAILABLE", "Battery level not available.", null)
        }
      } else if (call.method == "getSmsMessages") {
          val messages = _getAllSms(this)
          result.success(messages)
      } else {
          result.notImplemented()
      }
    }
  }

    private fun _getAllSms(context: Context): ArrayList<Map<String, String>> {

        val messages = ArrayList<Map<String, String>>()

        val mProjection: Array<String> = arrayOf(
                Telephony.Sms.BODY,
                Telephony.Sms.SUBJECT,
                Telephony.Sms.DATE,
                Telephony.Sms.ADDRESS // Contract class constant for the locale column name
        )

        //val mSelectionArgs: Array<String> =
        val mSelection: String = "${Telephony.Sms.ADDRESS} = \"MPESA\""

        val cr = context.contentResolver
        val c = cr.query(Telephony.Sms.CONTENT_URI, mProjection, mSelection, null, "${Telephony.Sms.DATE} DESC")
        val totalSMS: Int
        if (c != null) {
            //print("Count = ${c.count}")
            totalSMS = c.count
            if (c.moveToFirst()) {
                for (j in 0 until totalSMS) {
                    //val smsDate = c.getString(c.getColumnIndexOrThrow(Telephony.Sms.DATE))
                    //val number = c.getString(c.getColumnIndexOrThrow(Telephony.Sms.ADDRESS))
                    val body = c.getString(c.getColumnIndexOrThrow(Telephony.Sms.BODY))
                    //var person = c.getString(c.getColumnIndexOrThrow(Telephony.Sms.ADDRESS))
                    //val sub = c.getString(c.getColumnIndexOrThrow(Telephony.Sms.SUBJECT))
                    val date = c.getString(c.getColumnIndexOrThrow(Telephony.Sms.DATE))
                    // val dateFormat = Date(Long.valueOf(smsDate))
                    //val type: String
                    /*when (Integer.parseInt(c.getString(c.getColumnIndexOrThrow(Telephony.Sms.TYPE)))) {
                      //Telephony.Sms.MESSAGE_TYPE_INBOX -> type = "inbox"
                      //Telephony.Sms.MESSAGE_TYPE_SENT -> type = "sent"
                      //Telephony.Sms.MESSAGE_TYPE_OUTBOX -> type = "outbox"
                      else -> {
                      }
                    }*/
                    val m = mapOf(Pair(date, body))
                    messages.add(m)
                    //print("(Address:$person date: $date body: $body )\n")
                    c.moveToNext()
                }
            }
            c.close()
            return messages
        } else {
            Toast.makeText(this, "No message to show!", Toast.LENGTH_SHORT).show()
            return messages
        }
    }

  private fun getBatteryLevel(): Int {
    val batteryLevel: Int
    if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
      val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
      batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    } else {
      val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
      batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
    }

    return batteryLevel
  }
}

