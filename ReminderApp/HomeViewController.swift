//
//  HomeViewController.swift
//  ReminderApp
//
//  Created by Yogesh Tandel on 21/10/19.
//  Copyright © 2019 Yogesh Tandel. All rights reserved.
//

import UIKit
import UserNotifications


struct ReminderModal:Codable{
    var Title:String
    var Description:String
    var Frequency:TimeFrequencyType
    var Id:String
    var StartTime:Date?
    var EndTime:Date?
}

class HomeViewController: UIViewController, AddReminderViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var myTable: UITableView!
    
    var reminderArrObj = [ReminderModal]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerTableCells()
        
        myTable.delegate = self
        myTable.dataSource = self
        
        let defaults = UserDefaults.standard
        if let arrObj = defaults.object(forKey: "ObjectReminder") as? Data {
            let decoder = JSONDecoder()
            if let obj = try? decoder.decode([ReminderModal].self, from: arrObj) {
                print(obj.count)
                reminderArrObj = obj
                myTable.reloadData()
            }
        }
        
        
        
        
    }
    func registerTableCells(){
        myTable.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        //myTable.register(UINib(nibName: "UserNotificationCell", bundle: nil), forCellReuseIdentifier: "UserNotificationCell")
        myTable.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
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
        
        let btn_AddReminder = UIButton(type: .custom)
        btn_AddReminder.setTitle("Add", for: .normal)
        //btn_AddReminder.setImage(UIImage(named: "icon_reg_conpassword_green"), for: .normal)
        btn_AddReminder.setTitleColor(UIColor.white, for: .normal)
        btn_AddReminder.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn_AddReminder.addTarget(self, action: #selector(AddReminderClicked), for: .touchUpInside)
        let menuitem1 = UIBarButtonItem(customView: btn_AddReminder)
        self.navigationItem.setRightBarButtonItems([menuitem1], animated: true)
    }

    @objc func AddReminderClicked(sender:UIButton){
        let vc = AddReminderViewController()
         vc.delegate = self
         vc.modalPresentationStyle = .overCurrentContext
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    func didCompleteAddReminder(obj:ReminderModal) {
        print(obj)
        
        
        reminderArrObj.append(obj)
        saveReminderObjToDefaults()
        myTable.reloadData()
        
        
        let name = obj.Title
        let description = obj.Description
        /*var time = obj.DateTime ?? Date()
        let id =  obj.IdStr ?? "afsw3445Ad34astkkj"
        let fid = obj.frequencyId ?? 0
        //let fname = obj.frequencyName ?? ""*/
        
        //var time = Date()
        let id =  obj.Id
        let fid = obj.Frequency.id
        //let timeInterval = floor((time.timeIntervalSinceReferenceDate)/60)*60

        
        // build notification
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "\(name)", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "\(description)", arguments: nil)
        content.sound = UNNotificationSound.default
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber;
        content.categoryIdentifier = "com.qtechsoftware.ReminderApp"
        // Deliver the notification in 60 seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: TimeInterval(fid*60), repeats: true)
        let request = UNNotificationRequest.init(identifier: "\(id)", content: content, trigger: trigger)

        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request)
       
    }
    
    func saveReminderObjToDefaults(){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(reminderArrObj) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "ObjectReminder")
        }
        print("Object Saved")
    }
    
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = reminderArrObj.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*let cell = myTable.dequeueReusableCell(withIdentifier: "DefaultCell")!
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = reminderArrObj[indexPath.row].Title
        
        cell.textLabel?.textColor = UIColor.black
        cell.selectionStyle = .none
        return cell*/
        let cell = myTable.dequeueReusableCell(withIdentifier: "NotificationCell") as? NotificationCell
        cell?.UpDateCell(obj:reminderArrObj[indexPath.row])
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            //Code I want to do here
            print("Deleted")
            self.DeleteNotificationWithID(index:indexPath.row)
            //UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["com.qtechsoftware.ReminderApp"])
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        return swipeActions
    }

    
    func DeleteNotificationWithID(index:Int){
        print(index)
        let count = reminderArrObj.count
        if count > 0{
            let identifier = reminderArrObj[index].Id
            for i in 0..<count{
                if reminderArrObj[i].Id == identifier{
                    reminderArrObj.remove(at: i)
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
                    saveReminderObjToDefaults()
                    break
                }
            }
            myTable.reloadData()
        }
    }
}
