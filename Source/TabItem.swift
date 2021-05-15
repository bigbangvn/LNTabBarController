//
//  TabItem.swift
//  LNTabBarController
//
//  Created by Bang Nguyen on 23/3/21.
//

import UIKit

public struct TabItem {
    private let displayTitle: String?
    private let icon: UIImage?
    let viewController: UIViewController
    
    public init(viewController: UIViewController,
                displayTitle: String? = nil,
                icon: UIImage? = nil) {
        self.viewController = viewController
        self.displayTitle = displayTitle
        self.icon = icon
    }
    
    public func anyTitle() -> String? {
        return viewController.title ?? displayTitle
    }
    
    public func anyIcon() -> UIImage? {
        return viewController.tabBarItem.image ?? icon
    }
}
