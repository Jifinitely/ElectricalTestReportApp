import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct SettingsView: View {
    // Company Info
    @AppStorage("companyName") private var companyName = "Platinum Electrical & Air"
    @AppStorage("companyAddress") private var companyAddress = "PO Box 268, FERNY HILLS DC QLD 4055"
    @AppStorage("companyPhone") private var companyPhone = "1300 606 380"
    @AppStorage("companyEmail") private var companyEmail = "maintenance@platinumelectrical.net"
    @AppStorage("companyABN") private var companyABN = "32 109 626 940"
    @AppStorage("companyLicense") private var companyLicense = "65576"
    // Tester Info
    @AppStorage("testerName") private var testerName = ""
    @AppStorage("testerLicense") private var testerLicense = ""
    // Signature
    @AppStorage("defaultSignature") private var defaultSignature: Data?
    @State private var signatureImage: UIImage? = nil
    @State private var showSignaturePad = false
    @State private var tempSignatureImage: UIImage? = nil // For live preview
    // Theme
    @AppStorage("isDarkMode") private var isDarkMode = false
    // Export/Import
    @State private var showExportSheet = false
    @State private var exportData: Data? = nil
    @State private var showImportPicker = false
    // Alert for reset
    @State private var showResetAlert = false
    @State private var showHelp = false
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Company Information")) {
                        TextField("Company Name", text: $companyName)
                        TextField("Address", text: $companyAddress)
                        TextField("Phone", text: $companyPhone)
                        TextField("Email", text: $companyEmail)
                        TextField("ABN", text: $companyABN)
                        TextField("License Number", text: $companyLicense)
                    }
                    Section(header: Text("Default Tester Information")) {
                        TextField("Tester Name", text: $testerName)
                        TextField("License Number", text: $testerLicense)
                    }
                    Section(header: Text("Signature Management")) {
                        if let data = defaultSignature, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                        } else {
                            Text("No default signature saved.")
                        }
                        Button("Set Default Signature") {
                            tempSignatureImage = nil
                            showSignaturePad = true
                        }
                        Button("Clear Default Signature") {
                            defaultSignature = nil
                        }
                        if let tempImage = tempSignatureImage {
                            Text("Signature Preview:")
                            Image(uiImage: tempImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                                .border(Color.blue)
                        }
                    }
                    Section(header: Text("Appearance")) {
                        Toggle("Dark Mode", isOn: $isDarkMode)
                    }
                    Section(header: Text("Export/Backup")) {
                        Button("Export All Reports") {
                            let reports = HistoryStorage.load()
                            if let data = try? JSONEncoder().encode(reports) {
                                exportData = data
                                showExportSheet = true
                            }
                        }
                        .sheet(isPresented: $showExportSheet) {
                            if let data = exportData {
                                ActivityView(activityItems: [data])
                            }
                        }
                        Button("Import/Restore Backup") {
                            showImportPicker = true
                        }
                        .fileImporter(isPresented: $showImportPicker, allowedContentTypes: [.json]) { result in
                            switch result {
                            case .success(let url):
                                if let data = try? Data(contentsOf: url),
                                   let reports = try? JSONDecoder().decode([ElectricalTestReport].self, from: data) {
                                    HistoryStorage.save(reports)
                                }
                            default: break
                            }
                        }
                    }
                    Section(header: Text("Reset App Data")) {
                        Button("Reset All Data") {
                            showResetAlert = true
                        }
                        .foregroundColor(.red)
                    }
                    Section(header: Text("About/Help")) {
                        Text("Version 1.0")
                        Text("Support: jeff.chadkirk@platinumelectrical.net")
                        NavigationLink("Test Standards (AS/NZS 3000, 3018, 3008)", destination: StandardsView())
                        Button("In-App Help") { showHelp = true }
                    }
                }
                .navigationTitle("Settings")
                .alert(isPresented: $showResetAlert) {
                    Alert(
                        title: Text("Reset All Data?"),
                        message: Text("This will delete all saved reports and settings. This action cannot be undone."),
                        primaryButton: .destructive(Text("Reset")) {
                            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                        },
                        secondaryButton: .cancel()
                    )
                }
                .sheet(isPresented: $showSignaturePad) {
                    SignaturePadView(signatureImage: Binding(
                        get: { tempSignatureImage },
                        set: { newImage in
                            tempSignatureImage = newImage
                            // Do not save to defaultSignature until user closes modal
                        })
                    )
                    .onDisappear {
                        if let img = tempSignatureImage, let data = img.pngData() {
                            defaultSignature = data
                            signatureImage = img
                        }
                    }
                }
                .sheet(isPresented: $showHelp) {
                    HelpView()
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Help & Instructions")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 8)
                    Group {
                        Text("• Fill out the Electrical Test Report form with all required details, including customer, site address, job number, and test results.")
                        Text("• You can add up to 8 test results per report. If you reach the limit, a popup will ask if you want to clear all test results. Only test results are cleared; all other form fields remain unchanged.")
                        Text("• For Cable Size, enter only the number (e.g., 2.5). The unit 'mm²' (millimetres squared) will be added automatically in the PDF.")
                        Text("• For Protection Size and Type, enter only the number (e.g., 20). The unit 'A' (Amps) will be added automatically in the PDF.")
                        Text("• For Earth Continuity and Fault Loop Impedance, enter only the number. The '<' (less than) symbol will be added automatically in the PDF.")
                        Text("• For Insulation Resistance, enter only the number. The '>' (greater than) symbol will be added automatically in the PDF.")
                        Text("• For Pass/Fail fields, simply select Pass or Fail using the provided options.")
                        Text("• Add each test result by entering the details and tapping 'Add Result'. You can add multiple results per report.")
                        Text("• Tap 'Preview & Export PDF' to generate a PDF of your report. You can share or save the PDF from the preview screen.")
                        Text("• All exported reports are saved in the History tab. You can view, share, or delete any report from your history.")
                        Text("• Use the Settings tab to update your company and tester information, manage your default signature, and backup or restore your data.")
                        Text("• To set a default signature, tap 'Set Default Signature' and sign in the pad. The signature will be used on all new reports.")
                        Text("• Use 'Export All Reports' to back up your data as a ZIP file. Use 'Import/Restore Backup' to restore from a backup file.")
                        Text("• For support, email jeff.chadkirk@platinumelectrical.net.")
                    }
                    Divider()
                    Text("Frequently Asked Questions (FAQs)")
                        .font(.headline)
                        .padding(.top, 8)
                    Group {
                        Text("Q: How do I add a new test result?\nA: Fill in the test result fields and tap 'Add Result'. The result will appear in the list above the button.")
                        Text("Q: What do I enter for Cable Size, Protection Size, Earth Continuity, Fault Loop Impedance, and Insulation Resistance?\nA: Enter only the number. The correct unit or symbol (mm² for millimetres squared, A for Amps, < for less than, > for greater than) will be added automatically in the PDF.")
                        Text("Q: How do I export all reports?\nA: Tap 'Export All Reports' in Settings. The app will export a ZIP file containing your data.")
                        Text("Q: How do I delete a report from history?\nA: Swipe left on a report in the History tab and tap 'Delete'.")
                        Text("Q: How do I change my company or tester information?\nA: Go to the Settings tab and update the fields under 'Company Information' and 'Default Tester Information'.")
                        Text("Q: How do I set or update my signature?\nA: In Settings, tap 'Set Default Signature', sign in the pad, and close the modal to save.")
                        Text("Q: Can I restore my data if I reinstall the app?\nA: Yes, if you exported a backup ZIP file, you can use 'Import/Restore Backup' in Settings to restore your reports.")
                        Text("Q: Who do I contact for help?\nA: Email jeff.chadkirk@platinumelectrical.net for support.")
                        Text("Q: How many test results can I add?\nA: You can add up to 8 test results per report. If you try to add more, a popup will appear asking if you want to clear all test results. Only test results are cleared; all other form fields remain unchanged.")
                    }
                }
                .padding()
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct PDFToShow: Identifiable, Equatable {
    let name: String
    var id: String { name }
}

