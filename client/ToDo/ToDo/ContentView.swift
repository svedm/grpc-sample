//
//  ContentView.swift
//  ToDo
//
//  Created by Svetoslav on 05.11.2020.
//

import SwiftUI
import GRPC
import NIO
import Combine

struct ToDoItem {
    var id: String
    var text: String
}

class ToDoViewModel: ObservableObject {
    private let group: EventLoopGroup
    private let client: Todo_ToDoServiceClient
    private var disposeBag = Set<AnyCancellable>()

    @Published var list: [ToDoItem] = []

    init() {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let connection = ClientConnection.insecure(group: group)
            .connect(host: "localhost", port: 5000)
        client = Todo_ToDoServiceClient(channel: connection)
    }

    deinit {
        print("\(self)")
        try? group.syncShutdownGracefully()
    }

    func fetch() {
        let call = client.list(Todo_Empty())

        Future<[Todo_ToDoItem], Never> { completion in
            do {
                let response = try call.response.wait()
                completion(.success(response.items))
            } catch {
                print(error)
            }
        }
        .map { $0.map { ToDoItem(id: $0.id, text: $0.text) } }
        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .receive(on: DispatchQueue.main)
        .assign(to: &$list)
    }

    func add(task: String) {
        var request = Todo_AddRequest()
        request.text = task
        let call = client.add(request)

        Future<Todo_ToDoItem, Never> { completion in
            do {
                let response = try call.response.wait()
                completion(.success(response))
            } catch {
                print(error)
            }
        }
        .map { ToDoItem(id: $0.id, text: $0.text) }
        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .receive(on: DispatchQueue.main)
        .sink { item in
            self.list.append(item)
        }
        .store(in: &disposeBag)
    }

    func remove(id: String) {
        var request = Todo_RemoveRequest()
        request.id = id
        let call = client.remove(request)

        Future<Todo_ToDoItem, Never> { completion in
            do {
                let response = try call.response.wait()
                completion(.success(response))
            } catch {
                print(error)
            }
        }
        .map { ToDoItem(id: $0.id, text: $0.text) }
        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .receive(on: DispatchQueue.main)
        .sink { item in
            self.list.removeAll { $0.id == item.id }
        }
        .store(in: &disposeBag)
    }
}

struct ContentView: View {
    @ObservedObject private var viewModel = ToDoViewModel()
    @State private var newTask: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.list, id: \.id) { item in
                        ToDoRow(text: item.text)
                    }
                    .onDelete(perform: delete)
                }
                HStack {
                    TextField("New task", text: $newTask)
                    Button("Add", action: add)
                }
                .padding(12)
            }
            .navigationTitle("Tasks")
        }
        .onAppear(perform: viewModel.fetch)
    }

    private func add() {
        viewModel.add(task: newTask)
        newTask = ""
    }

    private func delete(indexSet: IndexSet) {
        indexSet.forEach { index in
            let item = viewModel.list[index]
            viewModel.remove(id: item.id)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
