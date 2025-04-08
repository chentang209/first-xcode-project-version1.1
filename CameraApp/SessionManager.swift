import UIKit
import Foundation

class SessionManager {
    static let shared = SessionManager()
    
    private var idleTimer: Timer?
    private let timeoutDuration: TimeInterval = 60 // 1分钟无操作
    private var isLogoutAlertShowing = false
    
    func startMonitoring() {
        resetTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(resetTimer), name: .userDidInteract, object: nil)
    }
    
    func stopMonitoring() {
        idleTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func resetTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: timeoutDuration, repeats: false) { [weak self] _ in
            self?.showLogoutConfirmation()
        }
    }
    
    private func showLogoutConfirmation() {
        guard !isLogoutAlertShowing else { return }
        
        let alert = UIAlertController(
            title: "会话即将超时",
            message: "检测到长时间无操作，请选择操作",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "继续使用", style: .default) { _ in
            self.isLogoutAlertShowing = false
            self.resetTimer()
        })
        
        alert.addAction(UIAlertAction(title: "立即登出", style: .destructive) { _ in
            self.performLogout()
        })
        
        if let topVC = UIApplication.shared.topViewController() {
            self.isLogoutAlertShowing = true
            topVC.present(alert, animated: true)
            
            
        }
    }
    
    private func performLogout() {
        PFUser.logOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: loginVC)
    }
}

// 用户交互通知
extension Notification.Name {
    static let userDidInteract = Notification.Name("UserDidInteract")
}

// 获取顶层ViewController
extension UIApplication {
    func topViewController() -> UIViewController? {
        return windows.first?.rootViewController?.visibleViewController
    }
}

extension UIViewController {
    func visibleViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presentedViewController.visibleViewController()
        }
        return self
    }
}