//
//  WKNavigationDelegate.swift
//
//  Created by Jiwon Nam on 2021/03/22.
//

import UIKit
import WebKit

extension JWWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        loadingIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            debugPrint("URL is nil")
            return
        }
        let urlString = String(describing: url.absoluteString)
        debugPrint("Decoded URL: \(urlString)")
        // if scheme
        if !(url.scheme ?? "").contains("http") &&  UIApplication.shared.canOpenURL(url) {
            loadingIndicator.stopAnimating()
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
        
        if urlString.hasPrefix("http:") {
            let validUrlString = urlString.replacingOccurrences(of: "http:", with: "https:")
            webView.load(URLRequest(url: URL(string: validUrlString)!))
        }
        
        if urlString == "call://close" {
            self.dismiss(animated: true, completion: nil)
            decisionHandler(.cancel)
            return
        }
        else { decisionHandler(.allow) }
    }
}

extension JWWebViewController: WKUIDelegate, WKScriptMessageHandler {
    /// webview bridge delegate
    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage) {
        // using javascript function to get data
//        if message.name == "farm", let jsonString = message.body as? String {
//            guard let data = jsonString.data(using: .utf8) else { return }
//            if let identityEntity = try? JSONDecoder().decode(IdentityEntity.self, from: data) {
//                Log.log(data.JSONFormatter!)
//                delegate?.webViewAuthenticationHandler(data: identityEntity)
//            }
//        }
//        else if message.name == "setAddress", let jsonString = message.body as? String {
//            guard let data = jsonString.data(using: .utf8) else { return }
//            if let addressEntity = try? JSONDecoder().decode(AddressEntity.self, from: data) {
//                Log.log(data.JSONFormatter!)
//                delegate?.webViewAuthenticationHandler(data: addressEntity)
//
//            }
//        }
    }
    
    /// webview alert delegate
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Swift.Void) {
        debugPrint("Javascript Alert - \(String(describing: webView.url?.absoluteString))")
        
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel) { _ in
            completionHandler()
        }
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    /// webview alert confirmation or cancellation delegate
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
      let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)

      let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
        completionHandler(false)
      }

      let okAction = UIAlertAction(title: "확인", style: .default) { _ in
        completionHandler(true)
      }

      alertController.addAction(cancelAction)
      alertController.addAction(okAction)

      DispatchQueue.main.async {
        self.present(alertController, animated: true, completion: nil)
      }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // open target = "_blank"
        if let frame = navigationAction.targetFrame, frame.isMainFrame {
            return nil
        }
        webView.load(navigationAction.request)
        return nil
    }
    
}

