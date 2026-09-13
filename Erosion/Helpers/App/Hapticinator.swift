//
//  Hapticinator.swift
//  PartyUI
//
//  Created by lunginspector on 2/12/26.
//

import Foundation
import UIKit
import Combine

@MainActor
public class Haptic: ObservableObject {
    public static let shared = Haptic()
    
    public func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1.0) {
        Task { @MainActor in
            UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred(intensity: intensity)
        }
    }
    
    public func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        Task { @MainActor in
            UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
        }
    }
}
