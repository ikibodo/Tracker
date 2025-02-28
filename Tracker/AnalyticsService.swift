//
//  AnalyticsService.swift
//  Tracker
//
//  Created by N L on 24.2.25..
//
import Foundation
import AppMetricaCore

struct AnalyticsService {
    
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "6ba88354-7ec4-4297-bf17-24dc5795bbc4") else { return }
        AppMetrica.activate(with: configuration)
    }

    private static func report(event: String, item: String? = nil) {
        var parameters: [String: Any] = ["screen": "Main"]
        
        if let item = item {
            parameters["item"] = item
        }
        print("EVENT: \(event), PARAMETERS: \(parameters)")

        AppMetrica.reportEvent(name: event, parameters: parameters, onFailure: { error in
            print("FAILED TO REPORT EVENT: \(event)")
            print("ERROR: \(error.localizedDescription)")
        })
    }
 
    static func openScreen() {
        print("Opening Main Screen")
        report(event: "open")
    }
 
    static func closeScreen() {
        print("Closing Main Screen")
        report(event: "close")
    }
 
    static func tapAddTrack() {
        print("Tapped 'Add Track' Button")
        report(event: "click", item: "add_track")
    }
 
    static func tapTrack() {
        print("Tapped on a Track")
        report(event: "click", item: "track")
    }
 
    static func tapFilter() {
        print("Tapped 'Filter' Button")
        report(event: "click", item: "filter")
    }
 
    static func tapEdit() {
        print("Selected 'Edit' from Context Menu")
        report(event: "click", item: "edit")
    }
 
    static func tapDelete() {
        print("Selected 'Delete' from Context Menu")
        report(event: "click", item: "delete")
    }
}
