package in.pravidh.pushpachit

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import in.pravidh.pushpachit.ui.AppRoot

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { AppRoot() }
    }
}
