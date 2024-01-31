//
//  ItemDomainView.swift
//  BB
//
//  Created by Andreas Seeger on 22.01.2024.
//

import ComposableArchitecture
import SwiftUI

struct ItemDetailView: View {
  @State var store: StoreOf<ItemDetailFeature>

  var body: some View {
    Form {
      Section("Item") {
        TextField("Title", text: $store.item.title)
      }
      Section("SubItems") {
        if store.item.subItems.isEmpty {
          ContentUnavailableView {
            Label("There are currently no subItems yet for this item…", systemImage: "gearshape.2")
          } actions: {
            Button("Add first subItem", systemImage: "plus") {
              store.send(.addNewSubItemAction(.addNewSubItemButtonTapped))
            }
          }
        }
        ForEach(store.item.subItems) { subItem in
          NavigationLink(
            state: RootFeature.Path.State.subItemDetail(
              SubItemFeature.State(itemId: store.item.id, subItem: subItem))
          ) {
              Text(subItem.title)
            }
          .swipeActions {
            Button {
              store.send(.deleteSubItemButtonTapped(subItem.id))
            } label: {
              Label("Delete", systemImage: "trash")
            }
            .tint(.red)
          }
        }
      }
      .sheet(
        item: $store.scope(
          state: \.destination?.addNewSubItem,
          action: \.destination.addNewSubItem
        )
      ) { sheetStore in
        let _ = BBLogger.misc.debug("[\(#filePath) \(#function)] showing up add subItem sheet with new subItem \(sheetStore.subItem.debugDescription)")
        NavigationStack {
          SubItemView(store: sheetStore)
            .toolbar {
              ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                  store.send(.addNewSubItemAction(.addNewSubItemCancelButtonTapped))
                }
              }
              ToolbarItem(placement: .confirmationAction) {
                Button("Confirm") {
                  BBLogger.misc.debug("[\(#filePath) \(#function)] New subItem to save: \(sheetStore.subItem.debugDescription)")
                  self.store.send(.addNewSubItemAction(.addNewSubItemConfirmButtonTapped(sheetStore.subItem)))
                }
//                .disabled(sheetStore.itemSubItem.title.isEmpty)
              }
            }
        }
      }
    }
    .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    .navigationTitle(store.item.title)
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  ItemDetailView(
    store: Store(
      initialState: ItemDetailFeature.State(
        item: Item()
      )
    ) {
      ItemDetailFeature()
    }
  )
}
