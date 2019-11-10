//
//  NotificationCell.swift
//  ReminderApp
//
//  Created by Yogesh Tandel on 02/11/19.
//  Copyright © 2019 Yogesh Tandel. All rights reserved.
//

import UIKit

class TextObj {
    var text:String?
    var fontname:String?
    var fontsize:CGFloat?
    var color:UIColor?
}

class NotificationCell: UITableViewCell {
    
    
    @IBOutlet weak var btn_Checkbox: UIButton!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Subtitle: UILabel!
    @IBOutlet weak var lbl_Time: UILabel!
    @IBOutlet weak var lbl_Repeat: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //checkmark.rectangle.fill
        //checkmark.rectangle
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func UpDateCell(obj:ReminderModal){
        lbl_Title.text = obj.Title
        lbl_Subtitle.text = obj.Description
        lbl_Time.text = "Between \(ConvertDateToString(myDate: obj.StartTime ?? Date())) - \(ConvertDateToString(myDate: obj.EndTime ?? Date()))"
        
        
        let txObj1 = TextObj()
        txObj1.color = UIColor.black
        txObj1.fontname = "Helvetica-Bold"
        txObj1.fontsize = 18.0
        txObj1.text = "EVERY\n"
        
        let txObj2 = TextObj()
        txObj2.color = UIColor.black
        txObj2.fontname = "Helvetica-Bold"
        txObj2.fontsize = 15.0
        txObj2.text = obj.Frequency.name
        
        let txObj3 = TextObj()
        txObj3.color = UIColor.black
        txObj3.fontname = "Helvetica-Bold"
        txObj3.fontsize = 18.0
        txObj3.text = ""
        
        lbl_Repeat.attributedText = self.decorateTextCommon(obj1: txObj1, obj2: txObj2, obj3: txObj3)
        lbl_Repeat.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
    }
    
    func ConvertDateToString(myDate:Date)->String{
        //yyyy-MM-dd HH:mm:ss
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US")
        let myString = formatter.string(from: myDate)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "h:mm a"
        let myStringafd = formatter.string(from: yourDate!)
        return myStringafd
    }
    
}

extension UIView{
    func decorateTextCommon(obj1:TextObj, obj2:TextObj, obj3:TextObj)->NSAttributedString{
        let textAttributesOne = [NSAttributedString.Key.foregroundColor: obj1.color, NSAttributedString.Key.font: UIFont(name: obj1.fontname ?? "Poppins-Regular", size: obj1.fontsize ?? 14.0)!]
        let textAttributesTwo = [NSAttributedString.Key.foregroundColor: obj2.color, NSAttributedString.Key.font: UIFont(name: obj2.fontname ?? "Poppins-Regular", size: obj2.fontsize ?? 14.0)!]
        let textAttributesThree = [NSAttributedString.Key.foregroundColor: obj3.color, NSAttributedString.Key.font: UIFont(name: obj3.fontname ?? "Poppins-Regular", size: obj3.fontsize ?? 14.0)!]
        
        let textPartOne = NSMutableAttributedString(string: obj1.text ?? "", attributes: textAttributesOne as [NSAttributedString.Key : Any])
        let textPartTwo = NSMutableAttributedString(string: obj2.text ?? "", attributes: textAttributesTwo as [NSAttributedString.Key : Any])
        let textPartThree = NSMutableAttributedString(string: obj3.text ?? "", attributes: textAttributesThree as [NSAttributedString.Key : Any])
        
        let textCombination = NSMutableAttributedString()
        textCombination.append(textPartOne)
        textCombination.append(textPartTwo)
        textCombination.append(textPartThree)
        return textCombination
    }
}
