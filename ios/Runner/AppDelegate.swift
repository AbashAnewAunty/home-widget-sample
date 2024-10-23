import UIKit
import Flutter
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "be.tramckrijte.workmanagerExample.taskId")
    WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "be.tramckrijte.workmanagerExample.iOSBackgroundAppRefresh", frequency: NSNumber(value: 20 * 60))

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
