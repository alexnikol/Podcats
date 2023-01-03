// Copyright © 2022 Almost Engineer. All rights reserved.

import UIKit
import AudioPlayerModuleiOS

protocol RootTabBarViewDelegate {
    func onOpen()
}

final class RootTabBarController: UITabBarController {
    private let playerHeight = 60.0
    private(set) var stickyAudioPlayerController: StickyAudioPlayerViewController?
    var viewDelegate: RootTabBarViewDelegate?
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required convenience init(stickyAudioPlayerController: StickyAudioPlayerViewController, viewDelegate: RootTabBarViewDelegate) {
        self.init(nibName: nil, bundle: nil)
        self.stickyAudioPlayerController = stickyAudioPlayerController
        self.viewDelegate = viewDelegate
        setPlayerControllerAsChild()
        viewDelegate.onOpen()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBlurView()
        tabBar.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.4)
        tabBar.isTranslucent = true
        tabBar.isOpaque = true
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        extendedLayoutIncludesOpaqueBars = true
    }
    
    private func setPlayerControllerAsChild() {
        guard let stickyAudioPlayerController = stickyAudioPlayerController, let playerView = stickyAudioPlayerController.view else { return }
        self.view.addSubview(playerView)
        self.addChild(stickyAudioPlayerController)
        stickyAudioPlayerController.didMove(toParent: self)
        playerView.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.4)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.isHidden = true
        NSLayoutConstraint.activate([
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            playerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: 0.0),
            playerView.heightAnchor.constraint(equalToConstant: playerHeight)
        ])
    }
    
    func configureBlurView() {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = tabBar.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tabBar.insertSubview(blurEffectView, at: 0)
        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor, constant: 0.0),
            blurEffectView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor, constant: 0.0),
            blurEffectView.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: 0.0),
            blurEffectView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: 0.0)
        ])
    }
    
    private func updateSafeAreaDependOnPlayerState(isPlayerVisible: Bool) {
        (self.viewControllers ?? []).forEach {
            if isPlayerVisible {
                $0.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(self.playerHeight), right: 0)
            } else {
                $0.additionalSafeAreaInsets = .zero
            }
        }
    }
}

extension RootTabBarController: RootStickyPlayerView {
    
    func hideStickyPlayer() {
        stickyAudioPlayerController?.view.isHidden = true
        updateSafeAreaDependOnPlayerState(isPlayerVisible: false)
    }
    
    func showStickyPlayer() {
        stickyAudioPlayerController?.view.isHidden = false
        updateSafeAreaDependOnPlayerState(isPlayerVisible: true)
    }
}
