package com.example.tarixiy_filimlar

import android.content.Context
import com.felnanuke.google_cast.GoogleCastOptionsProvider
import com.google.android.gms.cast.framework.CastOptions
import com.google.android.gms.cast.framework.OptionsProvider
import com.google.android.gms.cast.framework.SessionProvider
import com.google.android.gms.cast.framework.media.CastMediaOptions

// Plagin sozlamalarini oladi, lekin Cast bildirishnomasini (MediaNotificationService) o'chiradi:
// shunda FOREGROUND_SERVICE_MEDIA_PLAYBACK ruxsati va Play deklaratsiyasi kerak bo'lmaydi.
class CastOptionsProvider : OptionsProvider {

    override fun getCastOptions(context: Context): CastOptions {
        val base = GoogleCastOptionsProvider.options
        val mediaOptions = CastMediaOptions.Builder()
            .setNotificationOptions(null)
            .setMediaSessionEnabled(false)
            .build()
        return CastOptions.Builder()
            .setReceiverApplicationId(base.receiverApplicationId)
            .setLaunchOptions(base.launchOptions)
            .setResumeSavedSession(base.resumeSavedSession)
            .setEnableReconnectionService(base.enableReconnectionService)
            .setCastMediaOptions(mediaOptions)
            .build()
    }

    override fun getAdditionalSessionProviders(context: Context): List<SessionProvider>? = null
}