struct StandardsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showTable81 = false
    @State private var showTable82 = false
    @State private var showSection836 = false
    @State private var showSection837 = false
    @State private var showSection8310 = false
    @State private var showSection8 = false
    @State private var showPDF: PDFToShow? = nil
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Test Standards Required for a Pass")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 8)
                Text("All test results must comply with the following standards:")
                HStack(spacing: 8) {
                    Button(action: { showPDF = PDFToShow(name: "AS3000.pdf") }) {
                        Text("AS/NZS 3000:2018").underline().foregroundColor(.blue)
                    }
                    Button(action: { showPDF = PDFToShow(name: "AS3017.pdf") }) {
                        Text("AS/NZS 3018").underline().foregroundColor(.blue)
                    }
                    Button(action: { showPDF = PDFToShow(name: "AS3008.pdf") }) {
                        Text("AS/NZS 3008").underline().foregroundColor(.blue)
                    }
                }
                Text("• AS/NZS 3000: Section 8 - Verification (Testing and Inspection)")
                Text("• AS/NZS 3018: Electrical Installations - Testing and Inspection Guidelines")
                Text("• AS/NZS 3008: Electrical Installations - Selection of Cables")
                Divider()
                Group {
                    Text("Key Requirements for a Pass:")
                        .font(.headline)
                    Button(action: { showSection8 = true }) {
                        Text("• Visual Inspection: All wiring, connections, and equipment must be installed correctly, securely, and free from visible damage or defects as per AS/NZS 3000 Section 8.")
                            .foregroundColor(.blue)
                    }
                    Button(action: { showTable81 = true }) {
                        Text("• Earth Continuity: Measured resistance must be less than the maximum allowed by AS/NZS 3000 Table 8.1. Typically, <1Ω for final subcircuits.")
                            .foregroundColor(.blue)
                    }
                    Button(action: { showSection836 = true }) {
                        Text("• Insulation Resistance: Must be greater than 1 MΩ between all live conductors and earth, as per AS/NZS 3000 Section 8.3.6.")
                            .foregroundColor(.blue)
                    }
                    Button(action: { showSection837 = true }) {
                        Text("• Polarity Test: All switches, circuit breakers, and socket outlets must be correctly connected as per AS/NZS 3000 Section 8.3.7.")
                            .foregroundColor(.blue)
                    }
                    Button(action: { showTable82 = true }) {
                        Text("• Fault Loop Impedance: Must not exceed the values specified in AS/NZS 3000 Table 8.2 to ensure protective devices operate within required times.")
                            .foregroundColor(.blue)
                    }
                    Button(action: { showSection8310 = true }) {
                        Text("• RCD Test: Residual Current Devices must trip within the time and current requirements of AS/NZS 3000 Section 8.3.10.")
                            .foregroundColor(.blue)
                    }
                    Text("• Operational Test: All equipment and safety devices must operate correctly as per manufacturer and standard requirements.")
                }
                Divider()
                Text("Refer to the full standards for detailed requirements and tables. For more information, consult AS/NZS 3000:2018, AS/NZS 3018, and AS/NZS 3008.")
            }
            .padding()
        }
        .navigationTitle("Test Standards")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Label("Back", systemImage: "chevron.left")
                }
            }
        }
        .sheet(isPresented: $showTable81) {
            VStack(alignment: .leading, spacing: 12) {
                Text("AS/NZS 3000 Table 8.1 (Earth Continuity)")
                    .font(.headline)
                Text("Maximum earth continuity resistance for various conductors:")
                HStack {
                    Text("Conductor Type").bold()
                    Spacer()
                    Text("Max Resistance (Ω)").bold()
                }
                Divider()
                HStack { Text("Final subcircuit ≤ 40A"); Spacer(); Text("1.0") }
                HStack { Text("Final subcircuit > 40A"); Spacer(); Text("2.0") }
                HStack { Text("Main earthing conductor"); Spacer(); Text("0.5") }
                HStack { Text("Bonding conductor"); Spacer(); Text("0.5") }
                HStack { Text("Connection to earth electrode"); Spacer(); Text("2.0") }
                HStack { Text("Connection to metallic water pipe"); Spacer(); Text("0.5") }
                Text("Refer to the full standard for all conductor types and installation conditions.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Button("Close") { showTable81 = false }
            }.padding()
        }
        .sheet(isPresented: $showTable82) {
            VStack(alignment: .leading, spacing: 12) {
                Text("AS/NZS 3000 Table 8.2 (Fault Loop Impedance)")
                    .font(.headline)
                Text("Maximum Zs (Ω) values for common circuit breakers and fuses:")
                HStack {
                    Text("Device/Rating").bold()
                    Spacer()
                    Text("Max Zs (Ω)").bold()
                }
                Divider()
                HStack { Text("6A, 10A, 16A (Type B)"); Spacer(); Text("7.29") }
                HStack { Text("20A (Type B)"); Spacer(); Text("2.19") }
                HStack { Text("32A (Type B)"); Spacer(); Text("1.37") }
                HStack { Text("6A, 10A, 16A (Type C)"); Spacer(); Text("3.63") }
                HStack { Text("20A (Type C)"); Spacer(); Text("1.09") }
                HStack { Text("32A (Type C)"); Spacer(); Text("0.68") }
                HStack { Text("RCD-protected"); Spacer(); Text("1667") }
                Text("Refer to the full standard for all device types, ratings, and installation conditions.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Button("Close") { showTable82 = false }
            }.padding()
        }
        .sheet(isPresented: $showSection836) {
            VStack(alignment: .leading, spacing: 12) {
                Text("AS/NZS 3000 Section 8.3.6 (Insulation Resistance)")
                    .font(.headline)
                Text("Insulation resistance between all live conductors and earth must be greater than 1 MΩ. Test at 500V DC for most circuits.\nIf the measured value is below 1 MΩ, investigate and rectify before energizing.")
                Button("Close") { showSection836 = false }
            }.padding()
        }
        .sheet(isPresented: $showSection837) {
            VStack(alignment: .leading, spacing: 12) {
                Text("AS/NZS 3000 Section 8.3.7 (Polarity Test)")
                    .font(.headline)
                Text("All switches, circuit breakers, and socket outlets must be correctly connected so that the active conductor is switched and fused.\nTest by verifying correct connection at each point.")
                Button("Close") { showSection837 = false }
            }.padding()
        }
        .sheet(isPresented: $showSection8310) {
            VStack(alignment: .leading, spacing: 12) {
                Text("AS/NZS 3000 Section 8.3.10 (RCD Test)")
                    .font(.headline)
                Text("RCDs must trip within 300ms at rated current (30mA), and within 40ms at 5x rated current.\nTest using an RCD tester as per manufacturer and standard requirements.")
                Button("Close") { showSection8310 = false }
            }.padding()
        }
        .sheet(isPresented: $showSection8) {
            VStack(alignment: .leading, spacing: 12) {
                Text("AS/NZS 3000 Section 8 (Visual Inspection)")
                    .font(.headline)
                Text("All wiring, connections, and equipment must be installed correctly, securely, and free from visible damage or defects.\nCheck for correct cable support, protection, and terminations.")
                Button("Close") { showSection8 = false }
            }.padding()
        }
        .sheet(item: $showPDF) { pdfToShow in
            StandardsPDFViewer(pdfName: pdfToShow.name)
        }
    }
}

