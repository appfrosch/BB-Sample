//
//  RootFeature+PathReducer.swift
//  BB
//
//  Created by Andreas Seeger on 23.01.2024.
//

import ComposableArchitecture
import SwiftUI

// MARK: Path Definitions
extension RootFeature {
  @Reducer
  struct Path: Equatable {
    @ObservableState
    enum State: Equatable {
      case itemDetail(ItemDetailFeature.State)
      case subItemDetail(SubItemFeature.State)
    }

    enum Action: Equatable {
      case itemDetail(ItemDetailFeature.Action)
      case subItemDetail(SubItemFeature.Action)
    }

    var body: some ReducerOf<Self> {
      Scope(state: \.itemDetail, action: \.itemDetail) {
        ItemDetailFeature()
      }
      Scope(state: \.subItemDetail, action: \.subItemDetail) {
        SubItemFeature()
      }
    }
  }
}
