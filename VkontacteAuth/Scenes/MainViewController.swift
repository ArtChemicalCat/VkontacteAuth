//
//  MainViewController.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 07.07.2022.
//

import UIKit
import Combine

final class MainViewController: UIViewController {
    //MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    @Injected private var store: AppStore
    
    private var authVC: WelcomeViewController?
    private var profileVC: ProfileViewController?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        observeState()
    }
    
    //MARK: - Metods
    private func observeState() {
        store.$state
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] state in
                self?.newState(state)
            }
            .store(in: &subscriptions)
    }
    
    private func newState(_ state: AppState) {
        switch state {
        case let .signedIn(signedInState):
            presentProfile(state: signedInState)
        case let .notSignedIn(onboardingState):
            presentLogIn(onboardingState)
        }
    }
    
    private func presentLogIn(_ state: OnboardingState) {
        guard !children.contains(where: { $0 is WelcomeViewController }) else { return }
        
        if profileVC != nil {
            removeChild(profileVC)
            profileVC = nil
        }
        
        let onboardingStatePublisher = store.$state
            .removeDuplicates()
            .map { state -> ScopedState<OnboardingState> in
                switch state {
                case .signedIn:
                    return .outOfScope
                case .notSignedIn(let onboardingState):
                    return .inScope(onboardingState)
                }
            }
            .eraseToAnyPublisher()
        
        authVC = WelcomeViewController(statePublisher: onboardingStatePublisher)
        presentFullScreen(authVC!)
    }
    
    private func presentProfile(state: LoggedInState) {
        guard !children.contains(where: { $0 is ProfileViewController }) else { return }
        
        if authVC != nil {
            removeChild(authVC)
            authVC = nil
        }
        
        let statePublisher = store.$state
            .removeDuplicates()
            .map { state -> ScopedState<LoggedInState> in
                switch state {
                case let .signedIn(loggedInState):
                    return .inScope(loggedInState)
                case .notSignedIn:
                    return .outOfScope
                }
            }
            .eraseToAnyPublisher()
        
        profileVC = ProfileViewController(statePublisher: statePublisher)
        presentFullScreen(profileVC!)
    }
    
    private func presentFullScreen(_ child: UIViewController) {
        guard child.parent == nil else { return }
        
        addChild(child)
        view.addSubview(child.view)
        child.view.frame = view.frame
        
        child.didMove(toParent: self)
    }
    
    private func removeChild(_ child: UIViewController?) {
        guard let child = child else { return }
        guard child.parent != nil else { return }
        
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}

