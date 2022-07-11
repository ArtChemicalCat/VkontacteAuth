//
//  UIViewContoller+Extension.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 11.07.2022.
//

import UIKit

extension UIViewController {
    func presentFullScreen(_ child: UIViewController) {
        guard child.parent == nil else { return }
        
        addChild(child)
        view.addSubview(child.view)
        child.view.frame = view.frame
        
        child.didMove(toParent: self)
    }
    
    func removeChild(_ child: UIViewController?) {
        guard let child = child else { return }
        guard child.parent != nil else { return }
        
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
