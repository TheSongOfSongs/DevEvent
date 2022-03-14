//
//  DevEventTableViewCell.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import UIKit

class DevEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var roundedBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundedBackgroundView.makeCornerRounded(radius: 15)
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        favoriteImageView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
