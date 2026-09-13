//
//  Exitinator.swift
//  PartyUI
//
//  Created by lunginspector on 2/12/26.
//

import Foundation
import UIKit

@MainActor
func exitinator() {
    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
        exit(0)
    }
}
