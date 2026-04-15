//
//  PDFGenerator.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 13/04/2026.
//

import SwiftUI
import UIKit

// Converts a view into a sharable PDF
struct PDFGenerator {
    static func createVehicleReportPDF(
        vehicle: VehicleModel,
        modifications: [ModificationModel],
        fuelLogs: [FuelLogModel],
        latestMileage: Int?
    ) throws -> URL {

        // A4 paper size
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

        // Calculate height based on content
        let targetSize = CGSize(width: contentWidth, height: UIView.layoutFittingCompressedSize.height)
        let fittedSize = hostedView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        let finalHeight = min(fittedSize.height, maxContentHeight)
        hostedView.bounds = CGRect(x: 0, y: 0, width: contentWidth, height: finalHeight)

        // Sanitise file name
        let safeMake = vehicle.make.replacingOccurrences(of: " ", with: "_")
        let safeModel = vehicle.model.replacingOccurrences(of: " ", with: "_")

        // Save to temporary folder
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(safeMake)_\(safeModel)_Report.pdf")

        // Setup the actual PDF context
        let pageBounds = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageBounds)

        // Start render
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

        // Return file path
        return url
    }
}
