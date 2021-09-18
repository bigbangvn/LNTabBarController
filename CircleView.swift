//
//  CircleView.swift
//  LNTabBarController
//
//  Created by Bang Nguyen on 16/9/21.
//

import UIKit

final class CircleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width/2
    }
}
