//
//  StreamViewController+WebView.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 04/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

extension StreamViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // There is an issue with the fullview video feed when used in an iOS web view which means the aspect ratio is not maintained
        // and part of it is therefore cut off. By changing the style tag to use vh/vw rather than percentage, this issue is fixed.
        // I've mentioned this to Theo, and hopefully we can get this change applied directly to the website and this won't be necessary!
        let js = "document.getElementById(\"videoCanvasFullView\").setAttribute(\"style\", \"height: 100vh; width: 100vw;\")"
        _ = cameraWebView.stringByEvaluatingJavaScript(from: js)
        
        cameraLoadingView.isHidden = true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        cameraErrorLabel.text = error.localizedDescription
    }
    
}
