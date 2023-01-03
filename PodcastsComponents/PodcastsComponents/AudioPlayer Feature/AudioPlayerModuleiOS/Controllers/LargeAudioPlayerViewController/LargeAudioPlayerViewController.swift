// Copyright © 2022 Almost Engineer. All rights reserved.

import UIKit
import SharedComponentsiOSModule
import AudioPlayerModule
import MediaPlayer
import AVKit
import LoadResourcePresenter

public final class LargeAudioPlayerViewController: UIViewController {
    private enum Defaults {
        enum ThumbnailSize {
            static let activeSideSize = CGFloat(200)
            static let inactiveSideSize = CGFloat(160)
        }
    }
    
    @IBOutlet weak var rootStackView: UIStackView!
    @IBOutlet weak var thumbnailView: ThumbnailView!
    @IBOutlet public private(set) weak var progressView: UISlider!
    @IBOutlet public private(set) weak var leftTimeLabel: UILabel!
    @IBOutlet public private(set) weak var rightTimeLabel: UILabel!
    @IBOutlet public private(set) weak var titleLabel: UILabel!
    @IBOutlet public private(set) weak var descriptionLabel: UILabel!
    @IBOutlet public private(set) weak var playButton: UIButton!
    @IBOutlet public private(set) weak var forwardButton: UIButton!
    @IBOutlet public private(set) weak var backwardButton: UIButton!
    @IBOutlet public private(set) weak var volumeView: UISlider!
    @IBOutlet public private(set) weak var airPlayButton: UIButton!
    @IBOutlet public private(set) weak var speedPlaybackButton: UIButton!
    @IBOutlet weak var leftVolumeIconView: UIImageView!
    @IBOutlet weak var rightVolumeIconView: UIImageView!
    @IBOutlet weak var thumbnailIWidthCNST: NSLayoutConstraint!
    @IBOutlet weak var thumbnailIHeightCNST: NSLayoutConstraint!
    @IBOutlet weak var thumbnailIViewSideCNST: NSLayoutConstraint!
    @IBOutlet weak var rootStackViewTopCNST: NSLayoutConstraint!
    @IBOutlet weak var controlsStackView: UIStackView!
    @IBOutlet public private(set) weak var bufferLoader: UIActivityIndicatorView!
    private var delegate: LargeAudioPlayerViewDelegate?
    private var controlsDelegate: AudioPlayerControlsDelegate?
    private var hiddenMPVolumeSliderControl: UISlider?
    private var hiddenRoutePickerButton: UIButton?
    private var isProgressViewEditing = false
    private var thumbnailViewController: ThumbnailDynamicViewController?
    
    // MARK: - Initialization
    
    public convenience init(
        delegate: LargeAudioPlayerViewDelegate,
        controlsDelegate: AudioPlayerControlsDelegate,
        thumbnailViewController: ThumbnailDynamicViewController
    ) {
        self.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
        self.delegate = delegate
        self.controlsDelegate = controlsDelegate
        self.thumbnailViewController = thumbnailViewController
    }
    
