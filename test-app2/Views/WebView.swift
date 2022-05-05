//
//  WebView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 15.04.22.
//

import SwiftUI
import WebKit
import Foundation
import FirebaseAuth

struct WebView: UIViewRepresentable {
 
    var url: URL
    
    var completionHandler: ((Bool) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
 
    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
       
        config.setURLSchemeHandler(nil, forURLScheme: "my-custom-scheme")
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        return webView
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        webView.load(request)
        
        
    }
}

class Coordinator: NSObject, WKNavigationDelegate {
    
    var parent: WebView
    init(_ parent: WebView) {
        self.parent = parent
    }
    
    // func webview
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      //  print("response \(navigationAction.request.url)")
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
       
        if let httpResponse = navigationResponse.response as? HTTPURLResponse {
            httpResponse.allHeaderFields
//            let statusCode = httpResponse.value(forKey:   )
           //  print("httpResponse.allHeaderFields \(httpResponse.allHeaderFields)")
        }
        decisionHandler(.allow)
    }
//
    

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        

    }

    

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("yes")
    }
    

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        guard let url = webView.url, let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: {
            $0.name == "code" })?.value else {
            // print(url)
            // hide webView if it tries to go to the redirect uri
            if webView.url?.host == URL(string: AuthManager.Constants.redirectURI)?.host {
                webView.isHidden = true
                DispatchQueue.main.async {
                    self.parent.completionHandler?(false)
                }
            }
            // do nothing
            return
        }

        print("code: \(code)")
        AuthManager.shared.handleAuthorizationCodeFlow(code: code) { success in
            DispatchQueue.main.async {
                self.parent.completionHandler?(success)
            }
        }

    }
}
