//
//  FeatureViews.swift
//  CampusConnectApp
//
//  Created by GitHub Copilot on 26/12/2025.
//

import SwiftUI

struct EventFeedView: View {
    @EnvironmentObject private var store: MockDataStore
    @State private var selectedCategory: EventCategory? = nil
    @State private var selectedEvent: Event?
    @State private var commentText = ""
    @State private var showingCommentSheet = false
    @State private var shareMessage = ""
    @State private var showingShareAlert = false
    @State private var showingNewEventSheet = false

    var filteredEvents: [Event] {
        guard let category = selectedCategory else { return store.events }
        return store.events.filter { $0.category == category }
    }
    
    var backgroundGradient: LinearGradient {
        if let category = selectedCategory {
            return LinearGradient(
                colors: [
                    category.color.opacity(0.08),
                    category.color.opacity(0.03),
                    Color.white.opacity(0.95),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    AppTheme.primary.opacity(0.06),
                    AppTheme.primary.opacity(0.02),
                    Color.white.opacity(0.98),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Professional Background with Color Theme
                backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Category Filter Chips with Color Themes
                    VStack(spacing: 0) {
                        // Enhanced Gradient Header based on selected category
                        if let category = selectedCategory {
                            LinearGradient(
                                colors: [
                                    category.color.opacity(0.4),
                                    category.color.opacity(0.2),
                                    category.color.opacity(0.05),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 12)
                        } else {
                            LinearGradient(
                                colors: [
                                    AppTheme.primary.opacity(0.3),
                                    AppTheme.primary.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 12)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                categoryChip(
                                    label: "All",
                                    icon: "sparkles",
                                    color: AppTheme.primary,
                                    active: selectedCategory == nil
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedCategory = nil
                                    }
                                }
                                ForEach(EventCategory.allCases) { category in
                                    categoryChip(
                                        label: category.label,
                                        icon: category.icon,
                                        color: category.color,
                                        active: selectedCategory == category
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.vertical, AppTheme.Spacing.md)
                        }
                        .background(
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                        )
                    }
                    
                    if filteredEvents.isEmpty {
                        VStack(spacing: AppTheme.Spacing.lg) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 64))
                                .foregroundStyle(
                                    selectedCategory?.color.opacity(0.3) ?? AppTheme.primary.opacity(0.3)
                                )
                            Text("No events in this category yet")
                                .font(AppTheme.Typography.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("Check back later or switch categories to discover what's happening on campus.")
                                .font(AppTheme.Typography.footnote)
                                .foregroundStyle(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            Button {
                                showingNewEventSheet = true
                            } label: {
                                HStack(spacing: AppTheme.Spacing.sm) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create First Event")
                                }
                                .font(AppTheme.Typography.subheadline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppTheme.Spacing.lg)
                                .padding(.vertical, AppTheme.Spacing.md)
                                .background(
                                    selectedCategory?.gradient ?? AppTheme.gradient
                                )
                                .clipShape(Capsule())
                                .shadow(color: (selectedCategory?.color ?? AppTheme.primary).opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .padding(.top, AppTheme.Spacing.md)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredEvents) { event in
                                EventCard(
                                    event: event,
                                    likeAction: { store.toggleLike(for: event.id) },
                                    interestAction: { store.toggleInterest(for: event.id) },
                                    commentAction: {
                                        selectedEvent = event
                                        showingCommentSheet = true
                                    },
                                    shareAction: {
                                        store.incrementShare(for: event.id)
                                        shareMessage = "Shared \(event.title)"
                                        showingShareAlert = true
                                    }
                                )
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: AppTheme.Spacing.sm, leading: AppTheme.Spacing.lg, bottom: AppTheme.Spacing.sm, trailing: AppTheme.Spacing.lg))
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewEventSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.primary)
                    }
                }
            }
            .alert("Shared", isPresented: $showingShareAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(shareMessage)
            })
            .sheet(isPresented: $showingCommentSheet) {
                if let event = selectedEvent {
                    CommentSheet(event: event, commentText: $commentText) { text in
                        store.addComment(to: event.id, body: text)
                    }
                    .presentationDetents([.medium, .large])
                }
            }
            .sheet(isPresented: $showingNewEventSheet) {
                NewEventSheet(selectedCategory: $selectedCategory) { title, description, date, category in
                    store.createEvent(title: title, description: description, date: date, category: category)
                }
            }
        }
    }

    private func categoryChip(label: String, icon: String, color: Color = AppTheme.primary, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
            }
            .font(AppTheme.Typography.footnoteBold)
            .foregroundStyle(active ? .white : color)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                Capsule()
                    .fill(active ? color : color.opacity(0.12))
            )
            .overlay(
                Capsule()
                    .stroke(active ? Color.clear : color.opacity(0.25), lineWidth: 1.5)
            )
            .shadow(color: active ? color.opacity(0.35) : Color.clear, radius: 6, x: 0, y: 3)
        }
    }
}

