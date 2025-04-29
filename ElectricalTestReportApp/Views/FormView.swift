//
//  FormView.swift
//  ElectricalTestReportApp
//
//  Created by Jeff Chadkirk on 29/4/2025.
//


// Views/FormView.swift
import SwiftUI

struct FormView: View {
    @ObservedObject var viewModel: FormViewModel
    @State private var showPDFPreview = false
    @State private var showValidationAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        TextField("Customer", text: $viewModel.customer)
                        TextField("Site Address", text: $viewModel.siteAddress)
                        TextField("Work Activity", text: $viewModel.workActivity)
                        TextField("Job No.", text: $viewModel.jobNo)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    TestResultsTableView(testResults: $viewModel.testResults)

                    Group {
                        TextField("Tested by", text: $viewModel.testedBy)
                        TextField("Licence Number", text: $viewModel.licenceNumber)
                        DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    Text("Signature")
                    SignaturePadView(signatureImage: $viewModel.signatureImage)
                        .frame(height: 120)

                    Button("Preview & Export PDF") {
                        if viewModel.isFormValid {
                            // Save to history
                            var reports = HistoryStorage.load()
                            reports.append(viewModel.toElectricalTestReport())
                            HistoryStorage.save(reports)
                            showPDFPreview = true
                        } else {
                            showValidationAlert = true
                        }
                    }
                    .padding()
                    .alert(isPresented: $showValidationAlert) {
                        Alert(title: Text("Missing Information"), message: Text("Please fill all required fields and add at least one test result and a signature."), dismissButton: .default(Text("OK")))
                    }
                    .sheet(isPresented: $showPDFPreview) {
                        PDFPreviewView(report: viewModel)
                    }
                }
                .padding()
            }
        }
    }
}