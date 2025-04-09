//
//  AppDelegate.swift
//  CameraApp
//
//  Created by hang yang on 1/21/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import Parse
import Foundation
import Toast_Swift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // ****************************************************************************
        // Initialize Parse SDK
        // ****************************************************************************
        
        // 在后台线程初始化Parse
        DispatchQueue.global(qos: .userInitiated).async {
            let configuration = ParseClientConfiguration {
                $0.applicationId = "ParseServerMyCameraAppId123"
                $0.clientKey = ""
                $0.server = "http://8.138.186.198:1337/parse"
            }
            Parse.initialize(with: configuration)

        // 设置默认ACL
        let defaultACL = PFACL()
        defaultACL.hasPublicReadAccess = true
        if let currentUser = PFUser.current() {
            defaultACL.setWriteAccess(true, for: currentUser)
        }
        PFACL.setDefault(defaultACL, withAccessForCurrentUser: true)
            
            // 确保在主线程初始化窗口
            DispatchQueue.main.async {
                self.window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                // 明确指定要加载的ViewController作为根视图控制器
                let initialVC = storyboard.instantiateViewController(withIdentifier: "MainViewController")
                self.window?.rootViewController = initialVC

                self.window?.makeKeyAndVisible()
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        // ****************************************************************************
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        // PFFacebookUtils.initializeFacebook()
        // ****************************************************************************
        
        //PFUser.enableAutomaticUser()
        
        // 已被移动到初始化块内的ACL设置
        // PFACL.setDefault(...)
        
        if application.applicationState != UIApplication.State.background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let oldPushHandlerOnly = !responds(to: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            var noPushPayload = false
            if let options = launchOptions {
                noPushPayload = options[UIApplication.LaunchOptionsKey.remoteNotification] == nil
            }
            if oldPushHandlerOnly || noPushPayload {
                PFAnalytics.trackAppOpened(launchOptions: launchOptions)
            }
        }
        
        if #available(iOS 10.0, *) {
            // iOS 10+
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                print("Notifications access granted: \(granted.description)")
            }
            application.registerForRemoteNotifications()
        } else {
            // iOS 8, 9
            let types: UIUserNotificationType = [.alert, .badge, .sound]
            let settings = UIUserNotificationSettings(types: types, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        return true
    }
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground()
        
        PFPush.subscribeToChannel(inBackground: "") { succeeded, error in
            if succeeded {
                print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.\n")
            } else {
                print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.\n", error!)
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.\n")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@\n", error)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        PFPush.handle(userInfo)
        if application.applicationState == UIApplication.State.inactive {
            PFAnalytics.trackAppOpened(withRemoteNotificationPayload: userInfo)
        }
        
        // 避免直接创建TableViewController实例，因为这样创建的实例没有从storyboard加载，其UI元素为nil
        if (((userInfo["aps"] as! NSDictionary)["alert"]) as! String).contains("请求添加你为好友") {
            
            print("execute")
            // 设置一个全局标志，在TableViewController的viewDidLoad或viewWillAppear中处理
            bool = false
        
        }
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    SessionManager.shared.startMonitoring()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        let pfi = PFInstallation.current()
        pfi?.setObject(0, forKey: "badge")
        var retryCount = 0
        let maxRetries = 3
        
        func saveInstallation() {
            pfi?.saveInBackground { (success, error) in
                if let error = error {
                    print("Parse服务器连接失败: \(error.localizedDescription)")
                    if retryCount < maxRetries {
                        retryCount += 1
                        print("尝试第\(retryCount)次重连...")
                        saveInstallation()
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(
                                title: "连接超时",
                                message: "服务器响应超时，请检查网络后重试",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "重试", style: .default) { _ in
                                retryCount = 0
                                saveInstallation()
                            })
                            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
                            self.window?.rootViewController?.present(alert, animated: true)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        if let topVC = self.window?.rootViewController {
                            topVC.view.hideToastActivity()
                            topVC.view.makeToast("连接恢复成功", duration: 2.0, position: ToastPosition.center)
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.window?.rootViewController?.view.makeToastActivity(ToastPosition.center)
        }
        saveInstallation()

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // 不直接创建TableViewController实例，避免nil解包崩溃问题
        print("original identifier was : \(response.notification.request.identifier)")
        print("original body was : \(response.notification.request.content.body)")
        print("Tapped in notification")
        
        if (response.notification.request.content.body).contains("\\U8bf7\\U6c42\\U6dfb\\U52a0\\U4f60\\U4e3a\\U597d\\U53cb") {
            // 设置全局变量，让TableViewController在加载时使用
            bool = false
        }
            
    }
    
    ///////////////////////////////////////////////////////////
    // Uncomment this method if you want to use Push Notifications with Background App Refresh
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    //     if application.applicationState == UIApplicationState.Inactive {
    //         PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    //     }
    // }
    
    //--------------------------------------
    // MARK: Facebook SDK Integration
    //--------------------------------------
    
    ///////////////////////////////////////////////////////////
    // Uncomment this method if you are using Facebook
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    //     return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, session:PFFacebookUtils.session())
    // }
}


