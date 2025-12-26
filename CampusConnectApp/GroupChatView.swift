//
//  GroupChatView.swift
//  CampusConnectApp
//
//  Created by CampusConnect on 26/12/2025.
//

import SwiftUI

struct GroupChatView: View {
    let group: StudyGroup
    @EnvironmentObject private var store: MockDataStore
    @State private var messageText = ""
    @State private var messages: [DemoMessage] = []
    @Environment(\.dismiss) private var dismiss
    
    struct DemoMessage: Identifiable {
        let id = UUID()
        let senderName: String
        let senderAvatar: String
        let text: String
        let time: Date
        let isMe: Bool
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages Area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.md) {
                        // Welcome Banner
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(AppTheme.primary.opacity(0.5))
                                .padding()
                                .background(AppTheme.primary.opacity(0.1))
                                .clipShape(Circle())
                            
                            Text("Welcome to \(group.subject)")
                                .font(AppTheme.Typography.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                            
                            Text("This is the start of your study group chat.")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .padding(.vertical, AppTheme.Spacing.xl)
                        .flipped() // Un-flip for content
                        
                        // Messages
                        ForEach(messages) { message in
                            GroupMessageRow(message: message)
                                .id(message.id)
                                .flipped() // Un-flip for content
                        }
                    }
                    .padding()
                }
                .flipped() // Flip scroll view to start from bottom
                .onAppear {
                    loadDemoMessages()
                    // No need to scroll to bottom if flipped, it starts there
                }
                .onChange(of: messages.count) {
                    // With flipped list, new items (appended) appear at the "top" visual (bottom scroll)
                    // We actually need to prepend for flipped list or handle it normally.
                    // Let's stick to standard "Scroll to bottom" approach instead of flipping for simplicity first.
                }
            }
            .background(AppTheme.background)
            
            Divider()
            
            // Input Area
            HStack(spacing: AppTheme.Spacing.md) {
                TextField("Message \(group.moduleCode)...", text: $messageText, axis: .vertical)
                    .font(AppTheme.Typography.body)
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.outline, lineWidth: 1)
                    )
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppTheme.textTertiary : AppTheme.primary)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.surface)
        }
        .navigationTitle(group.subject)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let newMessage = DemoMessage(
            senderName: "Me",
            senderAvatar: store.currentUser?.avatarName ?? "person.fill",
            text: messageText,
            time: Date(),
            isMe: true
        )
        
        withAnimation {
            messages.append(newMessage)
            messageText = ""
        }
        
        // Simulate reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                messages.append(DemoMessage(
                    senderName: "Sarah Chen",
                    senderAvatar: "person.crop.circle.fill",
                    text: "Great point! Does anyone have the notes from yesterday?",
                    time: Date(),
                    isMe: false
                ))
            }
        }
    }
    
    private func loadDemoMessages() {
        if messages.isEmpty {
            messages = [
                DemoMessage(
                    senderName: "David Miller",
                    senderAvatar: "person.circle.fill",
                    text: "Hey everyone! When are we meeting next?",
                    time: Date().addingTimeInterval(-86400),
                    isMe: false
                ),
                DemoMessage(
                    senderName: "Emily Zhang",
                    senderAvatar: "person.crop.square.fill",
                    text: "I think Thursday at 6pm works best for most of us.",
                    time: Date().addingTimeInterval(-82000),
                    isMe: false
                ),
                DemoMessage(
                    senderName: "David Miller",
                    senderAvatar: "person.circle.fill",
                    text: "Sounds good to me. Library room B again?",
                    time: Date().addingTimeInterval(-80000),
                    isMe: false
                )
            ]
        }
    }
}

// Standard ScrollView approach (without flipping)
extension GroupChatView {
    // Re-defining body to use standard scroll-to-bottom logic
    var standardBody: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.md) {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(AppTheme.primary.opacity(0.5))
                                .padding()
                                .background(AppTheme.primary.opacity(0.1))
                                .clipShape(Circle())
                            
                            Text("Welcome to \(group.subject)")
                                .font(AppTheme.Typography.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                            
                            Text("This is the start of your study group chat.")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .padding(.vertical, AppTheme.Spacing.xl)
                        
                        ForEach(messages) { message in
                            GroupMessageRow(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    loadDemoMessages()
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: messages.count) {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: messageText) {
                    // Optional: scroll to bottom when typing starts
                }
            }
            .background(AppTheme.background)
            
            Divider()
            
            HStack(spacing: AppTheme.Spacing.md) {
                TextField("Message \(group.moduleCode)...", text: $messageText, axis: .vertical)
                    .font(AppTheme.Typography.body)
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.outline, lineWidth: 1)
                    )
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppTheme.textTertiary : AppTheme.primary)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.surface)
        }
        .navigationTitle(group.subject)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let last = messages.last {
            withAnimation {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}

// Helper for flipping (not used in standardBody but good to have if needed)
struct Flipped: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

extension View {
    func flipped() -> some View {
        modifier(Flipped())
    }
}

struct GroupMessageRow: View {
    let message: GroupChatView.DemoMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isMe {
                Spacer()
            } else {
                Image(systemName: message.senderAvatar)
                    .font(.system(size: 24))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.surface)
                    .clipShape(Circle())
            }
            
            VStack(alignment: message.isMe ? .trailing : .leading, spacing: 4) {
                if !message.isMe {
                    Text(message.senderName)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.leading, 4)
                }
                
                Text(message.text)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(message.isMe ? .white : AppTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.isMe ? AppTheme.primary : AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: AppTheme.Shadow.sm, radius: 2, x: 0, y: 1)
            }
            
            if !message.isMe {
                Spacer()
            }
        }
    }
}
