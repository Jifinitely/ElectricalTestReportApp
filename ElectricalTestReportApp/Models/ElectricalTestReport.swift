//
//  ElectricalTestReport.swift
//  ElectricalTestReportApp
//
//  Created by Jeff Chadkirk on 29/4/2025.
//


// Models/ElectricalTestReport.swift
import Foundation

struct ElectricalTestReport: Identifiable, Codable {
    let id: UUID
    var customer: String
    var siteAddress: String
    var workActivity: String
    var jobNo: String
    var testResults: [TestResult]
    var testedBy: String
    var licenceNumber: String
    var date: Date
    var signatureData: Data? // UIImage PNG data
}

// Models/TestResult.swift
import Foundation

struct TestResult: Identifiable, Codable {
    let id: UUID
    var testDate: String
    var circuitOrEquipment: String
    var visualInspection: String
    var circuitNo: String
    var cableSize: String
    var protectionSizeType: String
    var neutralNo: String
    var earthContinuity: String
    var rcd: String
    var insulationResistance: String
    var polarityTest: String
    var faultLoopImpedance: String
    var operationalTest: String
}