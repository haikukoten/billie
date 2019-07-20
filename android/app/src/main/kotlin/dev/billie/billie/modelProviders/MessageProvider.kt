package dev.billie.billie.modelProviders

import android.content.Context
import android.provider.Telephony

/**
 * Created by Harry K on 7/20/19. <kituyiharry@gmail.com>
 */

class MessageProvider(private val _context: Context) {

    fun getSms(): ArrayList<Map<String, String>> {

        val sms = ArrayList<Map<String, String>>()
        val mProjection: Array<String> = arrayOf(
                Telephony.Sms.BODY,
                Telephony.Sms.DATE,
                Telephony.Sms.ADDRESS
        )
        val mSelection = "${Telephony.Sms.ADDRESS} = \"MPESA\""
        val resolver = _context.contentResolver
        val cursor = resolver.query(
                Telephony.Sms.CONTENT_URI, mProjection, mSelection, null,
                "${Telephony.Sms.DATE} DESC")
        val totalSMS: Int
        if (cursor != null) {
            totalSMS = cursor.count
            if (cursor.moveToFirst()) {
                for (j in 0 until totalSMS) {
                    val body = cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.BODY))
                    val date = cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.DATE))
                    val m = mapOf(Pair(date, body))
                    sms.add(m)
                    cursor.moveToNext()
                }
            }
            cursor.close()
            return sms
        } else {
            return sms
        }
    }
}