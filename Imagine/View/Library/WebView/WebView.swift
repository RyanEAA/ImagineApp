//
//  WebView.swift
//  Imagine
//
//  Created by Ryan Aparicio-Aparicio on 12/3/24.
//

import Foundation
import SwiftUI
import WebKit

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: String
    
    // to pass the highlighted text back to the parent view
    @Binding var highlightedText: String
    
    // handles interaction between ios and webkitview
    class Coordinator: NSObject, WKScriptMessageHandler {
        var parent: WebView
        
        init(parent: WebView) {
            self.parent = parent
        }
        
        // Handle messages received from JavaScript
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "selectionHandler", let selectedText = message.body as? String {
                print("Selected Text: \(selectedText)")
                self.parent.highlightedText = selectedText
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        // Create a custom WKWebViewConfiguration
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        // Add JavaScript to listen for text selection changes
        let jsCode = """
        document.addEventListener('selectionchange', function() {
            let selectedText = window.getSelection().toString();
            if (selectedText) {
                window.webkit.messageHandlers.selectionHandler.postMessage(selectedText);
            }
        });
        """
        let userScript = WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        
        // Add the Swift message handler
        contentController.add(context.coordinator, name: "selectionHandler")
        configuration.userContentController = contentController
        
        // Create the WKWebView with the configuration
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // Load the URL here
        if let validURL = URL(string: url) {
            webView.load(URLRequest(url: validURL))
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
//        if let validURL = URL(string: url) {
//            uiView.load(URLRequest(url: validURL))
//        }
    }
}


#Preview {
    WebView(url: "https://codewithchris.com/",
            highlightedText: .constant("Preview Selected Text"))
}
