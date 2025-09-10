//
//  FocusViewController.swift
//  XProcrastinate
//
//  Created by Nayan Kasireddi on 8/1/24.
//

import UIKit

class FocusViewController: UIViewController {
    
    @IBOutlet weak var phaseLabel: UILabel!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    var timer: Timer?
    var totalTime: Int = 0
    var isFocusPeriod = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTimerLabel()
        updatePhaseLabel()
        endButton.isEnabled = false
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if timer == nil {
            totalTime = 30 * 60 // 30 minutes in seconds
            startTimer()
            startButton.isEnabled = false
            endButton.isEnabled = true
        }
    }
    
    @IBAction func endButtonTapped(_ sender: UIButton) {
        stopTimer()
        resetTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        isFocusPeriod = true
        totalTime = 0
        updateTimerLabel()
        updatePhaseLabel()
        startButton.isEnabled = true
        endButton.isEnabled = false
    }
    
    func updatePhaseLabel() {
            phaseLabel.text = isFocusPeriod ? "Work" : "Break"
        }
    
    @objc func updateTimer() {
        if totalTime > 0 {
            totalTime -= 1
            updateTimerLabel()
        } else {
            if isFocusPeriod {
                // Switch to break period
                isFocusPeriod = false
                totalTime = 10 * 60 // 10 minutes in seconds
                updatePhaseLabel()
            } else {
                // Timer finished, reset
                isFocusPeriod = true
                totalTime = 30 * 60
                updatePhaseLabel()
            }
        }
    }
    
    func updateTimerLabel() {
        let minutes = totalTime / 60
        let seconds = totalTime % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}
