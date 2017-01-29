//
//  AppDelegate.swift
//  TestTest
//
//  Created by Булат Галиев on 28.01.17.
//  Copyright © 2017 Булат Галиев. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if UserDefaults.standard.string(forKey: "accessToken") == nil {
            ResponseParser.sharedInstance.authorize {ResponseParser.sharedInstance.getCategories(completion: self.instantiateFirstController)}
        } else {
            ResponseParser.sharedInstance.getCategories(completion: self.instantiateFirstController)
        }
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor(red: 77.0 / 255, green: 79.0 / 255, blue: 84.0 / 255, alpha: 1)
//        navigationBarAppearace.barTintColor = UIColor(red: 214.0 / 255, green: 86.0 / 255, blue: 61.0 / 255, alpha: 1)
        navigationBarAppearace.isTranslucent = false
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 77.0 / 255, green: 79.0 / 255, blue: 84.0 / 255, alpha: 1)]
        return true
    }
    
    func instantiateFirstController(postCategories: [PostCategory]) {
        if let navigationViewController = self.window!.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "RevealController") as? UINavigationController {
//        if let navigationController = window?.rootViewController as? UINavigationController {
            if let mainViewController = navigationViewController.viewControllers[0] as? ACTabScrollViewController {
                mainViewController.postCategories = postCategories
            }
            self.window?.rootViewController = navigationViewController
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

