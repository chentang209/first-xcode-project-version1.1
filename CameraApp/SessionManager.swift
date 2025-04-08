import UIKit
import Foundation
import Parse

class SessionManager {
    static let shared = SessionManager()
    
    private var idleTimer: Timer?
    private let timeoutDuration: TimeInterval = 30 // 半分钟无操作
    private var isLogoutAlertShowing = false
    
    func startMonitoring() {
        print("SessionManager: 开始监控用户活动")
        resetTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(resetTimer), name: .userDidInteract, object: nil)
        print("SessionManager: 已添加.userDidInteract通知观察者")
    }
    
    func stopMonitoring() {
        idleTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func resetTimer() {
        print("SessionManager: 重置计时器")
        idleTimer?.invalidate()
        print("SessionManager: 当前计时器状态: \(idleTimer?.isValid == true ? "运行中" : "已停止")")
        idleTimer = Timer.scheduledTimer(withTimeInterval: timeoutDuration, repeats: false) { [weak self] _ in
            print("SessionManager: 计时器触发，显示登出确认")
            self?.showLogoutConfirmation()
        }
        print("SessionManager: 新计时器已创建，将在\(timeoutDuration)秒后触发")
    }
    
    private func showLogoutConfirmation() {
        print("SessionManager: 准备显示登出确认对话框")
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
    static let userDidInteract = Notification.Name("userDidInteract")
}

// 获取顶层ViewController
extension UIApplication {
    func topViewController() -> UIViewController? {
        guard let window = windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }
        return rootViewController.visibleViewController()
    }
}

extension UIViewController {
    func visibleViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.visibleViewController()
        }
        return self
    }
}
