//
//  MyCustomAlert.swift
//  ReminderApp
//
//  Created by Yogesh Tandel on 21/10/19.
//  Copyright © 2019 Yogesh Tandel. All rights reserved.
//

import Foundation
import UIKit

class MyCustomAlert:NSObject{
    var objAlertController:UIAlertController?
    var vcController:UIViewController?
    
    
    override init() {
        super.init()
    }
    class var sharedInstance: MyCustomAlert {
        struct Singleton {
            static let instance = MyCustomAlert()
        }
        return Singleton.instance
    }
    func ShowAlert(vc:UIViewController, myTitle:String, myMessage:String){
        vcController = vc;
        objAlertController = UIAlertController(title: myTitle, message: myMessage, preferredStyle: UIAlertController.Style.alert)
        let objAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        objAlertController!.addAction(objAction)
        vc.present(self.objAlertController!, animated: true, completion: nil)
        
        /*let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(objAlertController!, animated: true, completion: nil)*/
    }
    
    func HideAlert(){
        objAlertController!.dismiss(
            animated: true, completion: nil)
    }

}
