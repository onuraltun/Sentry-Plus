//
//  MailComposeViewController.swift
//  Sentry Plus
//
//  Created by Onur Altun on 24.04.2024.
//

import SwiftUI
import MessageUI

class MailComposeViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    static let shared = MailComposeViewController()
    let supportMail = "support@sentry-plus.com"
    let supportMailSubject = "Support Request - Sentry Plus"
    
    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([supportMail])
            mail.setSubject(supportMailSubject)
            mail.setMessageBody(getMailBody(), isHTML: false)
            
            UIApplication.shared.windows.last?.rootViewController?.present(mail, animated: true, completion: nil)
        } else {
            openMailApp()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func openMailApp(){
        let address = supportMail
        let subject = supportMailSubject
        
        // Example email body with useful info for bug reports
        let body = getMailBody()
        
        // Build the URL from its components
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = address
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        
        guard let url = components.url else {
            NSLog("Failed to create mailto URL")
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    func getDeviceType() -> String {
        return UIDevice.current.model
    }
    
    func getOsVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    func getMailBody() -> String {
        let appVersion = getAppVersion()
        let deviceType = getDeviceType()
        let osVersion = getOsVersion()
        
        let body = """
        \n\n\n\n
        App Version: \(appVersion)
        Device Type: \(deviceType)
        OS Version: \(osVersion)
        """
        
        return body
    }
}
