// Copyright © 2022 Almost Engineer. All rights reserved.

import UIKit
import Combine
import AudioPlayerModule
import SharedComponentsiOSModule
import AudioPlayerModuleiOS

final class LargeAudioPlayerViewAdapter {
    private weak var controller: LargeAudioPlayerViewController?
    private var onSpeedPlaybackChange: ((PlaybackSpeed) -> Void)?
    weak var presenter: LargeAudioPlayerPresenter?
    
    init(controller: LargeAudioPlayerViewController,
         onSpeedPlaybackChange: @escaping (PlaybackSpeed) -> Void) {
        self.controller = controller
        self.onSpeedPlaybackChange = onSpeedPlaybackChange
    }
}

extension LargeAudioPlayerViewAdapter: LargeAudioPlayerView {

    func display(viewModel: LargeAudioPlayerViewModel) {
        controller?.display(viewModel: viewModel)
    }
    
    func diplayFuturePrepareForSeekProgress(with progress: ProgressViewModel) {
        controller?.displayProgressOnPrepareForSeek(viewModel: progress)
    }
    
    func displaySpeedPlaybackSelection(with list: [PlaybackSpeed]) {
        guard let mapper = presenter?.map(playbackSpeed:) else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.accentColor
        let selectedColor = UIColor.accentColor
        let defaultColor = UIColor.label
        
        list.forEach { model in
            let viewModel = mapper(model)
            let action = UIAlertAction(title: viewModel.displayTitle, style: .default, handler: { [weak self] _ in
                self?.onSpeedPlaybackChange?(model)
            })
            let color = viewModel.isSelected ? selectedColor : defaultColor
            action.setValue(color, forKey: "titleTextColor")
            alert.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        cancelAction.setValue(defaultColor, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        self.controller?.present(alert, animated: true)
    }
}
