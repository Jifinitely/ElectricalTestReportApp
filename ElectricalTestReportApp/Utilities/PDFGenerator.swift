//
//  PDFGenerator.swift
//  ElectricalTestReportApp
//
//  Created by Jeff Chadkirk on 29/4/2025.
//


// Utilities/PDFGenerator.swift
import PDFKit
import SwiftUI

struct PDFGenerator {
    static func generatePDF(report: ElectricalTestReport, signature: UIImage?) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Electrical Test Report App",
            kCGPDFContextAuthor: "Platinum Electrical & Air"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        // A4 landscape
        let pageWidth = 841.8
        let pageHeight = 595.2
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let cgctx = ctx.cgContext
            // Fonts
            let staticFont = UIFont(name: "Helvetica", size: 10) ?? UIFont.systemFont(ofSize: 10)
            let staticFontBold = UIFont(name: "Helvetica-Bold", size: 10) ?? UIFont.boldSystemFont(ofSize: 10)
            let staticFontHeader = UIFont(name: "Helvetica-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
            let monoFont = UIFont(name: "Courier", size: 11) ?? UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
            // Header: Logo and company info
            let logo = UIImage(named: "PlatinumLogoWide")
            logo?.draw(in: CGRect(x: pageWidth/2 - 180, y: 10, width: 360, height: 70))
            let companyInfo = "CorpDevel Technologies Pty Ltd\nTrading as Platinum Electrical & Air\nPO Box 268, FERNY HILLS DC QLD 4055\nTelephone: 1300 606 380\nEmail: maintenance@platinumelectrical.net\nABN: 32 109 626 940\nContractor Licence No: 65576"
            companyInfo.draw(in: CGRect(x: 32, y: 24, width: 200, height: 80), withAttributes: [.font: staticFont])
            let accreditedMaster = UIImage(named: "AccreditedMasterElectrician")
            accreditedMaster?.draw(in: CGRect(x: pageWidth - 180, y: 25, width: 160, height: 60))
            // Title
            let title = "Electrical Test Report"
            title.draw(at: CGPoint(x: pageWidth/2 - 80, y: 70), withAttributes: [.font: staticFontHeader])
            // Two-column fields
            let leftX: CGFloat = 32
            let rightX: CGFloat = pageWidth/2 + 10
            let fieldY0: CGFloat = 100
            let fieldSpacing: CGFloat = 18
            let leftFields = ["Customer:", "Switchboard Location:", "Building Number:", "Make:", "Serial:"]
            let leftValues = [report.customer, "", "", "", ""]
            let rightFields = ["Site Address:", "Chassis ID:", "Job Number:", "Model:", "Type:"]
            let rightValues = [report.siteAddress, "", report.jobNo, "", ""]
            for i in 0..<leftFields.count {
                leftFields[i].draw(at: CGPoint(x: leftX, y: fieldY0 + CGFloat(i)*fieldSpacing), withAttributes: [.font: staticFont])
                leftValues[i].draw(at: CGPoint(x: leftX + 110, y: fieldY0 + CGFloat(i)*fieldSpacing), withAttributes: [.font: monoFont])
                rightFields[i].draw(at: CGPoint(x: rightX, y: fieldY0 + CGFloat(i)*fieldSpacing), withAttributes: [.font: staticFont])
                rightValues[i].draw(at: CGPoint(x: rightX + 110, y: fieldY0 + CGFloat(i)*fieldSpacing), withAttributes: [.font: monoFont])
            }
            // Table
            let tableY: CGFloat = fieldY0 + CGFloat(leftFields.count)*fieldSpacing + 16
            let colWidths: [CGFloat] = [
                44, 62, 62, 32, 40, 62, 32, 50, 28, 58, 74, 50, 57.8
            ]
            let tableWidth: CGFloat = colWidths.reduce(0, +)
            let tableX: CGFloat = (pageWidth - tableWidth) / 2
            let rowHeight: CGFloat = 28
            let colTitles = [
                "Test Date",
                "Circuit or Equipment",
                "Visual Inspection Complete\n(Pass/Fail)",
                "Circuit No.",
                "Cable Size",
                "Protection Size and Type",
                "Neutral No.",
                "Earth Continuity\n(Ohms)",
                "RCD",
                "Insulation Resistance\n(MEGOHM)",
                "Polarity Test Equipment or\nCircuit (Pass/Fail)",
                "Fault Loop Impedance Test\n(Ohms)",
                "Operational Test\n(Pass/Fail)"
            ]
            // Draw table header
            var x = tableX
            for (i, title) in colTitles.enumerated() {
                let w = colWidths[i]
                let headerRect = CGRect(x: x, y: tableY, width: w, height: rowHeight)
                // Center multi-line header text
                let lines = title.components(separatedBy: "\n")
                let headerFont = staticFontBold.withSize(7)
                let totalTextHeight = CGFloat(lines.count) * headerFont.lineHeight
                var lineY = headerRect.midY - totalTextHeight/2
                for line in lines {
                    let textSize = (line as NSString).size(withAttributes: [.font: headerFont])
                    let textX = headerRect.midX - textSize.width/2
                    (line as NSString).draw(at: CGPoint(x: textX, y: lineY), withAttributes: [.font: headerFont])
                    lineY += headerFont.lineHeight
                }
                cgctx.stroke(headerRect)
                x += w
            }
            // Draw table rows
            let maxRows = max(8, report.testResults.count)
            for row in 0..<maxRows {
                x = tableX
                let y = tableY + rowHeight * CGFloat(row + 1)
                for (col, w) in colWidths.enumerated() {
                    let cellRect = CGRect(x: x, y: y, width: w, height: rowHeight)
                    cgctx.stroke(cellRect)
                    // Fill with data if available
                    if row < report.testResults.count {
                        let result = report.testResults[row]
                        let values = [
                            result.testDate,
                            result.circuitOrEquipment,
                            result.visualInspection,
                            result.circuitNo,
                            result.cableSize,
                            result.protectionSizeType,
                            result.neutralNo,
                            result.earthContinuity,
                            result.rcd,
                            result.insulationResistance,
                            result.polarityTest,
                            result.faultLoopImpedance,
                            result.operationalTest
                        ]
                        if col < values.count {
                            let value = values[col]
                            let boldMonoFont = UIFont(name: "Courier-Bold", size: 8) ?? UIFont.boldSystemFont(ofSize: 8)
                            value.draw(in: cellRect.insetBy(dx: 2, dy: 2), withAttributes: [.font: boldMonoFont])
                        }
                    }
                    x += w
                }
            }
            // Footer
            let certY = tableY + rowHeight * CGFloat(maxRows + 1) + 10
            let certText = "I certify that the electrical installation, to the extent that it is effected by the electrical work, has been tested to ensure it is electrically safe and is in accordance with the requirements of the wiring rules and any other standard applying to the electrical installation under the Electrical Safety Regulation 2002."
            certText.draw(in: CGRect(x: tableX, y: certY, width: tableWidth, height: 40), withAttributes: [.font: staticFont])
            let footerY = certY + 40
            "Tested by:".draw(at: CGPoint(x: tableX, y: footerY), withAttributes: [.font: staticFont])
            report.testedBy.draw(at: CGPoint(x: tableX + 60, y: footerY), withAttributes: [.font: monoFont])
            "Licence Number:".draw(at: CGPoint(x: tableX + 220, y: footerY), withAttributes: [.font: staticFont])
            report.licenceNumber.draw(at: CGPoint(x: tableX + 320, y: footerY), withAttributes: [.font: monoFont])
            "Tester's Signature:".draw(at: CGPoint(x: tableX + 420, y: footerY), withAttributes: [.font: staticFont])
            // Draw signature image if available
            if let signature = signature {
                signature.draw(in: CGRect(x: tableX + 540, y: footerY - 8, width: 60, height: 24))
            }
            "Date:".draw(at: CGPoint(x: tableX + 620, y: footerY), withAttributes: [.font: staticFont])
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            let dateString = dateFormatter.string(from: report.date)
            dateString.draw(at: CGPoint(x: tableX + 660, y: footerY), withAttributes: [.font: monoFont])
        }
        return data
    }
}