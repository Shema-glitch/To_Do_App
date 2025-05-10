//
//  To-Do App
//
//  Created by Shema Charmant on 5/7/25.
//

import SwiftUI

struct TutorialOverlay: View {
    @Binding var isShowing: Bool
    let onComplete: () -> Void
    @State private var currentStep = 0
    @State private var offset = CGSize.zero
    @State private var opacity = 0.0
    
    let steps = [
        (title: "Welcome to TaskFlow! 👋", message: "Let's get you started with smart task management", icon: "wand.and.stars"),
        (title: "AI-Powered Magic ✨", message: "Watch as TaskFlow intelligently categorizes and prioritizes your tasks", icon: "brain"),
        (title: "Voice Commands 🎤", message: "Try adding tasks hands-free with voice commands", icon: "waveform"),
        (title: "Smart Organization 📊", message: "Your tasks are automatically sorted into beautiful categories", icon: "folder.fill")
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 20) {
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .padding()
                    .transition(.scale.combined(with: .opacity))
                
                Text(steps[currentStep].title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .transition(.slide)
                
                Text(steps[currentStep].message)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal)
                    .transition(.move(edge: .trailing))
                
                HStack(spacing: 8) {
                    ForEach(0..<steps.count) { index in
                        Circle()
                            .fill(currentStep == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentStep == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentStep)
                    }
                }
                
                Button(action: {
                    withAnimation(.spring()) {
                        if currentStep < steps.count - 1 {
                            currentStep += 1
                        } else {
                            isShowing = false
                            onComplete()
                        }
                    }
                }) {
                    Text(currentStep < steps.count - 1 ? "Next" : "Get Started")
                        .padding()
                        .frame(width: 200)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                }
                .transition(.scale)
            }
            .padding()
            .background(Color(.systemBackground).opacity(0.1))
            .cornerRadius(20)
            .padding()
            .offset(offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring()) {
                    opacity = 1.0
                    offset = .zero
                }
            }
        }
    }
}