// New Event Creation Sheet
struct NewEventSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var store: MockDataStore
    @Binding var selectedCategory: EventCategory?
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDate = Date()
    @State private var selectedEventCategory: EventCategory = .academic
    @State private var validationMessage: String?
    
    var onSave: (String, String, Date, EventCategory) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.white,
                        selectedEventCategory.color.opacity(0.03)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Header
                        VStack(spacing: AppTheme.Spacing.xs) {
                            Text("Create New Event")
                                .font(AppTheme.Typography.title2)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("Share what's happening on campus")
                                .font(AppTheme.Typography.footnote)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .padding(.top, AppTheme.Spacing.lg)
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Category")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundStyle(AppTheme.textPrimary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppTheme.Spacing.sm) {
                                    ForEach(EventCategory.allCases) { category in
                                        Button {
                                            withAnimation(.spring(response: 0.2)) {
                                                selectedEventCategory = category
                                            }
                                        } label: {
                                            HStack(spacing: AppTheme.Spacing.xs) {
                                                Image(systemName: category.icon)
                                                    .font(.system(size: 14))
                                                Text(category.label)
                                                    .font(AppTheme.Typography.footnoteBold)
                                            }
                                            .foregroundStyle(selectedEventCategory == category ? .white : category.color)
                                            .padding(.horizontal, AppTheme.Spacing.md)
                                            .padding(.vertical, AppTheme.Spacing.sm)
                                            .background(
                                                Capsule()
                                                    .fill(selectedEventCategory == category ? category.color : category.color.opacity(0.12))
                                            )
                                            .overlay(
                                                Capsule()
                                                    .stroke(selectedEventCategory == category ? Color.clear : category.color.opacity(0.25), lineWidth: 1.5)
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, AppTheme.Spacing.xs)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        
                        // Title Input
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Event Title")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundStyle(AppTheme.textPrimary)
                            TextField("Enter event title", text: $title)
                                .font(AppTheme.Typography.body)
                                .padding(AppTheme.Spacing.md)
                                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedEventCategory.color.opacity(0.3), lineWidth: 1.5)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        
                        // Description Input
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Description")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundStyle(AppTheme.textPrimary)
                            TextField("Describe your event...", text: $description, axis: .vertical)
                                .font(AppTheme.Typography.body)
                                .lineLimit(3...8)
                                .padding(AppTheme.Spacing.md)
                                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedEventCategory.color.opacity(0.3), lineWidth: 1.5)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        
                        // Date Selection
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Event Date")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundStyle(AppTheme.textPrimary)
                            DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .padding(AppTheme.Spacing.md)
                                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedEventCategory.color.opacity(0.3), lineWidth: 1.5)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        
                        // Validation Message
                        if let message = validationMessage {
                            HStack(spacing: AppTheme.Spacing.xs) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(AppTheme.error)
                                Text(message)
                                    .font(AppTheme.Typography.footnote)
                                    .foregroundStyle(AppTheme.error)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                        }
                        
                        // Create Button
                        Button {
                            guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
                                validationMessage = "Title is required"
                                return
                            }
                            guard !description.trimmingCharacters(in: .whitespaces).isEmpty else {
                                validationMessage = "Description is required"
                                return
                            }
                            validationMessage = nil
                            onSave(title, description, selectedDate, selectedEventCategory)
                            selectedCategory = selectedEventCategory
                            dismiss()
                        } label: {
                            Text("Create Event")
                                .font(AppTheme.Typography.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.Spacing.md)
                                .background(selectedEventCategory.gradient)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: selectedEventCategory.color.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.top, AppTheme.Spacing.sm)
                        .padding(.bottom, AppTheme.Spacing.xl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }
}

