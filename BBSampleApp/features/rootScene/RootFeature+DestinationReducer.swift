//
//  RootFeature+DestinationReducer.swift
//  BB
//
//  Created by Andreas Seeger on 23.01.2024.
//

import ComposableArchitecture
import SwiftUI

extension RootFeature {
  //MARK: ItemListDomain Destinations
  @Reducer
  struct Destination {
    @ObservableState
    enum State: Equatable {
      case alert(AlertState<RootFeature.Action.Alert>)
      case addNewItem(ItemDetailFeature.State)
    }
    enum Action: Equatable {
      case addNewItem(ItemDetailFeature.Action)
      //MARK: deleting a item
      case alert(RootFeature.Action.Alert)
    }
    var body: some ReducerOf<Self> {
      Scope(state: /State.addNewItem, action: /Action.addNewItem) {
        ItemDetailFeature()
      }
    }
  }
}
