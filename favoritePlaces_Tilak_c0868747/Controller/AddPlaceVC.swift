//
//  AddPlaceVC.swift
//  favoritePlaces_Tilak_c0868747
//
//  Created by Tilak Acharya on 2023-01-24.
//

import Foundation
import UIKit
import MapKit
import CoreData

class AddPlaceVC : UIViewController,CLLocationManagerDelegate{
    
    weak var delegate : PlaceListTVC?
    
    var locations = [MKMapItem]()
    
    @IBOutlet weak var locationBtn: UIButton!
    
    @IBOutlet weak var searchbar: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var myCurrentLocationAnnotation:MKPointAnnotation?
    
    var favPlace : FavPlace?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedContext : NSManagedObjectContext!
    
    var currentAnnotation : MKPointAnnotation = MKPointAnnotation()
    
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMap()
        
        managedContext = appDelegate.persistentContainer.viewContext
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isHidden = true
        searchbar.addTarget(self, action: #selector(AddPlaceVC.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    
    func initMap(){
        mapView.delegate = self
        
        mapView.isZoomEnabled = false
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        addDoubleTap()
    }
    
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(addAnnotationOnDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
    }
    @objc func addAnnotationOnDoubleTap(sender: UITapGestureRecognizer){
        
        mapView.removeAnnotation(currentAnnotation)
        
        
        currentAnnotation = MKPointAnnotation()
        
        
        func getLocationName(manager: CLLocationManager,location:CLLocationCoordinate2D){
            var title = ""
            var locality = ""
            var postalCode = ""
            
            let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            CLGeocoder().reverseGeocodeLocation(loc) { (placemarks, error) in
                if error != nil {
                    print(error!)
                } else {
                    if let placemark = placemarks?[0] {
                        
                        
                        locality = placemark.locality ?? ""
                        postalCode = placemark.postalCode ?? ""
                        
                        var address = ""
                        if placemark.subThoroughfare != nil {
                            address += placemark.subThoroughfare! + " "
                        }
                        
                        if placemark.thoroughfare != nil {
                            address += placemark.thoroughfare! + "\n"
                        }
            
                        if placemark.subAdministrativeArea != nil {
                            address += placemark.subAdministrativeArea! + "\n"
                        }
         
                        
                        if placemark.country != nil {
                            address += placemark.country! + "\n"
                        }
                        
                        title = address
                        
                        self.putValues(title: title, lat: location.latitude, lng: location.longitude, locality: locality, postalCode: postalCode)
                        
                        self.currentAnnotation.title = "Fav Place"
                        self.currentAnnotation.subtitle = title
                        
                        self.mapView.addAnnotation(self.currentAnnotation)
                    }
                }
            }
        
        }
        
        let touchPoint = sender.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        currentAnnotation.coordinate = coordinate
    
        getLocationName(manager: locationManager, location: coordinate)
        
        
    }
    
    func putValues(title:String,lat:Double,lng:Double,locality:String,postalCode:String){
        if(favPlace == nil){
            favPlace = FavPlace(title: title, lat: lat, lng: lng, postalCode: postalCode, locality: locality)
        }
        else{
            favPlace?.title = title
            favPlace?.lat = lat
            favPlace?.lng = lng
            favPlace?.locality = locality
            favPlace?.postalCode = postalCode
        }
    }
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text
    
        
        if((text ?? "").isEmpty){
            locations.removeAll()
            tableView.isHidden = true
            tableView.reloadData()
            return
        }
        
        guard
            let searchBarText = textField.text else {
            return
        }
        
        tableView.isHidden = false
        searchLocation(name: searchBarText)
        
    }
    
    func showLocationMarker(location:MKMapItem){
        
        mapView.removeAnnotation(currentAnnotation)
        
        tableView.isHidden = false
        
        currentAnnotation = MKPointAnnotation()
        currentAnnotation.coordinate = location.placemark.coordinate
        currentAnnotation.title = "Fav Place"
        currentAnnotation.subtitle = location.placemark.title
        
        moveMapToCoordinate(location: location.placemark.coordinate)
        
        mapView.addAnnotation(currentAnnotation)
    }
    
    
    func searchLocation(name:String){
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = name
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.locations = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        removeMyCurrentLocation()

        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "My location", subtitle: "you are here")
        
        manager.stopUpdatingLocation()
    }
    func removeMyCurrentLocation(){
        if let annotation = myCurrentLocationAnnotation {
            mapView.removeAnnotation(annotation)
        }
    }
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {

        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        moveMapToCoordinate(location: location)
        
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        
        myCurrentLocationAnnotation = annotation
        
        mapView.addAnnotation(annotation)
    }
    
    func moveMapToCoordinate(location:CLLocationCoordinate2D){
        
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}

extension AddPlaceVC : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        let location = locations[indexPath.row]
        cell.textLabel?.text = location.placemark.name
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let location = locations[indexPath.row]
        showLocationMarker(location: location)
        
        locations.removeAll()
        tableView.reloadData()
        tableView.isHidden = true
        
    }
}


extension AddPlaceVC: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        switch annotation.title {
        case "My location":
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = false
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        default:
            
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Fav Place")
            annotationView.image = UIImage(named: "marker")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Your Favorite", message: "Do you want to save this place ?", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Yes", style: .default){ _ in
            
            
            guard let place = self.favPlace else {
                alertController.dismiss(animated: false)
                return
            }
            
            PlaceManager.shared.addPlace(place: place, managedContext: self.managedContext)
            alertController.dismiss(animated: false)
            self.dismiss(animated: true)
            self.delegate?.tableView.reloadData()
            
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }


}
