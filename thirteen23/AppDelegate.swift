//
//  AppDelegate.swift
//  thirteen23
//
//  Created by Tom Nelson on 8/5/15.
//  Copyright © 2015 TKO Solutions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.backgroundColor = UIColor.white
            window.rootViewController = ViewController()
            window.makeKeyAndVisible()
        }
        return true
    }
}

