//
//  String+Extensions.swift
//  Campus-iOS
//
//  Created by Nikolai Madlener on 11.12.22.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
