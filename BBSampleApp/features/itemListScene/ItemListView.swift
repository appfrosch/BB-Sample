//
//  ItemListDomainView.swift
//  BB
//
//  Created by Andreas Seeger on 22.01.2024.
//

import ComposableArchitecture
import SwiftUI

struct ItemListView: View {
  @Bindable var store: StoreOf<RootFeature>

  var body: some View {
    List {
      ForEach(store.items) { item in
        NavigationLink(
          state: RootFeature.Path.State.itemDetail(ItemDetailFeature.State(item: item)),
          label: {
            Text(item.title)
          }
        )
        .swipeActions {
          Button {
            store.send(.deleteItemButtonTapped(item.id))
          } label: {
            Label("Delete", systemImage: "trash")
          }
          .tint(.red)
        }
              }
            }
    .overlay {
      if store.items.isEmpty {
        ContentUnavailableView {
          Label("There are currently no items yet…", systemImage: "plus")
        } actions: {
          addNewItemButton(with: "Add first item…")
        }

      }
    }
    .toolbar {
      if !store.items.isEmpty {
        ToolbarItem(placement: .automatic) {
          addNewItemButton()
            .labelStyle(.titleAndIcon)
        }
      }
    }
    .sheet(
      item: $store.scope(
        state: \.destination?.addNewItem,
        action: \.destination.addNewItem
      )
    ) { sheetStore in

      NavigationStack {
        ItemDetailView(store: sheetStore)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Cancel") {
                self.store.send(.addNewItemAction(.addNewItemCancelButtonTapped))
              }
            }
            ToolbarItem(placement: .confirmationAction) {
              Button("Confirm") {
                self.store.send(.addNewItemAction(.addNewItemConfirmButtonTapped))
              }
              .disabled(sheetStore.item.title.isEmpty)
            }
          }
          .navigationTitle("Add a new item")
          .navigationBarTitleDisplayMode(.inline)
          .interactiveDismissDisabled(true)//Make sure that this modifier is exactly here–it won't be of effect otherwise!
      }
    }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .navigationTitle("BB Sample")
  }

  func addNewItemButton(with labelText: String = "Add item…") -> some View {
    Button {
      store.send(.addNewItemAction(.addNewItemButtonTapped))
    } label: {
      Label(labelText, systemImage: "plus")
    }
  }
}

//MARK: View Previews
#Preview("w/o any items") {
  ItemListView(
    store: Store(
      initialState: RootFeature.State(items: [])
    ) {
      RootFeature()
    }
  )
}

#Preview("w/ items") {
  ItemListView(
    store: Store(
      initialState: RootFeature.State(
        items: Item.sampleArray
      )
    ) {
      RootFeature()
    }
  )
}

#Preview("deletion alert") {
  ItemListView(
    store: Store(
      initialState: RootFeature.State(
        items: Item.sampleArray,
        destination: .alert(.delete(item: Item.sample1))
      )
    ) {
      RootFeature()
    }
  )
}

#Preview("add new item") {
  ItemListView(
    store: Store(
      initialState: RootFeature.State(
        items: Item.sampleArray,
        destination: .addNewItem(
          ItemDetailFeature.State(
            item: Item()
          )
        )
      )
    ) {
      RootFeature()
    }
  )
}

#Preview("edit an item") {
  ItemListView(
    store: Store(
      initialState: RootFeature.State(
        items: Item.sampleArray,
        path: StackState([
          RootFeature.Path.State.itemDetail(ItemDetailFeature.State(item: Item.sample1))
        ])
      )
    ) {
      RootFeature()
    }
  )
}
