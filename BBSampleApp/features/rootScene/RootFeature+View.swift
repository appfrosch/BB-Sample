//
//  RootFeature+View.swift
//  BB
//
//  Created by Andreas Seeger on 23.01.2024.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Navigation View
struct RootFeatureView: View {
    @State var store: StoreOf<RootFeature>

    var body: some View {
      NavigationStack(
        path: $store.scope(state: \.path, action: \.path)) {
          ItemListView(store: store)
        } destination: { store in
          switch store.state {
          case .itemDetail:
            if let store = store.scope(state: \.itemDetail, action: \.itemDetail) {
              ItemDetailView(store: store)
            }
          case .subItemDetail:
            if let store = store.scope(state: \.subItemDetail, action: \.subItemDetail) {
              SubItemView(store: store)
            }
          }
        }
    }
}

// MARK: - Navigation Preview
#Preview {
    RootFeatureView(
      store: Store(
        initialState: RootFeature.State(),
        reducer: { RootFeature() }
      )
    )
}

