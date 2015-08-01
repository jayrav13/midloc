//
//  ViewController.swift
//  Midloc
//
//  Created by Jay Ravaliya on 7/31/15.
//  Copyright (c) 2015 JRav. All rights reserved.
//


// All import statements.
import UIKit
import CoreLocation
import Darwin
import Alamofire
import SwiftyJSON
import MessageUI

// Globally available location manager data.
var manager : CLLocationManager!

// ViewController for initial view
class InitialViewController: UIViewController, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate {
    
    // make GoogleMaps model variable available
    var gm : GoogleMaps!
    
    // Initialize variables to store all location data.
    var locationData : [Float] = [0.0, 0.0, 0.0, 0.0]
    var midpointCoordinates : [Float] = [0.0, 0.0]
    var initView : InitialView!
    
    // Execute on view load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // establish CLLocationManager, delegate to self, establish desired accuracy
        // request authorization when in use and start updating location
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        // set this view's bakgroundColor
        view.backgroundColor = UIColor.whiteColor()
        
        // add initView, set button targets
        initView = InitialView(frame: view.frame)
        view.addSubview(initView)
        initView.yourZipCodeSwitch.addTarget(self, action: "yourZipCodeSwitchPressed:", forControlEvents: UIControlEvents.ValueChanged)
        initView.searchButton.addTarget(self, action: "searchPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        initView.pickerViewButton.addTarget(self, action: "showHidePickerView:", forControlEvents: UIControlEvents.TouchUpInside)
        initView.mainInfoButton.addTarget(self, action: "infoPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        initView.mainEmailButton.addTarget(self, action: "contactUs:", forControlEvents: UIControlEvents.TouchUpInside)
        initView.gs.addTarget(self, action: "showHidePickerView:")
        
        gm = GoogleMaps()
        /*gm.googleMapsRequest([40.0, -74.0], types: "restaurant") { (swiftyJSON) -> Void in
            print(swiftyJSON)
        }*/
        gm.zipToLatitudeLongitude("07470", completion: { (data) -> Void in
            println(data)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     * Email Functions and Controllers
     */
    func contactUs(sender: AnyObject) {
        let mailComposerViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.initView.activityIndicator.alpha = 1.0
            self.initView.activityIndicator.startAnimating()
            self.presentViewController(mailComposerViewController, animated: true, completion: { () -> Void in
                
            })
        }
        else {
            self.showMailErrorMessage()
        }
    }
    
    func showMailErrorMessage() {
        let sendMailErrorAlert = UIAlertView(title: "Cannot Send Email", message: "Please check device configuration and try again. Or report the issue by emailing midlocapp@gmail.com", delegate: self, cancelButtonTitle: "Close")
        sendMailErrorAlert.show()
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["midlocapp@gmail.com"])
        mailComposerVC.setSubject("[Midloc] Here's what I think...")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.initView.activityIndicator.stopAnimating()
            self.initView.activityIndicator.alpha = 0.0
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // validate the input in the text fields, return a Boolean variable
    func validateInput(input : String) -> Bool
    {
        // if the input is an integer
        if let value = input.toInt()
        {
            // if the length of the integer is 5 digits
            // note - this is the length of the text value, not numeric value
            // to allow for 0's in the first positions
            if count(input) != 5
            {
                // display an error, return false
                displayAlert("Zip Code", message: "Please enter a five digit Zip Code.", button: "Close")
                return false
            }
                // else, return true
            else
            {
                return true
            }
        }
            // if the value is not an integer
        else
        {
            // keep in mind that if the text Current Location is in the cell, we're still ok
            if input != "Current Location"
            {
                // display error if the input cell is not a number AND is not "Current Location"
                // return false
                displayAlert("Zip Code", message: "Please enter a numeric Zip Code", button: "Close")
                return false
            }
                // else, return true
            else
            {
                return true
            }
        }
    }
    
    // custom functions
    // displayAlerts
    func displayAlert(title:String, message:String, button:String)
    {
        let alert = UIAlertView()
        alert.title = title
        alert.message = message
        alert.addButtonWithTitle(button)
        alert.show()
        
        // in this case, whenever an alert is displayed, the activity indicator needs to stop
        // running.
        initView.activityIndicator.stopAnimating()
        initView.activityIndicator.alpha = 0
        
        // stop ignoring user input attempts.
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    // determines midpoint via a very rudamentary method
    func midpoint(coordinates:[Float]) -> [Float]
    {
        var returnValue : [Float] = [0.0, 0.0]
        
        returnValue[0] = (coordinates[0] + coordinates[2]) / 2
        returnValue[1] = (coordinates[1] + coordinates[3]) / 2
        
        return returnValue
    }
    
    // Enable/disable "Current Location" feature for Your Location.
    func yourZipCodeSwitchPressed(sender: AnyObject) {
        if initView.yourZipCodeSwitch.on
        {
            initView.yourTemp = initView.yourZipCode.text
            initView.yourZipCode.text = "Current Location"
            initView.yourZipCode.enabled = false
        }
        else
        {
            initView.yourZipCode.text = initView.yourTemp
            initView.yourZipCode.enabled = true
        }
    }
    
    func searchPressed(sender: AnyObject) {
        if validateInput(initView.yourZipCode.text) && validateInput(initView.yourFriendZipCode.text) {
            println(initView.yourZipCode.text)
            println(initView.yourFriendZipCode.text)
        }
    }
    
    // hide keypad when text box is not being edited
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        
        if(initView.pickerView.frame.origin.y + initView.pickerView.frame.height == screenHeight) {
            UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                self.initView.pickerView.frame = CGRect(x: 0, y: screenHeight + 216.0, width: screenWidth, height: 216.0)
                
                }) { (myBool : Bool) -> Void in
                    
                    
            }
        }
        
        super.touchesBegan(touches, withEvent: event)
    }
    
    // animates the PickerView to select venue type
    func showHidePickerView(sender: AnyObject) {
        
        if (initView.pickerView.frame.origin.y == screenHeight + 216.0) {
            
            UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                self.initView.pickerView.frame = CGRect(x: 0, y: screenHeight - 216.0, width: screenWidth, height: 216.0)
                
                }) { (myBool : Bool) -> Void in
                    
            }
        }
        else {
            
            UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                self.initView.pickerView.frame = CGRect(x: 0, y: screenHeight + 216.0, width: screenWidth, height: 216.0)
                
                }) { (myBool : Bool) -> Void in
                    
                    
            }
        }
        
    }
    
    func infoPressed(sender:AnyObject) {
        
        var initInfoView : InitialInfoView = InitialInfoView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight*2))
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
                initInfoView.frame = self.view.frame
            
            }) { (myBool : Bool) -> Void in
                
        }
        
        view.addSubview(initInfoView)
    }
    
    
    
}
