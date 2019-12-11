import UIKit
import Combine

struct ToDo: Codable {
    var userId: Int
    var id: Int
    var title: String
    var completed: Bool
    
    static var placeholder: ToDo {
        return ToDo(userId: 0, id: 0, title: "", completed: true)
    }
}

/// Data Task old way

let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!

func requestTodo(from url: URL, completion: @escaping (ToDo?) -> Void) {
    let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print(error)
            return
        }
        
        guard let data = data else { return }
        let decoder = JSONDecoder()
        let todo = try? decoder.decode(ToDo.self, from: data)
        completion(todo)
    }
    dataTask.resume()
}

requestTodo(from: url) { todo in
    guard let todo = todo else { return }
    print("Without Combine")
    print(todo)
}

/// Data Task with Combine

let publisher = URLSession.shared.dataTaskPublisher(for: url)
let cancellable = publisher.map { $0.data }
    .decode(type: ToDo.self, decoder: JSONDecoder())
    .receive(on: RunLoop.main)
    .sink(receiveCompletion: { response in
        print(response)
    }, receiveValue: {
        print("Received response from Combine publisher")
        print($0)
    })

func requestTodoFromPublisher(with url: URL) -> AnyPublisher<ToDo, Error> {
    return URLSession.shared.dataTaskPublisher(for: url)
        .map { $0.data }
        .decode(type: ToDo.self, decoder: JSONDecoder())
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
}

let anyPublisher = requestTodoFromPublisher(with: url)
    .catch { error in
        Just(ToDo.placeholder) }
    .sink { todo in print(todo) }
