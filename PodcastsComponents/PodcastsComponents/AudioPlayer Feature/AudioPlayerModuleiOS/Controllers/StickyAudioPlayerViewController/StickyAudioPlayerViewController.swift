// Copyright © 2022 Almost Engineer. All rights reserved.

import UIKit
import SharedComponentsiOSModule
import AudioPlayerModule

public class StickyAudioPlayerViewController: UIViewController {
    @IBOutlet public private(set) weak var titleLabel: UILabel!
    @IBOutlet public private(set) weak var descriptionLabel: UILabel!
    @IBOutlet public private(set) weak var thumbnailView: DefaultImageView!
    @IBOutlet private(set) weak var forwardButton: UIButton!
    @IBOutlet public private(set) weak var playButton: UIButton!
    @IBOutlet public private(set) weak var bufferLoader: UIActivityIndicatorView!
    private var delegate: StickyAudioPlayerViewDelegate?
    private var controlsDelegate: AudioPlayerControlsDelegate?
    private var thumbnailViewController: ThumbnailDynamicViewController?
    
    public convenience init(
        delegate: StickyAudioPlayerViewDelegate,
        controlsDelegate: AudioPlayerControlsDelegate,
        thumbnailViewController: ThumbnailDynamicViewController
    ) {
        self.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
        self.delegate = delegate
        self.controlsDelegate = controlsDelegate
        self.thumbnailViewController = thumbnailViewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        updateInitialValuesOnCreate()
        configureViews()
        thumbnailViewController?.view = thumbnailView
        delegate?.onOpen()
    }
    
    @IBAction public func playToggleTap(_ sender: Any) {
        guard let controlsDelegate = controlsDelegate else { return }
        controlsDelegate.isPlaying ? controlsDelegate.pause() : controlsDelegate.play()
    }
    
    @IBAction public func goForewardTap(_ sender: Any) {
        controlsDelegate?.seekToSeconds(30)
    }
    
    public func display(viewModel: StickyAudioPlayerViewModel) {
        titleLabel.text = viewModel.titleLabel
        descriptionLabel.text = viewModel.descriptionLabel
        updatePlayButtonWith(state: viewModel.playbackViewModel)
    }
}

// MARK: - UI setup
private extension StickyAudioPlayerViewController {
    
    func configureViews() {
        addOnOpenActions()
        configureThumbnailView()
        configureBlurView()
        configureActionButtons()
    }
    
    func configureActionButtons() {
        playButton.tintColor = UIColor.accentColor
        playButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24), forImageIn: .normal)
        forwardButton.tintColor = UIColor.accentColor
        forwardButton.setImage(.init(systemName: "goforward.30"), for: .normal)
        forwardButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
    }
    
    func updateInitialValuesOnCreate() {
        titleLabel.text = nil
        descriptionLabel.text = nil
    }
    
    func updatePlayButtonWith(state: PlaybackStateViewModel) {
        switch state {
        case .pause, .playing:
            playButton.setImage(state.image, for: .normal)
            playButton.isHidden = false
            bufferLoader.isHidden = true
            bufferLoader.stopAnimating()
            
        case .loading:
            playButton.setImage(nil, for: .normal)
            playButton.isHidden = true
            bufferLoader.isHidden = false
            bufferLoader.startAnimating()
        }
    }
    
    func configureBlurView() {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0)
        ])
    }
    
    func addOnOpenActions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onPlayerOpen))
        view.addGestureRecognizer(tap)
        
        let topSwipe = UISwipeGestureRecognizer(target: self, action: #selector(onPlayerOpen))
        topSwipe.direction = .up
        view.addGestureRecognizer(topSwipe)
    }
    
    @objc
    func onPlayerOpen() {
        delegate?.onPlayerOpen()
    }
    
    func configureThumbnailView() {
        thumbnailView.setCornerRadius(4.0)
    }
}
