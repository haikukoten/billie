package dev.billie.billie

import android.content.Context
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters

/**
 * Created by Harry K on 7/18/19. <kituyiharry@gmail.com>
 */
class ZipUploadWorker(context: Context, workerParameters: WorkerParameters)
    : Worker(context, workerParameters) {


    override fun doWork(): Result {
        Log.d("ZIPUPLOADWORKER", "Zipper has been Called")
        return Result.success()
    }


}