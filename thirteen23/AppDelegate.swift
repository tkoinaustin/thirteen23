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


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if let window = window {
            window.backgroundColor = UIColor.whiteColor()
            window.rootViewController = ViewController()
            window.makeKeyAndVisible()
        }
        return true
    }
}

