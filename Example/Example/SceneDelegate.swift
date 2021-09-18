//
//  SceneDelegate.swift
//  Example
//
//  Created by Bang Nguyen on 22/3/21.
//

import LNTabBarController

extension UIColor {
    
    static func colorFromRGBHexValue(_ rgbValue: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let fgrColor = UIColor.colorFromRGBHexValue(0x00AAC8)
    let bgrColor = UIColor.colorFromRGBHexValue(0xEFFDFF)
    let normalColor = UIColor.colorFromRGBHexValue(0xBEBEBE)

    private func setupNav() -> UIViewController {
        let items = [
            TabItem(viewController: HomeViewController(), displayTitle: "Talk", icon: #imageLiteral(resourceName: "talks.png"), selectedIcon: #imageLiteral(resourceName: "talks-fill.png")),
            TabItem(viewController: CalenderViewController(), displayTitle: "Chat", icon: #imageLiteral(resourceName: "chats.png"), selectedIcon: #imageLiteral(resourceName: "chat-fill.png")),
            TabItem(viewController: FriendsViewController(), displayTitle: "Newsfeed", icon: #imageLiteral(resourceName: "newsfeed.png"), selectedIcon: #imageLiteral(resourceName: "newsfeed-fill.png")),
            TabItem(viewController: ProfileViewController(), displayTitle: "Learn", icon: #imageLiteral(resourceName: "learn.png"), selectedIcon: #imageLiteral(resourceName: "learn-fill.png"))
        ]
        let style = NavMenuStyle(normalBgrColor: nil,
                                 normalFgrColor: normalColor,
                                 highlightBgrColor: bgrColor,
                                 highlightFgrColor: fgrColor,
                                 dotColor: .red)
        let vc = NavigationMenuBaseController(items, style: style)
        vc.tabChange = { (prev, new) in
            print("Tab change: \(prev) \(new)")
        }
        vc.showDot(tab: 2, showDot: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            vc.changeTab(tab: 2)
        }
        return vc
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }  
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = setupNav()
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
class CalenderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
}
class FriendsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
}
class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .brown
    }
}
