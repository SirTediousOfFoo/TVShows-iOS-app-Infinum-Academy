//
//  LoginViewController.swift
//  TVShows
//
//  Created by Infinum on 05/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController {

    //MARK :- Outlets
    
    @IBOutlet weak var rememberMeCheckboxButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    //MARK :- Properties
    
    var rememberMeIsSelected: Bool = false
    
    //MARK :- Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        logInButton.layer.cornerRadius = 10
    }
    
    //MARK :- Actions
    @IBAction func checkboxStateChanged() {
        if rememberMeIsSelected { //I hope this is a good way of doing these
            rememberMeCheckboxButton.setImage(UIImage(named: "ic-checkbox-empty"), for: UIControl.State.normal)
            rememberMeIsSelected = false
        }
        else{
            rememberMeCheckboxButton.setImage(UIImage(named: "ic-checkbox-filled"), for: UIControl.State.normal)
            rememberMeIsSelected = true
        }
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
