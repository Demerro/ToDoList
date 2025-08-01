//
//  SceneDelegate.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 31.07.25.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private let appDependencyContainer = AppDependencyContainer()
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let window = UIWindow(windowScene: scene as! UIWindowScene)
        window.rootViewController = appDependencyContainer.appRouter.navigationController
        appDependencyContainer.appRouter.showTaskList()
        window.makeKeyAndVisible()
        self.window = window
    }
}
