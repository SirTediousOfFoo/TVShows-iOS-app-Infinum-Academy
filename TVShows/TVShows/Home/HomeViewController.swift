//
//  HomeViewController.swift
//  TVShows
//
//  Created by Infinum on 15/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    //MARK: - Properties
    
    var userData: LoginData? = nil
    
    //MARK: - Outlets
    
    @IBOutlet weak var myLabel: UILabel!
    
    //MARK: - Lifetime functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userData = userData {
            myLabel.text = "\(userData.token)"
        }
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
