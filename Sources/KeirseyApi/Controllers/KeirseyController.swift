//
//  KeirseyController.swift
//  KeirseyApi
//

import Vapor

struct KeirseyController {

    // POST /api/v1/keirsey/result
    func result(req: Request) async throws -> KeirseyResponseDTO {
        let dto = try req.content.decode(KeirseyRequestDTO.self)   // 400
        let answers = try validate(dto.answers)                    // 422
        let domainResult = KeirseyScorer.calculate(answers: answers)
        return KeirseyResponseDTO(result: domainResult)
    }

    private func validate(_ raw: [Int: String]) throws -> [Int: String] {
        let expected = Set(1...70)
        let received = Set(raw.keys)
        let missing = expected.subtracting(received).sorted()
        let extra = received.subtracting(expected).sorted()

        guard missing.isEmpty, extra.isEmpty else {
            throw Abort(.unprocessableEntity, reason:
                "Expected answers for questions 1...70. Missing: \(missing.prefix(10)), unexpected: \(extra.prefix(10))"
            )
        }

        var cleaned: [Int: String] = [:]
        for (number, value) in raw {
            let v = value.lowercased()
            guard v == "a" || v == "b" else {
                throw Abort(.unprocessableEntity, reason:
                    "Question \(number): answer must be 'a' or 'b', got '\(value)'"
                )
            }
            cleaned[number] = v
        }
        return cleaned
    }
}
