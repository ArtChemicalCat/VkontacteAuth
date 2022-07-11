//
//  AppDelegate.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 06.07.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let userSessionRepository = UserSessionRepository()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let userSession = UserSessionRepository().readUserSession()
        let initialAppState = AppState(from: userSession)
        let store = AppStore(initial: initialAppState, reducer: Reducers.authReducer, middlewares: [Middlewares.loggerMiddleware])
        
        let mainVC = UINavigationController(rootViewController: MainViewController(store: store))
        
        let window = UIWindow()
        window.frame = UIScreen.main.bounds
        window.makeKeyAndVisible()
        window.rootViewController = mainVC
        self.window = window
        
        return true
    }

}

