//
//  DevEventTableViewCell.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import UIKit
import RxSwift

class DevEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var roundedBackgroundView: UIView!
    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!
    
    var shadowLayer: CAShapeLayer?
    var gestureDisposable = SingleAssignmentDisposable()
    
    private var shadowColor: UIColor = {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return .white
        } else {
            return .black.withAlphaComponent(0.5)
        }
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundedBackgroundView.makeCornerRounded(radius: 15)
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        roundedBackgroundView.layer.cornerRadius = 20
        roundedBackgroundView.layer.shadowOpacity = 0.25
        roundedBackgroundView.layer.shadowColor = shadowColor.cgColor
        roundedBackgroundView.layer.shadowRadius = 50
        roundedBackgroundView.layer.masksToBounds = false
    }
    
    override func prepareForReuse() {
        hostLabel.text = ""
        dateLabel.text = ""
        favoriteImageView.isHidden = true
        gestureDisposable.dispose()
        gestureDisposable = SingleAssignmentDisposable()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateWith(event: Event, setFavoriteImageViewHidden: Bool? = nil) {
        titleLabel.text = event.name
        
        if let detail = event.detail {
            hostLabel.text = detail.host
            dateLabel.text = "\(detail.eventPeriodName ?? ""): \(detail.duration ?? "")"
        }
        
        if let setFavoriteImageViewHidden = setFavoriteImageViewHidden {
            favoriteImageView.isHidden = setFavoriteImageViewHidden
        } else {
            favoriteImageView.isHidden = !event.isFavorite
        }
    }
    
    func updateUIForFavorite() {
        titleTrailingConstraint.constant = 20
    }
}
