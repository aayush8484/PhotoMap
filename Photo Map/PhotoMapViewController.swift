//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate, MKMapViewDelegate{
    var photoAnnotationDetails = PhotoAnnotation()

    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
        photoAnnotationDetails.coordinate = locationCoordinate
        photoAnnotationDetails.photo = postImage
        let annotation = MKPointAnnotation()
        annotation.coordinate  = locationCoordinate
        annotation.title = photoAnnotationDetails.title
        mapView.addAnnotation(annotation)
        self.mapView.delegate = self
        self.mapView.view(for: annotation)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var mapView: MKMapView!
    var postImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                              MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
    }

    @IBAction func didTapCamera(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            vc.sourceType = .camera
        }else{
            vc.sourceType = .photoLibrary
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        postImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "tagSegue", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "tagSegue"){
            let locationsViewController = segue.destination as! LocationsViewController
            locationsViewController.delegate = self
        }else if(segue.identifier == "fullImageSegue"){
            let fullImageViewController = segue.destination as! FullImageViewController
            fullImageViewController.fImage = photoAnnotationDetails.photo
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegue(withIdentifier: "fullImageSegue", sender: self)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        
        
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            // annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
        }else{
            annotationView?.annotation = annotation
        }

        let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeRenderImageView.image = photoAnnotationDetails.photo
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let _ = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        annotationView?.image = UIImage(cgImage: photoAnnotationDetails.photo as! CGImage, scale: 0.5, orientation: UIImageOrientation.up)
        annotationView?.leftCalloutAccessoryView = resizeRenderImageView
        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
        return annotationView
    }
}
