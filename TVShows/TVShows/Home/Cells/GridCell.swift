//
//  GridCell.swift
//  TVShows
//
//  Created by Infinum on 05/08/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit

class GridCell: UICollectionViewCell {
    
    @IBOutlet var imageHolder: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageHolder.image = nil
    }
    
    func setupUI() {
        imageHolder.layer.cornerRadius = 20
    }
    
    func configure(with item: Show) {
        let url = URL(string: "https://api.infinum.academy" + item.imageUrl)
        imageHolder.kf.setImage(with: url)
    }
}
