//
//  ContentView.swift
//  CampusConnectApp
//
//  Created by Muhammad Abbas on 26/12/2025.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var store: MockDataStore

    var body: some View {
        Group {
            if store.currentUser == nil {
                AuthView()
            } else {
                MainTabView()
            }
        }
    }
}

struct AuthView: View {
    @EnvironmentObject private var store: MockDataStore
    @State private var isRegister = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var course = ""
    @State private var year = 1
    @State private var selectedAvatar = "person.crop.circle.fill"
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var useCustomImage = false
    @State private var validationMessage: String?
    
    private let avatarOptions = [
        "person.crop.circle.fill",
        "person.circle.fill",
        "person.crop.square.fill",
        "person.fill",
        "person.2.fill",
        "person.3.fill"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Professional Background
                AppTheme.softGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Top Illustration Section with Safe Area
                        VStack(spacing: AppTheme.Spacing.lg) {
                            Image("login_img")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                            
                            // Welcome Message
                            VStack(spacing: AppTheme.Spacing.xs) {
                                Text(isRegister ? "Create Account" : "Welcome Back!")
                                    .font(AppTheme.Typography.largeTitle)
                                    .foregroundStyle(AppTheme.textPrimary)
                                
                                Text(isRegister ? "Join the campus community" : "Log in to your existing account")
                                    .font(AppTheme.Typography.body)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, AppTheme.Spacing.lg)
                            }
                        }
                        .padding(.top, AppTheme.Spacing.xxl)
                        .padding(.bottom, AppTheme.Spacing.xl)

