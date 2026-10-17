//
//  KeirseyResult.swift
//  KeirseyApi
//

import Foundation

// Внутреннее представление буквы психотипа
private enum Letter: String {
    case E, I, S, N, T, F, J, P
}

// Один вопрос теста с метаданными о шкале
private struct Question {
    let number: Int
    let left: Letter   // вариант "а"
    let right: Letter  // вариант "б"
}

struct KeirseyScorer {
    
    // Все 70 вопросов с привязкой к шкалам
    private static let questions: [Question] = [
        // E/I (10)
        .init(number: 1,  left: .E, right: .I),
        .init(number: 8,  left: .E, right: .I),
        .init(number: 15, left: .E, right: .I),
        .init(number: 22, left: .E, right: .I),
        .init(number: 29, left: .E, right: .I),
        .init(number: 36, left: .E, right: .I),
        .init(number: 43, left: .E, right: .I),
        .init(number: 50, left: .E, right: .I),
        .init(number: 57, left: .E, right: .I),
        .init(number: 64, left: .E, right: .I),
        
        // S/N (20)
        .init(number: 2,  left: .S, right: .N),
        .init(number: 3,  left: .S, right: .N),
        .init(number: 9,  left: .S, right: .N),
        .init(number: 10, left: .S, right: .N),
        .init(number: 16, left: .S, right: .N),
        .init(number: 17, left: .S, right: .N),
        .init(number: 23, left: .S, right: .N),
        .init(number: 24, left: .S, right: .N),
        .init(number: 30, left: .S, right: .N),
        .init(number: 31, left: .S, right: .N),
        .init(number: 37, left: .S, right: .N),
        .init(number: 38, left: .S, right: .N),
        .init(number: 44, left: .S, right: .N),
        .init(number: 45, left: .S, right: .N),
        .init(number: 51, left: .S, right: .N),
        .init(number: 52, left: .S, right: .N),
        .init(number: 58, left: .S, right: .N),
        .init(number: 59, left: .S, right: .N),
        .init(number: 65, left: .S, right: .N),
        .init(number: 66, left: .S, right: .N),
        
        // T/F (20)
        .init(number: 4,  left: .T, right: .F),
        .init(number: 5,  left: .T, right: .F),
        .init(number: 11, left: .T, right: .F),
        .init(number: 12, left: .T, right: .F),
        .init(number: 18, left: .T, right: .F),
        .init(number: 19, left: .T, right: .F),
        .init(number: 25, left: .T, right: .F),
        .init(number: 26, left: .T, right: .F),
        .init(number: 32, left: .T, right: .F),
        .init(number: 33, left: .T, right: .F),
        .init(number: 39, left: .T, right: .F),
        .init(number: 40, left: .T, right: .F),
        .init(number: 46, left: .T, right: .F),
        .init(number: 47, left: .T, right: .F),
        .init(number: 53, left: .T, right: .F),
        .init(number: 54, left: .T, right: .F),
        .init(number: 60, left: .T, right: .F),
        .init(number: 61, left: .T, right: .F),
        .init(number: 67, left: .T, right: .F),
        .init(number: 68, left: .T, right: .F),
        
        // J/P (20)
        .init(number: 6,  left: .J, right: .P),
        .init(number: 7,  left: .J, right: .P),
        .init(number: 13, left: .J, right: .P),
        .init(number: 14, left: .J, right: .P),
        .init(number: 20, left: .J, right: .P),
        .init(number: 21, left: .J, right: .P),
        .init(number: 27, left: .J, right: .P),
        .init(number: 28, left: .J, right: .P),
        .init(number: 34, left: .J, right: .P),
        .init(number: 35, left: .J, right: .P),
        .init(number: 41, left: .J, right: .P),
        .init(number: 42, left: .J, right: .P),
        .init(number: 48, left: .J, right: .P),
        .init(number: 49, left: .J, right: .P),
        .init(number: 55, left: .J, right: .P),
        .init(number: 56, left: .J, right: .P),
        .init(number: 62, left: .J, right: .P),
        .init(number: 63, left: .J, right: .P),
        .init(number: 69, left: .J, right: .P),
        .init(number: 70, left: .J, right: .P),
    ]
    
