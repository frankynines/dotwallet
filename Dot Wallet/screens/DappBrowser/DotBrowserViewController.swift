//
//  DappBrowserViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/7/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import WebKit



class DotBrowserViewController:UIViewController, WKNavigationDelegate, WKUIDelegate{
    
    let address = EtherWallet.account.address
    let rcpUrl = "https://mainnet.infura.io/llyrtzQ3YhkdESt2Fzrk"
    //"https://ropsten.infura.io/515c97cd80d74be4b77697ae4715d975"
    let serverChain = "116"
    
    enum Method: String {
        case getAccounts
        case signTransaction
        case signMessage
        case signPersonalMessage
        case publishTransaction
        case approveTransaction
    }
    func userAgent() -> String {
        let info = Bundle.main.infoDictionary
        let version = info!["CFBundleSHortVersionString"]
        let platform = UIDevice.current.systemVersion
        let userAgentString = "com.mydotwallet.app \(version) \(platform)"
        return userAgentString
    }
    
    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        
        var js = "window.SOFA = {config: {netVersion:116, accounts: ['"+self.address!+"'], rcpUrl: '" + self.rcpUrl + "'}}; "
        
        if let filepath = Bundle.main.path(forResource: "sofa-web3", ofType: "js") {
            do {
                js += try String(contentsOfFile: filepath)
                print("Loaded sofa.js")
            } catch {
                print("Failed to load sofa.js")
            }
        } else {
            print("Sofa.js not found in bundle")
        }
        
        var userScript: WKUserScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        
//        scriptMessageHandlersNames.forEach { handlerName in
//            configuration.userContentController.add(self, name: handlerName)
//        }
        
        configuration.userContentController.addUserScript(userScript)
        
        return configuration
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = WKWebView(frame: self.view.frame, configuration: self.webViewConfiguration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.keyboardDismissMode = .interactive
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
    
        webView.load(URLRequest(url: URL(string: "https://rarebits.io/mywallet")!))
    }
    
    private lazy var scriptMessageHandlersNames: [String] = {
        return [Method.getAccounts.rawValue,
                Method.signPersonalMessage.rawValue,
                Method.signMessage.rawValue,
                Method.signTransaction.rawValue,
                Method.publishTransaction.rawValue,
                Method.approveTransaction.rawValue]
    }()
    
    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        print (message)
//        guard let method = Method(rawValue: message.name) else { return DLog("failed \(message.name)") }
//        guard let callbackId = (message.body as? NSDictionary)?.value(forKey: "callback") as? String else { return DLog("missing callback id") }
//
//        switch method {
//        case .getAccounts:
//            let payload = "{\\\"error\\\": null, \\\"result\\\": [\\\"" + Cereal.shared.paymentAddress + "\\\"]}"
//            jsCallback(callbackId: callbackId, payload: payload)
//        case .signPersonalMessage:
//            signPersonalMessage(from: message, callbackId: callbackId)
//        case .signMessage:
//            signMessage(from: message, callbackId: callbackId)
//        case .signTransaction:
//            signTransaction(from: message, callbackId: callbackId)
//        case .publishTransaction:
//            publishTransaction(from: message, callbackId: callbackId)
//        case .approveTransaction:
//            let payload = "{\\\"error\\\": null, \\\"result\\\": true}"
//            jsCallback(callbackId: callbackId, payload: payload)
//        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
}
