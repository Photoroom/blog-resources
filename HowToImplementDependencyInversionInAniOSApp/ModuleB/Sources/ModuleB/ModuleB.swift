import ModuleBProtocol

public struct ModuleB {
    public init() {
    }
}

extension ModuleB: ModuleBProtocol {
    public func randomNumber() async -> Int {
        let numbers: [Int] = Array(0..<100).shuffled()
        return numbers[0]
    }
}
