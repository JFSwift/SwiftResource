//
//  ViewController.swift
//  SwiftResource
//
//  Created by JoFox on 2022/3/26.
//

import UIKit
import ResourceExt

class ViewController: UIViewController {

    @IBOutlet weak var d: UIButton!
    @IBOutlet weak var c: UIButton!
    @IBOutlet weak var b: UIButton!
    @IBOutlet weak var a: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let imagea = UIImage.resource.loadImage(name: "module_a", bundleName: "ModuleA")
        a.setImage(imagea, for: .normal)
        b.setImage(UIImage.resource.loadImage(name: "module_b", bundleName: "ModuleB"), for: .normal)
        c.setImage(UIImage.resource.loadImage(name: "module_c", bundleName: "ModuleC"), for: .normal)
        d.setImage(UIImage.resource.loadImage(name: "module_d", bundleName: "ModuleD"), for: .normal)
    }


}

