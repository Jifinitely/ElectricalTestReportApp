# Electrical Test Report App

A SwiftUI app for creating, previewing, and exporting electrical test reports in compliance with Australian/New Zealand standards (AS/NZS 3000, 3018, 3008).

## Features
- Easy entry of test results (up to 8 per report)
- PDF export with company branding and signature
- Standards reference with in-app PDF viewer and search/bookmarking
- Live preview of test results table (as it will appear in the PDF)
- Edit and delete test results before export
- Settings for company and tester info
- Data backup/restore (ZIP export/import)
- In-app help and FAQ

## About
The Electrical Test Report App is designed to streamline the process of creating and managing electrical test reports for electricians and electrical contractors. The app helps ensure compliance with Australian and New Zealand electrical safety standards while making the documentation process more efficient and error-free.

### Key Benefits
- **Time-Saving**: Quickly generate professional test reports with automatic calculations and standard compliance checks
- **Accuracy**: Built-in validation and automatic unit conversions reduce human error
- **Compliance**: Direct access to relevant AS/NZS standards within the app
- **Professional Output**: Generate branded PDF reports with company details and digital signatures
- **Data Management**: Easy backup and restore functionality for test records
- **User-Friendly**: Intuitive interface designed specifically for electricians

### Standards Compliance
The app is designed to comply with:
- AS/NZS 3000:2018 (Wiring Rules)
- AS/NZS 3018:2017 (Electrical Installations - Verification Guidelines)
- AS/NZS 3008.1.1:2017 (Selection of Cables)

## Screenshots

### Standards Reference & Table
![Test Standards Reference](screenshots/test_standards.jpg)
*View and search key requirements for a pass, with tappable links to tables and sections.*

![Table 8.1 Modal](screenshots/table_81_modal.jpg)
*View full details for AS/NZS 3000 Table 8.1 (Earth Continuity) in a modal.*

### History
![History Tab](screenshots/history.jpg)
*View and share previously exported reports.*

### Test Results Entry
![Test Results Entry](screenshots/test_results_entry.jpg)
*Enter up to 8 test results per report, with clear labels for each field.*

## Setup
1. Clone this repository.
2. Open the project in Xcode (iOS 15+ recommended).
3. Add your standards PDFs (AS3000.pdf, AS3017.pdf, AS3008.pdf) to the main app bundle.
4. Build and run on a simulator or device.

## Usage
- Fill out the form with customer, site, and test details.
- Add up to 8 test results per report.
- Use the Preview tab to see your table as it will appear in the PDF.
- Export to PDF for compliance documentation.
- Reference standards and search/bookmark key sections in-app.

## Disclaimer
This app is for electrical safety compliance record-keeping. It is not an official standards document. Always consult the latest AS/NZS standards for legal compliance.

## Credits
Developed by Platinum Electrical & Air. 