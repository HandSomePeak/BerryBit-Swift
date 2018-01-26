//
//  AppDelegate.swift
//  BerryBit
//
//  Created by 杨峰 on 17/12/4.
//  Copyright © 2017年 BerryBit. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var coreDataHelper : CoreDataHelper?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        
        // 判断跳转到登录还是跳转到主页
        let info = UserDefaults.standard.dictionary(forKey: "PersonalInfo")
        print("AppDelegate = \(String(describing: info))")
        if info != nil {
            let info_1 : Dictionary<String, AnyObject> = info! as Dictionary<String, AnyObject>
            let personal = PersonalInfo.init(dict: info_1)
            if personal.id != nil {
                // 已经登录过了，直接跳转到主页
                print("已经登录过了，直接跳转到主页")
                let vc = HomeVC()
                self.window?.rootViewController = vc
                self.window?.makeKeyAndVisible()
                return true
            }
        }
        
        // 未登录过，跳转到注册登录页面
        print("未登录过，跳转到注册登录页面")
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        let vc = ViewController()
        self.window?.rootViewController = vc
        
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.cdh().backgroundSaveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.cdh().backgroundSaveContext()
    }

    func cdh() -> CoreDataHelper {
        if (self.coreDataHelper == nil) {
            self.coreDataHelper = CoreDataHelper.shareInstance
            self.coreDataHelper?.setupCoreData()
        }
        return self.coreDataHelper!
    }
}

