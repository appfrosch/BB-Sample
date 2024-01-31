//
//  BBApp.swift
//  BB
//
//  Created by Andreas Seeger on 17.05.23.
//

import ComposableArchitecture
import SwiftUI

@main
struct BBSampleApp: App {
  var body: some Scene {
    WindowGroup {
      RootFeatureView(
        store: Store(
          initialState: RootFeature.State()) {
            RootFeature()
          }
        )
    }
  }
}

#Preview {
  RootFeatureView(
    store: Store(
      initialState: RootFeature.State()) {
        RootFeature()
      }
    )
}
