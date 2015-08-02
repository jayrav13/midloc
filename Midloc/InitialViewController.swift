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
    var gm : GoogleMaps = GoogleMaps()
    
    // Initialize variables to store all location data.
    var yourLocation : [Float] = [0.0, 0.0]
    var yourFriendLocation : [Float] = [0.0, 0.0]
    var midpointCoordinates : [Float] = [0.0, 0.0]
    var initView : InitialView!
    var queries : Int!
    
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
        initView.yourZipCodeSwitch.addTarget(self, action: "yourZipCodeSwitchPressed:", forControlEvents: UIControlEvents.ValueChanged)
        initView.searchButton.addTarget(self, action: "searchPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        initView.pickerViewButton.addTarget(self, action: "showHidePickerView:", forControlEvents: UIControlEvents.TouchUpInside)
        initView.mainInfoButton.addTarget(self, action: "infoPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        initView.mainEmailButton.addTarget(self, action: "contactUs:", forControlEvents: UIControlEvents.TouchUpInside)
        initView.gs.addTarget(self, action: "showHidePickerView:")
        view.addSubview(initView)
        
        queries = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Email Functions and Controllers
     */
    // function for email button
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
    
    // email error message if email isn't supported
    func showMailErrorMessage() {
        let sendMailErrorAlert = UIAlertView(title: "Cannot Send Email", message: "Please check device configuration and try again. Or report the issue by emailing midlocapp@gmail.com", delegate: self, cancelButtonTitle: "Close")
        sendMailErrorAlert.show()
    }
    
    // configured MailController that extends the original MailController
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["midlocapp@gmail.com"])
        mailComposerVC.setSubject("[Midloc] Here's what I think...")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    // dismisses MailController
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.initView.activityIndicator.stopAnimating()
            self.initView.activityIndicator.alpha = 0.0
        })
    }
    
    /*
     * Search Functions
     */
    
    // When search is pressed.
    func searchPressed(sender: AnyObject) {
        if validateInput(initView.yourZipCode.text) && validateInput(initView.yourFriendZipCode.text) {
            if(initView.yourZipCode.text == "Current Location") {
                yourLocation = [Float(manager.location.coordinate.latitude), Float(manager.location.coordinate.longitude)]
                self.queries = self.queries + 1
                self.segueToNextViewController()
            }
            else {
                gm.zipToLatitudeLongitude(initView.yourZipCode.text, completion: { (data) -> Void in
                    self.yourLocation[0] = Float(data["coordinates"]["latitude"].doubleValue)
                    self.yourLocation[1] = Float(data["coordinates"]["longitude"].doubleValue)
                    self.queries = self.queries + 1
                    self.segueToNextViewController()
                })
            }
            
            gm.zipToLatitudeLongitude(initView.yourFriendZipCode.text, completion: { (data) -> Void in
                self.yourFriendLocation[0] = Float(data["coordinates"]["latitude"].doubleValue)
                self.yourFriendLocation[1] = Float(data["coordinates"]["longitude"].doubleValue)
                self.queries = self.queries + 1
                self.segueToNextViewController()
            })
            
            

            
        }
        else {
            self.displayAlert("Try Again!", message: "Be sure to use \"Current Location\" or a five digit zip code.", button: "Close")
        }
    }
    
    // Segue to next ViewController
    func segueToNextViewController() {
        if self.queries == 2 {
            var midpoint : [Float] = self.midpoint(yourLocation, yourFriendCoordinates: yourFriendLocation)
            gm.googleMapsRequest(midpoint, types: initView.pickerViewData[initView.currentIndex]["value"]!, completion: { (swiftyJSON) -> Void in
                var ltvc : LocationsTableViewController = LocationsTableViewController()
                ltvc.swiftyJSON = swiftyJSON
                var navController : UINavigationController = UINavigationController(rootViewController: ltvc)
                self.presentViewController(navController, animated: true, completion: { () -> Void in
                    self.queries = 0
                    print(swiftyJSON)
                })
                
            })
            
        }
        
    }
    
    /*
     * Custom Functions
     */
    
    // changes header color (time, etc) to lighter color
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // Returns true if input appears to be valid, else will return false.
    func validateInput(input : String) -> Bool
    {
        if let value = input.toInt()
        {
            return (count(input) == 5)
        }
        else
        {
            return (input == "Current Location")
        }
    }
    
    //  display a simple alert, handle activityIndicator animation and ignoringInteraction
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
        if UIApplication.sharedApplication().isIgnoringInteractionEvents()
        {
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
    }
    
    // Determines midpoint between two coordinates.
    func midpoint(yourCoordinates:[Float], yourFriendCoordinates:[Float]) -> [Float]
    {
        var returnValue : [Float] = [0.0, 0.0]
        
        returnValue[0] = (yourCoordinates[0] + yourFriendCoordinates[0]) / 2
        returnValue[1] = (yourCoordinates[1] + yourFriendCoordinates[1]) / 2
        
        return returnValue
    }
    
    // Action when switch value changes, managing temp value
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
    
    
    
    /*
     * Hide text box and pickerView if they are visible
     */
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        view.endEditing(true)
        
        if(initView.pickerView.frame.origin.y == screenHeight - 216.0) {
            self.showHidePickerView(self)
        }
    }
    
    /*
     * Show or Hide pickerView based on current status.
     */
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
    
    /*
     * Pressed Info Button - displays info about the main controller
     */
    func infoPressed(sender:AnyObject) {
        var initInfoView : InitialInfoView = InitialInfoView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight*2))
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
                initInfoView.frame = self.view.frame
            
            }) { (myBool : Bool) -> Void in
                
        }
        view.addSubview(initInfoView)
    }
    
}
