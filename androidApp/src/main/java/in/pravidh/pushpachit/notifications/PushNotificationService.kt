package in.pravidh.pushpachit.notifications

import android.util.Log
import com.google.firebase.messaging.FirebaseMessaging

object PushNotificationService {
    fun registerToken(onToken: (String) -> Unit) {
        FirebaseMessaging.getInstance().token
            .addOnSuccessListener(onToken)
            .addOnFailureListener { error -> Log.w("PushpaPush", "FCM token unavailable", error) }
    }
}
