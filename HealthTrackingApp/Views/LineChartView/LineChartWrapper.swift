//
//  LineChartWrapper.swift
//  HealthTrackingApp
//
//  Created by Abhishek on 12/01/25.
//


import SwiftUI

struct LineChartWrapper: UIViewControllerRepresentable {
    var metrics: [HealthTracking]
    var filterType: String?

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIHostingController(rootView: LineChartView(metrics: metrics, filterType: filterType))
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let hostingController = uiViewController as? UIHostingController<LineChartView> {
            hostingController.rootView = LineChartView(metrics: metrics, filterType: filterType)
        }
    }
}
