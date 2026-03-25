//
//  DemoCalculatorScreen.swift
//  DemoCalculatorScreen
//
//  Created by Utsav Shah on 25/03/26.
//

import SwiftUI
import KMPSDK

/// Primary SDK surface: presentation only; all business rules live in `KMPSDK`.
public struct DemoCalculatorScreen: View {
    @StateObject private var model: CalculatorViewModel

    public init(calculator: any ArithmeticCalculating) {
        _model = StateObject(wrappedValue: CalculatorViewModel(calculator: calculator))
    }

    public var body: some View {
        NavigationView {
            Form {
                if let serviceError = model.serviceErrorMessage {
                    serviceErrorSection(serviceError)
                }

                if let validation = model.validationMessage {
                    validationSection(validation)
                }

                Section(header: Text("Operands")) {
                    HStack {
                        Text("Left")
                        TextField("Left", text: Binding(
                            get: { model.lhsText },
                            set: { model.setLhs($0) }
                        ))
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Right")
                        TextField("Right", text: Binding(
                            get: { model.rhsText },
                            set: { model.setRhs($0) }
                        ))
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .multilineTextAlignment(.trailing)
                    }
                }

                Section(header: Text("Operation")) {
                    Picker("Operation", selection: Binding(
                        get: { model.selectedOperation },
                        set: { model.selectOperation($0) }
                    )) {
                        ForEach(ArithmeticOperator.allCases, id: \.self) { op in
                            Text(op.rawValue).tag(op)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Result (KMPSDK)")) {
                    HStack {
                        Text("Value")
                        Spacer()
                        if model.isComputing {
                            ProgressView()
                                .accessibilityLabel("Loading result")
                        } else {
                            Text(model.resultText)
                                .font(.title2.monospacedDigit())
                                .foregroundStyle(.primary)
                        }
                    }
                }

                Section {
                    Button {
                        Task { await model.compute() }
                    } label: {
                        Label("Calculate", systemImage: "function")
                    }
                    .disabled(model.isComputing)
                }
            }
            .navigationTitle("Arithmetic")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }

    @ViewBuilder
    private func serviceErrorSection(_ message: String) -> some View {
        let content = Section {
            Label {
                Text(message)
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }
            .font(.subheadline)
        }
        if #available(iOS 16.0, macOS 13.0, *) {
            content.listRowBackground(Color.red.opacity(0.12))
        } else {
            content
        }
    }

    @ViewBuilder
    private func validationSection(_ message: String) -> some View {
        let content = Section {
            Label {
                Text(message)
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.orange)
            }
            .font(.subheadline)
        }
        if #available(iOS 16.0, macOS 13.0, *) {
            content.listRowBackground(Color.orange.opacity(0.1))
        } else {
            content
        }
    }
}

#if DEBUG
#Preview {
    DemoCalculatorScreen(calculator: LiveArithmeticCalculator(simulatedLatencyNanoseconds: 0))
}
#endif
