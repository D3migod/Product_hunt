//
//  FeedTableViewController.swift
//  TestTest
//
//  Created by Булат Галиев on 28.01.17.
//  Copyright © 2017 Булат Галиев. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController {
    var postSections = [[Post]]()
    let responseParser = ResponseParser()
    var previousDaysShown = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl?.addTarget(self, action: #selector(FeedTableViewController.refresh), for: UIControlEvents.valueChanged)
        
        if UserDefaults.standard.string(forKey: "accessToken") != nil {
            getPosts()
        } else {
            authorizeAndGetPosts()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Updates tableView. Executed after getting posts.
     */
    func completion(posts: [Post]) {
        if postSections.count > 0 {
            postSections[0] = posts
        } else {
            postSections.append(posts)
        }
        self.tableView.reloadData()
    }
    
    /**
     Loads posts of today
     */
    func getPosts() {
        responseParser.getPosts(completion: completion, days_ago: 0)
    }
    
    /**
     Gets client level token and then loads posts of today
     */
    func authorizeAndGetPosts() {
        responseParser.authorize(completion: getPosts)
    }
    
    /**
     Loads posts of previous day
     */
    func loadPreviousDay() {
        previousDaysShown += 1
        responseParser.getPosts(completion: { (posts: [Post]) -> () in
            self.postSections.append(posts)
            self.tableView.reloadData()
        }, days_ago: previousDaysShown)
    }
    
    func refresh(sender:AnyObject) {
        refreshBegin(refreshEnd: {(x:Int) -> () in
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
        })
    }
    
    func refreshBegin(refreshEnd:@escaping (Int) -> ()) {
        DispatchQueue.global().async {
            self.getPosts()
            sleep(2)
            
            DispatchQueue.main.async {
                refreshEnd(0)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return postSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postSections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedTableViewCell
        cell.post = postSections[indexPath.section][indexPath.row]
        if indexPath.section == postSections.count - 1 && indexPath.row == postSections[indexPath.section].count - 1 {
            self.loadPreviousDay()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard postSections.count > section, postSections[section].count > 0 else {
            return nil
        }
        return postSections[section][0].day
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FeedToDetailSegue" {
            let detailTableViewController = segue.destination as! DetailTableViewController
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                let post = postSections[indexPath.section][indexPath.row]
                detailTableViewController.post = post
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

