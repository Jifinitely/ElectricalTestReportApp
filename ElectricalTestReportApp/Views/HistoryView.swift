import SwiftUI
import PDFKit

struct HistoryView: View {
    @State private var reports: [ElectricalTestReport] = HistoryStorage.load()
    @State private var showShareSheet = false
    @State private var pdfDataToShare: Data? = nil
    @State private var pdfPreviewData: Data? = nil
    @State private var showPDFPreview = false

    var body: some View {
        VStack {
            if reports.isEmpty {
                Text("No history available.")
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(reports) { report in
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(report.customer)
                                        .font(.headline)
                                    Text("Date: \(report.date, formatter: dateFormatter)")
                                        .font(.subheadline)
                                }
                                Spacer()
                                Button(action: {
                                    pdfDataToShare = PDFGenerator.generatePDF(report: report, signature: nil)
                                    showShareSheet = true
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .imageScale(.large)
                                        .padding(.leading, 8)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Button(action: {
                                    pdfPreviewData = PDFGenerator.generatePDF(report: report, signature: nil)
                                    showPDFPreview = true
                                }) {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .imageScale(.large)
                                        .padding(.leading, 8)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    .onDelete(perform: deleteReport)
                }
            }
        }
        .navigationTitle("History")
        .sheet(isPresented: $showShareSheet) {
            if let data = pdfDataToShare {
                ActivityView(activityItems: [data])
            }
        }
        .sheet(isPresented: $showPDFPreview) {
            if let data = pdfPreviewData, let pdfDoc = PDFDocument(data: data) {
                PDFKitRepresentedView(pdfDocument: pdfDoc)
            } else {
                Text("PDF Preview not available.")
            }
        }
        .onAppear {
            reports = HistoryStorage.load()
        }
    }

    private func deleteReport(at offsets: IndexSet) {
        reports.remove(atOffsets: offsets)
        HistoryStorage.save(reports)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}

struct HistoryStorage {
    static let key = "exported_reports"
    static func load() -> [ElectricalTestReport] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let reports = try? JSONDecoder().decode([ElectricalTestReport].self, from: data) else {
            return []
        }
        return reports
    }
    static func save(_ reports: [ElectricalTestReport]) {
        if let data = try? JSONEncoder().encode(reports) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
} 