import SwiftUI

struct RollingQuoteView: View {
    let quotes: [String]
    @State private var currentQuoteIndex = 0
    @State private var opacity = 1.0
    
    var body: some View {
        Text(quotes[currentQuoteIndex])
            .font(.title3)
            .bold()
            .multilineTextAlignment(.center)
            .foregroundColor(.blue)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .opacity(opacity)
            .onAppear {
                startQuoteTimer()
            }
    }
    
    private func startQuoteTimer() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.6)) {
                opacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
                withAnimation(.easeInOut(duration: 0.6)) {
                    opacity = 1
                }
            }
        }
    }
}
