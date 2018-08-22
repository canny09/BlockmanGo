//
//  AppDelegate.swift
//  BlockmanGo
//
//  Created by KiBen on 2018/7/4.
//  Copyright © 2018年 SanboxOL. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        PrepareLauncher.prepareRootViewController(&window)
        ThirdPartyService.initialize(launchOptions: launchOptions)
        BMUserDefaults.setString(AppInfo.currentShortVersion, forKey: .appShortVersion)
        return true
    }
}

