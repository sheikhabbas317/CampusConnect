//
//  MockDataStore.swift
//  CampusConnectApp
//
//  Created by GitHub Copilot on 26/12/2025.
//

import Foundation
import SwiftUI

@MainActor
final class MockDataStore: ObservableObject {
    @AppStorage("sessionUserId") private var sessionUserId: String = ""

    @Published var currentUser: User?
    @Published private(set) var users: [User]
    @Published private(set) var events: [Event]
    @Published private(set) var studyGroups: [StudyGroup]
    @Published private(set) var lostItems: [LostItem]
    @Published private(set) var comments: [Comment]
    @Published private(set) var threads: [MessageThread]
    @Published private(set) var messages: [Message]

    init() {
        let storedSession = UserDefaults.standard.string(forKey: "sessionUserId") ?? ""
        let sampleUsers = Self.makeSampleUsers()
        let sampleEvents = Self.makeSampleEvents(users: sampleUsers)
        let sampleStudyGroups = Self.makeSampleStudyGroups(users: sampleUsers)
        let sampleLostItems = Self.makeSampleLostItems(users: sampleUsers)
        let sampleThreads = Self.makeSampleThreads(users: sampleUsers)
        let sampleMessages = Self.makeSampleMessages(threads: sampleThreads, users: sampleUsers)

        self.users = sampleUsers
        self.events = sampleEvents
        self.studyGroups = sampleStudyGroups
        self.lostItems = sampleLostItems
        self.comments = []
        self.threads = sampleThreads
        self.messages = sampleMessages
        self.currentUser = Self.restoreUser(from: storedSession, in: sampleUsers)
    }

    func login(email: String, password: String) {
        guard let user = users.first(where: { $0.email.lowercased() == email.lowercased() && $0.password == password }) else { return }
        currentUser = user
        sessionUserId = user.id.uuidString
    }

    func register(name: String, email: String, password: String, course: String, year: Int, avatarName: String) {
        let newUser = User(id: UUID(), name: name, email: email, password: password, course: course, year: year, avatarName: avatarName, interests: ["Design", "Sports"])
        users.append(newUser)
        currentUser = newUser
        sessionUserId = newUser.id.uuidString
    }

    func socialLogin(provider: String) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let email = "user@\(provider.lowercased()).com"
            
            if let existingUser = self.users.first(where: { $0.email == email }) {
                self.currentUser = existingUser
                self.sessionUserId = existingUser.id.uuidString
            } else {
                let newUser = User(
                    id: UUID(),
                    name: "\(provider) User",
                    email: email,
                    password: "social-login-password",
                    course: "General Studies",
                    year: 1,
                    avatarName: "person.crop.circle.badge.checkmark",
                    interests: ["Social Networking"]
                )
                self.users.append(newUser)
                self.currentUser = newUser
                self.sessionUserId = newUser.id.uuidString
            }
        }
    }

    func logout() {
        // Ensure UI updates on main thread
        DispatchQueue.main.async {
            self.currentUser = nil
            self.sessionUserId = ""
        }
    }

    func addInterest(_ interest: String) {
        guard let userID = currentUser?.id, let idx = users.firstIndex(where: { $0.id == userID }) else { return }
        var user = users[idx]
        if !user.interests.contains(interest) {
            user.interests.append(interest)
            users[idx] = user
            currentUser = user
        }
    }

    func removeInterest(_ interest: String) {
        guard let userID = currentUser?.id, let idx = users.firstIndex(where: { $0.id == userID }) else { return }
        var user = users[idx]
        if let interestIdx = user.interests.firstIndex(of: interest) {
            user.interests.remove(at: interestIdx)
            users[idx] = user
            currentUser = user
        }
    }
    
    func toggleInterest(for eventID: UUID) {
        guard let userID = currentUser?.id else { return }
        guard let idx = events.firstIndex(where: { $0.id == eventID }) else { return }
        var event = events[idx]
        if event.interestedUserIDs.contains(userID) {
            event.interestedUserIDs.remove(userID)
        } else {
            event.interestedUserIDs.insert(userID)
        }
        events[idx] = event
    }

    func toggleLike(for eventID: UUID) {
        guard let userID = currentUser?.id else { return }
        guard let idx = events.firstIndex(where: { $0.id == eventID }) else { return }
        var event = events[idx]
        if event.likeUserIDs.contains(userID) {
            event.likeUserIDs.remove(userID)
        } else {
            event.likeUserIDs.insert(userID)
        }
        events[idx] = event
    }

    func addComment(to eventID: UUID, body: String) {
        guard let userID = currentUser?.id else { return }
        let comment = Comment(id: UUID(), authorID: userID, targetEventID: eventID, body: body, createdAt: Date())
        comments.append(comment)
        if let idx = events.firstIndex(where: { $0.id == eventID }) {
            var event = events[idx]
            event.commentIDs.append(comment.id)
            events[idx] = event
        }
    }

    func incrementShare(for eventID: UUID) {
        guard let idx = events.firstIndex(where: { $0.id == eventID }) else { return }
        var event = events[idx]
        event.shareCount += 1
        events[idx] = event
    }
    
    func createEvent(title: String, description: String, date: Date, location: String, maxCapacity: Int, category: EventCategory) {
        guard let userID = currentUser?.id else { return }
        let newEvent = Event(
            id: UUID(),
            title: title,
            description: description,
            date: date,
            location: location,
            maxCapacity: maxCapacity,
            category: category,
            interestedUserIDs: Set([userID]),
            likeUserIDs: Set(),
            commentIDs: [],
            shareCount: 0
        )
        events.insert(newEvent, at: 0) // Add to beginning
    }

    func createLostItem(title: String, description: String, location: String, isFound: Bool) {
        guard let userID = currentUser?.id else { return }
        let newItem = LostItem(
            id: UUID(),
            title: title,
            description: description,
            date: Date(),
            location: location,
            imageName: isFound ? "checkmark.seal.fill" : "magnifyingglass", // simplified mock image
            isFound: isFound,
            posterID: userID
        )
        lostItems.insert(newItem, at: 0)
    }

    func joinStudyGroup(_ id: UUID) {
        guard let userID = currentUser?.id else { return }
        guard let idx = studyGroups.firstIndex(where: { $0.id == id }) else { return }
        var group = studyGroups[idx]
        if group.memberIDs.contains(userID) {
            group.memberIDs.remove(userID)
        } else if group.memberIDs.count < group.maxMembers {
            group.memberIDs.insert(userID)
        }
        studyGroups[idx] = group
    }

    func sendMessage(in threadID: UUID, body: String) {
        guard let userID = currentUser?.id else { return }
        let message = Message(id: UUID(), threadID: threadID, senderID: userID, body: body, sentAt: Date(), isRead: false, status: .sent)
        messages.append(message)
        if let idx = threads.firstIndex(where: { $0.id == threadID }) {
            var thread = threads[idx]
            thread.messageIDs.append(message.id)
            thread.lastUpdated = Date()
            threads[idx] = thread
        }
    }

    func createOrFetchThread(with otherUserID: UUID) -> MessageThread? {
        guard let userID = currentUser?.id else { return nil }
        if let existing = threads.first(where: { Set($0.participantIDs) == Set([userID, otherUserID]) }) {
            return existing
        }
        let newThread = MessageThread(id: UUID(), participantIDs: [userID, otherUserID], lastUpdated: Date(), messageIDs: [])
        threads.append(newThread)
        return newThread
    }
}

