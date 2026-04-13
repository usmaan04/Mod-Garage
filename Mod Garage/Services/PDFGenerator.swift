//
//  PDFGenerator.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 13/04/2026.
//

import SwiftUI
import UIKit

struct PDFGenerator {
    static func createVehicleReportPDF(
        vehicle: VehicleModel,
        modifications: [ModificationModel],
        fuelLogs: [FuelLogModel],
        latestMileage: Int?
    ) throws -> URL {

        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let horizontalPadding: CGFloat = 20
        let verticalPadding: CGFloat = 20
        let contentWidth = pageWidth - (horizontalPadding * 2)
        let maxContentHeight = pageHeight - (verticalPadding * 2)

        let reportView = VehicleReportView(
            vehicle: vehicle,
            modifications: modifications,
            fuelLogs: fuelLogs,
            latestMileage: latestMileage
        )
        .frame(width: contentWidth, alignment: .topLeading)
        .background(Color.white)

        let hostingController = UIHostingController(rootView: reportView)
        let hostedView = hostingController.view!

        hostedView.backgroundColor = .white
        hostedView.bounds = CGRect(x: 0, y: 0, width: contentWidth, height: maxContentHeight)

        let targetSize = CGSize(width: contentWidth, height: UIView.layoutFittingCompressedSize.height)
        let fittedSize = hostedView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        let finalHeight = min(fittedSize.height, maxContentHeight)
        hostedView.bounds = CGRect(x: 0, y: 0, width: contentWidth, height: finalHeight)

        let safeMake = vehicle.make.replacingOccurrences(of: " ", with: "_")
        let safeModel = vehicle.model.replacingOccurrences(of: " ", with: "_")

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(safeMake)_\(safeModel)_Report.pdf")

        let pageBounds = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageBounds)

        try pdfRenderer.writePDF(to: url) { context in
            context.beginPage()

            let drawRect = CGRect(
                x: horizontalPadding,
                y: verticalPadding,
                width: contentWidth,
                height: finalHeight
            )

            hostedView.drawHierarchy(in: drawRect, afterScreenUpdates: true)
        }

        return url
    }
}
