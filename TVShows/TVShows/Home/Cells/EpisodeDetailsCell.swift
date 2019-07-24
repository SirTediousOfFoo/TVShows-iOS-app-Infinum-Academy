//
//  EpisodeDetailsCell.swift
//  TVShows
//
//  Created by Infinum on 24/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit

class EpisodeDetailsCell: UITableViewCell {
    
    //MARK: - Outlets
    
    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showDescriptionLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        showTitleLabel.text = "Title missing"
        showDescriptionLabel.text = "Description missing"
        episodeCountLabel.text = "0"
    }
    
}

// MARK: - Configure

extension EpisodeDetailsCell {
    func configure(with item: ShowDetails, numOfEpisodes: Int) {
        showTitleLabel.text = item.title
        showDescriptionLabel.text = item.description
        episodeCountLabel.text = "\(numOfEpisodes)"
    }
}
