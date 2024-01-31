//
//  RootFeature.swift
//  BB
//
//  Created by Andreas Seeger on 22.01.2024.
//

import ComposableArchitecture
import SwiftUI

// MARK: - RootFeature Reducer
@Reducer
struct RootFeature {
  @ObservableState
  struct State: Equatable {
    var items: IdentifiedArrayOf<Item>

    var path: StackState<Path.State>
    @Presents var destination: Destination.State?

    init(
      items: [Item] = .init(),
      path: StackState<Path.State> = StackState<Path.State>(),
      destination: Destination.State? = nil
    ) {
      self.items = []
      self.path = path
      self.destination = destination
        self.items = IdentifiedArray(uniqueElements: items)
    }
  }

  // MARK: Action Definition
  enum Action: Equatable {
    case path(StackAction<Path.State, Path.Action>)
    case destination(PresentationAction<Destination.Action>)

    case addNewItemAction(AddNewItemAction)

    enum AddNewItemAction {
      case addNewItemButtonTapped
      case addNewItemCancelButtonTapped
      case addNewItemConfirmButtonTapped
    }

    case deleteItemButtonTapped(Item.ID)
    enum Alert: Equatable {
      case confirmDeletion(id: Item.ID)
    }
  }

  // MARK: Reducer Body
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .path(.element(pathId, .itemDetail(.delegate(delegateAction)))):
        switch delegateAction {
        case let .updateItem(item):
          BBLogger.misc.debug("[\(#filePath) \(#function)] Item to save in root: \(item.debugDescription)")
          state.path.ids.forEach { id in
            if let itemState = state.path[id: id, case: \.itemDetail] {
              if itemState.item.id == item.id {
                state.path[id: id, case: \.itemDetail]?.item = item
              }
            }
          }
          return .none
        }

      case .path(.popFrom(id: let id)):
        switch state.path[id: id] {
        case .itemDetail(let itemDetailState):
          let mutatingItem = itemDetailState.item
          if let index = state.items.firstIndex(where: { $0.id == mutatingItem.id }) {
            if state.items[index] != mutatingItem {
              state.items.update(mutatingItem, at: index)
            }
          }
          return .none

        case .subItemDetail(let subItemDetailState):
          BBLogger.misc.debug("Entering case .subItemDetail")
          let itemBefore = state.items
          BBLogger.misc.debug("Items at start: \(itemBefore)")
          let itemId = subItemDetailState.itemId
          let mutatingSubItem = subItemDetailState.subItem
          guard var mutatingItem = state.items[id: itemId]
          else {
            return .none
          }
          guard let subItemIndex = mutatingItem.subItems.firstIndex(where: { $0.id == mutatingSubItem.id })
          else {
            return .none
          }
          mutatingItem.subItems[subItemIndex] = mutatingSubItem
          BBLogger.misc.debug("Saving mutatingItem: \(mutatingItem.debugDescription)")

          if let updatedItem = state.items.updateOrAppend(mutatingItem) {
            BBLogger.misc.debug("Updated item \(updatedItem.debugDescription)")
          } else {
            BBLogger.misc.error("Could not update item.")
            return .none
          }

          let itemsAfter = state.items
          BBLogger.misc.debug("Items at end: \(itemsAfter)")

          //Save to the itemDetail state in the path
          if let itemDetailId = state.path.ids.dropLast().last {
            state.path[id: itemDetailId, case: \.itemDetail]?.item = mutatingItem
          }
          return .none

        case .none:
          return .none
        }

      case .path:
        return .none

      case .destination(.dismiss):
        return .none

      case let .destination(.presented(.alert(.confirmDeletion(id: id)))):
        defer { state.destination = nil }
        guard let item = state.items[id: id]
        else {
          XCTFail("Could not delete item with id \(id) because it was not found.")
          return .none
        }
        state.items.remove(item)
        return .none

      case .destination:
        return .none

      case .addNewItemAction(let newItemAction):
        switch newItemAction {
        case .addNewItemButtonTapped:
          state.destination = .addNewItem(ItemDetailFeature.State(item: Item()))
          return .none

        case .addNewItemCancelButtonTapped:
          state.destination = nil
          return .none

        case .addNewItemConfirmButtonTapped:
          defer { state.destination = nil }
          guard case let .addNewItem(itemDomainState) = state.destination
          else {
            XCTFail("Cannot add a new item as `addNewItem` is unexpectedly nil.")
            return .none
          }
          let newItem = itemDomainState.item
          print(newItem)
          state.items.insert(newItem, at: 0)
          return .none

        }
      case let .deleteItemButtonTapped(id):
        guard let item = state.items[id: id]
        else {
          XCTFail("Could not find item with id \(id).")
          return .none
        }
        state.destination = .alert(.delete(item: item))
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) { Destination() }
    .forEach(\.path, action: /Action.path) { Path() }
//    ._printChanges()
  }
}
