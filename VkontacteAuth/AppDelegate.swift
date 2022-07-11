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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let container = DIContainer.shared
        container.register(type: UserSessionRepository.self,
                           component: UserSessionRepository())
        container.register(type: RequestManager.self,
                           component: RequestManager())
        
        let userSession = container.resolve(type: UserSessionRepository.self).readUserSession()
        let initialAppState = AppState(from: userSession)
        let store = AppStore(initial: initialAppState, reducer: Reducers.authReducer, middlewares: [Middlewares.loggerMiddleware,
                                                                                                    Middlewares.getProfileInfoMiddleware,
                                                                                                    Middlewares.userSessionManagingMiddleware])
        
        container.register(type: AppStore.self, component: store)
        let mainVC = UINavigationController(rootViewController: MainViewController())
        
        let window = UIWindow()
        window.frame = UIScreen.main.bounds
        window.makeKeyAndVisible()
        window.rootViewController = mainVC
        self.window = window
        
        return true
    }

}

