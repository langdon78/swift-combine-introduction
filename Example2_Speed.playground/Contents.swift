import UIKit
import Combine

/// Using CurrentValueSubject in a delegate pattern

/// Interface for setting current speed
protocol SpeedDelegate {
    func setCurrent(speed: Int)
}

/// Publishes current speed value and
/// implements SpeedDelegate
class SpeedPublisher {
    let subject = CurrentValueSubject<Int, Never>(0)
}

extension SpeedPublisher: SpeedDelegate {
    func setCurrent(speed: Int) {
        subject.send(speed)
    }
}

/// Car object calls speedDelegate when speed value changes
class Car {
    var speedDelegate: SpeedDelegate
    var speed: Int = 0 {
        didSet {
            speedDelegate.setCurrent(speed: speed)
        }
    }
    
    init(speedDelegate: SpeedDelegate) {
        self.speedDelegate = speedDelegate
    }
    
    func accellerate() {
        speed += 10
    }
    
    func brake() {
        if speed > 10 {
            speed -= 10
        }
    }
}

/// Displays speed value each time speed changes
class Display {
    var cancellable: AnyCancellable
    
    init(subject: CurrentValueSubject<Int, Never>) {
        self.cancellable = subject.sink { speed in
            print("Your current speed is \(speed)")
        }
    }
    
    deinit {
        cancellable.cancel()
    }
}

/// Cop object holds a subscriber to speed publisher.
/// If Cop is currently subscribing to speed publisher
/// and speed value exceeds speed limit, a ticket event
/// is fired
class Cop {
    let speedLimit: Int = 60
    var cancellable: AnyCancellable?
    var speed: Int = 0 {
        didSet {
            checkRadar(for: speed)
        }
    }
    
    func startSpeedTrap(speedPublisher: CurrentValueSubject<Int, Never>) {
        print("Driver has entered speed trap")
        self.cancellable = speedPublisher.assign(to: \.speed, on: self)
    }
    
    func stopSpeedTrap() {
        print("Driver has exited speed trap")
        cancellable?.cancel()
    }
    
    func checkRadar(for speed: Int) {
        if speed > speedLimit {
            print("You got a speeding ticket!!")
        }
    }
    
    deinit {
        cancellable?.cancel()
    }
}

var speedPublisher = SpeedPublisher()
var car = Car(speedDelegate: speedPublisher)
var display = Display(subject: speedPublisher.subject)
var theCops = Cop()

car.accellerate()
car.accellerate()
car.accellerate()
car.accellerate()
car.accellerate()
car.accellerate()
car.accellerate()
theCops.startSpeedTrap(speedPublisher: speedPublisher.subject)
car.brake()
car.brake()
car.accellerate()
car.accellerate()
car.brake()
car.brake()
car.accellerate()
theCops.stopSpeedTrap()
car.accellerate()
car.accellerate()
car.accellerate()
