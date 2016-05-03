//
//  CustomAnnotation.swift
//  occupyhdm
//
//  Created by Fabian Kugler on 22.03.16.
//  Copyright © 2016 occupyhdm. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var state: Bool
    
    init(coordinate : CLLocationCoordinate2D, title : String, subtitle : String)
    {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.state = false
    }
    
    func toggleState(state: Bool?)
    {
        if state == nil
        {
            self.state = !self.state
            return
        }
        
        self.state = state!
    }
}