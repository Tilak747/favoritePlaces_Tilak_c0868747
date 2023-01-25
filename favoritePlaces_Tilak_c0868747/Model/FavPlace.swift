//
//  FavPlace.swift
//  favoritePlaces_Tilak_c0868747
//
//  Created by Tilak Acharya on 2023-01-24.
//

import Foundation

class FavPlace{
    var title:String
    var lat:Double
    var lng:Double
    var postalCode:String
    var locality:String
    
    init(title: String, lat: Double, lng: Double, postalCode: String, locality: String) {
        self.title = title
        self.lat = lat
        self.lng = lng
        self.postalCode = postalCode
        self.locality = locality
    }
}
