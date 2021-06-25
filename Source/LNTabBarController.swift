//
//  LNTabBarController.swift
//  LNTabBarController
//
//  Created by Bang Nguyen on 23/3/21.
//

import SnapKit

public struct NavMenuStyle {
    public init(normalBgrColor: UIColor?,
                normalFgrColor: UIColor?,
                highlightBgrColor: UIColor?,
                highlightFgrColor: UIColor?) {
        self.normalBgrColor = normalBgrColor
        self.normalFgrColor = normalFgrColor
        self.highlightBgrColor = highlightBgrColor
        self.highlightFgrColor = highlightFgrColor
    }
    
    let normalBgrColor: UIColor?
    let normalFgrColor: UIColor?
    let highlightBgrColor: UIColor?
    let highlightFgrColor: UIColor?
}

open class NavigationMenuBaseController: UITabBarController {
    public private(set) var customTabBar: UIView!
    private let tabItems: [TabItem]
    private let initialIndex: Int
    private let style: NavMenuStyle
    public var tabChange: ((_ prevTab: Int, _ currentTab: Int) -> Void)?
    
    public init(_ tabItems: [TabItem], style: NavMenuStyle, initialIndex: Int = 0) {
        self.tabItems = tabItems
        self.style = style
        self.initialIndex = initialIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTabBar()
        delegate = self
    }
    
    private func loadTabBar() {
        self.setupCustomTabBar(tabItems)
        self.viewControllers = tabItems.map { $0.viewController }
        self.selectedIndex = initialIndex
    }
    
    private var observation: NSKeyValueObservation?
    
    private func hideDefaultTabBar() {
        // Removing the upper border of the UITabBar.
        //
        // Note: Don't use `tabBar.clipsToBounds = true` if you want
        // to add a custom shadow to the `tabBar`!
        //
        if #available(iOS 13, *) {
            // iOS 13:
            let appearance = tabBar.standardAppearance
            appearance.configureWithOpaqueBackground()
            appearance.shadowImage = nil
            appearance.shadowColor = nil
            tabBar.standardAppearance = appearance
        } else {
            // iOS 12 and below:
            tabBar.shadowImage = UIImage()
            tabBar.backgroundImage = UIImage()
        }
    }
    
    // Build the custom tab bar and hide default
    private func setupCustomTabBar(_ items: [TabItem]) {
        // hide the tab bar
        //tabBar.isHidden = true // Affect UICollectionViewController bottom inset
        //tabBar.alpha = 0
        hideDefaultTabBar()
        let newTabBar = TabNavigationMenu(menuItems: items,
                                          frame: tabBar.frame,
                                          initialIndex: initialIndex,
                                          style: style)
        newTabBar.itemTapped = didChangeTab
        //newTabBar.image = UIImage(named: "tabBarbg")
        //newTabBar.isUserInteractionEnabled = true
        
        // Add it to the view
        tabBar.addSubview(newTabBar)
        newTabBar.frame = tabBar.bounds
        customTabBar = newTabBar
        
        // Need to use this to manually set frame -> fix case hidesBottomBarWhenPushed
        // if use view.addSubview(newTabBar) and constraint frame to tabBar
        // Inside the UITabBarController, tabBar can have change that break our constraints
        observation = observe(\.self.tabBar.frame, options: [.new]) { (obj, change) in
            guard let frame = change.newValue else { return }
            
            obj.customTabBar.frame = obj.tabBar.bounds
            obj.customTabBar.isHidden = obj.tabBar.isHidden
            obj.tabBar.bringSubviewToFront(obj.customTabBar)
            print("Tab bar frame: \(frame) Hidden: \(obj.tabBar.isHidden)")
        }
    }
    
    private func didChangeTab(tab: Int) {
        print("Prev tab: \(selectedIndex), selecting tab: \(tab) ")
        tabChange?(selectedIndex, tab)
        if tab != selectedIndex {
            selectedIndex = tab
        }
    }
    
    
    public func changeTab(tab: Int, animate: Bool = false) {
        guard tab != selectedIndex else { return }
        selectedIndex = tab
        (customTabBar as? TabNavigationMenu)?.activateTab(tab: tab, animate: animate)
    }
}

// code for animations with custon tab bar controller from https://stackoverflow.com/a/54774397/2166424
extension NavigationMenuBaseController: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
}

final class MyTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let viewControllers: [UIViewController]?
    private let transitionDuration: Double = 0.25

    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVC.view,
            let fromIndex = getIndex(forViewController: fromVC),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = toVC.view,
            let toIndex = getIndex(forViewController: toVC)
            else {
                transitionContext.completeTransition(false)
                return
        }

        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        fromFrameEnd.origin.x = toIndex > fromIndex ? frame.origin.x - frame.width : frame.origin.x + frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? frame.origin.x + frame.width : frame.origin.x - frame.width
        toView.frame = toFrameStart

        transitionContext.containerView.addSubview(toView)
        UIView.animate(withDuration: self.transitionDuration, animations: {
            fromView.frame = fromFrameEnd
            toView.frame = frame
        }, completion: {success in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(success)
        })
    }

    private func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        for (index, thisVC) in vcs.enumerated() {
            if thisVC == vc { return index }
        }
        return nil
    }
}
