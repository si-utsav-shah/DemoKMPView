//
//  CalculatorViewModel.swift
//  CalculatorViewModel
//
//  Created by Utsav Shah on 25/03/26.
//

import Combine
import KMPSDK

/// Presentation layer: owns UI state and maps **KMPSDK** outcomes to strings.
/// Uses `ObservableObject` so the view SDK supports iOS versions before `@Observable` (iOS 17+).
/// Arithmetic rules live only in `KMPSDK` (`ArithmeticCalculating` implementations).
@MainActor
final class CalculatorViewModel: ObservableObject {
    @Published private(set) var lhsText: String = "12"
    @Published private(set) var rhsText: String = "3"
    @Published private(set) var selectedOperation: ArithmeticOperator = .add
    @Published private(set) var resultText: String = "—"
    /// Input/parsing only — before a `CalculationRequest` is sent to **KMPSDK**.
    @Published private(set) var validationMessage: String?
    /// Mapped from **KMPSDK** service errors (not business-rule duplication).
    @Published private(set) var serviceErrorMessage: String?
    @Published private(set) var isComputing = false

    private let calculator: any ArithmeticCalculating

    init(calculator: any ArithmeticCalculating) {
        self.calculator = calculator
    }

    func setLhs(_ text: String) {
        lhsText = text
    }

    func setRhs(_ text: String) {
        rhsText = text
    }

    func selectOperation(_ operation: ArithmeticOperator) {
        selectedOperation = operation
    }

    func compute() async {
        validationMessage = nil
        serviceErrorMessage = nil

        guard let lhs = Double(lhsText), let rhs = Double(rhsText) else {
            validationMessage = "Enter valid numbers."
            resultText = "—"
            return
        }

        isComputing = true
        defer { isComputing = false }

        let request = CalculationRequest(lhs: lhs, rhs: rhs, operation: selectedOperation)
        do {
            let value = try await calculator.calculate(request)
            resultText = formatForDisplay(value)
        } catch let error as ArithmeticError {
            resultText = "—"
            serviceErrorMessage = KMPSDKErrorMapping.userMessage(for: error)
        } catch is CancellationError {
            resultText = "—"
        } catch {
            resultText = "—"
            let message = KMPSDKErrorMapping.userMessage(forUnknownServiceError: error)
            if !message.isEmpty {
                serviceErrorMessage = message
            }
        }
    }

    private func formatForDisplay(_ value: Double) -> String {
        if value.rounded(.towardZero) == value, abs(value) <= Double(Int.max) {
            return String(Int(value))
        }
        return String(format: "%.6g", value)
    }
}