                        // Form Section
                        VStack(spacing: AppTheme.Spacing.lg) {
                            // Mode Toggle
                            HStack(spacing: 0) {
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        isRegister = false
                                    }
                                } label: {
                                    Text("LOGIN")
                                        .font(AppTheme.Typography.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(isRegister ? AppTheme.textSecondary : .white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, AppTheme.Spacing.sm)
                                        .background(isRegister ? Color.clear : AppTheme.primary)
                                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                }
                                
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        isRegister = true
                                    }
                                } label: {
                                    Text("REGISTER")
                                        .font(AppTheme.Typography.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(isRegister ? .white : AppTheme.textSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, AppTheme.Spacing.sm)
                                        .background(isRegister ? AppTheme.primary : Color.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                }
                            }
                            .padding(4)
                            .background(AppTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                            .shadow(color: AppTheme.Shadow.sm, radius: 4, x: 0, y: 2)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            // Register Fields
                            if isRegister {
                                VStack(spacing: AppTheme.Spacing.md) {
                                    // Profile Image Section
                                    VStack(spacing: AppTheme.Spacing.sm) {
                                        if useCustomImage, let image = selectedImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(AppTheme.primary, lineWidth: 3))
                                        } else {
                                            ZStack {
                                                Circle()
                                                    .fill(AppTheme.primary.opacity(0.1))
                                                    .frame(width: 100, height: 100)
                                                Image(systemName: selectedAvatar)
                                                    .font(.system(size: 50))
                                                    .foregroundStyle(AppTheme.primary)
                                            }
                                            .overlay(Circle().stroke(AppTheme.primary, lineWidth: 3))
                                        }
                                        
                                        HStack(spacing: AppTheme.Spacing.md) {
                                            Button {
                                                useCustomImage = true
                                                showImagePicker = true
                                            } label: {
                                                HStack(spacing: AppTheme.Spacing.xs) {
                                                    Image(systemName: "photo.badge.plus")
                                                    Text("Upload")
                                                        .font(.system(size: 14, weight: .medium))
                                                }
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, AppTheme.Spacing.md)
                                                .padding(.vertical, AppTheme.Spacing.sm)
                                                .background(AppTheme.primary)
                                                .clipShape(Capsule())
                                            }
                                            
                                            Button {
                                                useCustomImage = false
                                            } label: {
                                                HStack(spacing: AppTheme.Spacing.xs) {
                                                    Image(systemName: "person.crop.circle")
                                                    Text("Avatar")
                                                        .font(.system(size: 14, weight: .medium))
                                                }
                                                .foregroundStyle(AppTheme.primary)
                                                .padding(.horizontal, AppTheme.Spacing.md)
                                                .padding(.vertical, AppTheme.Spacing.sm)
                                                .background(AppTheme.primary.opacity(0.1))
                                                .overlay(
                                                    Capsule()
                                                        .stroke(AppTheme.primary.opacity(0.3), lineWidth: 1.5)
                                                )
                                                .clipShape(Capsule())
                                            }
                                        }
                                        
                                        if !useCustomImage {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: AppTheme.Spacing.sm) {
                                                    ForEach(avatarOptions, id: \.self) { avatar in
                                                        Button {
                                                            selectedAvatar = avatar
                                                        } label: {
                                                            ZStack {
                                                                Circle()
                                                                    .fill(selectedAvatar == avatar ? AppTheme.primary.opacity(0.2) : Color(red: 0.95, green: 0.95, blue: 0.95))
                                                                    .frame(width: 50, height: 50)
                                                                    .overlay(
                                                                        Circle()
                                                                            .stroke(selectedAvatar == avatar ? AppTheme.primary : Color.clear, lineWidth: 2)
                                                                    )
                                                                Image(systemName: avatar)
                                                                    .font(.system(size: 22))
                                                                    .foregroundStyle(selectedAvatar == avatar ? AppTheme.primary : Color.gray)
                                                            }
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal, AppTheme.Spacing.xs)
                                            }
                                        }
                                    }
                                    .padding(.vertical, AppTheme.Spacing.sm)
                                    
                                    ModernInputField(icon: "person.fill", placeholder: "Full name", text: $name)
                                    ModernInputField(icon: "book.closed.fill", placeholder: "Course", text: $course)
                                    
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundStyle(AppTheme.primary)
                                            .frame(width: 20)
                                        Text("Year: \(year)")
                                            .font(.system(size: 15))
                                            .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))
                                        Spacer()
                                        Stepper("", value: $year, in: 1...6)
                                            .labelsHidden()
                                    }
                                    .padding(.horizontal, AppTheme.Spacing.md)
                                    .padding(.vertical, AppTheme.Spacing.md)
                                    .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .padding(.horizontal, AppTheme.Spacing.lg)
                            }
                            
                            // Email and Password Fields
                            VStack(spacing: AppTheme.Spacing.md) {
                                ModernInputField(
                                    icon: "person.fill",
                                    placeholder: "Campus email",
                                    text: $email
                                )
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                
                                ModernPasswordField(
                                    icon: "lock.fill",
                                    placeholder: "Password",
                                    text: $password,
                                    showForgotPassword: !isRegister
                                )
                                
                                if let message = validationMessage {
                                    HStack(spacing: AppTheme.Spacing.xs) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundStyle(AppTheme.error)
                                        Text(message)
                                            .font(.system(size: 13))
                                            .foregroundStyle(AppTheme.error)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, AppTheme.Spacing.lg)
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            // Login/Register Button
                            Button(action: handleSubmit) {
                                Text(isRegister ? "CREATE ACCOUNT" : "LOG IN")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppTheme.Spacing.md)
                                    .background(AppTheme.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                    .shadow(color: AppTheme.Shadow.button, radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.top, AppTheme.Spacing.sm)
                            
                            // Social Login Section
                            if !isRegister {
                                VStack(spacing: AppTheme.Spacing.md) {
                                    HStack {
                                        Rectangle()
                                            .fill(AppTheme.outline)
                                            .frame(height: 1)
                                        Text("Or connect using")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundStyle(AppTheme.textSecondary)
                                            .padding(.horizontal, AppTheme.Spacing.sm)
                                        Rectangle()
                                            .fill(AppTheme.outline)
                                            .frame(height: 1)
                                    }
                                    .padding(.horizontal, AppTheme.Spacing.lg)
                                    
                                    HStack(spacing: AppTheme.Spacing.md) {
                                        SocialLoginButton(
                                            icon: "f",
                                            text: "Facebook",
                                            color: Color(hex: "1877F2")
                                        )
                                        
                                        SocialLoginButton(
                                            icon: "G",
                                            text: "Google",
                                            color: Color(hex: "DB4437")
                                        )
                                    }
                                    .padding(.horizontal, AppTheme.Spacing.lg)
                                }
                                .padding(.top, AppTheme.Spacing.md)
                            }
                            
                            // Sign Up / Sign In Link
                            HStack(spacing: AppTheme.Spacing.xs) {
                                Text(isRegister ? "Already have an account?" : "Don't have an account?")
                                    .font(AppTheme.Typography.body)
                                    .foregroundStyle(AppTheme.textSecondary)
                                
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        isRegister.toggle()
                                    }
                                } label: {
                                    Text(isRegister ? "Sign In" : "Sign Up")
                                        .font(AppTheme.Typography.bodyBold)
                                        .foregroundStyle(AppTheme.primary)
                                }
                            }
                            .padding(.top, AppTheme.Spacing.lg)
                            .padding(.bottom, AppTheme.Spacing.xl)
                        }
                    }
                    .padding(.bottom, AppTheme.Spacing.xl)
                }
                .scrollIndicators(.hidden)
                .safeAreaPadding(.top)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }

    private func handleSubmit() {
        validationMessage = nil
        
        guard !email.isEmpty else {
            validationMessage = "Email required"
            return
        }
        
        guard !password.isEmpty else {
            validationMessage = "Password required"
            return
        }
        
        if isRegister {
            guard !name.isEmpty else {
                validationMessage = "Name required"
                return
            }
            // Use selected avatar as fallback since we can't persist custom images in mock store
            let finalAvatarName = selectedAvatar
            store.register(name: name, email: email, password: password, course: course.isEmpty ? "Undeclared" : course, year: year, avatarName: finalAvatarName)
        } else {
            store.login(email: email, password: password)
            if store.currentUser == nil {
                validationMessage = "Invalid email or password"
            }
        }
    }
}

