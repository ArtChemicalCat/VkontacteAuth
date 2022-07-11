//
//  AuthViewController.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 06.07.2022.
//

import WebKit
import UIKit
import Combine

final class AuthViewController: UIViewController {
    //MARK: - Views
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                view.configuration.websiteDataStore.httpCookieStore.delete(cookie)
            }
        }
        
        view.navigationDelegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    private let statePublisher: AnyPublisher<ScopedState<OnboardingState>, Never>
    
    @Injected private var store: AppStore

    //MARK: - LifeCycle
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
        loadURL()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.dispatch(.authViewDismissed)
    }
    
    //MARK: - Metods
    private func observeState() {
        statePublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] state in
                switch state {
                case .outOfScope:
                    self?.dismiss(animated: false)
                case .inScope(let onboardingState):
                    switch onboardingState {
                    case .welcomeScreen:
                        self?.dismiss(animated: true)
                    default:
                        return
                    }
                }
            }
            .store(in: &subscriptions)
    }
            
    private func loadURL() {
        guard let request = try? AuthTokenRequest.auth.request(authToken: "") else { return }
        webView.load(request)
        
    }
    
    private func layout() {
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

//MARK: - WKNavigationDelegate
extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        
        var components = URLComponents()
        components.query = url.fragment
        
        guard let queryItems = components.queryItems,
              let code = queryItems.first(where: { $0.name == "access_token" })?.value,
        let expiresIn = queryItems.first(where: { $0.name == "expires_in" })?.value,
        let userID = queryItems.first(where: { $0.name == "user_id" })?.value else { return }
        let token = APIToken(accessToken: code, expiresIn: Int(expiresIn) ?? 0)
        let userSession = UserSession(userID: Int(userID)!, token: token)
        
        store.dispatch(.authenticationFinished(userSession))
    }
}
