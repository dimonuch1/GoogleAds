//
//  UIViewController+Extension.swift
//  
//
//  Created by Koliush Dmitry on 24.03.2023.
//

import UIKit

extension UIViewController {
    static var root: UIViewController? {
        UIApplication.shared.connectedScenes
                    // Keep only active scenes, onscreen and visible to the user
                    .filter { $0.activationState == .foregroundActive }
                    // Keep only the first `UIWindowScene`
                    .first(where: { $0 is UIWindowScene })
                    // Get its associated windows
                    .flatMap({ $0 as? UIWindowScene })?.windows
                    // Finally, keep only the key window
                    .first(where: \.isKeyWindow)?
                    .rootViewController
    }
}
