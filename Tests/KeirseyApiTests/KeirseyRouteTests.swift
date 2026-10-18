//
//  KeirseyRouteTests.swift
//  KeirseyApi
//

@testable import KeirseyApi
import VaporTesting
import Testing
import NIOFoundationEssentialsCompat

@Suite("Rout tests")
struct KeirseyRouteTests {
    @Test("Test all a variants")
    func testResultRouteA() async throws {
        try await withApp(configure: configure) { app in
            
            var answers: [Int: String] = [:]
            for i in 1...70 {
                answers[i] = "a"
            }
            
            let testRequestData = try JSONEncoder().encode(KeirseyRequestDTO(answers: answers))
            
            try await app
                .testing().test(
                .POST,
                "api/v1/keirsey/result",
                headers: ["Content-Type": "application/json"],
                body: ByteBuffer(data: testRequestData),
                afterResponse: { res async in
                    #expect(res.status == .ok)
                    
                    do {
                        let responce = try res.content.decode(KeirseyResponseDTO.self)
                        #expect(responce.code == "ESTJ")
                    } catch {
                        Issue.record("Не удалось распарсить ответ сервера: \(error)")
                    }
                })
        }
    }
    
    @Test("Test all b variants")
    func testResultRouteB() async throws {
        try await withApp(configure: configure) { app in
            
            var answers: [Int: String] = [:]
            for i in 1...70 {
                answers[i] = "b"
            }
            
            let testRequestData = try JSONEncoder().encode(KeirseyRequestDTO(answers: answers))
            
            try await app
                .testing().test(
                .POST,
                "api/v1/keirsey/result",
                headers: ["Content-Type": "application/json"],
                body: ByteBuffer(data: testRequestData),
                afterResponse: { res async in
                    #expect(res.status == .ok)
                    
                    do {
                        let responce = try res.content.decode(KeirseyResponseDTO.self)
                        #expect(responce.code == "INFP")
                    } catch {
                        Issue.record("Не удалось распарсить ответ сервера: \(error)")
                    }
                })
        }
    }
}
