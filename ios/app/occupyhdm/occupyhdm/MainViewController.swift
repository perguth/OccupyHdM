//
//  MainViewController.swift
//  occupyhdm
//
//  Created by Fabian Kugler on 22.03.16.
//  Copyright © 2016 occupyhdm. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        self.mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(48.742393, 9.101142), MKCoordinateSpanMake(0.005, 0.005)), animated: false)
        self.mapView.delegate = self
        
        let jsonString = "{ \"locations\" : [ { \"name\" : \"Location 1\", \"lat\" : 48.742070, \"lon\" : 9.102263 }, { \"name\" : \"Location 2\", \"lat\" : 48.740995, \"lon\" : 9.101709 } ] }"
        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        do {
            let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            
            if let locations = jsonDictionary["locations"] as? NSArray
            {
                for location in locations
                {
                    self.mapView.addAnnotation(CustomAnnotation(
                        coordinate: CLLocationCoordinate2DMake(
                            (location["lat"] as! NSNumber).doubleValue,
                            (location["lon"] as! NSNumber).doubleValue),
                        title: location["name"] as! String)
                    )
                }
            }
        }
        catch {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logout(sender: AnyObject) {
        
    }
    
    //MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation)
        {
            return nil
        }
        
        var aView = mapView.dequeueReusableAnnotationViewWithIdentifier("pinView")
        
        if aView == nil
        {
            aView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
        }
        
        aView?.image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pin_green", ofType: "png")!)

        return aView
    }
}
