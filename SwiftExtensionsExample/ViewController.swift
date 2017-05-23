//
//  ViewController.swift
//  SwiftExtensionsExample
//
//  Created by 赵国庆 on 2017/5/15.
//  Copyright © 2017年 kagenZhao. All rights reserved.
//

import UIKit
import SwiftExtensions

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let attStr = "我是个链接, 不可编辑的"
        let resStr = "我是前边的文字" + " " + attStr +  " " + "我是后边的文字"
        let attStrRange = (resStr as NSString).range(of: attStr)
        let att = NSMutableAttributedString(string: resStr, attributes: nil)
        att.setAttributes([NSLinkAttributeName: URL(string: "www.baidu.com")!], range: attStrRange)
        textView.attributedText = att
        textView.delegate = self
    }
}

extension ViewController: UITextViewDelegate {
    public func textViewDidChangeSelection(_ textView: UITextView) {
        guard NSLocationInRange(textView.selectedRange.location, NSRange(location: 0, length: textView.text.characters.count)) else { return }
        var findRange = NSRange()
        var beforeRange = NSRange()
        let current = textView.attributedText.attribute(NSLinkAttributeName, at: textView.selectedRange.location, effectiveRange: &findRange)
        var before: Any?
        if NSLocationInRange(textView.selectedRange.location - 1, NSRange(location: 0, length: textView.text.characters.count)) {
            if let before = textView.attributedText.attribute(NSLinkAttributeName, at: textView.selectedRange.location - 1, effectiveRange: &beforeRange) {
                findRange = beforeRange
            }
        }
        guard current != nil || before != nil else { return }
        textView.delegate = nil
        let currentSelect = textView.selectedRange.location
        var leftRange = NSRange(location: findRange.location - 1, length: 0)
        let rightRange = NSRange(location: findRange.location + findRange.length + 1, length: 0)
        if currentSelect - leftRange.location > findRange.length / 2 {
            textView.selectedRange = rightRange
        } else {
            textView.selectedRange = leftRange
        }
        textView.delegate = self
    }
}


