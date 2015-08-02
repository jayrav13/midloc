//
//  LocationsTableViewController.swift
//  ParseStarterProject
//
//  Created by Jay Ravaliya on 8/2/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import SwiftyJSON

// store the current JSON data for future View Controllers

class LocationsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // tableView and two bar button items
    var tableView : UITableView!
    var mapButton : UIBarButtonItem!
    var backButton : UIBarButtonItem!
    
    var swiftyJSON : JSON!
    var locationData : [Float]!
    var midpointCoordinates : [Float]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // end ignoring any interaction with the user (begins when user presses search in ViewController)
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        // set up TableView
        tableView = UITableView(frame: self.view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // set up and add both bar buttons
        mapButton = UIBarButtonItem(title: "Map", style: UIBarButtonItemStyle.Plain, target: self, action: "mapButtonPressed:")
        self.navigationItem.rightBarButtonItem = mapButton
        
        backButton = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonPressed:")
        self.navigationItem.leftBarButtonItem = backButton
        
        // add TableView and name the ViewController
        self.view.addSubview(tableView)
        self.navigationItem.title = "Midloc"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // setting up each cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // dequeue cell and set style to Subtitle
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        // if it is open now, set the Subtitle as such and set text. if not, indicate closed.
        if count(swiftyJSON["results"][indexPath.row]["opening_hours"]["open_now"].stringValue) > 0
        {
            if swiftyJSON["results"][indexPath.row]["opening_hours"]["open_now"].stringValue == "true"
            {
                cell.detailTextLabel!.text = "Currently Open"
                cell.detailTextLabel!.textColor = UIColor(red: 53.0/255.0, green: 175.0/255.0, blue: 37.0/255.0, alpha: 1)
                
            }
            else
            {
                cell.detailTextLabel!.text = "Currently Closed"
                cell.detailTextLabel!.textColor = UIColor.redColor()
            }
        }
            // if data unavailable, indicate.
        else
        {
            cell.detailTextLabel!.text = "Hours Unavailable"
            cell.detailTextLabel!.textColor = UIColor.blackColor()
        }
        
        // add name, set font data
        cell.textLabel!.text = swiftyJSON["results"][indexPath.row]["name"].stringValue
        
        cell.textLabel!.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        cell.detailTextLabel!.font = UIFont(name: "AppleSDGothicNeo-Light", size: 12)
        
        // set background color as alternating colors
        if indexPath.row % 2 == 0
        {
            cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        }
        else
        {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        // return
        return cell
    }
    
    // when row is selected, deselect right away and push
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /*var dvc : DetailsViewController = DetailsViewController()
        dvc.currentJSON = swiftyJSON["results"][indexPath.row]
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.navigationController?.pushViewController(dvc, animated: true)*/
    }
    
    // return count and height in next two functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return swiftyJSON["results"].count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    // navigate to respective viewcontrollers (via push or present)
    func mapButtonPressed(sender: UIButton!)
    {
        /*var mvc : MapViewController = MapViewController()
        mvc.swiftyJSON = self.swiftyJSON
        mvc.locationData = self.locationData
        mvc.midpointCoordinates = self.midpointCoordinates
        
        self.navigationController?.pushViewController(mvc, animated: true)*/
    }
    
    func backButtonPressed(sender: UIButton!)
    {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
}
