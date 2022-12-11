//
//  MensaService.swift
//  Campus-iOS
//
//  Created by Nikolai Madlener on 11.12.22.
//

import Foundation
import Alamofire

final class MensaService {
    static let shared = MensaService()
    private var menu: MensaMenu?
    
    public func getMensaMenu(mensaApiKey: String) -> MensaMenu? {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let thisWeekEndpoint = EatAPI.menu(location: mensaApiKey, year: Date().year, week: Date().weekOfYear)
        AF.request(thisWeekEndpoint).responseDecodable(of: MealPlan.self, decoder: decoder) { (response) in
            guard let value = response.value else { return }

            self.menu = value.days.first(where: {
                !$0.dishes.isEmpty && ($0.date.isToday ?? false || $0.date.isLaterThanOrEqual(to: Date()) ?? false)
            })
        }
        return menu
    }
}