struct EventCard: View {
    @EnvironmentObject private var store: MockDataStore
    let event: Event
    let likeAction: () -> Void
    let interestAction: () -> Void
    let commentAction: () -> Void
    let shareAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Enhanced Category Color Bar with Gradient
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(event.category.gradient)
                    .frame(height: 5)
                
                // Subtle shine effect
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 5)
            }
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                // Header with Title and Category
                HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                    // Category Icon Badge
                    ZStack {
                        Circle()
                            .fill(event.category.color.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: event.category.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(event.category.color)
                    }
                    
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(event.title)
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                            .multilineTextAlignment(.leading)
                        
                        Text(event.category.label)
                            .font(AppTheme.Typography.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, 4)
                            .background(event.category.gradient)
                            .clipShape(Capsule())
                            .shadow(color: event.category.color.opacity(0.25), radius: 3, x: 0, y: 1)
                    }
                    
                    Spacer()
                }
            
                // Description
                Text(event.description)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Date and Interest Button
                HStack(spacing: AppTheme.Spacing.md) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14))
                            .foregroundStyle(event.category.color)
                        Text(event.date, style: .date)
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(AppTheme.textSecondary)
                        Text("•")
                            .foregroundStyle(AppTheme.textTertiary)
                        Text(event.date, style: .time)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    Spacer()
                    interestButton
                }
                
                Divider()
                    .background(event.category.color.opacity(0.2))
                    .padding(.vertical, AppTheme.Spacing.xs)
                
                // Action Buttons
                HStack(spacing: AppTheme.Spacing.lg) {
                    actionButton(
                        system: likeSymbol,
                        label: "\(event.likeUserIDs.count)",
                        color: event.likeUserIDs.contains(store.currentUser?.id ?? UUID()) ? event.category.color : AppTheme.textSecondary,
                        action: likeAction
                    )
                    
                    actionButton(
                        system: "text.bubble",
                        label: "\(event.commentIDs.count)",
                        color: AppTheme.textSecondary,
                        action: commentAction
                    )
                    
                    ShareLink(item: shareText, subject: Text(event.title)) {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "arrowshape.turn.up.forward")
                                .font(AppTheme.Typography.footnote)
                            Text("\(event.shareCount)")
                                .font(AppTheme.Typography.footnote)
                        }
                        .foregroundStyle(AppTheme.textSecondary)
                    }
                    .simultaneousGesture(TapGesture().onEnded { shareAction() })
                    
                    Spacer()
                }
                .font(AppTheme.Typography.footnote)
            }
            .padding(AppTheme.Spacing.lg)
        }
        .background(
            ZStack {
                // Main background
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .fill(AppTheme.surface)
                
                // Subtle category color tint
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                event.category.color.opacity(0.03),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        .shadow(color: event.category.color.opacity(0.1), radius: 12, x: 0, y: 6)
        .shadow(color: AppTheme.Shadow.card, radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            event.category.color.opacity(0.15),
                            event.category.color.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .accessibilityElement(children: .combine)
    }

    private var interestButton: some View {
        let isInterested = store.currentUser.map { event.interestedUserIDs.contains($0.id) } ?? false
        return Button(action: interestAction) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: isInterested ? "checkmark.circle.fill" : "circle")
                    .font(AppTheme.Typography.caption)
                Text(isInterested ? "Interested" : "Interested?")
                    .font(AppTheme.Typography.footnoteBold)
            }
            .foregroundStyle(isInterested ? .white : event.category.color)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                Group {
                    if isInterested {
                        event.category.gradient
                    } else {
                        event.category.color.opacity(0.1)
                    }
                }
            )
            .overlay(
                Capsule()
                    .stroke(isInterested ? Color.clear : event.category.color.opacity(0.3), lineWidth: 1.5)
            )
            .clipShape(Capsule())
            .shadow(color: isInterested ? event.category.color.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
        }
    }

    private var likeSymbol: String {
        guard let user = store.currentUser else { return "hand.thumbsup" }
        return event.likeUserIDs.contains(user.id) ? "hand.thumbsup.fill" : "hand.thumbsup"
    }

    private func actionButton(system: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: system)
                    .font(AppTheme.Typography.footnote)
                Text(label)
                    .font(AppTheme.Typography.footnote)
            }
            .foregroundStyle(color)
        }
    }
}

