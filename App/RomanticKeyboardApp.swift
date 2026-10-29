import SwiftUI

@main
struct RomanticKeyboardApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    @State private var text = ""
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 1, green: 0.8, blue: 0.88),
                                    Color(red: 0.96, green: 0.45, blue: 0.62)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 18) {
                Text("🌹 Romantic Keyboard 🌹").font(.title.bold()).foregroundColor(.white)
                Text("Settings → General → Keyboard → Keyboards → Add New Keyboard → Romantic Keyboard.\nPasse 🌐 key eken keyboard eka switch karanna.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                TextField("Methana type karala balanna 💕", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
            }
        }
    }
} 
