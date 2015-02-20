//
//  FeedTableViewController.swift
//  RSSReader
//
//  Created by Ziyang Tan on 2/19/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController, MWFeedParserDelegate, SideBarDelegate {
    
    var feedItems = [MWFeedItem]()
    var sidebar = SideBar()
    var savedFeeds = [Feed]()
    var feedNames = [String]()
    
    func request(urlString:String?) {
        if urlString == nil {
            let url = NSURL(string:"http://feeds.nytimes.com/nyt/rss/Technology")
            let feedParser = MWFeedParser(feedURL: url)
            feedParser.delegate = self
            feedParser.parse()
        } else {
            let url = NSURL(string:urlString!)
            let feedParser = MWFeedParser(feedURL: url)
            feedParser.delegate = self
            feedParser.parse()
        }
      
    }
    
    func loadSavedFeeds() {
        savedFeeds = [Feed]()
        feedNames = [String]()
        
        feedNames.append("Add Feed")
        
        let moc = SwiftCoreDataHelper.managedObjectContext()
        
        let results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Feed), withPredicate: nil, managedObjectContext: moc)
        
        if results.count > 0 {
            for feed in results {
                let f = feed as Feed
                savedFeeds.append(f)
                feedNames.append(f.name)
            }
        }
        
        sidebar = SideBar(sourceView: self.navigationController!.view, menuItems: feedNames)
        sidebar.delegate = self
    }
    
    //MARK: - FEED PARSER DELEGATE
    
    func feedParserDidStart(parser: MWFeedParser!) {
        feedItems = [MWFeedItem]()
    }
    
    func feedParserDidFinish(parser: MWFeedParser!) {
        self.tableView.reloadData()
    }
    
    func feedParser(parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
        println(info)
        self.title = info.title
    }
    
    func feedParser(parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        feedItems.append(item)
    }
    
    //MARK: - SIDEBAR DELEGATE
    func sideBarDidSelectMenuButtonAtIndex(index: Int) {
        if index == 0 { // ADD FEED BUTTON
            let alert = UIAlertController(title: "Add new feed", message: "Enter feed name and URL", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler({ (textField:UITextField!) -> Void in
                textField.placeholder = "Feed name"
            })
            
            alert.addTextFieldWithConfigurationHandler({ (textField:UITextField!) -> Void in
                textField.placeholder = "Feed URL"
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { (alertAction:UIAlertAction!) -> Void in
                let textFields = alert.textFields
                
                let feedNameTextField = textFields?.first as UITextField
                let feedURLTextField = textFields?.last as UITextField
                
                if feedNameTextField.text != "" && feedURLTextField.text != "" {
                    let moc = SwiftCoreDataHelper.managedObjectContext()
                    
                    let feed = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Feed), managedObjectConect: moc) as Feed
                    
                    feed.name = feedNameTextField.text
                    feed.url = feedURLTextField.text
                    
                    SwiftCoreDataHelper.saveManagedObjectContext(moc)
                    
                    self.loadSavedFeeds()
                }
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let moc = SwiftCoreDataHelper.managedObjectContext()
            
            let selectedFeed = moc.existingObjectWithID(savedFeeds[index - 1].objectID, error: nil) as Feed
            
            request(selectedFeed.url)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedFeeds()
      
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        request(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return feedItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as FeedTableViewCell
        
        cell.itemImageView.image = UIImage(named: "placeholder")
        
        let item = feedItems[indexPath.row] as MWFeedItem?
        cell.itemAuthorLabel.text = item?.author
        cell.itemTitleLabel.text = item?.title
        
        if item?.content != nil {
            
            let htmlContent = item!.content as NSString
            var imageSource = ""
            
            let rangeOfString = NSMakeRange(0, htmlContent.length)
            let regex = NSRegularExpression(pattern: "(<img.*?src=\")(.*?)(\".*?>)", options: nil, error: nil)
            
            if htmlContent.length > 0 {
                let match = regex?.firstMatchInString(htmlContent, options: nil, range: rangeOfString)
                
                if match != nil {
                    let imageURL = htmlContent.substringWithRange(match!.rangeAtIndex(2)) as NSString
                    print(imageURL)
                    
                    if NSString(string: imageURL.lowercaseString).rangeOfString("feedburner").location == NSNotFound {
                        imageSource = imageURL
                    }
                    
                }
            }
            
            if imageSource != "" {
                cell.itemImageView.setImageWithURL(NSURL(string:imageSource), placeholderImage: UIImage(named:"placeholder"))
            } else {
                cell.itemImageView.image = UIImage(named:"placeholder")
            }
            
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = feedItems[indexPath.row] as MWFeedItem
        
        let webBrowser = KINWebBrowserViewController()
        let url = NSURL(string: item.link)
        
        webBrowser.loadURL(url)
        
        self.navigationController?.pushViewController(webBrowser, animated: true)
    }
}
