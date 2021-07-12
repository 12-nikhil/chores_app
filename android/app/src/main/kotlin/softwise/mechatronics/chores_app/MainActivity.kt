package softwise.mechatronics.chores_app
import android.app.NotificationManager
import android.content.Context
import android.os.Bundle
import android.os.PersistableBundle
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin
import com.tekartik.sqflite.SqflitePlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant
//import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService
import io.flutter.plugins.pathprovider.PathProviderPlugin
import io.flutter.view.FlutterMain

class MainActivity : FlutterActivity(), PluginRegistry.PluginRegistrantCallback {
    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
//        FlutterFirebaseMessagingBackgroundService.setPluginRegistrant(this)
//        FlutterFirebaseMessagingBackgroundExecutor.setPluginRegistrant(this)
        //this.getFlutterEngine()?.let { GeneratedPluginRegistrant.registerWith(it) }


    }

    override
    fun registerWith(registry: PluginRegistry) {
        PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"))
        FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"))

        //FlutterFirebaseMessagingPlugin.registerWith(registry.registrarFor("plugins.flutter.io/firebase_messaging"))

    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        super.configureFlutterEngine(flutterEngine)

    }
    /* override
    fun onResume() {
        super.onResume()
        closeAllNotifications();
    }

    private fun closeAllNotifications() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancelAll()
    }*/

}

