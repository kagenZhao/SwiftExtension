//
//  ViewController.swift
//  SwiftExtensionsExample
//
//  Created by 赵国庆 on 2017/5/15.
//  Copyright © 2017年 kagenZhao. All rights reserved.
//

import UIKit
import SwiftExtensions
import RxCocoa
import RxSwift
import ReactiveCocoa

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    var disposeBag = DisposeBag()
    let subject = RACSubject()
    let variable = Variable("111")
    let variable2 = Variable("bbb")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

//        subject.bind(to: variable)
//        
//        subject.subscribeNext { (value) in
//            print("subject ---- \(value)")
//        }
//        
//        variable.asObservable().subscribe(onNext: { (value) in
//            print("var1 ---- \(value)")
//        })
//        
//        variable2.asObservable().subscribe(onNext: {value in
//            print("var2 ---- \(value)")
//            
//        })
//        let s: Observable<String> = subject.replay().brige()
//            s.subscribe(onNext: { (str: String) in
//            print("bridge 1---- \(str)")
//        })
//        
//        s.subscribe(onNext: { (str: String) in
//            print("bridge 2---- \(str)")
//        })
//        s.subscribe(onNext: { (str: String) in
//            print("bridge 3---- \(str)")
//        })
//        s.subscribe(onNext: { (str: String) in
//            print("bridge 4---- \(str)")
//        })
        
        
        let some : String?? = nil
        let some2: String?? = .some(nil)
        let c = (some ?? "inner") ?? "outer"
        let d = (some2 ?? "inner") ?? "outer"
        
        print(c)
        print(d)
        
    }
    
    @IBAction func action1(_ sender: Any) {
        
        
        
//        variable2.value = "赵国庆"
    }
    
    @IBAction func action2(_ sender: Any) {
//         variable.value = 
    }
    
    
}

