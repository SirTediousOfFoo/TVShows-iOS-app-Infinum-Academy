//
//  AddEpisodeViewController.swift
//  TVShows
//
//  Created by Infinum on 22/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit

class AddEpisodeViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var seasonEpisodePicker: UIPickerView!
    
    //MARK: - Properties
    
  //  let numbersRange: CountableClosedRange = 1...50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        // Do any additional setup after loading the view.
    }
    
    func setupDelegates() {
        seasonEpisodePicker.delegate = self
        seasonEpisodePicker.dataSource = self
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

//MARK: - Picker view setup

extension AddEpisodeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return "\(row+1)"
    }
}
