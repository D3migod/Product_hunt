//
//  DetailTableViewController.swift
//  TestTest
//
//  Created by Булат Галиев on 28.01.17.
//  Copyright © 2017 Булат Галиев. All rights reserved.
//

import UIKit
import AlamofireImage
import SafariServices

class DetailTableViewController: UITableViewController {
    @IBOutlet weak var screenshotImageView: UIImageView!
    @IBOutlet weak var upvotesButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var redirectUrl: String!
    
    var post: Post?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let unwrappedPost = post {
            titleLabel.text = unwrappedPost.name
            descriptionLabel.text = unwrappedPost.tagline
            upvotesButton.setTitle("▲ \(unwrappedPost.upvotes)",for: .normal)
            if let url = URL(string: unwrappedPost.screenshot.bigImageUrl) {
                screenshotImageView.af_setImage(
                    withURL: url,
                    placeholderImage: #imageLiteral(resourceName: "product_hunt_placeholder")
                )
            }
            redirectUrl = unwrappedPost.redirect_url
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 220
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 220
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    @IBAction func showItButtonPressed(_ sender: Any) {
        if let url = URL(string: redirectUrl) {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            present(vc, animated: true)
        }
    }
    
}
