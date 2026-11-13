//
//  Alertinator.swift
//  PartyUI
//
//  Created by lunginspector on 2/12/26.
//

import Foundation
import UIKit

@MainActor
public class Alertinator {
    public static let shared = Alertinator()
    
    var alertController: UIAlertController?
    
    public func alert(title: String, body: String, showCancel: Bool = true) {
        let title = NSLocalizedString(title, comment: "")
        let body = NSLocalizedString(body, comment: "")
        Task { @MainActor in
            alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if showCancel {
                alertController?.addAction(.init(title: NSLocalizedString("OK", comment: ""), style: .cancel))
            }
            alertController?.view.tintColor = UIColor(named: "AccentColor")
            self.present(alertController!)
        }
    }
    
    public func alert(title: String, body: String, showCancel: Bool = true, actionLabel: String = "OK", action: @escaping () -> Void) {
        let title = NSLocalizedString(title, comment: "")
        let body = NSLocalizedString(body, comment: "")
        let actionLabel = NSLocalizedString(actionLabel, comment: "")
        Task { @MainActor in
            alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            alertController?.addAction(.init(title: actionLabel, style: .default) { _ in
                action()
            })
            if showCancel {
                alertController?.addAction(.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
            }
            alertController?.view.tintColor = UIColor(named: "AccentColor")
            self.present(alertController!)
        }
    }
    
    public func prompt(title: String, placeholder: String = "", text: String = "", showCancel: Bool = true, completion: @escaping (String?) async -> Void) {
        let title = NSLocalizedString(title, comment: "")
        let placeholder = NSLocalizedString(placeholder, comment: "")
        Task { @MainActor in
            alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alertController?.addTextField { field in
                if !placeholder.isEmpty {
                    field.placeholder = placeholder
                }
                if !text.isEmpty {
                    field.text = text
                }
            }
            if showCancel {
                alertController?.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
                    Task {
                        await completion(nil)
                    }
                })
            }
            alertController?.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
                let field = self.alertController?.textFields?.first
                Task {
                    await completion(field?.text)
                }
            })
            alertController?.view.tintColor = UIColor(named: "AccentColor")
            self.present(alertController!)
        }
    }
    
    @MainActor
    private func present(_ alert: UIAlertController) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           var topController = window.rootViewController {
            
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alert, animated: true)
        }
    }
}
