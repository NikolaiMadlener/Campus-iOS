//
//  CLLocation+Extensions.swift
//  Campus-iOS
//
//  Created by Nikolai Madlener on 11.12.22.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D  {
    var location: CLLocation { CLLocation(latitude: latitude, longitude: longitude) }
}