private extension EventCard {
    var shareText: String {
        "Check out this event: \(event.title) — \(event.description)"
    }
}

struct CommentSheet: View {
    @EnvironmentObject private var store: MockDataStore
    let event: Event
    @Binding var commentText: String
    var onSend: (String) -> Void

    var eventComments: [Comment] {
        store.comments.filter { $0.targetEventID == event.id }.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Comments")
                    .font(AppTheme.Typography.title3)
                    .foregroundStyle(AppTheme.textPrimary)
                Text(event.title)
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(AppTheme.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.background)
            
            Divider()
            
            // Comments List
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    if eventComments.isEmpty {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 32))
                                .foregroundStyle(AppTheme.textTertiary)
                            Text("No comments yet")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                            Text("Be the first to comment!")
                                .font(AppTheme.Typography.footnote)
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, AppTheme.Spacing.xl)
                    } else {
                        ForEach(eventComments) { comment in
                            CommentRow(comment: comment)
                        }
                    }
                }
                .padding(AppTheme.Spacing.lg)
            }
            
            Divider()
            
            // Input Section
            HStack(spacing: AppTheme.Spacing.md) {
                TextField("Add a comment...", text: $commentText, axis: .vertical)
                    .font(AppTheme.Typography.body)
                    .lineLimit(1...4)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                            .stroke(AppTheme.outline.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                
                Button {
                    guard !commentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    onSend(commentText)
                    commentText = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title3)
                        .foregroundStyle(commentText.trimmingCharacters(in: .whitespaces).isEmpty ? AppTheme.textTertiary : AppTheme.primary)
                }
                .disabled(commentText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.surface)
        }
    }
}

struct CommentRow: View {
    @EnvironmentObject private var store: MockDataStore
    let comment: Comment

    var author: User? {
        store.users.first(where: { $0.id == comment.authorID })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(alignment: .top) {
                // Avatar
                Image(systemName: author?.avatarName ?? "person.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    HStack {
                        Text(author?.name ?? "User")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Text(comment.createdAt, style: .time)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    Text(comment.body)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }
}

struct StudyGroupsView: View {
    @EnvironmentObject private var store: MockDataStore
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                if filteredGroups.isEmpty {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.textTertiary)
                        Text("No study groups found")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Try adjusting your search or check back later.")
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredGroups) { group in
                            StudyGroupCard(group: group, isMember: isMember(of: group)) {
                                store.joinStudyGroup(group.id)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: AppTheme.Spacing.sm, leading: AppTheme.Spacing.lg, bottom: AppTheme.Spacing.sm, trailing: AppTheme.Spacing.lg))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Study Groups")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search by subject or module"
            )
        }
    }

    private var filteredGroups: [StudyGroup] {
        let groups = store.studyGroups
        guard !searchText.isEmpty else { return groups }
        let query = searchText.lowercased()
        return groups.filter { group in
            group.subject.lowercased().contains(query) ||
            group.moduleCode.lowercased().contains(query)
        }
    }

    private func isMember(of group: StudyGroup) -> Bool {
        guard let userID = store.currentUser?.id else { return false }
        return group.memberIDs.contains(userID)
    }
}

