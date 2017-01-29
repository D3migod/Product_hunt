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
    
    var contentViews: [UIView] = []
    var postCategories: [PostCategory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabScrollView.defaultPage = 1
        tabScrollView.tabSectionHeight = 44
        tabScrollView.pagingEnabled = true
        tabScrollView.cachedPageLimit = 3
        
        tabScrollView.delegate = self
        tabScrollView.dataSource = self
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        for category in postCategories {
            let vc = storyboard.instantiateViewController(withIdentifier: "FeedTableViewController") as! FeedTableViewController
            vc.category = category
            
            addChildViewController(vc)
            contentViews.append(vc.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, didScrollPageTo index: Int) {
    }
    
    // MARK: ACTabScrollViewDataSource
    func numberOfPagesInTabScrollView(_ tabScrollView: ACTabScrollView) -> Int {
        return postCategories.count
    }
    
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
