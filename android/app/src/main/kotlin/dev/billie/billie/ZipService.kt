package dev.billie.billie


/**
 * Created by Harry K on 7/15/19. <kituyiharry@gmail.com>
 */

import android.app.*
import android.content.Intent
import android.os.Build
import android.support.v4.app.NotificationCompat

class ZipService : IntentService("ZipService") {

    private var result = Activity.RESULT_CANCELED

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Toast.makeText(this, "ZipService Up", Toast.LENGTH_SHORT).show()
        val input = intent?.getStringExtra("inputExtra")

        createNotificationChannel()

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, 0)

        val notification = NotificationCompat.Builder(this, "ZipService")
                .setContentTitle("Foreground Service")
                .setContentText(input)
                .setSmallIcon(android.R.drawable.ic_menu_upload)
                .setContentIntent(pendingIntent)
                .build()

        startForeground(1, notification)
        return super.onStartCommand(intent, flags, startId)
    }

    // will be called asynchronously by Android
    override fun onHandleIntent(intent: Intent?) {
        //Toast.makeText(this@ZipService, "HandleZipService", Toast.LENGTH_SHORT).show();
        //val p: Process = Runtime.getRuntime().exec("getprop").inputStream
        //P7ZipApi.executeCommand("tar --help")
        Thread.sleep(10000)
        publishResults("PATH", Activity.RESULT_OK)
    }

    private fun publishResults(outputPath: String, result: Int) {
        val intent = Intent(NOTIFICATION)
        intent.putExtra(FILEPATH, outputPath)
        intent.putExtra(RESULT, result)
        sendBroadcast(intent)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                    "ZipService",
                    "Zip Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT
            )

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    companion object {
        const val FILEPATH = "filepath"
        const val RESULT = "result"
        const val NOTIFICATION = "dev.billie.billie.ZipService"
    }
}

/*class ZipService : Service() {

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        Toast.makeText(this, "ZipService Up", Toast.LENGTH_SHORT).show()
        val context: Context = this

        val input = intent.getStringExtra("inputExtra")
        createNotificationChannel()
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, 0)

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Foreground Service")
                .setContentText(input)
                //.setSmallIcon(R.drawable.ic_stat_name)
                .setContentIntent(pendingIntent)
                .build()

        startForeground(1, notification)

        //do heavy work on a background thread
        val handler = Handler()
        handler.postDelayed(object : Runnable {
            override fun run() {
                //Do something after 100ms
                Toast.makeText(context, "check", Toast.LENGTH_SHORT).show()
                stopSelf()
            }
        }, 15500)

        //stopSelf();

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                    CHANNEL_ID,
                    "Zip Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT
            )

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    companion object {
        val CHANNEL_ID = "ZipServiceChannel"
    }
}*/
