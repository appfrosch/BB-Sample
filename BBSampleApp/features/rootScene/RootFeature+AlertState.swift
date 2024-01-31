//
//  RootFeature+AlertState.swift
//  BB
//
//  Created by Andreas Seeger on 23.01.2024.
//

import ComposableArchitecture
import SwiftUI

//MARK: ItemListDomain Alert
extension AlertState where Action == RootFeature.Action.Alert {
  static func delete(item: Item) -> Self {
    AlertState {
      TextState(#"Delete "\#(item.title)""#)
    } actions: {
      ButtonState(role: .destructive, action: .send(.confirmDeletion(id: item.id), animation: .default)) {
        TextState("Delete")
      }
    } message: {
      TextState("Are you sure you want to remove this item from the list?")
    }
  }
}
