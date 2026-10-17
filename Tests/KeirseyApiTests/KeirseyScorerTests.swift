//
//  KeirseyScorerTests.swift
//  KeirseyApi
//

import XCTest
@testable import KeirseyApi

final class KeirseyScorerTests: XCTestCase {
    
    // Тест 1: если ответы не присланы вообще, то все шкалы в ничьей -> "INFP"
    func testEmptyAnswersReturnsINFP() {
        let result = KeirseyScorer.calculate(answers: [:])
        XCTAssertEqual(result.code, "INFP")
    }
    
    // Тест 2: все ответы "a" -> все левые буквы -> "ESTJ"
    func testAllAReturnsESTJ() {
        var answers: [Int: String] = [:]
        for i in 1...70 { answers[i] = "a" }
        
        let result = KeirseyScorer.calculate(answers: answers)
        XCTAssertEqual(result.code, "ESTJ")
        XCTAssertEqual(result.title, "Администратор")
    }
    
    // Тест 3: все ответы "b" -> все правые буквы -> "INFP"
    func testAllBReturnsINFP() {
        var answers: [Int: String] = [:]
        for i in 1...70 { answers[i] = "b" }
        
        let result = KeirseyScorer.calculate(answers: answers)
        XCTAssertEqual(result.code, "INFP")
    }
    
    // Тест 4: регистр ответа не важен
    func testAnswerCaseInsensitive() {
        var a1: [Int: String] = [:]
        var a2: [Int: String] = [:]
        for i in 1...70 {
            a1[i] = "A"
            a2[i] = "a"
        }
        XCTAssertEqual(
            KeirseyScorer.calculate(answers: a1).code,
            KeirseyScorer.calculate(answers: a2).code
        )
    }
    
    // Тест 5: явный расчёт одного типа - INTJ
    // E/I: 10 "б" -> I (10-0)
    // S/N: 20 "б" -> N (0-20)
    // T/F: 20 "а" -> T (20-0)
    // J/P: 20 "б" -> P (0-20)
    func testExplicitINTJ() {
        var answers: [Int: String] = [:]
        let eiQuestions = [1, 8, 15, 22, 29, 36, 43, 50, 57, 64]
        let snQuestions = [2, 3, 9, 10, 16, 17, 23, 24, 30, 31, 37, 38, 44, 45, 51, 52, 58, 59, 65, 66]
        let tfQuestions = [4, 5, 11, 12, 18, 19, 25, 26, 32, 33, 39, 40, 46, 47, 53, 54, 60, 61, 67, 68]
        let jpQuestions = [6, 7, 13, 14, 20, 21, 27, 28, 34, 35, 41, 42, 48, 49, 55, 56, 62, 63, 69, 70]
        
        for q in eiQuestions { answers[q] = "b" } // -> I
        for q in snQuestions { answers[q] = "b" } // -> N
        for q in tfQuestions { answers[q] = "a" } // -> T
        for q in jpQuestions { answers[q] = "b" } // -> P
        
        let result = KeirseyScorer.calculate(answers: answers)
        XCTAssertEqual(result.code, "INTP")
        XCTAssertEqual(result.title, "Архитектор")
    }
}
