//
//  ToDoRow.swift
//  ToDo
//
//  Created by Svetoslav on 05.11.2020.
//

import SwiftUI

struct ToDoRow: View {
    var text: String

    var body: some View {
        Text(text)
    }
}

struct ToDoRow_Previews: PreviewProvider {
    static var previews: some View {
        ToDoRow(text: "Test")
    }
}
