//
//  BaseViewController.swift
//  BluetoothDemo
//
//  Created by Dung Nguyen on 8/31/16.
//  Copyright © 2016 Dung Nguyen. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var HUD: MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// Show Dialog
    func showErrorDialogRequestError() {
        let alert = UIAlertView(title: "Error", message: "Please try another device.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func showDialogWithTitle(title:String, message:String) {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    // Show and hide HUD view
    func showHudWithString(contentStr: String) -> () {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.HUD = MBProgressHUD(view: self.view)
            self.view.addSubview(self.HUD!)
            self.HUD?.label.text = NSLocalizedString(contentStr, comment: "")
            self.HUD?.showAnimated(true)
        })
    }
    
    func hideHudLoading() -> () {
        // UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.HUD?.hideAnimated(true)
            self.HUD?.removeFromSuperview()
            self.HUD = nil
        })
    }
    
    func showHudLoadingInView(view:UIView) {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
    }
    
}
