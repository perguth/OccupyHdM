//
//  SettingsTableViewController.swift
//  occupyhdm
//
//  Created by Fabian Kugler on 12.04.16.
//  Copyright © 2016 occupyhdm. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var labelAccuracy: UILabel!
    @IBOutlet weak var sliderAccuracy: UISlider!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var sliderDistance: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let accuracy = Float(NSUserDefaults.standardUserDefaults().integerForKey("accuracy"))
        
        if accuracy != 0.0
        {
            sliderAccuracy.value = accuracy
            labelAccuracy.text = String(Int(accuracy))
        }
        else
        {
            sliderAccuracy.value = 62.5
            labelAccuracy.text = "63"
        }
        
        let distance = Float(NSUserDefaults.standardUserDefaults().integerForKey("distance"))
        
        if distance != 0.0
        {
            sliderDistance.value = distance
            labelDistance.text = String(Int(distance))
        }
        else
        {
            sliderDistance.value = 27.5
            labelDistance.text = "28"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func accuracyChanged(sender: UISlider) {
        let accuracy = Int(sender.value)
        
        self.labelAccuracy.text = String(accuracy)
        NSUserDefaults.standardUserDefaults().setInteger(accuracy, forKey: "accuracy")
    }
    
    @IBAction func distanceChanged(sender: UISlider) {
        let distance = Int(sender.value)
        
        self.labelDistance.text = String(distance)
        NSUserDefaults.standardUserDefaults().setInteger(distance, forKey: "distance")
    }
}