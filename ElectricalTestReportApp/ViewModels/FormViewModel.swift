//
//  FormViewModel.swift
//  ElectricalTestReportApp
//
//  Created by Jeff Chadkirk on 29/4/2025.
//


// ViewModels/FormViewModel.swift
import Foundation
import SwiftUI

class FormViewModel: ObservableObject {
    @Published var customer = ""
    @Published var siteAddress = ""
    @Published var workActivity = ""
    @Published var jobNo = ""
    @Published var testResults: [TestResult] = []
    @Published var testedBy = ""
    @Published var licenceNumber = ""
    @Published var date = Date()
    @Published var signatureImage: UIImage? = nil

    // Validation
    var isFormValid: Bool {
        !customer.isEmpty && !siteAddress.isEmpty && !testedBy.isEmpty && !licenceNumber.isEmpty && !testResults.isEmpty && signatureImage != nil
    }

    func reset() {
        customer = ""
        siteAddress = ""
        workActivity = ""
        jobNo = ""
        testResults = []
        testedBy = ""
        licenceNumber = ""
        date = Date()
        signatureImage = nil
    }

    func toElectricalTestReport() -> ElectricalTestReport {
        ElectricalTestReport(
            id: UUID(),
            customer: customer,
            siteAddress: siteAddress,
            workActivity: workActivity,
            jobNo: jobNo,
            testResults: testResults,
            testedBy: testedBy,
            licenceNumber: licenceNumber,
            date: date,
            signatureData: signatureImage?.pngData()
        )
    }
}