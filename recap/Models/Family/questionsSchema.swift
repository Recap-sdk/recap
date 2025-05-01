//
//  questionsSchema.swift
//  recap
//
//  Created by s1834 on 06/02/25.
//

import UIKit
import Foundation
import FirebaseFirestore

enum QuestionCategory: String, Codable {
    case immediateMemory
    case recentMemory
    case remoteMemory
}

enum QuestionSubcategory: String, Codable {
    case dailyRoutine
    case general
    case health
    case family
    case spiritual
    case hobbies
    case musicMovies
    case familyAdded
    case nutrition
    case fitnessExercise
    case socialInteraction
    case moodEmotion
    case personalHygiene
    case medicationManagement
    case cognitiveExercises
    case outdoorActivities
}

enum QuestionType: String, Codable {
    case multipleChoice
    case singleCorrect
    case yesNo
    case audio
    case image
    case openEnded
    case ratingScale
    case fillInTheBlank
    case matching
    case sorting
    case trueFalse
    case slider
    case dragAndDrop
    case sequence
}

struct Question: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var category: QuestionCategory
    var subcategory: QuestionSubcategory
    var tag: String?
    var answerOptions: [String]
    var answers: [String]
    var correctAnswers: [String]?
    var image: String?
    var isAnswered: Bool
    var askInterval: TimeInterval
    var lastAsked: Date?
    var timesAsked: Int
    var timesAnsweredCorrectly: Int
    var timeFrame: TimeFrame
    var createdAt: Date?
    var addedAt: Date?
    var priority: Int
    var audio: String?
    var isActive: Bool
    var lastAnsweredCorrectly: Date?
    var hint: String?
    var confidence: Int?
    var hardness: Int
    var questionType: QuestionType

    init(
        text: String,
        category: QuestionCategory,
        subcategory: QuestionSubcategory,
        tag: String?,
        answerOptions: [String],
        answers: [String],
        correctAnswers: [String]?,
        image: String?,
        isAnswered: Bool,
        askInterval: TimeInterval,
        timeFrame: TimeFrame,
        priority: Int,
        audio: String?,
        isActive: Bool,
        hint: String?,
        confidence: Int?,
        hardness: Int,
        questionType: QuestionType
    ) {
        self.text = text
        self.category = category
        self.subcategory = subcategory
        self.tag = tag
        self.answerOptions = answerOptions
        self.answers = answers
        self.correctAnswers = correctAnswers
        self.image = image
        self.isAnswered = isAnswered
        self.askInterval = askInterval
        self.lastAsked = nil
        self.timesAsked = 0
        self.timesAnsweredCorrectly = 0
        self.timeFrame = timeFrame
        self.createdAt = Date()
        self.addedAt = nil
        self.priority = priority
        self.audio = audio
        self.isActive = isActive
        self.lastAnsweredCorrectly = nil
        self.hint = hint
        self.confidence = confidence
        self.hardness = hardness
        self.questionType = questionType
    }
}
