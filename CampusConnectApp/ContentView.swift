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
                    .transition(.move(edge: .leading))
            } else {
                MainTabView()
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut, value: store.currentUser)
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
    @State private var selectedAvatar = "person.fill"
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var useCustomImage = false
    @State private var validationMessage: String?
    @State private var isSocialLoggingIn = false
    
    private let avatarOptions = [
        "person.fill", // Generic/Male
        "person.circle.fill" // Generic/Female
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Professional Animated Background
                GeometryReader { proxy in
                    ZStack {
                        AppTheme.background.ignoresSafeArea()
                        
                        // Decorative Blobs
                        Circle()
                            .fill(AppTheme.primary.opacity(0.1))
                            .frame(width: 300, height: 300)
                            .blur(radius: 60)
                            .offset(x: -100, y: -150)
                        
                        Circle()
                            .fill(AppTheme.secondary.opacity(0.1))
                            .frame(width: 300, height: 300)
                            .blur(radius: 60)
                            .offset(x: 100, y: 150)
                    }
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Top Illustration Section with Safe Area
                        VStack(spacing: AppTheme.Spacing.lg) {
                            Image("login_img")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 180)
                                .shadow(color: AppTheme.Shadow.lg, radius: 20, x: 0, y: 10)
                            
                            // Welcome Message
                            VStack(spacing: AppTheme.Spacing.xs) {
                                Text(isRegister ? "Join CampusConnect" : "Welcome Back")
                                    .font(AppTheme.Typography.largeTitle)
                                    .foregroundStyle(AppTheme.textPrimary)
                                
                                Text(isRegister ? "Connect with your classmates today" : "Sign in to continue your journey")
                                    .font(AppTheme.Typography.body)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, AppTheme.Spacing.lg)
                            }
                        }
                        .padding(.top, AppTheme.Spacing.xl)
                        .padding(.bottom, AppTheme.Spacing.lg)

                        // Form Card
                        VStack(spacing: AppTheme.Spacing.lg) {
                            // Mode Toggle
                            HStack(spacing: 0) {
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        isRegister = false
                                    }
                                } label: {
                                    Text("Login")
                                        .font(AppTheme.Typography.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(isRegister ? AppTheme.textSecondary : AppTheme.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(isRegister ? Color.clear : .white)
                                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                        .shadow(color: isRegister ? .clear : AppTheme.Shadow.sm, radius: 4, x: 0, y: 2)
                                }
                                
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        isRegister = true
                                    }
                                } label: {
                                    Text("Register")
                                        .font(AppTheme.Typography.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(isRegister ? AppTheme.primary : AppTheme.textSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(isRegister ? .white : Color.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                        .shadow(color: isRegister ? AppTheme.Shadow.sm : .clear, radius: 4, x: 0, y: 2)
                                }
                            }
                            .padding(4)
                            .background(AppTheme.background)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
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
                                    HStack(alignment: .center) {
                                        Rectangle()
                                            .fill(AppTheme.outline)
                                            .frame(height: 1)
                                        Text("Or connect using")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundStyle(AppTheme.textSecondary)
                                            .padding(.horizontal, AppTheme.Spacing.sm)
                                            .layoutPriority(1)
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
                                        ) {
                                            isSocialLoggingIn = true
                                            store.socialLogin(provider: "Facebook")
                                        }
                                        
                                        SocialLoginButton(
                                            icon: "G",
                                            text: "Google",
                                            color: Color(hex: "DB4437")
                                        ) {
                                            isSocialLoggingIn = true
                                            store.socialLogin(provider: "Google")
                                        }
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
                
                if isSocialLoggingIn {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: AppTheme.Spacing.md) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Logging in...")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(.white)
                    }
                    .padding(AppTheme.Spacing.xl)
                    .background(AppTheme.surface.opacity(0.2)) // Glassmorphism
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                }
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
