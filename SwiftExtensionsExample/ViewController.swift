//
//  ViewController.swift
//  SwiftExtensionsExample
//
//  Created by Kagen Zhao on 2016/12/2.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
}


class vehicle
{
    var voice: Double  { return 10 }
    var description : String
    {
        return ("声音为：\(voice)")
    }
    func makeNoise() {
        
    }
}

class newVehicle : vehicle
{
    override var voice: Double { return 100 }
    
}