    // 16 психотипов с описаниями
    static let descriptions: [String: (title: String, description: String)] = [
        "INTJ": ("Робеспьер / Исследователь", "Логико-интуитивный интроверт. Наиболее самоуверенный и прагматичный. Склонен к построению систем. Сильные стороны: аналитический ум, системность, точность и порядок."),
        "ISFP": ("Художник", "Сенсорно-этический интроверт. Острота ощущения текущей минуты, чувствительность, эстетичность, стремление к гармонии и комфорту."),
        "ISFJ": ("Консерватор", "Этико-сенсорный интроверт. Заботливый, верный традициям, трудолюбивый, аккуратный, стремится доводить дело до конца."),
        "INFJ": ("Предсказатель", "Этико-интуитивный интроверт. Глубокие нравственные ориентиры, проницательность, ранимость, стремление к гармонии в отношениях."),
        "ESTJ": ("Администратор", "Логико-сенсорный экстраверт. Высокая ответственность, практичность, стремление к порядку, четкому выполнению задач в срок."),
        "ISTJ": ("Опекун", "Логико-сенсорный интроверт. Человек структуры, правил и инструкций. Надежный, пунктуальный, конкретный."),
        "ENTJ": ("Фельдмаршал", "Логико-интуитивный экстраверт. Руководитель-стратег, нацелен на результат, высокую эффективность и качество работы."),
        "ESFJ": ("Торговец", "Этико-сенсорный экстраверт. Коммуникабельный, гостеприимный, искренне заботится о людях, поддерживает традиции."),
        "ENTP": ("Изобретатель", "Интуитивно-логический экстраверт. Генератор идей, новатор, ищет захватывающие перспективы, легко ломает шаблоны."),
        "ENFP": ("Журналист", "Интуитивно-этический экстраверт. Воодушевляет людей, видит потенциал, обожает всё новое, оптимистичен и артистичен."),
        "ENFJ": ("Педагог", "Этико-интуитивный экстраверт. Гуманистический лидер, артистичен, вдохновляет аудиторию, чуток к чувствам других."),
        "INFP": ("Романтик", "Интуитивно-этический интроверт. Мечтатель, идеалист, чуткий к искусству, стремится к добру и справедливости."),
        "ISTP": ("Мастер", "Сенсорно-логический интроверт. Стремится к гармонии, мастер своего дела, практичен, сохраняет спокойствие в кризисах."),
        "INTP": ("Архитектор", "Интуитивно-логический интроверт. Глубокий аналитик, стремится к точности мысли и законам логики, философ и теоретик."),
        "ESTP": ("Антрепренер", "Сенсорно-логический экстраверт. Человек действия, решительный, волевой, мгновенно реагирует на кризис."),
        "ESFP": ("Тамада", "Этико-сенсорный экстраверт. Оптимист, щедрый, избегает скуки и рутины, делает жизнь ярким приключением.")
    ]
    
    // Принимает словарь ответов answers {номер_вопроса: "a" | "b"} и возвращает результат
    // Parameter answers: ответы пользователя
    // Returns: результат теста. Если ответ пропущен,то вопрос не учитывается
    static func calculate(answers: [Int: String]) -> KeirseyResult {
        var scores: [Letter: Int] = [:]
        
        for question in questions {
            guard let answer = answers[question.number] else { continue }
            let letter: Letter = (answer.lowercased() == "a") ? question.left : question.right
            scores[letter, default: 0] += 1
        }
        
        // 4-буквенный код по парам
        let pairs: [(Letter, Letter)] = [
            (.E, .I), (.S, .N), (.T, .F), (.J, .P)
        ]
        
        var code = ""
        for (left, right) in pairs {
            let leftScore  = scores[left]  ?? 0
            let rightScore = scores[right] ?? 0
            // Строго больше -> левая, иначе (включая ничью) -> правая
            code += leftScore > rightScore ? left.rawValue : right.rawValue
        }
        
        let pair = descriptions[code] ?? (
            title: "Неизвестный тип",
            description: "Не удалось определить психотип. Проверьте ответы."
        )
        
        return KeirseyResult(
            code: code,
            title: pair.title,
            description: pair.description
        )
    }
}
