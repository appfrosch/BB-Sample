//
//  SubItemDomain.swift
//  BB
//
//  Created by Andreas Seeger on 22.01.2024.
//

import ComposableArchitecture
import SwiftUI
import Tagged

// MARK: - SubItemFeature Reducer
@Reducer
struct SubItemFeature {
  @ObservableState
  struct State: Equatable {
    let itemId: Tagged<Item, UUID>
    var subItem: SubItem
    @Presents var destination: Destination.State?
//    var focus: Field?
  }

  // MARK: Action Definition
  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case destination(PresentationAction<Destination.Action>)

    case delegate(Delegate)
    enum Delegate: Equatable {}
  }

  // MARK: Reducer Body
  var body: some ReducerOf<Self> {
    BindingReducer()
      .onChange(of: \.subItem) { oldValue, newValue in
//        #error("I am not running through here when adding a new subItem.")
        // Create a minimal project with this navigation logic an ask in the TCA slack
        let _ = BBLogger.misc.debug("[\(#filePath) \(#function)] onChange: \(newValue.debugDescription)")
      }
    Reduce { state, action in
      switch action {
//      case .binding(\.subItem):
//        let subItem = state.subItem
//        BBLogger.misc.debug("Current value for subItem: \(subItem.debugDescription)")
//        return .none

      case .binding:
        return .none

      case .destination:
        return .none

      case .delegate:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) { Destination() }
    ._printChanges()
  }
}

// MARK: Field Definitions
//extension SubItemFeature {
//  enum Field: Hashable {
//    case title
//    case description
//  }
//}

// MARK: Destination Definitions
extension SubItemFeature {
  @Reducer
  struct Destination {
    @ObservableState
    enum State: Hashable {

    }

    enum Action: Hashable {

    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {

        }
      }
    }
  }
}

// MARK: - SubItem View
struct SubItemView: View {
    @State var store: StoreOf<SubItemFeature>
//    @FocusState private var focus: SubItemFeature.Field?

    var body: some View {
      Form {
        Section {
          TextField("SubItem Title", text: $store.subItem.title)
        }
      }
      .onAppear {
        BBLogger.misc.debug("[\(#filePath) \(#function)] on Appear \(store.subItem.debugDescription)")
      }
      .onChange(of: store.subItem) { oldValue, newValue in
        BBLogger.misc.debug("SubItem changed from \(oldValue.debugDescription) to \(newValue.debugDescription)")
      }
      .onChange(of: store.subItem.title) { oldValue, newValue in
        BBLogger.misc.debug("SubItem title changed from \(oldValue) to \(newValue)")
      }
    }
}

// MARK: - SubItem Preview
#Preview {
    SubItemView(
      store: Store(
        initialState: SubItemFeature.State(itemId: Item.sample1.id, subItem: SubItem()),
        reducer: { SubItemFeature() }
      )
    )
}
