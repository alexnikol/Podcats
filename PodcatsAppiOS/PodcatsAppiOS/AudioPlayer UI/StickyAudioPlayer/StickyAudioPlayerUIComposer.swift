// Copyright © 2022 Almost Engineer. All rights reserved.

import UIKit
import Combine
import PodcastsModule
import LoadResourcePresenter
import AudioPlayerModule
import SharedComponentsiOSModule
import AudioPlayerModuleiOS

public enum StickyAudioPlayerUIComposer {
    
    public static func playerWith(
        audioPlayerStatePublisher: AudioPlayerStatePublishers.AudioPlayerStatePublisher,
        controlsDelegate: AudioPlayerControlsDelegate,
        imageLoader: @escaping (URL) -> AnyPublisher<Data, Error>,
        onPlayerOpen: @escaping () -> Void
    ) -> StickyAudioPlayerViewController {
        let (thumbnailViewController, thumbnailSourceDelegate) = ThumbnailUIComposer.composeThumbnailWithDynamicImageLoader(imageLoader: imageLoader)
        
        let presentationAdapter = StickyAudioPlayerPresentationAdapter(
            audioPlayerStatePublisher: audioPlayerStatePublisher,
            thumbnaiSourceDelegate: thumbnailSourceDelegate,
            onPlayerOpen: onPlayerOpen
        )
                    
        let controller = StickyAudioPlayerViewController(
            delegate: presentationAdapter,
            controlsDelegate: controlsDelegate,
            thumbnailViewController: thumbnailViewController
        )
        let viewAdapter = StickyAudioPlayerViewAdapter(
            controller: controller
        )
        let presenter = StickyAudioPlayerPresenter(resourceView: viewAdapter)
        presentationAdapter.presenter = presenter
        return controller
    }
}
