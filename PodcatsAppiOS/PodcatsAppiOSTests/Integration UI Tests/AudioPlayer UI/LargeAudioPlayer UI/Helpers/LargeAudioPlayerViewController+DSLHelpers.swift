// Copyright © 2022 Almost Engineer. All rights reserved.

import UIKit
import AudioPlayerModuleiOS

extension LargeAudioPlayerViewController {
    
    func episodeTitleText() -> String? {
        return self.titleLabel.text
    }
    
    func episodeDescriptionText() -> String? {
        self.descriptionLabel.text
    }
    
    func volumeLevel() -> Float? {
        volumeView.value
    }
    
    func playbackProgress() -> Float? {
        progressView.value
    }
    
    func leftTimeLabelText() -> String? {
        leftTimeLabel.text
    }
    
    func rightTimeLabelText() -> String? {
        rightTimeLabel.text
    }
    
    func playButtonImage() -> UIImage? {
        playButton.image(for: .normal)
    }
    
    func speedPlaybackValue() -> String? {
        speedPlaybackButton.title(for: .normal)
    }
    
    func simulateUserInitiatedTogglePlaybackEpisode() {
        self.playToggleTap(self)
    }
    
    func simulateUserInitiatedVolumeChange(to value: Float) {
        let slider = UISlider()
        slider.value = value
        self.volumeDidChange(slider)
    }
    
    func simulateUserInitiatedSeekToProgessFirstWay(to value: Float) {
        let slider = UISlider()
        slider.value = value
        self.progressSliderTouchUpInside(slider)
    }
    
    func simulateUserInitiatedSeekToProgessSecondWay(to value: Float) {
        let slider = UISlider()
        slider.value = value
        self.progressSliderTouchUpOutside(slider)
    }
    
    func simulateUserInitiatedSeekForeward() {
        self.goForewardTap(self)
    }
    
    func simulateUserInitiatedSeekBackward() {
        self.goBackwardTap(self)
    }
    
    func simulateUserInitiatedShowSpeedPlayback() {
        self.speedPlaybackDidTap(self)
    }
}
