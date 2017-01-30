//
//  FeedTableViewCell.swift
//  TestTest
//
//  Created by Булат Галиев on 28.01.17.
//  Copyright © 2017 Булат Галиев. All rights reserved.
//

import UIKit
import AlamofireImage

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var post: Post? {
        didSet {
            if let unwrappedPost = post {
                titleLabel.text = unwrappedPost.name
                descriptionLabel.text = unwrappedPost.tagline
                upvoteButton.setTitle("▲ \(unwrappedPost.upvotes)",for: .normal)
                if let url = URL(string: unwrappedPost.thumbnail.image_url) {
                    thumbnailImageView.af_setImage(
                        withURL: url,
                        placeholderImage: #imageLiteral(resourceName: "product_hunt_placeholder")
                    )
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Configure upvoteButton appearance
        upvoteButton.backgroundColor = .clear
        upvoteButton.layer.cornerRadius = 2
        upvoteButton.layer.borderWidth = 1
        upvoteButton.layer.borderColor = UIColor.groupTableViewBackground.cgColor
    }

}
