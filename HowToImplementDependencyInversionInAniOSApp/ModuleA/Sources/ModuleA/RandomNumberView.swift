import SwiftUI
import ModuleBProtocol

public struct RandomNumberView: View {

    var numberGenerator: ModuleBProtocol

    @State var randomNumber: Int?

    public init(numberGenerator: ModuleBProtocol) {
        self.numberGenerator = numberGenerator
    }

    public var body: some View {
        VStack {
            if let number = randomNumber {
                Text("You random number is \(number)")
            } else {
                Text("Tap the button to get your random number")
            }
            Button("Get random number") {
                Task {
                    randomNumber = await numberGenerator.randomNumber()
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

struct RandomNumberView_Previews: PreviewProvider {
    static var previews: some View {
        RandomNumberView(
            numberGenerator: MockNumberGenerator()
        )
    }
}

struct MockNumberGenerator: ModuleBProtocol {
    func randomNumber() async -> Int {
        42
    }
}
