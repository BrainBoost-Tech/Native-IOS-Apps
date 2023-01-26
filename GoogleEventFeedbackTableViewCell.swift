//
//  GoogleEventFeedbackTableViewCell.swift
//  jaminwithus
//
//  Created by Office on 31/10/2021.
//  Copyright © 2021 Hafiz Anser. All rights reserved.
//

import UIKit
import Cosmos

class GoogleEventFeedbackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var parentView: UIView!{
        didSet{
            parentView.layer.cornerRadius = 8.0
        }
    }
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var profileImg: UIImageView!{
        didSet{
            profileImg.layer.cornerRadius = profileImg.frame.height / 2
        }
    }
    @IBOutlet weak var ratingView: CosmosView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(review: GoogleEventDetailReview){
        lblUserName.text = review.authorName
        if let userImgrUrl = review.getImageUrl() {
            profileImg.setImageWith(userImgrUrl)
        }
        ratingView.rating = review.getRating()
        lblDesc.text = review.text
    }
    
}