struct StudyGroupCard: View {
    let group: StudyGroup
    let isMember: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(group.subject)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(group.moduleCode)
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
                // Member Count Badge
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "person.2.fill")
                        .font(AppTheme.Typography.caption)
                    Text("\(group.memberIDs.count)/\(group.maxMembers)")
                        .font(AppTheme.Typography.caption)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(AppTheme.primary)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(AppTheme.primary.opacity(0.12))
                .clipShape(Capsule())
            }
            
            // Details
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack(spacing: AppTheme.Spacing.md) {
                    Label {
                        Text(group.meetingTime)
                            .font(AppTheme.Typography.footnote)
                    } icon: {
                        Image(systemName: "clock.fill")
                            .font(AppTheme.Typography.caption)
                    }
                    .foregroundStyle(AppTheme.textSecondary)
                    
                    Label {
                        Text(group.location)
                            .font(AppTheme.Typography.footnote)
                    } icon: {
                        Image(systemName: "mappin.circle.fill")
                            .font(AppTheme.Typography.caption)
                    }
                    .foregroundStyle(AppTheme.textSecondary)
                }
            }
            
            // Join Button
            JoinButton(isMember: isMember, action: action)
        }
        .appCard(elevated: true)
    }
}

struct JoinButton: View {
    let isMember: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: isMember ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(AppTheme.Typography.footnote)
                Text(isMember ? "Joined" : "Join Group")
                    .font(AppTheme.Typography.footnoteBold)
            }
            .foregroundStyle(isMember ? AppTheme.primary : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(isMember ? AppTheme.primary.opacity(0.15) : AppTheme.primary)
            .overlay(
                Capsule()
                    .stroke(isMember ? AppTheme.primary.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
    }
}

struct LostFoundView: View {
    @EnvironmentObject private var store: MockDataStore
    @State private var filterLostOnly = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                if filteredItems.isEmpty {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.textTertiary)
                        Text("No items found")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Try adjusting the filter or check back later.")
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            LostItemCard(item: item)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: AppTheme.Spacing.sm, leading: AppTheme.Spacing.lg, bottom: AppTheme.Spacing.sm, trailing: AppTheme.Spacing.lg))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Lost & Found")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Filter", selection: $filterLostOnly) {
                        Text("All").tag(false)
                        Text("Lost").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }
            }
        }
    }
}

struct LostItemCard: View {
    let item: LostItem
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .fill(item.isFound ? AppTheme.success.opacity(0.15) : AppTheme.warning.opacity(0.15))
                    .frame(width: 60, height: 60)
                Image(systemName: item.isFound ? "checkmark.seal.fill" : "magnifyingglass")
                    .font(.title3)
                    .foregroundStyle(item.isFound ? AppTheme.success : AppTheme.warning)
            }
            
            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack {
                    Text(item.title)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    StatusPill(isFound: item.isFound)
                }
                
                Text(item.description)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)
                
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "mappin.circle.fill")
                        .font(AppTheme.Typography.caption)
                    Text(item.location)
                        .font(AppTheme.Typography.footnote)
                }
                .foregroundStyle(AppTheme.textTertiary)
            }
        }
        .appCard(elevated: true)
    }
}

private extension LostFoundView {
    var filteredItems: [LostItem] {
        guard filterLostOnly else { return store.lostItems }
        return store.lostItems.filter { !$0.isFound }
    }
}

