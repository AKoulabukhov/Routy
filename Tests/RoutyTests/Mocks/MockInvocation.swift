struct MockInvocation<Input, Output> {
    var calls: [Input] = []
    var lastCall: Input? { calls.last }
    var callsCount: Int { calls.count }
    var hasCalls: Bool { !calls.isEmpty }
    var output: Output!

    mutating func reset() {
        calls = []
        output = nil
    }
}
