//
//  SharedComponents.swift
//  app-accelerator-2025
//

import SwiftUI

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
            (a, r, g, b) = (255, 0, 0, 0)
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

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.width ?? 0,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                      y: bounds.minY + result.frames[index].minY),
                          proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(
                width: maxWidth,
                height: currentY + lineHeight
            )
        }
    }
}

struct TrustPathLogo: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Unified TP logo shape with gradient
            TrustPathLogoShape()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.15, green: 0.29, blue: 0.39), // Dark blue-teal (top-left)
                            Color(red: 0.30, green: 0.50, blue: 0.55)  // Lighter green-teal (bottom-right)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .frame(width: size, height: size)
    }
}

struct TrustPathLogoShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let size = min(rect.width, rect.height)
        
        // T shape (left side) - unified path
        // Horizontal bar of T
        path.move(to: CGPoint(x: size * 0.1, y: size * 0.15))
        path.addLine(to: CGPoint(x: size * 0.5, y: size * 0.15))
        path.addLine(to: CGPoint(x: size * 0.5, y: size * 0.25))
        path.addLine(to: CGPoint(x: size * 0.25, y: size * 0.25))
        path.addLine(to: CGPoint(x: size * 0.25, y: size * 0.9))
        path.addLine(to: CGPoint(x: size * 0.15, y: size * 0.9))
        path.addLine(to: CGPoint(x: size * 0.15, y: size * 0.25))
        path.addLine(to: CGPoint(x: size * 0.1, y: size * 0.25))
        path.closeSubpath()
        
        // P shape with arrow (right side) - unified path
        // Vertical stem of P (shared with T)
        path.move(to: CGPoint(x: size * 0.5, y: size * 0.15))
        path.addLine(to: CGPoint(x: size * 0.6, y: size * 0.15))
        path.addLine(to: CGPoint(x: size * 0.6, y: size * 0.9))
        path.addLine(to: CGPoint(x: size * 0.5, y: size * 0.9))
        path.closeSubpath()
        
        // P loop with arrow
        let pCenterX = size * 0.6
        let pCenterY = size * 0.35
        let pRadius = size * 0.2
        
        // Top arc of P
        path.move(to: CGPoint(x: pCenterX, y: pCenterY - pRadius))
        path.addArc(
            center: CGPoint(x: pCenterX, y: pCenterY),
            radius: pRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        // Arrow pointing right (integrated in P loop)
        let arrowStartX = pCenterX + pRadius
        let arrowLength = size * 0.12
        path.addLine(to: CGPoint(x: arrowStartX + arrowLength, y: pCenterY))
        path.addLine(to: CGPoint(x: arrowStartX + arrowLength * 0.7, y: pCenterY - arrowLength * 0.25))
        path.move(to: CGPoint(x: arrowStartX + arrowLength, y: pCenterY))
        path.addLine(to: CGPoint(x: arrowStartX + arrowLength * 0.7, y: pCenterY + arrowLength * 0.25))
        
        // Bottom curve of P connecting back
        path.move(to: CGPoint(x: pCenterX, y: pCenterY + pRadius))
        path.addQuadCurve(
            to: CGPoint(x: size * 0.5, y: size * 0.75),
            control: CGPoint(x: size * 0.55, y: size * 0.65)
        )
        path.addLine(to: CGPoint(x: size * 0.5, y: size * 0.9))
        path.closeSubpath()
        
        return path
    }
}

