//
//  LNTabBarController.swift
//  LNTabBarController
//
//  Created by Bang Nguyen on 23/3/21.
//

import SnapKit

public final class NavigationMenuBaseController: UITabBarController {
    private var customTabBar: TabNavigationMenu!
    private let tabBarHeight: CGFloat = 44
    private let tabItems: [TabItem]
    
    public init(_ tabItems: [TabItem]) {
        self.tabItems = tabItems
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
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
        self.selectedIndex = 0
    }
    
    // Build the custom tab bar and hide default
    private func setupCustomTabBar(_ items: [TabItem]) {
        let frame = CGRect(x: tabBar.frame.origin.x, y: tabBar.frame.origin.x, width: tabBar.frame.width, height: tabBarHeight) // had to change from let frame = tabBar.frame because the default height of 49 was being passed instead of 67. The background wasn't fitting correctly so had to incrrease height by 1. Not quite sure why...
        
        // hide the tab bar
        tabBar.isHidden = true
        
        self.customTabBar = TabNavigationMenu(menuItems: items, frame: frame)
        self.customTabBar.translatesAutoresizingMaskIntoConstraints = false
        self.customTabBar.clipsToBounds = true
        self.customTabBar.itemTapped = self.changeTab
        
//        customTabBar.image = UIImage(named: "tabBarbg")
//        customTabBar.isUserInteractionEnabled = true
        // Add it to the view
        self.view.addSubview(customTabBar)
        customTabBar.snp.makeConstraints { $0.edges.equalTo(tabBar) }
    }
    
    func changeTab(tab: Int) {
        self.selectedIndex = tab
        print("selected: \(self.selectedIndex) ")
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
