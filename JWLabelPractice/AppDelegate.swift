//
//  AppDelegate.swift
//  JWLabelPractice
//
//  Created by Jiwon Nam on 4/9/21.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.rootViewController = UINavigationController(rootViewController: JWLabelTestViewController())
        window?.makeKeyAndVisible()
        
        return true
    }
}

