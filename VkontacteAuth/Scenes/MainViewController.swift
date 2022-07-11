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
        
        let authVC = WelcomeViewController(statePublisher: onboardingStatePublisher)
        presentFullScreen(authVC)
    }
    
    private func presentProfile(state: LoggedInState) {
        guard !children.contains(where: { $0 is ProfileViewController }) else { return }
        
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
        
        let profileVC = ProfileViewController(statePublisher: statePublisher)
        presentFullScreen(profileVC)
    }
    
    
}

