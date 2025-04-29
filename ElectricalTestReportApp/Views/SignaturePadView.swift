//
//  SignaturePadView.swift
//  ElectricalTestReportApp
//
//  Created by Jeff Chadkirk on 29/4/2025.
//


// Views/SignaturePadView.swift
import SwiftUI

struct SignaturePadView: View {
    @Binding var signatureImage: UIImage?
    @State private var points: [CGPoint] = []

    var body: some View {
        ZStack {
            Color.white
            Path { path in
                for (i, point) in points.enumerated() {
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
            }
            .stroke(Color.black, lineWidth: 2)
        }
        .gesture(DragGesture(minimumDistance: 0.1)
            .onChanged { value in
                points.append(value.location)
            }
            .onEnded { _ in
                signatureImage = renderSignature()
            }
        )
        .frame(height: 120)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
    }

    func renderSignature() -> UIImage? {
        let controller = UIHostingController(rootView: self.frame(width: 300, height: 120))
        let view = controller.view

        let targetSize = CGSize(width: 300, height: 120)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}