struct StandardsPDFViewer: View {
    let pdfName: String
    @State private var searchText = ""
    @State private var pdfDocument: PDFDocument? = nil
    @State private var searchResults: [PDFSelection] = []
    @State private var currentResultIndex: Int = 0
    @State private var bookmarks: [Int: String] = [:] // pageIndex: label
    @State private var showBookmarks = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    TextField("Search", text: $searchText, onCommit: search)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.horizontal, .top])
                    if !searchResults.isEmpty {
                        Button(action: previousResult) { Image(systemName: "chevron.up") }
                        Text("\(currentResultIndex + 1)/\(searchResults.count)")
                            .font(.caption)
                            .frame(minWidth: 40)
                        Button(action: nextResult) { Image(systemName: "chevron.down") }
                    }
                    Button(action: { showBookmarks = true }) {
                        Image(systemName: "bookmark")
                    }
                    Button("Close") { dismiss() }
                        .padding(.trailing)
                }
                Divider()
                if let pdfDocument = pdfDocument {
                    PDFKitRepresentedViewWithHighlight(pdfDocument: pdfDocument, selection: currentSelection, onBookmark: addOrRemoveBookmark, bookmarks: bookmarks, goToPage: goToPage)
                } else {
                    Text("PDF not found.")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if let url = Bundle.main.url(forResource: pdfName.replacingOccurrences(of: ".pdf", with: ""), withExtension: "pdf") {
                    pdfDocument = PDFDocument(url: url)
                }
            }
            .sheet(isPresented: $showBookmarks) {
                NavigationView {
                    List {
                        ForEach(bookmarks.sorted(by: { $0.key < $1.key }), id: \.key) { (page, label) in
                            Button(action: { goToPage(page); showBookmarks = false }) {
                                HStack {
                                    Text("Page \(page + 1)")
                                    if !label.isEmpty { Text(": \(label)") }
                                }
                            }
                        }
                        .onDelete { indices in
                            for index in indices {
                                let key = Array(bookmarks.keys.sorted())[index]
                                bookmarks.removeValue(forKey: key)
                            }
                        }
                    }
                    .navigationTitle("Bookmarks")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showBookmarks = false }
                        }
                    }
                }
            }
        }
    }

    var currentSelection: PDFSelection? {
        guard !searchResults.isEmpty, currentResultIndex < searchResults.count else { return nil }
        return searchResults[currentResultIndex]
    }

    func search() {
        guard let pdfDocument = pdfDocument, !searchText.isEmpty else {
            searchResults = []
            currentResultIndex = 0
            return
        }
        let results = pdfDocument.findString(searchText, withOptions: .caseInsensitive)
        searchResults = results
        currentResultIndex = 0
        for selection in results { selection.color = .yellow }
    }

    func nextResult() {
        guard !searchResults.isEmpty else { return }
        currentResultIndex = (currentResultIndex + 1) % searchResults.count
    }

    func previousResult() {
        guard !searchResults.isEmpty else { return }
        currentResultIndex = (currentResultIndex - 1 + searchResults.count) % searchResults.count
    }

    func addOrRemoveBookmark(page: Int, label: String = "") {
        if bookmarks[page] != nil {
            bookmarks.removeValue(forKey: page)
        } else {
            bookmarks[page] = label
        }
    }

    func goToPage(_ page: Int) {
        guard let pdfDocument = pdfDocument, let pdfView = PDFKitRepresentedViewWithHighlight.lastPDFView else { return }
        if let pageObj = pdfDocument.page(at: page) {
            pdfView.go(to: pageObj)
        }
    }
}

