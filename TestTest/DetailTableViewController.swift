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
    @IBOutlet weak var getItButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    private var redirectUrl: String!
    
    var post: Post?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show post data
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
        // Configure upvotes button appearance
        upvotesButton.backgroundColor = .white
        upvotesButton.layer.cornerRadius = 2
        upvotesButton.layer.borderWidth = 1
        upvotesButton.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        // Configure getIt button appearance
        getItButton.layer.cornerRadius = 2
        getItButton.layer.borderWidth = 1
        getItButton.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        // Configure tableView appearance
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 220
        // Hide bottom empty cells
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Fixed height for image
        if indexPath.row == 0 {
            return 220
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    // Opens post url in safari controller
    @IBAction func showItButtonPressed(_ sender: Any) {
        if let url = URL(string: redirectUrl) {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            present(vc, animated: true)
        }
    }
    
}
