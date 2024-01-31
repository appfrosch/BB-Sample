//
//  SubItem.swift
//  BB
//
//  Created by Andreas Seeger on 22.01.2024.
//

import Foundation
import Tagged

struct SubItem: Codable, Equatable, Identifiable {
  let id: Tagged<Self, UUID>
  var title: String

  init(
    id: UUID = UUID(),
    title: String = ""
  ) {
    self.id = Tagged(rawValue: id)
    self.title = title
  }
}

extension SubItem: CustomDebugStringConvertible {
  var debugDescription: String {
    """

    SubItem id: \(self.id)
    title: \(self.title)
    """
  }

}
