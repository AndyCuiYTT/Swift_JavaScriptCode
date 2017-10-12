 //
//  ViewController.swift
//  Swift_JavaScriptCode
//
//  Created by Andy on 2017/10/12.
//  Copyright © 2017年 AndyCuiYTT. All rights reserved.
//

import UIKit
import JavaScriptCore

@objc protocol JavaScriptCodeSwiftDelegate: JSExport {
    
    func printString(_ title: String);
    
    
}

@objc class JSObjcModel: NSObject, JavaScriptCodeSwiftDelegate {
    weak var jsContext: JSContext?
    
    func printString(_ title: String) {
        print(title)
        // swift 调用 JS 代码(buttonClick JS 方法名)
        let value = jsContext?.evaluateScript("buttonClick").call(withArguments: ["Hello World"])
        print(value ?? "")
    }
}




class ViewController: UIViewController {
    
    // JSContext: 代表 JS 的执行环境,通过- evaluateScript 方法就可以执行 JS 代码
    // JSValue: 封装了 JS 和 Objc 的对象类型,以及调用 JS 的 API 等
    // JSExport: 协议,遵守此协议就可以定义我们自己的协议,在协议中声明的 API 都会在 JS 暴露出来,才能调用
    
    
    
    fileprivate var jsContext: JSContext?
    @IBOutlet weak var webView: UIWebView!
    
    
//    fileprivate var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSubviews()
        self.loadHTML()
    }
    
    func setupSubviews() {
        
       
    }
    
    func loadHTML() {
//        let filePath: String = Bundle.main.path(forResource: "Index", ofType: "html")!
        let fileURL: URL = Bundle.main.url(forResource: "Index", withExtension: "html")!
        let request = URLRequest(url: fileURL)
        webView.loadRequest(request)
    }
    
    func runJavaScript() {
        // 通过 JSContext 执行 JS 代码
        let context: JSContext = JSContext()
        let jsValue: JSValue = context.evaluateScript("1+3")
        print(jsValue)
    }

}

extension ViewController: UIWebViewDelegate {
    
    
    
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let jsContext: JSContext = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext
//        jsContext.objectForKeyedSubscript("loginCallBack").call(withArguments: ["a","sss"])
        
        let model = JSObjcModel()
        model.jsContext = jsContext
        self.jsContext = jsContext
        
        // 这一步是将SwiftJavaScriptModel模型注入到JS中，在JS就可以通过WebViewJavascriptBridge调用我们暴露的方法了。
        self.jsContext?.setObject(model, forKeyedSubscript: "OCModel" as NSCopying & NSObjectProtocol)
        // 注册到本地的Html页面中
        let fileURL: URL = Bundle.main.url(forResource: "Index", withExtension: "html")!
        let _ = self.jsContext?.evaluateScript(try? String(contentsOf: fileURL, encoding: String.Encoding.utf8))
        
        self.jsContext?.exceptionHandler = { (context, exception) in
            print("exception @", exception ?? "")
            
        }
        
        
        
        
    }
    
    
}

