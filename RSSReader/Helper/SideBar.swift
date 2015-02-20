//
//  SideBar.swift
//  SideBarControlExample
//


import UIKit


/*
Optional protocol requirements can only be specified if your protocol is marked with the @objc attribute. Even if you are not interoperating with Objective-C, you need to mark your protocols with the @objc attribute if you want to specify optional requirements.

*/

@objc protocol SideBarDelegate{
    func sideBarDidSelectMenuButtonAtIndex(index:Int)
    optional func sideBarWillOpen()
    optional func sideBarWillClose()
}

class SideBar: NSObject, SideBarTableViewControllerDelegate {
   
    let barWidth:CGFloat = 150.0
    let sideBarTableViewTopInset:CGFloat = 64.0
    let sideBarContainerView:UIView = UIView()
    let sideBarTableViewController:SideBarTableViewController = SideBarTableViewController()
    var animator:UIDynamicAnimator!
    let origionView:UIView!
    var delegate:SideBarDelegate?
    var isSideBarOpen:Bool = false
    
    override
    init() {
        super.init()
    }
    
    
    init(sourceView:UIView, menuItems:Array<String>){
        super.init()
        origionView = sourceView
        sideBarTableViewController.tableData = menuItems
        
         setupSideBar()
        
        animator = UIDynamicAnimator(referenceView: origionView)
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        origionView.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        
        // TODO: MAYBE PLACE THAT WITHIN ORIGIN
        origionView.addGestureRecognizer(hideGestureRecognizer)
        
       
        
    }
    
    func setupSideBar(){
        sideBarContainerView.frame = CGRectMake(-barWidth-1, origionView.frame.origin.y, barWidth, origionView.frame.size.height)
        sideBarContainerView.backgroundColor = UIColor.clearColor()
        sideBarContainerView.clipsToBounds = false

        
        
        origionView.addSubview(sideBarContainerView)
        
        let blurView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
        blurView.frame = sideBarContainerView.bounds
        sideBarContainerView.addSubview(blurView)
        
        
        sideBarTableViewController.delegate = self
        sideBarTableViewController.tableView.frame = sideBarContainerView.bounds
        sideBarTableViewController.tableView.clipsToBounds = false
        sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        sideBarTableViewController.tableView.backgroundColor = UIColor.clearColor()
        sideBarTableViewController.tableView.scrollsToTop = false
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInset, 0, 0, 0)
        
        sideBarTableViewController.tableView.reloadData()
        
        sideBarContainerView.addSubview(sideBarTableViewController.tableView)
        
        
    }
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer){
        sideBarTableViewController.tableView.reloadData()
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left{
            showSideBar(false)
            delegate?.sideBarWillClose?()
        }else{
            showSideBar(true)
            delegate?.sideBarWillOpen?()
        }
    }
    
    func showSideBar(shouldOpen:Bool){
        animator.removeAllBehaviors()
        isSideBarOpen = shouldOpen
        
        let gravityX:CGFloat = (shouldOpen) ? 0.5 : -0.5
        let magnitude:CGFloat = (shouldOpen) ? 20 : -20
        var boundaryX:CGFloat = (shouldOpen) ? barWidth : -barWidth - 1.0
        
        let gravityBehavior:UIGravityBehavior = UIGravityBehavior(items: [sideBarContainerView])
        gravityBehavior.gravityDirection = CGVectorMake(gravityX, 0)
        animator.addBehavior(gravityBehavior)
        
        
        let collisionBehavior:UICollisionBehavior = UICollisionBehavior(items: [sideBarContainerView])
        collisionBehavior.addBoundaryWithIdentifier("menuBoundary", fromPoint: CGPointMake(boundaryX, 20.0),
            toPoint: CGPointMake(boundaryX, origionView.frame.size.height))
        animator.addBehavior(collisionBehavior)

        
        let pushBehavior:UIPushBehavior = UIPushBehavior(items: [sideBarContainerView], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.magnitude = magnitude
        animator.addBehavior(pushBehavior)
        
        let sideBarBehavior:UIDynamicItemBehavior = UIDynamicItemBehavior(items: [sideBarContainerView])
        sideBarBehavior.elasticity = 0.3
        animator.addBehavior(sideBarBehavior)
        
        
    }
    
    func sideBarControllerDidSelectRow(indexPath: NSIndexPath) {
        delegate?.sideBarDidSelectMenuButtonAtIndex(indexPath.row)
        showSideBar(false)
    }
    
}
