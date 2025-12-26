//
//  Models.swift
//  CampusConnectApp
//
//  Created by GitHub Copilot on 26/12/2025.
//

import Foundation
import SwiftUI

struct User: Identifiable, Equatable {
    let id: UUID
    var name: String
    var email: String
    var password: String
    var course: String
    var year: Int
    var avatarName: String
    var interests: [String]
}

struct Event: Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var date: Date
    var location: String
    var maxCapacity: Int
    var category: EventCategory
    var interestedUserIDs: Set<UUID>
    var likeUserIDs: Set<UUID>
    var commentIDs: [UUID]
    var shareCount: Int
}

enum EventCategory: String, CaseIterable, Identifiable {
    case academic
    case sports
    case social
    case career
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .academic: return "Academic"
        case .sports: return "Sports"
        case .social: return "Social"
        case .career: return "Career"
        case .other: return "Other"
        }
    }

    var color: Color {
        switch self {
        case .academic: return Color(hex: "4F46E5") // Indigo 600
        case .sports: return Color(hex: "10B981") // Emerald 500
        case .social: return Color(hex: "EC4899") // Pink 500
        case .career: return Color(hex: "F59E0B") // Amber 500
        case .other: return Color(hex: "8B5CF6") // Violet 500
        }
    }
    
    var icon: String {
        switch self {
        case .academic: return "book.fill"
        case .sports: return "figure.run"
        case .social: return "party.popper.fill"
        case .career: return "briefcase.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .academic:
            return LinearGradient(
                colors: [Color(hex: "4F46E5"), Color(hex: "818CF8")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sports:
            return LinearGradient(
                colors: [Color(hex: "10B981"), Color(hex: "34D399")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .social:
            return LinearGradient(
                colors: [Color(hex: "EC4899"), Color(hex: "F472B6")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .career:
            return LinearGradient(
                colors: [Color(hex: "F59E0B"), Color(hex: "FBBF24")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .other:
            return LinearGradient(
                colors: [Color(hex: "8B5CF6"), Color(hex: "A78BFA")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct StudyGroup: Identifiable, Equatable, Hashable {
    let id: UUID
    var subject: String
    var moduleCode: String
    var meetingTime: String
    var location: String
    var maxMembers: Int
    var memberIDs: Set<UUID>
}

struct LostItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var date: Date
    var location: String
    var imageName: String
    var isFound: Bool
    var posterID: UUID
}

struct Comment: Identifiable, Equatable {
    let id: UUID
    let authorID: UUID
    let targetEventID: UUID
    let body: String
    let createdAt: Date
}

struct MessageThread: Identifiable, Equatable, Hashable {
    let id: UUID
    var participantIDs: [UUID] // two-party for now
    var lastUpdated: Date
    var messageIDs: [UUID]
}

struct Message: Identifiable, Equatable {
    let id: UUID
    let threadID: UUID
    let senderID: UUID
    let body: String
    let sentAt: Date
    var isRead: Bool
    var status: MessageStatus
}

enum MessageStatus: String, Equatable {
    case sending
    case sent
    case delivered
    case read
}
