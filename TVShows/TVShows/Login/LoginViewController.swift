//
//  LoginViewController.swift
//  TVShows
//
//  Created by Infinum on 05/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var numberClicks: Int = 0
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        button.layer.cornerRadius = 20
        activityIndicator.startAnimating()
        Timer.scheduledTimer(timeInterval: TimeInterval(3), target: activityIndicator!, selector: #selector(UIActivityIndicatorView.stopAnimating), userInfo: nil, repeats: false)
        // Do any additional setup after loading the view.
    }
    

    @IBAction func buttonPressed(_ sender: Any) {
        numberClicks+=1
        if numberClicks%2 == 1 {
            activityIndicator.startAnimating()
        }
        else
        {
            activityIndicator.stopAnimating()
        }
        label.text = "\(numberClicks)"
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
