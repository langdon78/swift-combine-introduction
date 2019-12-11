import UIKit

struct Car {
    var make: String
    var model: String
}

/// Notification Center (old school)

let readyForDelivery = Notification.Name("readyForDelivery")

class FordDealership {
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(addInventory(notification:)), name: readyForDelivery, object: nil)
    }
    
    deinit {
        print("Removed Observer")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func addInventory(notification: Notification) {
        guard let car = notification.object as? Car else { return }
        print("-----Old School-----")
        print("Received \(car.make) \(car.model)")
    }
}

var fordDealership: FordDealership? = FordDealership()
let mustang = Car(make: "Ford", model: "Mustang")
NotificationCenter.default.post(name: readyForDelivery, object: mustang, userInfo: nil)
fordDealership = nil



/// Notification Center (new hotness)

import Combine

class ChevyDealership {
    var cancellable: AnyCancellable?
    
    init() {
        let publisher = NotificationCenter.default.publisher(for: readyForDelivery)
        cancellable = publisher.sink { notification in
            print("-----New Hotness-----")
            guard let car = notification.object as? Car else { return }
            print("Received \(car.make) \(car.model)")
        }
    }
    
    deinit {
        print("Cancelled Subscription")
        cancellable?.cancel()
    }
}

var chevyDealership: ChevyDealership? = ChevyDealership()
let chevy = Car(make: "Chevy", model: "Camero")
NotificationCenter.default.post(name: readyForDelivery, object: chevy, userInfo: nil)
chevyDealership = nil
