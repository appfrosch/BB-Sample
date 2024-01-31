import ComposableArchitecture
import SwiftUI

@Reducer
struct ItemDetailFeature {
  @ObservableState
  struct State: Equatable {
    var item: Item
    @Presents var destination: Destination.State?
  }
  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case destination(PresentationAction<Destination.Action>)

    case addNewSubItemAction(AddSubItemAction)
    enum AddSubItemAction: Equatable {
      case addNewSubItemButtonTapped
      case addNewSubItemCancelButtonTapped
      case addNewSubItemConfirmButtonTapped(SubItem)
    }

    case delegate(Delegate)
    enum Delegate: Equatable {
      case updateItem(Item)
    }

    case deleteSubItemButtonTapped(SubItem.ID)
    enum Alert: Equatable {
      case confirmDeletion(id: SubItem.ID)
    }
  }

  var body: some ReducerOf<Self> {
    BindingReducer()
      .onChange(of: \.item) { oldValue, newValue in
        let _ = BBLogger.misc.debug("[\(#filePath) \(#function)] newValue")
      }
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case let .destination(.presented(.alert(.confirmDeletion(id: id)))):
        defer { state.destination = nil }
        guard let itemSubItemIndex = state.item.subItems.firstIndex(where: { $0.id == id })
        else {
          XCTFail("Could not delete item with id \(id) because it was not found.")
          return .none
        }
        state.item.subItems.remove(at: itemSubItemIndex)
        return .send(.delegate(.updateItem(state.item)))

      case .destination:
        return .none

      case .addNewSubItemAction(let addSubItemAction):
        switch addSubItemAction {
        case .addNewSubItemButtonTapped:
          let newSubItem = SubItem()
          BBLogger.misc.debug("[\(#filePath) \(#function)] new subItem to add: \(newSubItem.debugDescription)")
          let subItemFeatureState = SubItemFeature.State(itemId: state.item.id, subItem: newSubItem)
          state.destination = .addNewSubItem(subItemFeatureState)
          return .none

        case .addNewSubItemCancelButtonTapped:
          state.destination = nil
          return .none

        case let .addNewSubItemConfirmButtonTapped(newSubItem):
          BBLogger.misc.debug("[\(#filePath) \(#function)]  \(newSubItem.debugDescription)")
          defer { state.destination = nil }
          guard case let .addNewSubItem(subItemFeatureState) = state.destination
          else {
            XCTFail("Cannot add a new subItem as `addNewSubItem` is unexpectedly nil.")
            return .none
          }
          let newSubItem = subItemFeatureState.subItem
          print(newSubItem)
          state.item.subItems.append(newSubItem)
          let itemDescription = state.item.debugDescription
          BBLogger.misc.debug("[\(#filePath) \(#function)] New item state: \(itemDescription)")
          return .send(.delegate(.updateItem(state.item)))
        }

      case let .deleteSubItemButtonTapped(subItemId):
        guard let itemSubItem = state.item.subItems.first(where: { $0.id == subItemId })
        else { return .none }
        state.destination = .alert(.delete(itemSubItem: itemSubItem))
        return .none

      case .delegate:
        return .none
      }

    }
//    ._printChanges()
  }
}

extension ItemDetailFeature {
  @Reducer
  struct Destination {
    @ObservableState
    enum State: Equatable {
      case addNewSubItem(SubItemFeature.State)
      case alert(AlertState<ItemDetailFeature.Action.Alert>)
    }

    enum Action: Equatable {
      case addNewSubItem(SubItemFeature.Action)
      case alert(ItemDetailFeature.Action.Alert)
    }

    var body: some ReducerOf<Self> {
      Scope(state: /State.addNewSubItem, action: /Action.addNewSubItem) {
        SubItemFeature()
      }
    }
  }
}

//MARK: ItemListDomain Alert
extension AlertState where Action == ItemDetailFeature.Action.Alert {
  static func delete(itemSubItem: SubItem) -> Self {
    AlertState {
      TextState(#"Delete "\#(itemSubItem.title)""#)
    } actions: {
      ButtonState(role: .destructive, action: .send(.confirmDeletion(id: itemSubItem.id), animation: .default)) {
        TextState("Delete")
      }
    } message: {
      TextState("Are you sure you want to remove this subItem from the list?")
    }
  }
}
