//
//  ActivityViewController.swift
//  test-app2
//
//  Created by Yonatan Mamo on 29.10.22.
//
import UIKit
import SwiftUI

struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {

        
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.activityItemsConfiguration = [
        UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
    
        // exclude
        controller.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.openInIBooks,
            UIActivity.ActivityType.markupAsPDF,
            UIActivity.ActivityType.sharePlay,
        ]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) { }

}
