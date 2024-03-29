//
//  EpisodeCell.swift
//  TVShows
//
//  Created by Infinum on 20/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {

    //MARK: - Outlets
    
    @IBOutlet private weak var episodeNumberLabel: UILabel!
    @IBOutlet private weak var episodeNameLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        episodeNumberLabel.text = nil
        episodeNameLabel.text = nil
    }
}

// MARK: - Configure

extension EpisodeCell {
    func configure(with item: Episode) {
        episodeNumberLabel.text = ("S\(item.season) E\(item.episodeNumber)")
        episodeNameLabel.text = item.title
    }
}