private extension MockDataStore {
    static func restoreUser(from idString: String, in users: [User]) -> User? {
        guard !idString.isEmpty, let uuid = UUID(uuidString: idString) else { return nil }
        return users.first(where: { $0.id == uuid })
    }

    static func makeSampleUsers() -> [User] {
        [
            User(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, name: "Alex Kim", email: "alex@campus.edu", password: "password123", course: "Computer Science", year: 3, avatarName: "person.crop.circle.fill", interests: ["AI", "Basketball", "Photography"]),
            User(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, name: "Priya Singh", email: "priya@campus.edu", password: "password123", course: "Design", year: 2, avatarName: "person.circle.fill", interests: ["UX", "Hiking"]),
            User(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, name: "Marcus Lee", email: "marcus@campus.edu", password: "password123", course: "Business", year: 4, avatarName: "person.crop.square", interests: ["Startups", "Finance"])
        ]
    }

    static func makeSampleEvents(users: [User]) -> [Event] {
        let now = Date()
        return [
            Event(id: UUID(), title: "AI Club Hack Night", description: "48-hour hackathon focused on accessibility and AI for good.", date: Calendar.current.date(byAdding: .day, value: 2, to: now)!, location: "Innovation Hub", maxCapacity: 50, category: .academic, interestedUserIDs: Set([users[0].id]), likeUserIDs: Set([users[1].id]), commentIDs: [], shareCount: 3),
            Event(id: UUID(), title: "Campus 5K Fun Run", description: "Join the annual charity run across campus.", date: Calendar.current.date(byAdding: .day, value: 5, to: now)!, location: "Main Quad", maxCapacity: 200, category: .sports, interestedUserIDs: Set([users[2].id]), likeUserIDs: Set(), commentIDs: [], shareCount: 1),
            Event(id: UUID(), title: "Design Critique Circle", description: "Weekly design review with peers.", date: Calendar.current.date(byAdding: .day, value: 1, to: now)!, location: "Art Building Rm 304", maxCapacity: 15, category: .social, interestedUserIDs: Set(), likeUserIDs: Set(), commentIDs: [], shareCount: 0)
        ]
    }

    static func makeSampleStudyGroups(users: [User]) -> [StudyGroup] {
        [
            StudyGroup(id: UUID(), subject: "iOS Development", moduleCode: "CS410", meetingTime: "Thu 6pm", location: "Library Lab B", maxMembers: 6, memberIDs: Set([users[0].id, users[1].id])),
            StudyGroup(id: UUID(), subject: "Microeconomics", moduleCode: "EC201", meetingTime: "Wed 4pm", location: "Room 210", maxMembers: 4, memberIDs: Set([users[2].id]))
        ]
    }

    static func makeSampleLostItems(users: [User]) -> [LostItem] {
        [
            LostItem(id: UUID(), title: "Blue Hydro Flask", description: "Left near the gym benches.", date: Date(), location: "Campus Gym", imageName: "flask", isFound: false, posterID: users[0].id),
            LostItem(id: UUID(), title: "Graphing Calculator", description: "TI-84 with stickers.", date: Date(), location: "Math Building", imageName: "calculator", isFound: true, posterID: users[1].id)
        ]
    }

    static func makeSampleThreads(users: [User]) -> [MessageThread] {
        [
            MessageThread(id: UUID(), participantIDs: [users[0].id, users[1].id], lastUpdated: Date(), messageIDs: [])
        ]
    }

    static func makeSampleMessages(threads: [MessageThread], users: [User]) -> [Message] {
        guard let thread = threads.first else { return [] }
        return [
            Message(id: UUID(), threadID: thread.id, senderID: users[0].id, body: "Hey, want to team up for the hackathon?", sentAt: Date().addingTimeInterval(-3600), isRead: true, status: .read),
            Message(id: UUID(), threadID: thread.id, senderID: users[1].id, body: "Yes! Let's meet tomorrow to plan.", sentAt: Date().addingTimeInterval(-3500), isRead: true, status: .read)
        ]
    }
}
