import SwiftUI
import AVFoundation

struct ContentView: View {

    // State variables for fruits
    @State private var fruitType1 = "apple"
    @State private var fruitType2 = "banana"
    @State private var fruitType3 = "watermelon"

    // Game state variables
    @State private var points = 0
    @State private var streak = 0
    @State private var streakRecord = 0
    @State private var difficulty = 1

    // Flags to control game logic
    @State private var masterUnlocked = false
    @State private var topMessage = ""
    @State private var start = true

    // Animation for title text
    @State private var titleScale: CGFloat = 1.0

    // Spin state and timer variables
    @State private var isSpinning = false
    @State private var spinTimer: Timer?

    // Code input for infinite spin mode
    @State private var codeInput = ""
    @State private var infiniteSpin = false

    @State private var audioPlayer: AVAudioPlayer?

    // Function to play the spin sound
    private func playSpinSound() {
        if let path = Bundle.main.path(forResource: "spinSound", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.play()
            } catch {
                print("Error loading spin sound: \(error)")
            }
        }
    }

    // Function to stop the spin sound
    private func stopSpinSound() {
        audioPlayer?.stop()
    }

    // Function to get a random fruit based on difficulty
    private func getRandomFruit() -> String {
        let fruits = ["apple", "banana", "watermelon"]
        let maxIndex = min(difficulty, fruits.count - 1)
        return fruits[Int.random(in: 0...maxIndex)]
    }

    // Function to handle the spin logic
    private func spin() {
        isSpinning = true
        spinTimer?.invalidate()
        let interval = 0.05

        playSpinSound()

        if infiniteSpin {
            spinTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                fruitType1 = getRandomFruit()
                fruitType2 = getRandomFruit()
                fruitType3 = getRandomFruit()

                if Int(Date().timeIntervalSince1970) % 2 == 0 {
                    finalizeSpin()
                }
            }
        } else {
            var iterations = 10
            spinTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                fruitType1 = getRandomFruit()
                fruitType2 = getRandomFruit()
                fruitType3 = getRandomFruit()
                iterations -= 1

                if iterations <= 0 {
                    timer.invalidate()
                    finalizeSpin()
                    isSpinning = false
                    stopSpinSound()
                }
            }
        }
    }

    // Function to finalize the spin and update game state
    private func finalizeSpin() {
        let isWin = fruitType1 == fruitType2 && fruitType2 == fruitType3

        if isWin {
            let pointsEarned = (difficulty == 1) ? 1 : 5
            points += pointsEarned
            streak += 1

            if streak > streakRecord {
                streakRecord = streak
            }

            if streak == 1 && start {
                topMessage = "Just one more win"
            } else if streak == 2 && !masterUnlocked {
                topMessage = "Awesome, you made it. Try the MASTER level"
                masterUnlocked = true
                start = false
            } else if streak >= 3 {
                topMessage = "Holy cow, what a pro"
            }
        } else {
            streak = 0
            topMessage = start ? "Unlock MASTER level by winning twice in a row" : ""
        }
    }

    var body: some View {
        ZStack {
            // Background wallpaper
            Image("wallpaper")
                .resizable()
                .ignoresSafeArea()

            VStack {
                // Title text with black outline
                ZStack {
                    Text("Spin Wars")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .offset(x: 2, y: 2) // Offset for the black outline

                    Text("Spin Wars")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.pink) // Main text color
                }
                .scaleEffect(titleScale)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        titleScale = 1.2
                    }
                }
                .padding()

                // Buttons to select difficulty
                HStack {
                    Button("Normal") {
                        difficulty = 1
                        if streak < 3 {
                            topMessage = ""
                        }
                    }
                    .buttonStyle(CustomButtonStyle())

                    if masterUnlocked {
                        Button("Master") {
                            difficulty = 2
                            if streak < 3 {
                                topMessage = "What a brave person"
                            }
                        }
                        .buttonStyle(CustomButtonStyle())
                    }
                }

                // Display messages to the player
                if !topMessage.isEmpty {
                    Text(topMessage)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.bottom)
                }

                // Display points and streak record with black outline
                ZStack {
                    Text("Points = \(points)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .offset(x: 2, y: 2)

                    Text("Points = \(points)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }

                ZStack {
                    Text("Streak Record = \(streakRecord)")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .offset(x: 2, y: 2)

                    Text("Streak Record = \(streakRecord)")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }

                // Button to reset points and streaks
                Button("Clear") {
                    points = 0
                    streak = 0
                    streakRecord = 0
                }
                .buttonStyle(GreyButtonStyle())
                .padding()

                Spacer()

                // Display the fruits
                HStack(spacing: 20) {
                    Image(fruitType1)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 150, maxHeight: 150)
                    Image(fruitType2)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 150, maxHeight: 150)
                    Image(fruitType3)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 150, maxHeight: 150)
                }
                .padding(.vertical, 20)

                Spacer()

                // Button to spin
                Button(action: spin) {
                    Image("button")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                }
                .disabled(isSpinning && !infiniteSpin)
                .padding(.horizontal, 20)

                // Code input field
                TextField("Enter Code", text: $codeInput)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding(.horizontal, 20)
            }
            .padding()
            .onChange(of: codeInput) {
                if codeInput == "Code" && !infiniteSpin {
                    infiniteSpin = true
                    if !isSpinning {
                        spin()
                    }
                } else if codeInput != "Code" && infiniteSpin {
                    infiniteSpin = false
                    spinTimer?.invalidate()
                    isSpinning = false
                    stopSpinSound()
                    finalizeSpin()
                }
            }
        }
    }
}

// Custom button styles
struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

struct GreyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray))
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
