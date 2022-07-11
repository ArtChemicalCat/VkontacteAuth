//
//  ProfileViewController.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 07.07.2022.
//

import UIKit
import Combine

final class ProfileViewController: UIViewController {
    //MARK: - Views
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.publisher(for: \.image)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
            image != nil ? self?.imageLoadingIndicator.stopAnimating() : self?.imageLoadingIndicator.startAnimating()
        }
        .store(in: &subscriptions)
        
        return imageView
    }()
    
    private lazy var imageLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        profileImage.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: profileImage.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    private lazy var logOutButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.title = "Log Out"
        let button = UIButton(configuration: config, primaryAction: UIAction(handler: { [unowned self] _ in
            store.dispatch(.logOut)
        }))
        
        return button
    }()
    
    //MARK: - Properties
    private let statePublisher: AnyPublisher<ScopedState<LoggedInState>, Never>
    private var subscriptions = Set<AnyCancellable>()

    @Injected private var store: AppStore
    
    //MARK: - LifeCycle
    init(statePublisher: AnyPublisher<ScopedState<LoggedInState>, Never>) {
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
        store.dispatch(.requestProfileInfo)
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
                case .inScope(let loggedInState):
                    loggedInState.isLoading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
                    
                    guard let user = loggedInState.user,
                          let imageURL = user.photoURL else { return }
                    
                    self?.profileImage.load(url: imageURL)
                    self?.nameLabel.text = user.fullName
                    self?.cityLabel.text = user.city
                }
            }
            .store(in: &subscriptions)
    }
}

//MARK: - Load image from URL
extension UIImageView {
    
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}

//MARK: - Layout
extension ProfileViewController {
    func layout() {
        view.backgroundColor = .systemBackground
        [profileImage, nameLabel, cityLabel, loadingIndicator, logOutButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: profileImage.topAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            cityLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            cityLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            cityLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            logOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logOutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}