struct PDFKitRepresentedViewWithHighlight: UIViewRepresentable {
    let pdfDocument: PDFDocument
    let selection: PDFSelection?
    let onBookmark: (Int, String) -> Void
    let bookmarks: [Int: String]
    let goToPage: (Int) -> Void
    static var lastPDFView: PDFView? = nil

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        PDFKitRepresentedViewWithHighlight.lastPDFView = pdfView
        addBookmarkButton(to: pdfView, context: context)
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        pdfView.document = pdfDocument
        if let selection = selection, let page = selection.pages.first {
            pdfView.go(to: selection)
            pdfView.setCurrentSelection(selection, animate: true)
            pdfView.highlightedSelections = [selection]
        } else {
            pdfView.highlightedSelections = nil
        }
        addBookmarkButton(to: pdfView, context: context)
    }

    private func addBookmarkButton(to pdfView: PDFView, context: Context) {
        pdfView.subviews.filter { $0 is UIButton && $0.tag == 9999 }.forEach { $0.removeFromSuperview() }
        let button = UIButton(type: .system)
        button.setTitle("Bookmark", for: .normal)
        button.tag = 9999
        button.addTarget(context.coordinator, action: #selector(Coordinator.bookmarkTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        pdfView.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: pdfView.trailingAnchor, constant: -16),
            button.topAnchor.constraint(equalTo: pdfView.topAnchor, constant: 16)
        ])
        context.coordinator.onBookmark = onBookmark
        context.coordinator.pdfView = pdfView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        var onBookmark: ((Int, String) -> Void)?
        weak var pdfView: PDFView?
        @objc func bookmarkTapped() {
            guard let pdfView = pdfView, let page = pdfView.currentPage, let pageIndex = pdfView.document?.index(for: page) else { return }
            onBookmark?(pageIndex, "")
        }
    }
} 