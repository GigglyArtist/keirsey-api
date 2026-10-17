//
//  KeirseyScorer.swift
//  KeirseyApi
//

import Foundation

struct KeirseyResult: Codable {
    let code: String          // "INTJ"
    let title: String         // "Робеспьер / Исследователь"
    let description: String   // полный текст описания
    
    enum CodingKeys: String, CodingKey {
        case code, title, description
    }
}
