import UIKit

/// Publisher array emthod

let animalPublisher = ["Lions", "Tigers", "Bears"].publisher

print("--Sink stream result:")
animalPublisher.sink(receiveCompletion: { error in print(error)}, receiveValue: {print($0)})


/// forEach array method

let animals = ["Lions", "Tigers", "Bears"]

print("\n--Basic forEach higher order function:")
animals.forEach { value in
    print(value)
}

