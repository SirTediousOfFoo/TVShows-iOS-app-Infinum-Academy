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
    
    @IBOutlet private weak var showTitleLabel: UILabel!
    @IBOutlet private weak var showDescriptionLabel: UILabel!
    @IBOutlet private weak var episodeCountLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        showTitleLabel.text = nil
        showDescriptionLabel.text = nil
        episodeCountLabel.text = nil
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
