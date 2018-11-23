//
//  ViewController.swift
//  map
//
//  Created by Ebtisam on 11/15/18.
//  Copyright © 2018 Ebtisam. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
//import Alamofire
//import SwiftyJSON
//Codable

enum Location {
    case startLocation
    case destinationLocation
}

struct State {
    let long: CLLocationDegrees
    let lat: CLLocationDegrees
}

class ViewController: UIViewController, GMSMapViewDelegate,  CLLocationManagerDelegate {
    
    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var startLocation: UITextField!
    @IBOutlet weak var destinationLocation: UITextField!
    
    
    
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        //map initiation code
        
        let camera = GMSCameraPosition.camera(withLatitude: -7.9293122, longitude: 112.5879156, zoom: 15.0)
        self.googleMaps.camera = camera
        
        self.googleMaps.delegate = self
        self.googleMaps?.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
        //self.googleMaps.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
       // self.view = googleMaps
        self.view.addSubview(googleMaps)
        
    }
    
    // function for create a marker pin on map
    
    
    //Location Manager
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.googleMaps?.animate(to: camera)
        
        self.locationManager.stopUpdatingLocation()
        
        let marker = GMSMarker()
        let latitude = (location?.coordinate.latitude)!
        let longitude = (location?.coordinate.longitude)!
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = "Current location)"
        //marker.icon = UIImage(named: "")
        marker.map = googleMaps
        
        
    }
    
    // MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMaps.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        googleMaps.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        googleMaps.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        googleMaps.isMyLocationEnabled = true
        googleMaps.selectedMarker = nil
        return false
    }
    
    
    
    
    
    //function for create direction path, from start location to desination location
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        self.googleMaps?.isMyLocationEnabled = true
        
        //var url = "\("https://maps.googleapis.com/maps/api/directions/json")?origin=\(origin)&destination=\(destination)&sensor=true&key=\("AIzaSyCSf_hGNPD1Y6hZdKw4etle9E0CB7p2oXA")"
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving")
        
        //OR if you want to use latitude and longitude for source and destination
        //let url = NSURL(string: "\("https://maps.googleapis.com/maps/api/directions/json")?origin=\("17.521100"),\("78.452854")&destination=\("15.1393932"),\("76.9214428")")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                if data != nil {
                    let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  [String:AnyObject]
                    //                        print(dic)
                    
                    let status = dic["status"] as! String
                    var routesArray:String?
                    if status == "OK" {
                        routesArray = (((dic["routes"]!as! [Any])[0] as! [String:Any])["overview_polyline"] as! [String:Any])["points"] as! String
                        //                            print("routesArray: \(String(describing: routesArray))")
                    }
                    
                    DispatchQueue.main.async {
                        let path = GMSPath.init(fromEncodedPath: routesArray!)
                        let singleLine = GMSPolyline.init(path: path)
                        singleLine.strokeWidth = 6.0
                        singleLine.strokeColor = .blue
                        singleLine.map = self.googleMaps
                            
                    }
                    
                   
                }
            } catch {
                print("Error")
            }
        }
        
        task.resume()
        
        
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        self.googleMaps?.isMyLocationEnabled = true
        
        var url = "\("https://maps.googleapis.com/maps/api/directions/json")?origin=\(origin)&destination=\(destination)&sensor=true&key=\("AIzaSyCSf_hGNPD1Y6hZdKw4etle9E0CB7p2oXA")"

       
        
        
        
        //let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCSf_hGNPD1Y6hZdKw4etle9E0CB7p2oXA"
        
        
            do{
                
                Alamofire.request(url).responseJSON { response in
                    
                    print(response.request as Any)  // original URL request
                    print(response.response as Any) // HTTP URL response
                    print(response.data as Any)     // server data
                    print(response.result as Any)   // result of response serialization
                    
                    let json = try! JSON(data: response.data!)
                    let routes =  json["routes"].arrayValue
                    
                    // print route using Polyline
                    
                    
                    
                    DispatchQueue.main.async {
                    
                    for route in routes
                    {
                        let routeOverviewPolyline = route["overview_polyline"].dictionary
                        let points = routeOverviewPolyline?["points"]?.stringValue
                        let path = GMSPath.init(fromEncodedPath: points!)
                        let polyline = GMSPolyline.init(path: path)
                        polyline.strokeWidth = 10
                        polyline.strokeColor = UIColor.red
                        polyline.map = self.googleMaps

                    }
                        }
                    
                }
                
                
                
            }catch let error as NSError{
                print("ther is an error \(error)")
            }
            
        
    }
    
    
    // when start location tap, this will open the search location
    @IBAction func openStartLocation(_ sender: UIButton) {
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .startLocation
        
        // Change text color
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    // when destination location tap, this will open the search location
    @IBAction func openDestinationLocation(_ sender: UIButton) {
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .destinationLocation
        
        // Change text color
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    
    // SHOW DIRECTION WITH BUTTON
    @IBAction func showDirection(_ sender: UIButton) {
        self.drawPath(startLocation: locationStart, endLocation: locationEnd)
        
        //let API_KEY = "AIzaSyCSf_hGNPD1Y6hZdKw4etle9E0CB7p2oXA"
        
        
        
    }
    
    
    
    
}

//  GMS Auto Complete Delegate, for autocomplete search location

extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error \(error)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        // Change map location
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16.0
        )
        
        // set coordinate to text
        
        if locationSelected == .startLocation {
            startLocation.text = "\(place.coordinate.latitude), \(place.coordinate.longitude)"
            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            
            let marker = GMSMarker()
            let latitude = place.coordinate.latitude
            let longitude = place.coordinate.longitude
            marker.position = CLLocationCoordinate2DMake(latitude, longitude)
            marker.title = "Start Point latitude:\(latitude) longitude:\(longitude)"
            //marker.icon = UIImage(named: "")
            marker.map = googleMaps
            
            
            
        } else {
            destinationLocation.text = "\(place.coordinate.latitude), \(place.coordinate.longitude)"
            locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            
            let marker = GMSMarker()
            let latitude = place.coordinate.latitude
            let longitude = place.coordinate.longitude
            marker.position = CLLocationCoordinate2DMake(latitude, longitude)
            marker.title = "End Point"
            //marker.icon = UIImage(named: "")
            marker.map = googleMaps
        }
        
        
        self.googleMaps.camera = camera
        self.dismiss(animated: true, completion: nil)
        
        
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

public extension UISearchBar {
    
    public func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    
}

