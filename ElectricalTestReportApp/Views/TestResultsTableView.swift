//
//  TestResultsTableView.swift
//  ElectricalTestReportApp
//
//  Created by Jeff Chadkirk on 29/4/2025.
//


// Views/TestResultsTableView.swift
import SwiftUI

struct TestResultsTableView: View {
    @Binding var testResults: [TestResult]
    @State private var newResult = TestResult(id: UUID(), testDate: "", circuitOrEquipment: "", visualInspection: "", circuitNo: "", cableSize: "", protectionSizeType: "", neutralNo: "", earthContinuity: "", rcd: "", insulationResistance: "", polarityTest: "", faultLoopImpedance: "", operationalTest: "")
    @State private var newTestDate = Date()
    @State private var editingResult: TestResult? = nil
    @State private var showEditModal = false
    @State private var showMaxAlert = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Test Results")
                .font(.headline)
            if testResults.isEmpty {
                Text("No test results added yet.")
                    .foregroundColor(.gray)
                    .padding(.bottom, 4)
            } else {
                List {
                    ForEach(testResults) { result in
                        Button(action: {
                            editingResult = result
                            showEditModal = true
                        }) {
                            HStack {
                                Text(result.testDate)
                                Text(result.circuitOrEquipment)
                                Text(result.visualInspection)
                                Text(result.circuitNo)
                                Text(result.cableSize)
                                Text(result.protectionSizeType)
                                Text(result.neutralNo)
                                Text(result.earthContinuity)
                                Text(result.rcd)
                                Text(result.insulationResistance)
                                Text(result.polarityTest)
                                Text(result.faultLoopImpedance)
                                Text(result.operationalTest)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                .frame(maxHeight: 220)
                .listStyle(PlainListStyle())
                .sheet(isPresented: $showEditModal) {
                    if let editingResult = editingResult, let idx = testResults.firstIndex(where: { $0.id == editingResult.id }) {
                        TestResultEditView(result: $testResults[idx], isPresented: $showEditModal)
                    }
                }
            }
            Divider()
            Group {
                Text("Test Date")
                DatePicker("", selection: $newTestDate, displayedComponents: .date)
                Text("Circuit/Equipment")
                TextField("Circuit/Equipment", text: $newResult.circuitOrEquipment)
                Text("Visual Inspection (Pass/Fail)")
                Picker("", selection: $newResult.visualInspection) {
                    Text("Pass").tag("Pass")
                    Text("Fail").tag("Fail")
                }
                .pickerStyle(SegmentedPickerStyle())
                Text("Circuit No.")
                TextField("Circuit No.", text: $newResult.circuitNo)
                Text("Cable Size (mm²)")
                TextField("Cable Size (mm²)", text: $newResult.cableSize)
                    .keyboardType(.decimalPad)
                Text("Protection Size and Type (Amps)")
                TextField("Protection Size and Type (Amps)", text: $newResult.protectionSizeType)
                Text("Neutral No.")
                TextField("Neutral No.", text: $newResult.neutralNo)
                Text("Earth Continuity (Ohms, '<' will be added in PDF)")
                TextField("Earth Continuity (Ohms, '<' will be added in PDF)", text: $newResult.earthContinuity)
                Text("RCD")
                TextField("RCD", text: $newResult.rcd)
                Text("Insulation Resistance (MEGAOHM, '>' will be added in PDF)")
                TextField("Insulation Resistance (MEGAOHM, '>' will be added in PDF)", text: $newResult.insulationResistance)
                Text("Polarity Test Equipment or Circuit (Pass/Fail)")
                Picker("", selection: $newResult.polarityTest) {
                    Text("Pass").tag("Pass")
                    Text("Fail").tag("Fail")
                }
                .pickerStyle(SegmentedPickerStyle())
                Text("Fault Loop Impedance Test (Ohms, '<' will be added in PDF)")
                TextField("Fault Loop Impedance Test (Ohms, '<' will be added in PDF)", text: $newResult.faultLoopImpedance)
                Text("Operational Test (Pass/Fail)")
                Picker("", selection: $newResult.operationalTest) {
                    Text("Pass").tag("Pass")
                    Text("Fail").tag("Fail")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Add Result") {
                if testResults.count >= 8 {
                    showMaxAlert = true
                    return
                }
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                newResult.testDate = formatter.string(from: newTestDate)
                if !newResult.testDate.isEmpty {
                    testResults.append(newResult)
                    newResult = TestResult(id: UUID(), testDate: "", circuitOrEquipment: "", visualInspection: "", circuitNo: "", cableSize: "", protectionSizeType: "", neutralNo: "", earthContinuity: "", rcd: "", insulationResistance: "", polarityTest: "", faultLoopImpedance: "", operationalTest: "")
                    newTestDate = Date()
                }
            }
            .alert(isPresented: $showMaxAlert) {
                Alert(
                    title: Text("Maximum Test Results Reached"),
                    message: Text("You have reached the maximum of 8 test results for this sheet. Would you like to clear all test results?"),
                    primaryButton: .destructive(Text("Clear")) {
                        testResults.removeAll()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct TestResultEditView: View {
    @Binding var result: TestResult
    @Binding var isPresented: Bool
    @State private var editDate = Date()

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Test Date", selection: Binding(
                    get: {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        return formatter.date(from: result.testDate) ?? Date()
                    },
                    set: { newDate in
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        result.testDate = formatter.string(from: newDate)
                    }
                ), displayedComponents: .date)
                TextField("Circuit/Equipment", text: $result.circuitOrEquipment)
                Picker("Visual Inspection (Pass/Fail)", selection: $result.visualInspection) {
                    Text("Pass").tag("Pass")
                    Text("Fail").tag("Fail")
                }
                .pickerStyle(SegmentedPickerStyle())
                TextField("Circuit No.", text: $result.circuitNo)
                TextField("Cable Size (mm²)", text: $result.cableSize)
                    .keyboardType(.decimalPad)
                TextField("Protection Size and Type (Amps)", text: $result.protectionSizeType)
                TextField("Neutral No.", text: $result.neutralNo)
                TextField("Earth Continuity (Ohms, '<' will be added in PDF)", text: $result.earthContinuity)
                TextField("RCD", text: $result.rcd)
                TextField("Insulation Resistance (MEGAOHM, '>' will be added in PDF)", text: $result.insulationResistance)
                Picker("Polarity Test Equipment or Circuit (Pass/Fail)", selection: $result.polarityTest) {
                    Text("Pass").tag("Pass")
                    Text("Fail").tag("Fail")
                }
                .pickerStyle(SegmentedPickerStyle())
                TextField("Fault Loop Impedance Test (Ohms, '<' will be added in PDF)", text: $result.faultLoopImpedance)
                Picker("Operational Test (Pass/Fail)", selection: $result.operationalTest) {
                    Text("Pass").tag("Pass")
                    Text("Fail").tag("Fail")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .navigationTitle("Edit Test Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { isPresented = false }
                }
            }
        }
    }
}