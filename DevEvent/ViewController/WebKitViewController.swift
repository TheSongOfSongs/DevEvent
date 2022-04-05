//
//  WebKitViewController.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/07.
//

import UIKit
import WebKit


class WebKitViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    static var defaultFileName: String = "Main"
    
    private var webView: WKWebView?
    var url: URL?
    var coordinator: WebKitCoordinator!
    var subView: UIView = UIView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let origin = CGPoint(x: 0, y: closeButton.frame.maxY)
        let frame = CGSize(width: view.frame.width,
                           height: view.frame.height - closeButton.frame.maxY)
        subView.frame = view.bounds
        webView?.frame = CGRect(origin: origin,
                                size: frame)
    }
    
    func loadWebView() {
        webView = WKWebView(frame: .zero)

        guard let webView = webView,
              let url = url else {
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
        webView.uiDelegate = self
        webView.navigationDelegate = self

        view.insertSubview(webView, belowSubview: closeButton)
    }
    
    @IBAction func close(_ sender: UIButton) {
        coordinator.dismiss()
    }
}

extension WebKitViewController: WKUIDelegate, WKNavigationDelegate   {
    /// WKNavigationDelegate 중복적으로 리로드되는 것 방지
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
}
