//
//  DTOs.swift
//  KeirseyApi
//

import Vapor

struct KeirseyRequestDTO: Content {
    let answers: [Int: String]
}

struct KeirseyResponseDTO: Content {
    let code: String
    let title: String
    let description: String

    init(result: KeirseyResult) {
        self.code = result.code
        self.title = result.title
        self.description = result.description
    }
}
