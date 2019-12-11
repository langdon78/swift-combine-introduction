import UIKit
import Combine

let redBox: UIView = {
    let view = UIView(frame: .zero)
    view.backgroundColor = .red
    return view
}()

let greenBox: UIView = {
    let view = UIView(frame: .zero)
    view.backgroundColor = .green
    return view
}()

let blueBox: UIView = {
    let view = UIView(frame: .zero)
    view.backgroundColor = .blue
    return view
}()

/// Map Operator

let boxPublisher = [redBox, greenBox, nil, blueBox].publisher

boxPublisher.map { box in
    box?.backgroundColor?.cgColor.components }
    .sink { values in
        print(values) }


/// Compact Map Operator

boxPublisher.compactMap { box in
    box?.backgroundColor?.cgColor.components }
    .sink { values in
        print(values) }

/// Assign and First/Last Operators

class Pixel {
    var color: UIColor = .white
    init() {}
}

var pixel = Pixel()

boxPublisher.compactMap { box in
    box?.backgroundColor }
//    .first()
//    .last()
    .last(where: { $0 == .green })
    .assign(to: \.color, on: pixel)

print(pixel.color)

/// flatMap Operator

class Person {
    var name: String
    var age: CurrentValueSubject<Int, Never>
    
    init(name: String, age: Int = 21) {
        self.name = name
        self.age = CurrentValueSubject<Int, Never>(age)
    }
}

let people = [
    Person(name: "James"),
    Person(name: "Mahesh", age: 25),
    Person(name: "Krishna", age: 23)
]

let peoplePublisher = people.publisher

peoplePublisher.sink { print($0.age) }

peoplePublisher.flatMap { person in
    person.age }
    .sink { age in
        print(age) }


/// merge and collect

let odds = [1,3,5,7].publisher
let evens = [2,4,6,8].publisher

odds.merge(with: evens)
.sink { value in
    print(value)}

odds.merge(with: evens)
    .collect()
    .sink { value in
        print(value)}


/// Remove duplcates

let pub = [1,1,1,2,2,2,3].publisher

pub.removeDuplicates().sink { print($0) }


/// scan and Timer publisher

let timerPub = Timer.publish(every: 1, on: RunLoop.main, in: .common).autoconnect()

let cancellable = timerPub.scan(0, { value, _ in
    return value + 1 })
    .sink { print($0) }

cancellable.cancel()


/// allSatisfy

evens.allSatisfy { $0 % 2 == 0 }
    .sink { print($0) }

let badEvens = evens.append(13)

badEvens.allSatisfy { $0 % 2 == 0 }
    .sink { print($0) }
