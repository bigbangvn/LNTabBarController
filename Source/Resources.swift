//
//  Resources.swift
//  LNTabBarController
//
//  Created by Bang Nguyen on 23/3/21.
//

import Foundation

private class EmptyClass {}

public final class Resources {
    public static func icon(_ name: String) -> UIImage? {
        let bundle = Bundle.init(for: EmptyClass.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
