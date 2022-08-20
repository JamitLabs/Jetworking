// Copyright © 2022 Jamit Labs GmbH. All rights reserved.

import UIKit

final class MainViewController: UIViewController {
    // MARK: - Properties
    /// Set method to perform the requests: Combine or plain completion handlers
    let useCombineVariant: Bool = false

    // MARK: - Methods
    @IBAction func getTodosPressed(_ sender: Any) {
        if useCombineVariant {
            ExampleClient.default.getAllTodos().sink { _ in } receiveValue: { todos in
                print(todos)
            }.store(in: &cancellables)
        } else {
            ExampleClient.default.getAllTodos { _, result in
                switch result {
                case let .success(todos):
                    print(todos)

                case let .failure(error):
                    print(error)
                }
            }
        }
    }

    @IBAction func getTodo1Pressed(_ sender: Any) {
        if useCombineVariant {
            ExampleClient.default.getSingleTodo(id: 1).sink { _ in } receiveValue: { todo in
                print(todo)
            }.store(in: &cancellables)
        } else {
            ExampleClient.default.getSingleTodo(id: 1) { _, result in
                switch result {
                case let .success(todo):
                    print(todo)

                case let .failure(error):
                    print(error)
                }
            }
        }
    }

    @IBAction func deleteTodo1Pressed(_ sender: Any) {
        if useCombineVariant {
            ExampleClient.default.deleteSingleTodo(id: 1).sink { _ in } receiveValue: { result in
                print(result)
            }.store(in: &cancellables)
        } else {
            ExampleClient.default.deleteSingleTodo(id: 1) { _, result in
                switch result {
                case let .success(empty):
                    print(empty)

                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}
