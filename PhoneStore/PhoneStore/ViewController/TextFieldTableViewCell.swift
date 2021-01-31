//
//  TextFieldTableViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 30/01/2021.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textFieldCell: UITextField!
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func setupTextfields(textFieldDelegate: UITextFieldDelegate,tag: Int, backColor: UIColor, placeHolder: String) {
        contentViewCell.backgroundColor = backColor
        textFieldCell.text = ""
        textFieldCell.delegate = textFieldDelegate
        textFieldCell.tag = tag
        
        titleLabel.text = placeHolder
        
    }
    
}
