import Flutter
import UIKit
import UserNotifications // 알림 삭제 위해 필요

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 앱 시작시 뱃지 클리어
    UIApplication.shared.applicationIconBadgeNumber = 0
    
    // 알림 권한 등록 필요 시 UNUserNotificationCenter 사용
    UNUserNotificationCenter.current().delegate = self

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // 앱이 포그라운드로 진입할 때 뱃지/알림 클리어
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    UIApplication.shared.applicationIconBadgeNumber = 0
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    print("✅ [AppDelegate] 뱃지 및 배달 알림 클리어 완료")
  }

  // 앱이 백그라운드 진입/종료 시에도 필요하다면 추가 가능
  // override func applicationWillResignActive(_ application: UIApplication) { ... }

  // 이 앱이 지원하는 방향 마스크 (세로 + 가로만)
  override func application(
    _ application: UIApplication,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
    // iPad까지 landscape 지원 필요하면 .allButUpsideDown 추천
    // return [.portrait, .landscapeLeft, .landscapeRight]
    return [.portrait, .landscapeLeft, .landscapeRight]
  }
}
