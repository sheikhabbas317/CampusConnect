//
//  Theme.swift
//  CampusConnectApp
//
//  Created by GitHub Copilot on 26/12/2025.
//

import SwiftUI

enum AppTheme {
    // MARK: - Colors
    static let primary = Color(hex: "4F46E5") // Indigo 600
    static let primaryDark = Color(hex: "4338CA") // Indigo 700
    static let primaryLight = Color(hex: "818CF8") // Indigo 400
    
    static let secondary = Color(hex: "0EA5E9") // Sky 500
    static let accent = Color(hex: "F59E0B") // Amber 500
    
    static let background = Color(hex: "F8FAFC") // Slate 50
    static let surface = Color.white
    static let card = Color.white
    
    static let textPrimary = Color(hex: "0F172A") // Slate 900
    static let textSecondary = Color(hex: "475569") // Slate 600
    static let textTertiary = Color(hex: "94A3B8") // Slate 400
    
    static let outline = Color(hex: "E2E8F0") // Slate 200
    
    static let success = Color(hex: "10B981") // Emerald 500
    static let warning = Color(hex: "F59E0B") // Amber 500
    static let error = Color(hex: "EF4444") // Red 500

    // MARK: - Gradients
    static let gradient = LinearGradient(
        colors: [primary, secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glassGradient = LinearGradient(
        colors: [.white.opacity(0.8), .white.opacity(0.4)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let softGradient = LinearGradient(
        colors: [Color(hex: "F1F5F9"), Color(hex: "E2E8F0")],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Radius
    enum Radius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 9999
    }

    // MARK: - Shadows
    enum Shadow {
        static let sm = Color.black.opacity(0.05)
        static let md = Color.black.opacity(0.1)
        static let lg = Color.black.opacity(0.15)
        
        static let card = Color.black.opacity(0.06)
        static let cardElevated = Color.black.opacity(0.12)
        static let button = Color.primary.opacity(0.25)
    }

    // MARK: - Typography
    enum Typography {
        // Large Display
        static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title1 = Font.system(.title, design: .rounded).weight(.bold)
        static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
        static let title3 = Font.system(.title3, design: .rounded).weight(.semibold)
        
        // Headlines
        static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
        static let subheadline = Font.system(.subheadline, design: .rounded).weight(.medium)
        
        // Body Text
        static let body = Font.system(.body, design: .default)
        static let bodyBold = Font.system(.body, design: .default).weight(.semibold)
        
        // Small Text
        static let footnote = Font.system(.footnote, design: .default)
        static let footnoteBold = Font.system(.footnote, design: .default).weight(.semibold)
        static let caption = Font.system(.caption, design: .default)
        static let caption2 = Font.system(.caption2, design: .default)
    }
}

// Helper for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Shared Styles

struct AppCardModifier: ViewModifier {
    var padding: CGFloat = AppTheme.Spacing.md
    var elevated: Bool = false
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            .shadow(
                color: elevated ? AppTheme.Shadow.cardElevated : AppTheme.Shadow.card,
                radius: elevated ? 16 : 12,
                x: 0,
                y: elevated ? 8 : 6
            )
    }
}

struct AppInputModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTheme.Typography.body)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous)
                    .stroke(AppTheme.outline.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.headline)
            .foregroundStyle(.white)
            .padding(.vertical, AppTheme.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .fill(AppTheme.primary)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(color: AppTheme.primary.opacity(0.3), radius: 12, x: 0, y: 6)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.bodyBold)
            .foregroundStyle(AppTheme.primary)
            .padding(.vertical, AppTheme.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .fill(AppTheme.primary.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .stroke(AppTheme.primary.opacity(0.3), lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ChipModifier: ViewModifier {
    var isActive: Bool
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .font(AppTheme.Typography.footnoteBold)
            .foregroundStyle(isActive ? color : AppTheme.textPrimary)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                Capsule()
                    .fill(isActive ? color.opacity(0.15) : AppTheme.card)
            )
            .overlay(
                Capsule()
                    .stroke(isActive ? color.opacity(0.3) : Color.clear, lineWidth: 1)
            )
    }
}

extension View {
    func appCard(padding: CGFloat = AppTheme.Spacing.md, elevated: Bool = false) -> some View {
        modifier(AppCardModifier(padding: padding, elevated: elevated))
    }
    
    func appInput() -> some View {
        modifier(AppInputModifier())
    }
    
    func primaryButtonStyle() -> some View {
        buttonStyle(PrimaryButtonStyle())
    }
    
    func secondaryButtonStyle() -> some View {
        buttonStyle(SecondaryButtonStyle())
    }
    
    func chipStyle(isActive: Bool, color: Color = AppTheme.primary) -> some View {
        modifier(ChipModifier(isActive: isActive, color: color))
    }
}
