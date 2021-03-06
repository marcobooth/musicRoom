//
//  AppDelegate.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/8/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import TwitterKit
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        
        // Facebook login stuff
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Google login stuff
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        // Twitter API
        Twitter.sharedInstance().start(withConsumerKey: "", consumerSecret: "")
        
        return true
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
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.absoluteString.lowercased().contains("") == true {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication:sourceApplication, annotation: annotation)
        } else if url.absoluteString.lowercased().contains("twitterkit-") == true {
            return Twitter.sharedInstance().application(application, open: url, options: [AnyHashable : Any]())
        } else {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print("error", error)
            // ...
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        segueFromCurrentVC(from: self.window?.rootViewController, credential: credential)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("signed out")
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func segueFromCurrentVC(from vc: UIViewController?, credential: AuthCredential) {
        if let vc = vc as? LoginViewController {
            GIDSignIn.sharedInstance().signOut()
            vc.loginWithCredential(credential: credential)
            return
        } else if let vc = vc as? SettingsTableViewController {
            GIDSignIn.sharedInstance().signOut()
            vc.addSocialAccount(credential: credential)
            return
        }
        
        // dig through all the VCs until we find either of the two above
        if let vc = vc as? MusicBarViewController {
            segueFromCurrentVC(from: vc.embeddedViewController, credential: credential)
        } else if let tabBarVC = vc as? UITabBarController {
            segueFromCurrentVC(from: tabBarVC.selectedViewController, credential: credential)
        } else if let navController = vc as? UINavigationController {
            segueFromCurrentVC(from: navController.visibleViewController, credential: credential)
        } else if let presentedVC = vc?.presentedViewController {
            segueFromCurrentVC(from: presentedVC, credential: credential)
        } else {
            print("Couldn't find the VC from which we can segue.")
        }
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let musicBarVC = controller as? MusicBarViewController {
            return topViewController(controller: musicBarVC.embeddedViewController)
        } else if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        } else if let tabController = controller as? UITabBarController, let selected = tabController.selectedViewController {
            return topViewController(controller: selected)
        } else if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        } else {
            return controller
        }
    }
}
