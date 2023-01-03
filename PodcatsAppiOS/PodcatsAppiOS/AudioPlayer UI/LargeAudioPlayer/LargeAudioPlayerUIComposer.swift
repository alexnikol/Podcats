// Copyright © 2022 Almost Engineer. All rights reserved.

import UIKit
import Combine
import PodcastsModule
import LoadResourcePresenter
import AudioPlayerModule
import SharedComponentsiOSModule
import AudioPlayerModuleiOS

public enum LargeAudioPlayerUIComposer {
    
    public static func playerWith(
        audioPlayerstatePublishers: AudioPlayerStatePublishers,
        controlsDelegate: AudioPlayerControlsDelegate,
        imageLoader: @escaping (URL) -> AnyPublisher<Data, Error>
    ) -> LargeAudioPlayerViewController {
        let (thumbnailViewController, thumbnailSourceDelegate) = ThumbnailUIComposer.composeThumbnailWithDynamicImageLoader(imageLoader: imageLoader)
        let presentationAdapter = LargeAudioPlayerPresentationAdapter(
            audioPlayerstatePublishers: audioPlayerstatePublishers,
            thumbnaiSourceDelegate: thumbnailSourceDelegate
        )
        
        let controller = LargeAudioPlayerViewController(
            delegate: presentationAdapter,
            controlsDelegate: controlsDelegate,
            thumbnailViewController: thumbnailViewController
        )
        let viewAdapter = LargeAudioPlayerViewAdapter(
            controller: controller,
            onSpeedPlaybackChange: controlsDelegate.changeSpeedPlaybackTo
        )
        let presenter = LargeAudioPlayerPresenter(resourceView: viewAdapter)
        viewAdapter.presenter = presenter
        presentationAdapter.presenter = presenter
        return controller
    }
}
