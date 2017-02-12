//
//  DetailedBusinessViewController.swift
//  Yelp
//
//  Created by Yinrong Liang on 2/11/17.
//  Copyright © 2017 Yinrong Liang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AFNetworking

class DetailedBusinessViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var business: Business!
    var locationManager : CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //mapview setup
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        
        photoView.setImageWith(business.imageURL!)
        titleLabel.text = business.name!
        
        addAnnotationAtAddress(address: business.address!, title: business.name!)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAnnotationAtAddress(address: String, title: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count != 0 {
                    let coordinate = placemarks.first!.location!
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate.coordinate
                    annotation.title = title
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            mapView.setRegion(region, animated: false)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