struct StatusPill: View {
    let isFound: Bool
    var body: some View {
        Text(isFound ? "Found" : "Lost")
            .font(AppTheme.Typography.caption)
            .fontWeight(.semibold)
            .foregroundStyle(isFound ? AppTheme.success : AppTheme.warning)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.xs)
            .background(isFound ? AppTheme.success.opacity(0.15) : AppTheme.warning.opacity(0.15))
            .overlay(
                Capsule()
                    .stroke(isFound ? AppTheme.success.opacity(0.3) : AppTheme.warning.opacity(0.3), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}

struct MessagesView: View {
    @EnvironmentObject private var store: MockDataStore
    @State private var path: [MessageThread] = []
    @State private var showingNewChat = false

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                if userThreads.isEmpty {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.textTertiary)
                        Text("No conversations yet")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Start a new chat from here or from a profile.")
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(userThreads) { thread in
                            NavigationLink(value: thread) {
                                MessageThreadRow(
                                    title: threadTitle(for: thread),
                                    preview: lastMessagePreview(for: thread),
                                    timestamp: lastMessageTimestamp(for: thread)
                                )
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: AppTheme.Spacing.sm, leading: AppTheme.Spacing.lg, bottom: AppTheme.Spacing.sm, trailing: AppTheme.Spacing.lg))
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationDestination(for: MessageThread.self) { thread in
                ChatDetailView(thread: thread)
                    .environmentObject(store)
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewChat = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.title3)
                            .foregroundStyle(AppTheme.primary)
                    }
                    .accessibilityLabel("Start new chat")
                }
            }
            .sheet(isPresented: $showingNewChat) {
                NewChatSheet { user in
                    if let thread = store.createOrFetchThread(with: user.id) {
                        showingNewChat = false
                        // Use a slight delay to ensure smooth transition after sheet dismissal
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if !path.contains(thread) {
                                path.append(thread)
                            }
                        }
                    }
                }
            }
        }
    }

    private var userThreads: [MessageThread] {
        guard let me = store.currentUser?.id else { return [] }
        return store.threads.filter { $0.participantIDs.contains(me) }
    }

    private func threadTitle(for thread: MessageThread) -> String {
        guard let me = store.currentUser else { return "Thread" }
        let otherID = thread.participantIDs.first(where: { $0 != me.id })
        return store.users.first(where: { $0.id == otherID })?.name ?? "Chat"
    }

    private func lastMessagePreview(for thread: MessageThread) -> String {
        let threadMessages = store.messages.filter { $0.threadID == thread.id }.sorted { $0.sentAt < $1.sentAt }
        return threadMessages.last?.body ?? "Start the conversation"
    }
    
    private func lastMessageTimestamp(for thread: MessageThread) -> Date? {
        let threadMessages = store.messages.filter { $0.threadID == thread.id }.sorted { $0.sentAt < $1.sentAt }
        return threadMessages.last?.sentAt
    }
}

struct MessageThreadRow: View {
    let title: String
    let preview: String
    let timestamp: Date?
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Avatar
            Image(systemName: "person.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.primary.opacity(0.3))
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    if let timestamp = timestamp {
                        Text(timestamp, style: .time)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
                Text(preview)
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }
        }
        .appCard()
    }
}

struct NewChatSheet: View {
    @EnvironmentObject private var store: MockDataStore
    @Environment(\.dismiss) private var dismiss
    var onSelect: (User) -> Void

    var otherUsers: [User] {
        guard let me = store.currentUser else { return [] }
        return store.users.filter { $0.id != me.id }
    }

