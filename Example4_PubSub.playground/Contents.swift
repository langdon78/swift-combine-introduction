import UIKit
import Combine

/// Custom publisher extension

extension Array {
    var publisher: Publishers.Sequence<Array<Element>, Never> {
        return Publishers.Sequence(sequence: self)
    }
}

/// Custom Subscription

class NameSubscription: Subscription {
    var demand: Subscribers.Demand = .unlimited
    
    init() {}
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    func cancel() {
        self.demand = .none
    }
    
    var combineIdentifier: CombineIdentifier = CombineIdentifier("" as AnyObject)
    
}

enum StringError: Error {
    case empty
}

/// Custom Publisher

struct NamePublisher: Publisher {
    typealias Output = String
    typealias Failure = Never
    
    var values: [String]
    
    func receive<S>(subscriber: S) where S : Subscriber, NamePublisher.Failure == S.Failure, NamePublisher.Output == S.Input {
        let sub = NameSubscription()
        
        // Let subscriber know subscription was created
        subscriber.receive(subscription: sub)
        
        for (index, value) in values.enumerated() {
            // Check Backpressure
            switch sub.demand {
            case .none: break
            case .unlimited: subscriber.receive(value)
            default:
                if index < sub.demand.max ?? 0 {
                    subscriber.receive(value)
                }
            }
        }
        subscriber.receive(completion: .finished)
    }
    
}

/// Custom Subscriber

class NameSubscriber: Subscriber {
    typealias Input = String // Subscriber Input must match Publisher Output
    typealias Failure = Never
    
    func receive(subscription: Subscription) {
        print("Received subscription")
        subscription.request(.max(2))
    }
    
    func receive(_ input: String) -> Subscribers.Demand {
        print("Received Value", input)
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("Completed")
    }
    
}

let namePub = NamePublisher(values: [
    "James",
    "Liz",
    "Wendy",
    "Santa"
])

let nameSub = NameSubscriber()
namePub.subscribe(nameSub)


namePub.sink(receiveCompletion: {_ in
    print("No more values")
}, receiveValue: {
    print("Recevied Value: \($0)")
})
