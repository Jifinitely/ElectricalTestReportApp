import SwiftUI

struct TestResultsPreviewView: View {
    @Binding var testResults: [TestResult]
    var body: some View {
        VStack(alignment: .leading) {
            Text("Preview Results")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 8)
            ScrollView(.horizontal) {
                VStack(spacing: 0) {
                    HStack(spacing: 2) {
                        ForEach(Self.headers, id: \.self) { Text($0).font(.caption2).bold().frame(width: 80, alignment: .center) }
                        Spacer().frame(width: 40)
                    }
                    Divider()
                    ForEach(0..<8, id: \.self) { i in
                        HStack(spacing: 2) {
                            if i < testResults.count {
                                let result = testResults[i]
                                Group {
                                    Text(result.testDate).frame(width: 80)
                                    Text(result.circuitOrEquipment).frame(width: 80)
                                    Text(result.visualInspection).frame(width: 80)
                                    Text(result.circuitNo).frame(width: 80)
                                    Text(result.cableSize.isEmpty ? "" : "\(result.cableSize) mm²").frame(width: 80)
                                    Text(result.protectionSizeType).frame(width: 80)
                                    Text(result.neutralNo).frame(width: 80)
                                    Text(result.earthContinuity.isEmpty ? "" : "< \(result.earthContinuity)").frame(width: 80)
                                    Text(result.rcd).frame(width: 80)
                                    Text(result.insulationResistance.isEmpty ? "" : "> \(result.insulationResistance)").frame(width: 80)
                                    Text(result.polarityTest).frame(width: 80)
                                    Text(result.faultLoopImpedance.isEmpty ? "" : "< \(result.faultLoopImpedance)").frame(width: 80)
                                    Text(result.operationalTest).frame(width: 80)
                                }
                                Button(action: { testResults.remove(at: i) }) {
                                    Image(systemName: "trash").foregroundColor(.red)
                                }.frame(width: 40)
                            } else {
                                ForEach(0..<13, id: \.self) { _ in Text("").frame(width: 80) }
                                Spacer().frame(width: 40)
                            }
                        }
                        Divider()
                    }
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.vertical)
        }
        .padding()
    }
    static let headers = [
        "Test Date", "Circuit/Equip", "Visual Insp.", "Circuit No.", "Cable Size", "Protection Size", "Neutral No.", "Earth Cont.", "RCD", "Insul. Resist.", "Polarity Test", "Fault Loop Imp.", "Operational Test"
    ]
} 