    // MARK: - Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        updateInitialValuesOnCreate()
        configureViews()
        delegate?.onOpen()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateToInterfaceOrientation()
    }
    
    // MARK: - Actions
    
    @IBAction public func playToggleTap(_ sender: Any) {
        guard let controlsDelegate = controlsDelegate else { return }
        controlsDelegate.isPlaying ? controlsDelegate.pause() : controlsDelegate.play()
    }
    
    @IBAction public func goForewardTap(_ sender: Any) {
        controlsDelegate?.seekToSeconds(30)
    }
    
    @IBAction public func goBackwardTap(_ sender: Any) {
        controlsDelegate?.seekToSeconds(-15)
    }
    
    @IBAction public func progressSliderDidChange(_ sender: UISlider) {
        controlsDelegate?.prepareForSeek(sender.value)
    }
    
    @IBAction public func progressSliderTouchUpInside(_ sender: UISlider) {
        updateUIWithProgressEditMode(isEditing: false)
        controlsDelegate?.seekToProgress(sender.value)
    }
    
    @IBAction public func progressSliderTouchUpOutside(_ sender: UISlider) {
        updateUIWithProgressEditMode(isEditing: false)
        controlsDelegate?.seekToProgress(sender.value)
    }
    
    @IBAction public func progressSliderTouchDown(_ sender: UISlider) {
        updateUIWithProgressEditMode(isEditing: true)
    }
    
    @IBAction public func volumeDidChange(_ sender: UISlider) {
        controlsDelegate?.changeVolumeTo(value: sender.value)
    }
    
    @IBAction public func airPlayDidTap(_ sender: Any) {
        hiddenRoutePickerButton?.sendActions(for: .touchUpInside)
    }
    
    @IBAction public func speedPlaybackDidTap(_ sender: Any) {
        delegate?.onSelectSpeedPlayback()
    }
    
    // MARK: - Public methods
    
    public func display(viewModel: LargeAudioPlayerViewModel) {
        titleLabel.text = viewModel.titleLabel
        descriptionLabel.text = viewModel.descriptionLabel
        updateUIWithUpdatesList(viewModel.updates)
    }
    
    public func displayProgressOnPrepareForSeek(viewModel: ProgressViewModel) {
        guard isProgressViewEditing else { return }
        leftTimeLabel.text = viewModel.currentTimeLabel
    }
    
    private func updateUIWithUpdatesList(_ list: [UpdatesViewModel]) {
        list.forEach { updateViewModel in
            switch updateViewModel {
            case let .playback(state):
                updatePlayButtonWith(state: state)
                updateThumbnail(state: state)
                
            case let .volumeLevel(volumeLevel):
                volumeView.value = volumeLevel
                hiddenMPVolumeSliderControl?.value = volumeLevel
                
            case let .progress(progressViewModel):
                if !isProgressViewEditing {
                    progressView.value = progressViewModel.progressTimePercentage
                    leftTimeLabel.text = progressViewModel.currentTimeLabel
                }
                rightTimeLabel.text = progressViewModel.endTimeLabel
                
            case let .speed(selectedSpeedViewModel):
                speedPlaybackButton.titleLabel?.text = selectedSpeedViewModel.displayTitle
                speedPlaybackButton.setTitle(selectedSpeedViewModel.displayTitle, for: .normal)
            }
        }
    }
    
    private func updatePlayButtonWith(state: PlaybackStateViewModel) {
        playButton.setImage(state.image, for: .normal)
        
        switch state {
        case .pause, .playing:
            bufferLoader.isHidden = true
            bufferLoader.stopAnimating()
            
        case .loading:
            bufferLoader.isHidden = false
            bufferLoader.startAnimating()
        }
    }
    
    private func updateThumbnail(state: PlaybackStateViewModel) {
        switch state {
        case .playing, .loading:
            thumbnailIViewSideCNST.constant = Defaults.ThumbnailSize.activeSideSize
            
        case .pause:
            thumbnailIViewSideCNST.constant = Defaults.ThumbnailSize.inactiveSideSize
        }
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.0,
            animations: {
                self.thumbnailView?.superview?.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func updateUIWithProgressEditMode(isEditing: Bool) {
        isProgressViewEditing = isEditing
        progressView.minimumTrackTintColor = isEditing ? .accentColor : .systemGray
        leftTimeLabel.textColor = isEditing ? .accentColor : .secondaryLabel
    }
}

// MARK: - UI setup
private extension LargeAudioPlayerViewController {
    
    func updateInitialValuesOnCreate() {
        titleLabel.text = nil
        descriptionLabel.text = nil
        progressView.value = 0
        volumeView.value = 0
        leftTimeLabel.text = nil
        rightTimeLabel.text = nil
    }
    
    func configureViews() {
        configureThumbnailView()
        configureVolumeViews()
        configureActionButtons()
        configureAVRoutePickerView()
    }
    
    func configureThumbnailView() {
        thumbnailViewController?.view = thumbnailView
    }
    
    func configureVolumeViews() {
        leftVolumeIconView.image = .init(systemName: "speaker.fill")
        rightVolumeIconView.image = .init(systemName: "speaker.wave.1.fill")
        configureMPVolumeView()
    }
    
    func configureActionButtons() {
        forwardButton.setImage(.init(systemName: "goforward.30"), for: .normal)
        forwardButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 34), forImageIn: .normal)
        backwardButton.setImage(.init(systemName: "gobackward.15"), for: .normal)
        backwardButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 34), forImageIn: .normal)
        airPlayButton.setImage(.init(systemName: "airplayaudio.circle"), for: .normal)
        airPlayButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24), forImageIn: .normal)
        speedPlaybackButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        
        playButton.layer.cornerRadius = 4.0
        playButton.tintColor = UIColor.accentColor
        playButton.addSubview(bufferLoader)
        
        NSLayoutConstraint.activate([
            bufferLoader.centerXAnchor.constraint(equalTo: playButton.centerXAnchor, constant: 0.0),
            bufferLoader.centerYAnchor.constraint(equalTo: playButton.centerYAnchor, constant: 0.0)
        ])
    }
    
    func configureMPVolumeView() {
        let volumeControl = MPVolumeView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        self.view.addSubview(volumeControl)
        volumeControl.isHidden = true
        let lst = volumeControl.subviews.filter{ NSStringFromClass($0.classForCoder) == "MPVolumeSlider" }
        let slider = lst.first as? UISlider
        hiddenMPVolumeSliderControl = slider
    }
    
    func configureAVRoutePickerView() {
        let routePickerView = AVRoutePickerView()
        view.addSubview(routePickerView)
        routePickerView.isHidden = true
        hiddenRoutePickerButton = routePickerView.subviews.first(where: { $0 is UIButton }) as? UIButton
    }
}

// MARK: - Rotation logic
private extension LargeAudioPlayerViewController {
    
    func updateToInterfaceOrientation() {
        let isPortrait = view.frame.height > view.frame.width
        thumbnailIHeightCNST?.isActive = isPortrait ? true : false
        thumbnailIWidthCNST?.isActive = isPortrait ? false : true
        rootStackViewTopCNST?.constant = isPortrait ? 0.0 : 24.0
        view.layoutIfNeeded()
        
        rootStackView?.axis = isPortrait ? .vertical : .horizontal
        controlsStackView?.axis = isPortrait ? .vertical : .horizontal
        controlsStackView?.alignment = isPortrait ? .fill : .center
        titleLabel?.textAlignment = isPortrait ? .center : .left
        descriptionLabel?.textAlignment = isPortrait ? .center : .left
    }
}
