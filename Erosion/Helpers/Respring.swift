// Respring.swift: easy respring on all iOS versions (probably).
// Web approach developed by @neonmodder123, implemented in Swift here by @skadz108.
// 4/9/26, https://jailbreak.party

import Foundation
import SwiftUI
import UIKit
import WebKit

let respringDocument = """
<!DOCTYPE html>
<html>
    <body>
        <!--  big credit to @neonmodder123  -->
        <iframe id="frame" srcdoc="" sandbox="allow-forms allow-modals allow-orientation-lock allow-pointer-lock allow-popups allow-presentation allow-scripts"></iframe>
        <script>
            const frame = document.getElementById('frame');
            const respringScript = `
                <html>
                <body>
                    <script>
                        const container = document.createElement('div');
                        container.style.cssText = 'perspective: 1px; perspective-origin: 9999999% 9999999%;';
                        document.body.appendChild(container);
    
                        for (let i = 0; i < 500; i++) {
                            let d = document.createElement('div');
                            d.style.cssText = 'position: absolute; width: 100vw; height: 100vh; backdrop-filter: blur(100px); -webkit-backdrop-filter: blur(100px); transform: translate3d(100000px, 100000px, ' + i + 'px) rotateY(90deg);';
                            container.appendChild(d);
                        }
    
                        setInterval(() => {
                            navigator.share({ title: 'R', text: 'R'.repeat(100000) }).catch(() => {});
                            let x = new Uint8Array(1024 * 1024 * 10);
                            crypto.getRandomValues(x);
                        }, 0);
                    <\\/script>
                </body>
                </html>
            `;
    
            frame.srcdoc = respringScript;
        </script>
    </body>
</html>
"""

struct RespringView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        WKWebpagePreferences().allowsContentJavaScript = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(respringDocument, baseURL: nil)
    }
}