// Image Picker for Photo Upload
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            EventFeedView()
                .tabItem {
                    Label("Events", systemImage: "sparkles")
                }
            StudyGroupsView()
                .tabItem {
                    Label("Groups", systemImage: "person.3.fill")
                }
            LostFoundView()
                .tabItem {
                    Label("Lost & Found", systemImage: "lasso.sparkles")
                }
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "bubble.left.and.bubble.right.fill")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(AppTheme.primary)
    }
}

// Modern Input Field Style
private struct ModernInputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.textPrimary)
                .textInputAutocapitalization(.words)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                .stroke(AppTheme.outline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
    }
}

// Modern Password Field with Forgot Password
private struct ModernPasswordField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let showForgotPassword: Bool
    @State private var isSecure = true

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 20)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.textPrimary)
                } else {
                    TextField(placeholder, text: $text)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.textPrimary)
                }
                
                Button {
                    isSecure.toggle()
                } label: {
                    Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(AppTheme.textTertiary)
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(AppTheme.outline, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            
            if showForgotPassword {
                HStack {
                    Spacer()
                    Button {
                        // Handle forgot password
                    } label: {
                        Text("Forgot Password?")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xs)
            }
        }
    }
}

// Social Login Button
private struct SocialLoginButton: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        Button {
            // Handle social login
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                Text(icon)
                    .font(.system(size: 20, weight: .bold))
                Text(text)
                    .font(AppTheme.Typography.bodyBold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}

private struct CompactPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.vertical, AppTheme.Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .fill(AppTheme.primary)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MockDataStore())
    }
}
