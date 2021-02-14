//
//  MovementDetailViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 14/02/2021.
//

import UIKit

class MovementDetailViewController: UIViewController {

    var mov: MovementsModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(mov?.toJSON())
    }
    



}
