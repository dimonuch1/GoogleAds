//
//  UIViewController+Extension.swift
//  
//
//  Created by Koliush Dmitry on 24.03.2023.
//

import UIKit

extension UIViewController {
    public static var root: UIViewController? {
        UIApplication.shared.connectedScenes
                    .filter { $0.activationState == .foregroundActive }
                    .first(where: { $0 is UIWindowScene })
                    .flatMap({ $0 as? UIWindowScene })?.windows
                    .first(where: \.isKeyWindow)?
                    .rootViewController
    }
}
