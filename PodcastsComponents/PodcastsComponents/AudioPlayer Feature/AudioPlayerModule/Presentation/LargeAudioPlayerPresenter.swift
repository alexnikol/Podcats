// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation

public protocol AudioPlayerView {
    func display(viewModel: LargeAudioPlayerViewModel)
}

public final class LargeAudioPlayerPresenter {
    private let calendar: Calendar
    private let locale: Locale
    private let resourceView: AudioPlayerView
    
    public init(resourceView: AudioPlayerView, calendar: Calendar = .current, locale: Locale = .current) {
        self.resourceView = resourceView
        self.calendar = calendar
        self.locale = locale
    }
    
    private lazy var dateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        var newCalendar = calendar
        newCalendar.locale = locale
        formatter.calendar = newCalendar
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
    
    public func map(playingItem: PlayingItem) -> LargeAudioPlayerViewModel {
        let description = "\(playingItem.podcast.title) | \(playingItem.podcast.publisher)"
        return LargeAudioPlayerViewModel(
            titleLabel: playingItem.episode.title,
            descriptionLabel: description,
            updates: playingItem.updates.map(map(_:))
        )
    }
    
    private func map(_ stateModel: PlayingItem.State) -> LargeAudioPlayerViewModel.UpdatesViewModel {
        switch stateModel {
        case let .playback(state):
            return .playback(PlaybackStateViewModel(playbackState: state))
            
        case let .volumeLevel(model):
            return .volumeLevel(model)
            
        case let .progress(model):
            return .progress(
                .init(
                    currentTimeLabel: mapCurrentTimeLabel(model.currentTimeInSeconds),
                    endTimeLabel: mapEndTimeLabel(model.totalTime),
                    progressTimePercentage: model.progressTimePercentage.roundToDecimal(2)
                )
            )
        }
    }
    
    public func didReceivePlayerState(with playingItem: PlayingItem) {
        resourceView.display(viewModel: map(playingItem: playingItem))
    }
    
    private func mapCurrentTimeLabel(_ timeInSeconds: Int) -> String {
        return positionalTime(timeInSeconds: TimeInterval(timeInSeconds))
    }
    
    private func mapEndTimeLabel(_ duration: EpisodeDuration) -> String {
        switch duration {
        case .notDefined:
            return "..."
        case let .valueInSeconds(timeInSeconds):
            return positionalTime(timeInSeconds: TimeInterval(timeInSeconds))
        }
    }
    
    private func positionalTime(timeInSeconds: TimeInterval) -> String {
        dateFormatter.allowedUnits = timeInSeconds >= 3600 ?
        [.hour, .minute, .second] :
        [.minute, .second]
        let fullTimeString = dateFormatter.string(from: timeInSeconds) ?? ""
        return fullTimeString.hasPrefix("0") ? String(fullTimeString.dropFirst()) : fullTimeString
    }
}

private extension Float {
    func roundToDecimal(_ fractionDigits: Int) -> Float {
        let multiplier = pow(10, Float(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