    var body: some View {
        NavigationStack {
            Group {
                if otherUsers.isEmpty {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Image(systemName: "person.2")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.textTertiary)
                        Text("No other users available")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.background)
                } else {
                    List(otherUsers) { user in
                        Button {
                            onSelect(user)
                            dismiss()
                        } label: {
                            HStack(spacing: AppTheme.Spacing.md) {
                                Image(systemName: user.avatarName)
                                    .font(.title2)
                                    .foregroundStyle(AppTheme.primary)
                                    .frame(width: 44, height: 44)
                                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                    Text(user.name)
                                        .font(AppTheme.Typography.headline)
                                        .foregroundStyle(AppTheme.textPrimary)
                                    Text(user.email)
                                        .font(AppTheme.Typography.footnote)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, AppTheme.Spacing.xs)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(AppTheme.background)
                }
            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }
}

struct ChatDetailView: View {
    @EnvironmentObject private var store: MockDataStore
    let thread: MessageThread
    @State private var draft = ""

    var threadMessages: [Message] {
        store.messages.filter { $0.threadID == thread.id }.sorted { $0.sentAt < $1.sentAt }
    }
    
    var chatTitle: String {
        guard let me = store.currentUser else { return "Chat" }
        let otherID = thread.participantIDs.first(where: { $0 != me.id })
        return store.users.first(where: { $0.id == otherID })?.name ?? "Chat"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        if threadMessages.isEmpty {
                            VStack(spacing: AppTheme.Spacing.md) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 48))
                                    .foregroundStyle(AppTheme.textTertiary)
                                Text("No messages yet")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text("Start the conversation!")
                                    .font(AppTheme.Typography.footnote)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, AppTheme.Spacing.xl)
                        } else {
                            ForEach(threadMessages) { message in
                                messageBubble(for: message)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding(.vertical, AppTheme.Spacing.md)
                }
                .onAppear {
                    if let lastMessage = threadMessages.last {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .onChange(of: threadMessages.count) {
                    if let lastMessage = threadMessages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(AppTheme.background)
            
            Divider()
            
            // Input Section
            HStack(spacing: AppTheme.Spacing.md) {
                TextField("Type a message...", text: $draft, axis: .vertical)
                    .font(AppTheme.Typography.body)
                    .lineLimit(1...4)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                            .stroke(AppTheme.outline.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
                
                Button {
                    let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    store.sendMessage(in: thread.id, body: trimmed)
                    draft = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppTheme.textTertiary : AppTheme.primary)
                }
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.surface)
        }
        .navigationTitle(chatTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func messageBubble(for message: Message) -> some View {
        let isMine = message.senderID == store.currentUser?.id
        HStack(alignment: .bottom, spacing: AppTheme.Spacing.sm) {
            if isMine { Spacer(minLength: 60) }
            
            VStack(alignment: isMine ? .trailing : .leading, spacing: AppTheme.Spacing.xs) {
                Text(message.body)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(isMine ? .white : AppTheme.textPrimary)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                            .fill(isMine ? AppTheme.primary : AppTheme.card)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                Text(message.sentAt, style: .time)
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.textTertiary)
                    .padding(.horizontal, AppTheme.Spacing.xs)
            }
            
            if !isMine { Spacer(minLength: 60) }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

struct ProfileView: View {
    @EnvironmentObject private var store: MockDataStore
    @State private var showingNewChat = false
    @State private var showingLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    if let user = store.currentUser {
                        // Profile Header
                        VStack(spacing: AppTheme.Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primary.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                Image(systemName: user.avatarName)
                                    .font(.system(size: 50))
                                    .foregroundStyle(AppTheme.primary)
                            }
                            .shadow(color: AppTheme.Shadow.md, radius: 8, x: 0, y: 4)
                            
                            VStack(spacing: AppTheme.Spacing.xs) {
                                Text(user.name)
                                    .font(AppTheme.Typography.title2)
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text(user.email)
                                    .font(AppTheme.Typography.body)
                                    .foregroundStyle(AppTheme.textSecondary)
                                Text("\(user.course) • Year \(user.year)")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                        }
                        .padding(.top, AppTheme.Spacing.lg)
                        
                        // Interests Section
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                            Text("Interests")
                                .font(AppTheme.Typography.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                            FlexibleTagView(tags: user.interests)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCard(elevated: true)
                        
                        // Action Buttons
                        VStack(spacing: AppTheme.Spacing.md) {
                            Button {
                                showingNewChat = true
                            } label: {
                                HStack {
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                    Text("Message a Classmate")
                                        .font(AppTheme.Typography.headline)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .primaryButtonStyle()
                            
                            Button {
                                showingLogoutConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.right.square")
                                    Text("Log Out")
                                        .font(AppTheme.Typography.headline)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.Spacing.md)
                                .background(AppTheme.error)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                                .shadow(color: AppTheme.error.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                }
                .padding(AppTheme.Spacing.lg)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingNewChat) {
                NewChatSheet { user in
                    _ = store.createOrFetchThread(with: user.id)
                }
            }
            .alert("Log Out", isPresented: $showingLogoutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    withAnimation {
                        store.logout()
                    }
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

struct FlexibleTagView: View {
    let tags: [String]
    var body: some View {
        FlexibleView(data: tags, spacing: AppTheme.Spacing.sm) { tag in
            Text(tag)
                .font(AppTheme.Typography.footnote)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.primary)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(AppTheme.primary.opacity(0.12))
                .overlay(
                    Capsule()
                        .stroke(AppTheme.primary.opacity(0.3), lineWidth: 1)
                )
                .clipShape(Capsule())
        }
    }
}

struct FlexibleView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    init(data: Data, spacing: CGFloat, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: spacing)], alignment: .leading, spacing: spacing) {
            ForEach(Array(data), id: \.self) { item in
                content(item)
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(MockDataStore())
}
