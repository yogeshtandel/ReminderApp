//
//  AddReminderViewController.swift
//  ReminderApp
//
//  Created by Yogesh Tandel on 21/10/19.
//  Copyright © 2019 Yogesh Tandel. All rights reserved.
//

import UIKit

struct TimeFrequencyType:Codable {
    let id: Int
    let name: String
}

protocol AddReminderViewControllerDelegate {
    func didCompleteAddReminder(obj: ReminderModal)
}

class AddReminderViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txf_Title: UITextField!
    @IBOutlet weak var txf_Description: UITextField!
    @IBOutlet weak var txf_Frequency: UITextField!
    @IBOutlet weak var txf_StartDateAndTime: UITextField!
    @IBOutlet weak var txf_EndDateAndTime: UITextField!
    
    @IBOutlet weak var btn_Done: UIButton!
    
    var delegate:AddReminderViewControllerDelegate!
    var datePicker:UIDatePicker?
    var singleTf: UITextField?
    var reminderTimeObj : ReminderModal?
    var isForEndTime:Bool = false
    
    let frequencyTypeArr = [
        TimeFrequencyType(id: 1, name: "1 Minute"),
        TimeFrequencyType(id: 5, name: "5 Minutes"),
        TimeFrequencyType(id: 10, name: "10 Minutes"),
        TimeFrequencyType(id: 15, name: "15 Minutes"),
        TimeFrequencyType(id: 20, name: "20 Minutes"),
        TimeFrequencyType(id: 39, name: "30 Minutes"),
        TimeFrequencyType(id: 60, name: "60 Minutes")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        txf_Title.delegate = self
        txf_Description.delegate = self
        txf_Frequency.delegate = self
        reminderTimeObj = ReminderModal(Title: "", Description: "", Frequency: TimeFrequencyType(id: 0, name: ""), Id: "", StartTime: nil, EndTime:nil)
        txf_Title.addTarget(self, action:#selector(didChangeFirstText), for: .editingChanged)
        txf_Description.addTarget(self, action:#selector(didChangeFirstText), for: .editingChanged)
        txf_StartDateAndTime.addTarget(self, action: #selector(OnClickSelectPickUpDate(sender:)), for: .editingDidBegin)
        txf_StartDateAndTime.tag = 11
        txf_EndDateAndTime.addTarget(self, action: #selector(OnClickSelectPickUpDate(sender:)), for: .editingDidBegin)
        txf_EndDateAndTime.tag = 12
        txf_Frequency.addTarget(self, action: #selector(OnClickSelectFrequency(sender:)), for: .editingDidBegin)
        btn_Done.addTarget(self, action: #selector(CompletedReminder), for: .touchUpInside)
        
        checkNotificationAuthorisation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let img = UIImage()
        navigationController?.navigationBar.shadowImage = img
        navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
        navigationController?.navigationBar.backgroundColor =  UIColor.black
        navigationController?.navigationBar.barTintColor = UIColor.black
        self.addNavButtons()
        
    }
    
    func addNavButtons() {
        let btn_back = UIButton(type: .custom)
        //btn_back.setImage(UIImage(named: "menu_close"), for: .normal)
        btn_back.setTitle("Back", for: .normal)
        btn_back.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn_back.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let menuitem1 = UIBarButtonItem(customView: btn_back)
        self.navigationItem.setLeftBarButtonItems([menuitem1], animated: true)
        
    }
    
    @objc func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
    

    @objc func OnClickSelectPickUpDate(sender:UITextField) {
        if sender.tag == 12 && reminderTimeObj?.StartTime == nil{
            MyCustomAlert.sharedInstance.ShowAlert(vc: self, myTitle: "", myMessage: "Please select Start Time")
            return
        }
        self.pickServiceDate(sender)
    }
    
    //MARK:- DATEPICKER
    func pickServiceDate(_ textField : UITextField){
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        var currentDate: Date = Date()
        let minDatecomponents: NSDateComponents = NSDateComponents()
        let maxDatecomponents: NSDateComponents = NSDateComponents()
        
        if textField.tag == 11{
            isForEndTime = false
            currentDate = Date()
            minDatecomponents.hour = 0
            maxDatecomponents.hour = 24
        }else if textField.tag == 12{
            isForEndTime = true
            currentDate = reminderTimeObj?.StartTime ?? Date()
            minDatecomponents.minute = 30
            maxDatecomponents.hour = 24
        }
        
        
        let minDate: NSDate = gregorian.date(byAdding: minDatecomponents as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        let maxDate: NSDate = gregorian.date(byAdding: maxDatecomponents as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker?.backgroundColor = UIColor.white
        self.datePicker?.datePickerMode = UIDatePicker.Mode.time
        
        //self.datePicker?.date = selDate as Date
        
        self.datePicker?.maximumDate = maxDate as Date
        self.datePicker?.minimumDate = minDate as Date
        textField.inputView = self.datePicker
        singleTf = textField
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    // MARK:- Button Done and Cancel
    @objc func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "h:mm a" //dd-MM-yyyy, HH:mm
        dateFormatter1.locale = Locale(identifier: "en_US")
        //dateFormatter1.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter1.amSymbol = "AM"
        dateFormatter1.pmSymbol = "PM"

        
        singleTf?.text = dateFormatter1.string(from: (datePicker?.date)!)
        singleTf?.resignFirstResponder()
        
        let dateStr = dateFormatter1.string(from: (datePicker?.date)!)
        //let myDateArr = dateStr.components(separatedBy: ", ")
        //print("Date -- \(myDateArr[0]) --- Time -- \(myDateArr[1])")
        if isForEndTime{
            reminderTimeObj?.EndTime = datePicker?.date
        }else{
            reminderTimeObj?.StartTime = datePicker?.date
        }
        
        
    }
    
    @objc func cancelClick() {
        singleTf?.resignFirstResponder()
    }
    
    
    //MARK:-  FREQUENCY
    @objc func OnClickSelectFrequency(sender:UITextField){
        
        self.view.endEditing(true)
        sender.resignFirstResponder()
        let alert = UIAlertController(title: "", message: "Repeat Every", preferredStyle: .actionSheet)
        
        for i in 0..<frequencyTypeArr.count{
            let mytitle = frequencyTypeArr[i].name
            let myid = frequencyTypeArr[i].id
            alert.addAction(UIAlertAction(title: mytitle, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                let fr = TimeFrequencyType(id:myid, name: mytitle)
                self.reminderTimeObj?.Frequency = fr
                self.txf_Frequency.text = mytitle
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction)in
            print("User click Cancel button")
        }))
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            // for iPAD support:
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x:self.view.bounds.width / 2.0, y:self.view.bounds.height / 2.0, width:1.0, height:1.0)
            //alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
            alert.popoverPresentationController?.permittedArrowDirections = []
            self.present(alert, animated: true, completion: nil)
        }else{
            //for iphone
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @objc func CompletedReminder(sender:UIButton){
        self.view.endEditing(true)
        let title = txf_Title.text ?? ""
        
        if title == ""{
            MyCustomAlert.sharedInstance.ShowAlert(vc: self, myTitle: "", myMessage: "Please Enter Title")
            txf_Title.becomeFirstResponder()
            return
        }else{
            reminderTimeObj?.Title = title
        }
        
        let desc = txf_Description.text ?? ""
        if desc == ""{
            MyCustomAlert.sharedInstance.ShowAlert(vc: self, myTitle: "", myMessage: "Please Enter Description")
            txf_Description.becomeFirstResponder()
            return
        }else{
            reminderTimeObj?.Description = desc
        }
        
        /*if reminderTimeObj?.DateStr == nil && reminderTimeObj?.TimeStr == nil{
            MyCustomAlert.sharedInstance.ShowAlert(vc: self, myTitle: "", myMessage: "Please Select Reminder Start Date And Time")
            return
        }*/
        
        if reminderTimeObj?.Frequency.id == 0{
            MyCustomAlert.sharedInstance.ShowAlert(vc: self, myTitle: "", myMessage: "Please Select Reminder Repeat Frequency")
            
            return
        }
        
        reminderTimeObj?.Id = randomString(length: 15)
        if let remObj = reminderTimeObj{
            delegate.didCompleteAddReminder(obj: remObj)
            dismiss(animated: true, completion: nil)
        }
    }

    @objc func didChangeFirstText(textField:UITextField) {
        if(textField.text == " "){
            textField.text = ""
        }
    }
    
    func checkNotificationAuthorisation(){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    //MARK:-  TEXTFIELD DELEGATE
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}


extension UIViewController{
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
