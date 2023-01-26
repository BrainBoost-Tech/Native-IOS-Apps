//
//  GameLocationCVCell.swift
//  QuestManager
//
//  Created by office on 02/05/2022.
//

import UIKit
import SDWebImage

class GameLocationCVCell: UICollectionViewCell {

    @IBOutlet weak var btnRadioImg: UIImageView!
    @IBOutlet weak var locImg: UIImageView!{
        didSet{
            locImg.layer.cornerRadius = 8.0
        }
    }
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configCell(model: GameLocationModel){
        self.lblName.text = model.name
        if model.isSelect{
            self.btnRadioImg.image = #imageLiteral(resourceName: "FillBtn")
        }else{
            self.btnRadioImg.image = #imageLiteral(resourceName: "EmptyBtn")
        }
        locImg.sd_setImage(with: URL(string: model.url), placeholderImage: #imageLiteral(resourceName: "PlaceHolderImg"), options: .queryDiskDataSync, context: nil)
    }

}
