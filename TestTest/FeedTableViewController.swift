//
//  FeedTableViewController.swift
//  TestTest
//
//  Created by Булат Галиев on 28.01.17.
//  Copyright © 2017 Булат Галиев. All rights reserved.
//

import UIKit
import UserNotifications

class FeedTableViewController: UITableViewController {
    private var postSections = [[Post]]()
    private var previousDaysShown = 0
    var category: PostCategory!
    var isCurrentlyShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl?.addTarget(self, action: #selector(FeedTableViewController.refresh), for: UIControlEvents.valueChanged)
        loadPreviousDay()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Loads posts of 'previousDaysShown' days ago
     */
    func loadPreviousDay() {
        ResponseParser.sharedInstance.getPosts(completion: { (posts: [Post], error: Error?) -> () in
            // Show user error
            guard error == nil else {
                if let localizedDescription = error?.localizedDescription {
                    let alertController = UIAlertController(title: "Error getting posts", message: "\(localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            // If no posts were created the day requested, ask for the posts for the previous day
            if posts.isEmpty {
                self.previousDaysShown += 1
                self.loadPreviousDay()
            } else {
                var mustSendNotification = false
                var newPosts: [Post]!
                // If posts for the day were loaded previously
                if self.postSections.count > self.previousDaysShown {
                    // If new posts appeared, return them and send a notification
                    if self.previousDaysShown == 0 {
                        mustSendNotification = true
                        newPosts = self.subtract(oldQueryPosts: self.postSections[0], newQueryPosts: posts)
                    }
                    self.postSections[self.previousDaysShown] = posts
                } else {
                    self.postSections.append(posts)
                }
                self.tableView.reloadData()
                // If new posts appeared, application is in background state and this controller is shown to user, send notification
                if mustSendNotification && UIApplication.shared.applicationState == .background && self.isCurrentlyShown {
                    self.sendNotification(newPosts: newPosts!)
                }
                self.previousDaysShown += 1
            }
        }, category: category, days_ago: previousDaysShown)
        
    }
    
    /**
     Sends notification about new posts.
     
     - Parameter newPosts: new posts received during last update
     - If newPosts contains one post, the description is shown
     - If newPosts contains several posts, the number and the category are shown
     */
    private func sendNotification(newPosts: [Post]) {
        guard newPosts.count > 0 else {
            return
        }
        let content = UNMutableNotificationContent()
        if newPosts.count == 1 {
            content.title = "Check out \(newPosts[0].name)!"
            content.body = newPosts[0].tagline
        } else {
            content.title = "Check out \(newPosts.count) new \(category.name.lowercased()) posts!"
        }
        content.sound = UNNotificationSound.default()
        let identifier = "UYLLocalNotification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let unwrappedError = error {
                print("Error sending notification \(unwrappedError.localizedDescription)")
            } else {
                print("Notification was sent successfully")
            }
        })
    }
    
    /**
     Sends notification about new posts.
     
     - Parameter newPosts: new posts received during last update
     - If newPosts contains one post, the description is shown
     - If newPosts contains several posts, the number and the category are shown
     */
    private func subtract(oldQueryPosts:[Post], newQueryPosts:[Post]) -> [Post] {
        var newPosts = [Post]()
        // Comparing all elements in the arrays just in case some post was deleted. Slow but reliable.
        for newQueryPost in newQueryPosts {
            var postIsNew = true
            for oldQueryPost in oldQueryPosts {
                if newQueryPost == oldQueryPost {
                    postIsNew = true
                    break
                }
            }
            if postIsNew {
                newPosts.append(newQueryPost)
            }
        }
        return newPosts
    }
    
    /**
     Updates tableView's content on push
     */
    func refresh(sender:AnyObject) {
        self.previousDaysShown = 0
        refreshBegin(refreshEnd: {() -> () in
            self.refreshControl?.endRefreshing()
        })
    }
    
    private func refreshBegin(refreshEnd:@escaping () -> ()) {
        DispatchQueue.global().async {
            self.loadPreviousDay()
            sleep(2)
            
            DispatchQueue.main.async {
                refreshEnd()
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
        if (indexPath.section == postSections.count - 1 && indexPath.row == postSections[indexPath.section].count - 1) {
            self.loadPreviousDay()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard postSections.count > section, postSections[section].count > 0 else {
            return nil
        }
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25 ))
        label.backgroundColor = .groupTableViewBackground
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = postSections[section][0].formattedDate
        label.textColor = UIColor(red: 77.0 / 255, green: 79.0 / 255, blue: 84.0 / 255, alpha: 1)
        label.textAlignment = .center
        
        return label
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard postSections.count > section, postSections[section].count > 0 else {
            return nil
        }
        return postSections[section][0].formattedDate
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

