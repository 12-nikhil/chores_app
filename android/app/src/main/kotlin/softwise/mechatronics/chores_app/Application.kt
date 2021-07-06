package softwise.mechatronics.chores_app

//import be.tramckrijte.workmanager.WorkmanagerPlugin
import com.tekartik.sqflite.SqflitePlugin
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
//import io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService
import io.flutter.plugins.pathprovider.PathProviderPlugin

public class Application: FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate()
        FlutterFirebaseMessagingService.setPluginRegistrant(this)
        //AlarmService.setPluginRegistrant(this)


    }

    override fun registerWith(registry: PluginRegistry) {
        FirebaseCloudMessagingPluginRegistrant.registerWith(registry)
        PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
        SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
        //AndroidAlarmManagerPlugin.registerWith(
    //       registry.registrarFor("io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin"))
        //SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
       // WorkmanagerPlugin.registerWith((registry.registrarFor("io.flutter.plugins.Workmanager.WorkmanagerPlugin")))
    }
}