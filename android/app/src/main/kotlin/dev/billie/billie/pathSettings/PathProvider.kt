package dev.billie.billie.pathSettings

import android.content.Context
import android.util.Log
import com.google.gson.Gson
import java.io.File

/**
 * Created by Harry K on 7/19/19. <kituyiharry@gmail.com>
 */

class PathProvider(private val _context: Context) {

    private val fileName = "${System.currentTimeMillis()}.json"
    private fun setupDirectory(): File {
        return File(_context.getExternalFilesDir("/Billie/backups/".replace("/", File.pathSeparator)),fileName)
    }

    @Throws
    fun writeMessages(messages: ArrayList<Map<String,String>>): String {
        val file = setupDirectory()
        try {
            file.printWriter().use {
                out ->  out.println(Gson().toJson(mapOf(Pair("sms",messages))))
            }
        } catch (e: Exception){
            Log.d("BillieFile", "File writing failed : ${e.printStackTrace()}")
            throw e
        }
        return file.absolutePath
    }

}
