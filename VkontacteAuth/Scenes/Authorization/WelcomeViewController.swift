//
//  WelcomeViewController.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 06.07.2022.
//

import UIKit
import Combine
import AuthenticationServices

final class WelcomeViewController: UIViewController {
    //MARK: - Views
    private lazy var authButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.title = "Log In"
        let action = UIAction { [weak self] _ in
            self?.store.dispatch(.logIn)
        }
        let button = UIButton(configuration: config, primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    //MARK: - Properties
    private let statePublisher: AnyPublisher<ScopedState<OnboardingState>, Never>
    private var subscriptions = Set<AnyCancellable>()
    
    @Injected private var store: AppStore
    
    init(statePublisher: AnyPublisher<ScopedState<OnboardingState>, Never>) {
        self.statePublisher = statePublisher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        observeState()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        presentedViewController?.dismiss(animated: false)
    }
    
    deinit {
        print(#function)
    }
    
    //MARK: - Metods
    private func observeState() {
        statePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                
                switch state {
                case .outOfScope:
                    self?.parent?.removeChild(self)
                case .inScope(let onboardingState):
                    switch onboardingState {
                    case .authenticationScreen:
                        self?.presentWebView()
                    case .welcomeScreen:
                        return
                    }
                }
            }
            .store(in: &subscriptions)
    }
    
    private func presentWebView() {
        let vc = AuthViewController(statePublisher: statePublisher)
        present(vc, animated: true)
    }
}

//MARK: - Layout
extension WelcomeViewController {
    private func layout() {
        view.backgroundColor = .systemBackground
        view.addSubview(authButton)
        
        NSLayoutConstraint.activate([
            authButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
    }
}

