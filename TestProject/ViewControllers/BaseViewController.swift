//
//  BaseViewController.swift
//  TestProject
//
//  Created by apple on 1/3/21.
//

import UIKit

class BaseViewController: UIViewController {

    @available(iOS 13.0, *)
    override var overrideUserInterfaceStyle: UIUserInterfaceStyle {
        get {
            return .light
        }
        set {
            super.overrideUserInterfaceStyle = newValue
        }
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

}
