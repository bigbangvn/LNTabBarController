//
//  TabItem.swift
//  LNTabBarController
//
//  Created by Bang Nguyen on 23/3/21.
//

import UIKit

public struct TabItem {
    private let displayTitle: String?
    let viewController: UIViewController
    let icon: UIImage?
    let highlightColor: UIColor?
    
    public init(displayTitle: String? = nil, viewController: UIViewController, icon: UIImage?, highlightColor: UIColor?) {
        self.displayTitle = displayTitle
        self.viewController = viewController
        self.icon = icon
        self.highlightColor = highlightColor
    }
    
    public func anyTitle() -> String? {
        return viewController.title ?? displayTitle
    }
}
