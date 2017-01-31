//
//  ACTabScrollViewController.swift
//  TestTest
//
//  Created by Булат Галиев on 29.01.17.
//  Copyright © 2017 Булат Галиев. All rights reserved.
//

import UIKit
import ACTabScrollView

class ACTabScrollViewController: UIViewController, ACTabScrollViewDelegate, ACTabScrollViewDataSource {
    @IBOutlet weak var tabScrollView: ACTabScrollView!
    
    private var contentViews: [UIView] = []
    // Each tab corresponds to a category
    var postCategories: [PostCategory] = []
    private var previousPageIndex = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure tabScrollView
        tabScrollView.defaultPage = 0
        tabScrollView.tabSectionHeight = 44
        tabScrollView.pagingEnabled = true
        tabScrollView.delegate = self
        tabScrollView.dataSource = self
        
        // Set up content section
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        for category in postCategories {
            let vc = storyboard.instantiateViewController(withIdentifier: "FeedTableViewController") as! FeedTableViewController
            vc.category = category
            addChildViewController(vc)
            contentViews.append(vc.view)
        }
        (self.childViewControllers[tabScrollView.defaultPage] as! FeedTableViewController).isCurrentlyShown = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    // MARK: ACTabScrollViewDelegate
    func tabScrollView(_ tabScrollView: ACTabScrollView, didChangePageTo index: Int) {
        (self.childViewControllers[previousPageIndex] as! FeedTableViewController).isCurrentlyShown = false
        (self.childViewControllers[index] as! FeedTableViewController).isCurrentlyShown = true
        previousPageIndex = index
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, didScrollPageTo index: Int) {
    }
    
    // MARK: ACTabScrollViewDataSource
    func numberOfPagesInTabScrollView(_ tabScrollView: ACTabScrollView) -> Int {
        return postCategories.count
    }
    
    // Configure tabs' appearance
    func tabScrollView(_ tabScrollView: ACTabScrollView, tabViewForPageAtIndex index: Int) -> UIView {
        let label = UILabel()
        label.text = postCategories[index].name.uppercased()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 77.0 / 255, green: 79.0 / 255, blue: 84.0 / 255, alpha: 1)
        label.textAlignment = .center
        
        label.sizeToFit()
        label.frame.size = CGSize(width: label.frame.size.width + 28, height: label.frame.size.height + 20)
        
        return label
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, contentViewForPageAtIndex index: Int) -> UIView {
        return contentViews[index]
    }
}
