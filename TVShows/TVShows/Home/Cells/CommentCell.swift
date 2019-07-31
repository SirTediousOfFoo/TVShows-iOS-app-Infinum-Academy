//
//  CommentCell.swift
//  TVShows
//
//  Created by Infinum on 31/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userLabel.text = nil
        commentLabel.text = nil
        userImage.image = nil
    }
}

extension CommentCell {
    func configure(with item: Comment, at rowNumber: Int) {
        userLabel.text = item.userEmail.components(separatedBy: "@")[0]
        commentLabel.text = item.text
       // This is one way of doing it but i really feel like the modulo operator is simpler here but I have no idea about how much cycles each operation takes so here it is.
        switch rowNumber.quotientAndRemainder(dividingBy: 3).remainder {
        case 0:
            userImage.image = UIImage(named: "img-placeholder-user1")
        case 1:
            userImage.image = UIImage(named: "img-placeholder-user2")
        case 2:
            userImage.image = UIImage(named: "img-placeholder-user3")
        default:
            userImage.image = UIImage(named: "img-placeholder-user1")
        }
       
    }
}
