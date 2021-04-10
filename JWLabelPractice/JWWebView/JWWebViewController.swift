//
//  JWWebViewController.swift
//
//  Created by Jiwon Nam on 2020/10/27.
//

import UIKit
import WebKit

//protocol OhaWebViewControllerdelegate: class {
//    func webViewAuthenticationHandler(data: Any?)
//}

class JWWebViewController: UIViewController {
    private var webViewTopConstraint: NSLayoutConstraint!
//    weak var delegate: JWWebViewControllerdelegate?
    var urlString: String?
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .large
        view.addSubview(indicator)
        return indicator
    } ()
    private lazy var webView: WKWebView = {
        // set bridge
        let contentController = WKUserContentController()
        contentController.add(self, name: "farm")
        contentController.add(self, name: "setAddress")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)
        return webView
    } ()
    
    deinit { print("delloc webview") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setConstraints()
        loadWebView()
    }
    
    /// set webview navigation bar title
    func setNavigationBarTitle(title: String) {
        self.title = title
    }
    
    @objc private func backButtonDidTapped(sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.stopLoading()
        // to prevent memory leak
//        webView.configuration.userContentController.removeScriptMessageHandler(forName: "farm")
//        webView.configuration.userContentController.removeScriptMessageHandler(forName: "setAddress")
    }
    
    private func loadWebView() {
        guard let urlString = urlString else { return }
        let validUrlString = (urlString.hasPrefix("http") ? urlString : "https://\(urlString)").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let url = URL(string: validUrlString), UIApplication.shared.canOpenURL(url) {
            let request = URLRequest(url: url,
                                     cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                     timeoutInterval: 10)
            webView.load(request)
        }
        else {
            debugPrint("fail to load web browser")
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func setConstraints() {
        webViewTopConstraint = NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}

