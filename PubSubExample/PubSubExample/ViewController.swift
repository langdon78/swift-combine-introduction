//
//  ViewController.swift
//  PubSubExample
//
//  Created by James Langdon on 12/7/19.
//  Copyright © 2019 corporatelangdon. All rights reserved.
//

import UIKit
import Combine

enum TapError: Error {
    case poop
}

class ViewController: UIViewController {
    
    @IBOutlet var shapeButtonCollection: [UIButton]! {
        didSet {
            for button in shapeButtonCollection {
                button.layer.cornerRadius = 15.0
            }
        }
    }
    @IBOutlet weak var pubIconButton: UIButton!
    @IBOutlet weak var greenPubIconButton: UIButton!
    @IBOutlet weak var redPubIconButton: UIButton!
    @IBOutlet weak var bluePubIconButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var greenLineView: UIView!
    @IBOutlet weak var redLineView: UIView!
    @IBOutlet weak var blueLineView: UIView!
    
    @IBOutlet weak var greenScoreLabel: UILabel!
    @IBOutlet weak var redScoreLabel: UILabel!
    @IBOutlet weak var blueScoreLabel: UILabel!
    
    var greenBulletEdge: CGFloat = 0
    var greenCloudEdge: CGFloat = 0
    
    var publisher: PassthroughSubject<UIButton, TapError>!
    var togglePublisher = CurrentValueSubject<([UIButton], Bool), Never>(([], false))
    
    var cancellable: AnyCancellable?
    var greenCancellable: AnyCancellable?
    var redCancellable: AnyCancellable?
    var blueCancellable: AnyCancellable?
    var resetCancellable: AnyCancellable?
    var toggleCancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureShooterSubscribers()
        configureToggleSubscribers()
    }
    
    private func configureShooterSubscribers() {
        publisher = PassthroughSubject<UIButton, TapError>()
        
        cancellable = publisher.tryMap { button in
            self.view(from: button, alignWith: self.pubIconButton)
        }
        .sink(receiveCompletion: onCompletion, receiveValue: { newView in
            SoundPlayer.shared.playSound(for: "pew")
            self.animate(view: newView, with: self.lineView)
        })
        
        greenCancellable = cancellable(for: publisher, alignWith: greenPubIconButton, color: .systemGreen, lineView: greenLineView, scoreUpdater: greenScoreLabel)
        redCancellable = cancellable(for: publisher, alignWith: redPubIconButton, color: .systemRed, lineView: redLineView, scoreUpdater: redScoreLabel)
        blueCancellable = cancellable(for: publisher, alignWith: bluePubIconButton, color: .systemBlue, lineView: blueLineView, scoreUpdater: blueScoreLabel)
    }
    
    private func configureToggleSubscribers() {
        toggleCancellable = togglePublisher.sink { (buttons, on) in
            buttons.forEach { $0.isEnabled = on }
        }
        
        resetCancellable = togglePublisher.map { !$0.1 }
        .assign(to: \.isEnabled, on: resetButton)
    }
    
    private func cancellable(for publisher: PassthroughSubject<UIButton, TapError>,
                                alignWith pubIcon: UIButton,
                                color: UIColor,
                                lineView: UIView,
                                scoreUpdater: UILabel) -> AnyCancellable {
        
        return publisher.catch { _ in Just(UIButton()) }
        .map { button in
            self.view(from: button, alignWith: pubIcon)
        }
        .filter { view in
            view.backgroundColor?.cgColor == color.cgColor && pubIcon.isEnabled
        }
        .sink { view in
            scoreUpdater.text = self.updateScore(for: scoreUpdater.text)
            self.animate(view: view, with: lineView)
        }
    }
    
    private func view(from button: UIButton, alignWith pubView: UIView) -> UIView {
        let view = UIView(frame:
            CGRect(
                x: 0,
                y: pubView.frame.origin.y,
                width: button.frame.width,
                height: button.frame.height))
        view.center = pubView.center
        view.backgroundColor = button.backgroundColor
        view.layer.cornerRadius = button.layer.cornerRadius
        return view
    }
    
    private func animate(view: UIView, with lineView: UIView) {
        self.view.addSubview(view)
        self.view.sendSubviewToBack(view)
        self.view.sendSubviewToBack(lineView)
        UIView.animate(withDuration: 2.0, delay: 0, options: [], animations: {
            view.frame.origin.x = 300
            UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
                view.frame.origin.x = 400
                view.backgroundColor = view.backgroundColor?.withAlphaComponent(0.0)
            }, completion: { _ in
                view.removeFromSuperview()
            })
        })
    }
    
    private func onCompletion(_ error: Subscribers.Completion<Error>) {
        SoundPlayer.shared.playSound(for: "fart")
        redScoreLabel.text = "0"
        greenScoreLabel.text = "0"
        blueScoreLabel.text = "0"
        self.togglePublisher.send((
            [
                self.pubIconButton,
                self.redPubIconButton,
                self.bluePubIconButton,
                self.greenPubIconButton
        ], false))
    }
    
    private func updateScore(for score: String?) -> String {
        guard let score = score,
            let currentScore = Int(score) else { return "0" }
        let newScore = currentScore + 1
        return String(newScore)
    }
    
    deinit {
        cancellable?.cancel()
        greenCancellable?.cancel()
        redCancellable?.cancel()
        blueCancellable?.cancel()
        resetCancellable?.cancel()
        toggleCancellable?.cancel()
    }
    
    @IBAction func shapeButtonPressed(_ sender: UIButton) {
        if sender.tag == 1 {
            publisher.send(completion: .failure(TapError.poop))
        } else {
            publisher.send(sender)
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        configureShooterSubscribers()
        sender.isEnabled = false
        togglePublisher.send(([
            pubIconButton,
            redPubIconButton,
            bluePubIconButton,
            greenPubIconButton
        ], true))
    }
    
    @IBAction func pubIconButtonPressed(_ sender: UIButton) {
        togglePublisher.send(([sender], !sender.isEnabled))
    }
    
}
