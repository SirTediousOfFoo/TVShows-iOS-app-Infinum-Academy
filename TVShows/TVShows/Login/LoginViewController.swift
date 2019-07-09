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
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK :- Properties
    
    private var numberOfClicks: Int = 0
    
    //MARK :- Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func configureUI() {
        button.layer.cornerRadius = 20
        activityIndicator.startAnimating()
    }
    
    //MARK :- Actions
    
    @IBAction private func buttonPressed() {
        numberOfClicks += 1
        if numberOfClicks.isMultiple(of: 2) {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
        label.text = "\(numberOfClicks)"
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
