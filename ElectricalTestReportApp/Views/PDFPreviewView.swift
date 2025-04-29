//
//  PDFPreviewView.swift
//  ElectricalTestReportApp
//
//  Created by Jeff Chadkirk on 29/4/2025.
//


// Views/PDFPreviewView.swift
import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    @ObservedObject var report: FormViewModel
    @State private var showShareSheet = false
    @State private var pdfData: Data? = nil

    var body: some View {
        VStack {
            if let data = pdfData, let pdfDoc = PDFDocument(data: data) {
                PDFKitRepresentedView(pdfDocument: pdfDoc)
                Button(action: { showShareSheet = true }) {
                    Label("Share PDF", systemImage: "square.and.arrow.up")
                        .padding()
                }
                .sheet(isPresented: $showShareSheet) {
                    if let data = pdfData {
                        ActivityView(activityItems: [data])
                    }
                }
            } else {
                Text("PDF Preview not available.")
            }
        }
        .onAppear {
            pdfData = PDFGenerator.generatePDF(report: report.toElectricalTestReport(), signature: report.signatureImage)
        }
    }
}

// Helper for PDFKit in SwiftUI
struct PDFKitRepresentedView: UIViewRepresentable {
    let pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}