//
//  EpisodeDetailsViewController.swift
//  TVShows
//
//  Created by Infinum on 31/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit
import CodableAlamofire
import PromiseKit
import Kingfisher
import KeychainAccess
import SVProgressHUD

final class EpisodeDetailsViewController: UIViewController {

    //MARK: - Properties
    
    var episode: Episode?
    var showImageUrl: String = ""
    
    //MARK: - Outlets
    
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var seasonEpisodeIndicatorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var episodeImage: UIImageView!
    
    //MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showEpisodeDetails()
        // Do any additional setup after loading the view.
    }
    
    private func showEpisodeDetails() //No need to even do API call here since all data shown is already loaded
    {
        guard let episode = episode else {
            showAlert(title: "Error", message: "Episode details are missing")
            return
        }
        
        descriptionLabel.text = episode.description
        episodeTitleLabel.text = episode.title
        seasonEpisodeIndicatorLabel.text = "S\(episode.season) E\(episode.episodeNumber)"
        
        if !episode.imageUrl.isEmpty {
            let url = URL(string: "https://api.infinum.academy" + episode.imageUrl)
            episodeImage.kf.setImage(with: url)
        }
        else if !showImageUrl.isEmpty {
            let url = URL(string: showImageUrl)
            episodeImage.kf.setImage(with: url)
        }
        else {
            episodeImage.image = UIImage(named: "ic-placeholder")
        }
    }
    
    // MARK: - Navigation

    @IBAction func navigateToComments() {
    }
    
    @IBAction func navigateBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
