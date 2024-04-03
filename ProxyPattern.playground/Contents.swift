import UIKit
import CoreGraphics

protocol Zerg {
    func greet()
    func move(to point: CGPoint)
}

protocol Terran {
    func greet()
    func move(to point: CGPoint)
}

protocol Creator<Creature> {
    associatedtype Creature

    func create() -> Creature
}

protocol TerranCreator: Creator where Creature: Terran {}
protocol ZergCreator: Creator where Creature: Zerg {}


final class Cocoon<Creator: ZergCreator> {
    private(set) var creature: Creator.Creature?

    private let creationInterval: TimeInterval
    private let creator: Creator

    private var rallyPoint: CGPoint?
    private var creationTimer: Timer?

    init(
        creationInterval: TimeInterval,
        creator: Creator
    ) {
        self.creationInterval = creationInterval
        self.creator = creator

        create()
    }

    func cancel() {
        creationTimer?.invalidate()
        creationTimer = nil
    }

    private func create() {
        creationTimer = Timer.scheduledTimer(
            withTimeInterval: creationInterval,
            repeats: false
        ) { [weak self] _ in
            self?.creature = self?.creator.create()
            self?.creature?.greet()
            self?.moveToPointIfNeeded()
        }
    }

    private func moveToPointIfNeeded() {
        guard let point = rallyPoint else {
            return
        }
        creature?.move(to: point)
    }
}

extension Cocoon: Zerg {
    func greet() {
        creature?.greet()
    }

    func move(to point: CGPoint) {
        if let zerg = creature {
            zerg.move(to: point)
        } else {
            rallyPoint = point
        }
    }
}

final class Mariner {
    private let name: String

    init(name: String) {
        self.name = name
    }
}

extension Mariner: Terran {
    func greet() {
        print("[TERRAN]: I'm terran \(name)")
    }

    func move(to point: CGPoint) {
        print("[TERRAN]: Mariner moved to \(point)")
    }
}

final class Drone {
    private let name: String

    init(name: String) {
        self.name = name
    }
}

extension Drone: Zerg {
    func greet() {
        print("[ZERG]: I'm drone named \(name)")
    }

    func move(to point: CGPoint) {
        print("[ZERG]: Drone moved to point \(point)")
    }
}

final class DroneCreator: ZergCreator {
    typealias Creature = Drone

    func create() -> Drone {
        let drone = Drone(name: UUID().uuidString)
        return drone
    }
}

let droneCreator = DroneCreator()

let droneCocoon = Cocoon(
    creationInterval: 3.0,
    creator: droneCreator
)

droneCocoon.move(to: .init(x: 3, y: 2))
