//
//  AppDelegate.swift
//  k-movie-diary
//
//  Created by Matthew Flood on 4/15/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        loadTmdbApiKey()
        return true
    }


    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {

        

        // Process the URL.
        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true)
        
        if components?.scheme == "kdramadiary" && components?.path == "authenticate" {

            let allScenes = UIApplication.shared.connectedScenes
            let scene = allScenes.first { $0.activationState == .foregroundActive }
                                    
            if let windowScene = scene as? UIWindowScene {
                
                if let rootViewController = windowScene.keyWindow?.rootViewController as? LoginViewController {
                    let loginSuccess = LoginResponseSuccess(success: true, expiresAt: "", requestToken: TmdbClient.Auth.requestToken!)
                    let errorString: String? = nil
                    rootViewController.handleLoginResponse(loginSuccess: loginSuccess, errorString: errorString)
                    return true
                }
            }
        }
        return false
    }
}

