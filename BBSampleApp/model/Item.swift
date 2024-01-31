//
//  Model.swift
//  BB
//
//  Created by Andreas Seeger on 17.05.23.
//

import Foundation
import Tagged

struct Item: Equatable, Identifiable {
  let id: Tagged<Self, UUID>
  var title: String
  var subItems: [SubItem]

  init(
    id: UUID = UUID(),
    title: String = "",
    subItems: [SubItem] = []
  ) {
    self.id = Tagged(rawValue: id)
    self.title = title
    self.subItems = subItems
  }
}

extension Item: CustomDebugStringConvertible {
  var debugDescription: String {
    """
    
    Item id: \(self.id)
    title: \(self.title)
    subItems: \(self.subItems)
    """
  }
  

}

//MARK: Item Mocks
extension Item {
  static let sample1 = Item(title: "1st Item")
  static let sampple2 = Item(title: "2nd Item")
  static let sample3 = Item(title: "3rd Item")
  
  static let sampleArray = [sample1, sampple2, sample3]
}
