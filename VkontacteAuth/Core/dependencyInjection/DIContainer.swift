//
//  DIContainer.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 11.07.2022.
//

import Foundation

protocol DIContainerProtocol {
    func register<Component>(type: Component.Type, component: Any)
    func resolve<Component>(type: Component.Type) -> Component
}

final class DIContainer: DIContainerProtocol {
    static let shared = DIContainer()
    
    private init() {}
    
    var components: [String: Any] = [:]
    
    func register<Component>(type: Component.Type, component: Any) {
        components["\(type)"] = component
    }
    
    func resolve<Component>(type: Component.Type) -> Component {
        guard let component = components["\(type)"] as? Component else {
            fatalError("\(type) not being registered")
        }
        return component
    }
}

@propertyWrapper
struct Injected<ObjectType> {
    var wrappedValue: ObjectType
    
    init() {
        self.wrappedValue = DIContainer.shared.resolve(type: ObjectType.self)
    }
}
