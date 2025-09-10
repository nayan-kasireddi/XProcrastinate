//
//  FocusViewController.swift
//  XProcrastinate
//
//  Created by Nayan Kasireddi on 8/1/24.
//

import UIKit
import AVFoundation
import UserNotifications

class FocusViewController: UIViewController {
    
    // MARK: - UI Elements (programmatically created)
    
    private let phaseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label
        label.text = "Work Time"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.text = "30:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .systemBlue
        progress.trackTintColor = .systemGray5
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        progress.progress = 0.0
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Focus", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let endButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("End Session", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let sessionCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.text = "0 focus sessions completed today"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        label.text = "Total: 0m today"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let streakLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemOrange
        label.text = "0 day streak"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Settings", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let motivationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        label.text = "🎯 Stay focused, you've got this!"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    
    private var timer: Timer?
    private var totalTime: Int = 0
    private var initialTime: Int = 0
    private var isFocusPeriod = true
    private var sessionCount = 0
    private var totalFocusTime = 0 // Track total focus time in minutes
    private var streakCount = 0 // Track consecutive days of focus sessions
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Focus Session Tracking
    private var currentSessionStartTime: Date?
    
    // New background handling properties
    private var backgroundStartTime: Date?
    private var backgroundPauseTimer: Timer?
    private var hasShownBackgroundAlert = false
    private var wasRunningWhenBackgrounded = false
    
    // Timer customization properties
    private var customFocusDuration = 30 * 60 // Default 30 minutes
    private var customBreakDuration = 10 * 60 // Default 10 minutes
    private var customLongBreakDuration = 20 * 60 // Default 20 minutes
    private var longBreakInterval = 4 // Default every 4 sessions
    
    private enum TimerState {
        case stopped, running, paused
    }
    
    private var timerState: TimerState = .stopped {
        didSet {
            updateUI()
            updateMotivationMessage()
        }
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let focusDuration = 30 * 60 // 30 minutes
        static let breakDuration = 10 * 60 // 10 minutes
        static let longBreakDuration = 20 * 60 // 20 minutes after 4 sessions
        static let longBreakInterval = 4
    }
    
    // Motivational messages for different states
    private let focusMotivations = [
        "🎯 Stay focused, you've got this!",
        "💪 Every second counts toward your goals!",
        "🔥 Deep work leads to great achievements!",
        "⚡ Channel your energy into this task!",
        "🌟 Excellence requires your full attention!",
        "🚀 You're building momentum with each minute!",
        "💎 Quality work happens in focused sessions!",
        "🧠 Your brain is at peak performance!"
    ]
    
    private let breakMotivations = [
        "😌 Rest your mind, you've earned it!",
        "🌸 A good break makes you more productive!",
        "☕ Recharge for your next focus session!",
        "🧘‍♀️ Let your mind wander and relax!",
        "🌱 Growth happens during rest too!",
        "💆‍♀️ Take care of yourself!",
        "🎨 Use this time for creative thinking!",
        "🌞 Enjoy this peaceful moment!"
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupNotifications()
        requestNotificationPermissions()
        updateUI()
        loadSessionData()
        loadUserSettings()
        setupStatsView()
        updateMotivationMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Prevent screen from dimming during focus sessions
        UIApplication.shared.isIdleTimerDisabled = true
        loadStreakData()
        
        // Handle return from background
        handleReturnFromBackground()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update gradient frame when view bounds change
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        
        // If user exits during focus session, reset timer
        if timerState == .running && isFocusPeriod {
            handleUserExit()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateUI()
        }
    }
    
    deinit {
        removeNotifications()
        endBackgroundTask()
        backgroundPauseTimer?.invalidate()
        cancelAllNotifications()
    }
    
    // MARK: - Notification Setup
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Create calming gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.1).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.05).cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.locations = [0.0, 0.3, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add all subviews
        view.addSubview(phaseLabel)
        view.addSubview(timerLabel)
        view.addSubview(progressView)
        view.addSubview(startButton)
        view.addSubview(endButton)
        view.addSubview(sessionCountLabel)
        view.addSubview(statsContainerView)
        view.addSubview(settingsButton)
        view.addSubview(motivationLabel)
        
        // Add stats labels to container
        statsContainerView.addSubview(totalTimeLabel)
        statsContainerView.addSubview(streakLabel)
        
        setupConstraints()
        addShadowEffects()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Phase label at top
            phaseLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            phaseLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phaseLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            phaseLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Timer label - large and centered
            timerLabel.topAnchor.constraint(equalTo: phaseLabel.bottomAnchor, constant: 30),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            timerLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Progress view below timer
            progressView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 30),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            // Motivation label
            motivationLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            motivationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            motivationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Button stack - centered horizontally with wider buttons
            startButton.topAnchor.constraint(equalTo: motivationLabel.bottomAnchor, constant: 40),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -75),
            startButton.widthAnchor.constraint(equalToConstant: 130),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            endButton.topAnchor.constraint(equalTo: startButton.topAnchor),
            endButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 75),
            endButton.widthAnchor.constraint(equalToConstant: 130),
            endButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Session count label
            sessionCountLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 30),
            sessionCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sessionCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            sessionCountLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Stats container
            statsContainerView.topAnchor.constraint(equalTo: sessionCountLabel.bottomAnchor, constant: 20),
            statsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statsContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Stats labels inside container
            totalTimeLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 16),
            totalTimeLabel.centerYAnchor.constraint(equalTo: statsContainerView.centerYAnchor),
            
            streakLabel.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -16),
            streakLabel.centerYAnchor.constraint(equalTo: statsContainerView.centerYAnchor),
            
            // Settings button at bottom
            settingsButton.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 20),
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 120),
            settingsButton.heightAnchor.constraint(equalToConstant: 40),
            settingsButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func addShadowEffects() {
        addShadowToView(startButton)
        addShadowToView(endButton)
        addShadowToView(settingsButton)
        addShadowToView(statsContainerView)
    }
    
    private func setupActions() {
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        endButton.addTarget(self, action: #selector(endButtonTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
    }
    
    private func setupStatsView() {
        // Stats view is already configured in the lazy initialization
        // Just add shadow
        addShadowToView(statsContainerView)
    }
    
    private func addShadowToView(_ view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Enhanced Background Handling
    
    @objc private func appDidEnterBackground() {
        backgroundStartTime = Date()
        hasShownBackgroundAlert = false
        wasRunningWhenBackgrounded = (timerState == .running)
        
        if timerState == .running {
            if isFocusPeriod {
                // Pause focus timer and start background monitoring
                pauseTimer()
                startBackgroundPauseMonitoring()
                scheduleBackgroundPauseNotification()
            } else {
                // Allow break timer to continue in background
                startBackgroundTask()
            }
        }
    }
    
    @objc private func appWillEnterForeground() {
        endBackgroundTask()
        backgroundPauseTimer?.invalidate()
        backgroundPauseTimer = nil
        cancelAllNotifications()
        updateMotivationMessage()
    }
    
    private func startBackgroundPauseMonitoring() {
        backgroundPauseTimer = Timer.scheduledTimer(withTimeInterval: 120.0, repeats: false) { [weak self] _ in
            self?.handleBackgroundPause()
        }
    }
    
    private func handleBackgroundPause() {
        guard !hasShownBackgroundAlert else { return }
        hasShownBackgroundAlert = true
        
        // Schedule local notification
        let content = UNMutableNotificationContent()
        content.title = "Focus Timer Paused"
        content.body = "Your focus session has been paused for 2 minutes. Return to continue!"
        content.sound = .default
        content.categoryIdentifier = "FOCUS_PAUSE_CATEGORY"
        
        let request = UNNotificationRequest(
            identifier: "background_pause_notification",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    private func scheduleBackgroundPauseNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Focus Timer Auto-Paused"
        content.body = "Your focus session was paused when you left the app. Tap to return and continue!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 120, repeats: false)
        let request = UNNotificationRequest(
            identifier: "focus_background_pause",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func handleReturnFromBackground() {
        guard let backgroundStartTime = backgroundStartTime else { return }
        
        let backgroundDuration = Date().timeIntervalSince(backgroundStartTime)
        self.backgroundStartTime = nil
        
        // Only show welcome back dialog if they were away for more than 10 seconds
        // and the timer was running when they left
        if backgroundDuration > 10 && wasRunningWhenBackgrounded && timerState == .paused {
            showWelcomeBackDialog(backgroundDuration: backgroundDuration)
        }
        
        wasRunningWhenBackgrounded = false
    }
    
    private func showWelcomeBackDialog(backgroundDuration: TimeInterval) {
        let minutes = Int(backgroundDuration) / 60
        let seconds = Int(backgroundDuration) % 60
        
        let timeAwayText = minutes > 0 ?
            "\(minutes) minute\(minutes == 1 ? "" : "s") and \(seconds) second\(seconds == 1 ? "" : "s")" :
            "\(seconds) second\(seconds == 1 ? "" : "s")"
        
        let alert = UIAlertController(
            title: "Welcome Back! 🎯",
            message: "You were away for \(timeAwayText). Your focus timer was paused to help you maintain concentration. Ready to continue?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Resume Focus", style: .default) { [weak self] _ in
            self?.resumeTimer()
        })
        
        alert.addAction(UIAlertAction(title: "End Session", style: .destructive) { [weak self] _ in
            self?.endSession()
        })
        
        // Auto-dismiss after 10 seconds and resume
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            if self?.presentedViewController == alert {
                alert.dismiss(animated: true) {
                    self?.resumeTimer()
                }
            }
        }
        
        present(alert, animated: true)
    }
    
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [
            "background_pause_notification",
            "focus_background_pause"
        ])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "background_pause_notification",
            "focus_background_pause"
        ])
    }
    
    // MARK: - Actions
    
    @objc private func startButtonTapped(_ sender: UIButton) {
        switch timerState {
        case .stopped:
            startNewSession()
        case .paused:
            resumeTimer()
        case .running:
            pauseTimer()
        }
        
        // Enhanced haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    @objc private func endButtonTapped(_ sender: UIButton) {
        showEndSessionAlert()
    }
    
    @objc private func settingsButtonTapped() {
        showSettingsMenu()
    }
    
    // MARK: - Settings Menu
    
    private func showSettingsMenu() {
        let alert = UIAlertController(title: "Focus Settings", message: "Customize your focus sessions", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Set Focus Duration", style: .default) { [weak self] _ in
            self?.showDurationPicker(type: .focus)
        })
        
        alert.addAction(UIAlertAction(title: "Set Break Duration", style: .default) { [weak self] _ in
            self?.showDurationPicker(type: .shortBreak)
        })
        
        alert.addAction(UIAlertAction(title: "Set Long Break Duration", style: .default) { [weak self] _ in
            self?.showDurationPicker(type: .longBreak)
        })
        
        alert.addAction(UIAlertAction(title: "Reset to Defaults", style: .destructive) { [weak self] _ in
            self?.resetToDefaults()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = settingsButton
            popover.sourceRect = settingsButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private enum DurationType {
        case focus, shortBreak, longBreak
    }
    
    private func showDurationPicker(type: DurationType) {
        let alert = UIAlertController(
            title: "Set Duration",
            message: "Enter duration in minutes (1-120)",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.placeholder = "Minutes"
            
            switch type {
            case .focus:
                textField.text = "\(self.customFocusDuration / 60)"
            case .shortBreak:
                textField.text = "\(self.customBreakDuration / 60)"
            case .longBreak:
                textField.text = "\(self.customLongBreakDuration / 60)"
            }
        }
        
        alert.addAction(UIAlertAction(title: "Set", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let text = textField.text,
                  let minutes = Int(text),
                  minutes >= 1 && minutes <= 120 else {
                self?.showInvalidDurationAlert()
                return
            }
            
            self?.updateDuration(type: type, minutes: minutes)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func updateDuration(type: DurationType, minutes: Int) {
        let seconds = minutes * 60
        
        switch type {
        case .focus:
            customFocusDuration = seconds
        case .shortBreak:
            customBreakDuration = seconds
        case .longBreak:
            customLongBreakDuration = seconds
        }
        
        saveUserSettings()
        
        let typeName = type == .focus ? "Focus" : (type == .shortBreak ? "Break" : "Long Break")
        showSuccessAlert(message: "\(typeName) duration set to \(minutes) minutes!")
    }
    
    private func resetToDefaults() {
        customFocusDuration = Constants.focusDuration
        customBreakDuration = Constants.breakDuration
        customLongBreakDuration = Constants.longBreakDuration
        saveUserSettings()
        showSuccessAlert(message: "Settings reset to defaults!")
    }
    
    private func showInvalidDurationAlert() {
        let alert = UIAlertController(
            title: "Invalid Duration",
            message: "Please enter a number between 1 and 120 minutes.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Great!", style: .default))
        present(alert, animated: true)
    }
    
    private func showEndSessionAlert() {
        let alert = UIAlertController(
            title: "End Session?",
            message: "Are you sure you want to end this focus session?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "End Session", style: .destructive) { [weak self] _ in
            self?.endSession()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Audio
    
    private func playCompletionSound() {
        guard let path = Bundle.main.path(forResource: "completion", ofType: "wav") else {
            // Fallback to system sound
            AudioServicesPlaySystemSound(1016) // Calendar Alert
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        } catch {
            print("Could not play sound: \(error)")
            AudioServicesPlaySystemSound(1016)
        }
    }
    
    // MARK: - Enhanced Data Persistence
    
    private func saveSessionData() {
        UserDefaults.standard.set(sessionCount, forKey: "focus_session_count")
        UserDefaults.standard.set(totalFocusTime, forKey: "total_focus_time")
        UserDefaults.standard.set(Date(), forKey: "last_focus_session_date")
    }
    
    private func loadSessionData() {
        // Reset daily session count and total time
        if let lastSession = UserDefaults.standard.object(forKey: "last_focus_session_date") as? Date {
            let calendar = Calendar.current
            if !calendar.isDate(lastSession, inSameDayAs: Date()) {
                sessionCount = 0
                totalFocusTime = 0
                saveSessionData()
            } else {
                sessionCount = UserDefaults.standard.integer(forKey: "focus_session_count")
                totalFocusTime = UserDefaults.standard.integer(forKey: "total_focus_time")
            }
        } else {
            sessionCount = 0
            totalFocusTime = 0
        }
    }
    
    private func saveUserSettings() {
        UserDefaults.standard.set(customFocusDuration, forKey: "custom_focus_duration")
        UserDefaults.standard.set(customBreakDuration, forKey: "custom_break_duration")
        UserDefaults.standard.set(customLongBreakDuration, forKey: "custom_long_break_duration")
        UserDefaults.standard.set(longBreakInterval, forKey: "long_break_interval")
    }
    
    private func loadUserSettings() {
        customFocusDuration = UserDefaults.standard.object(forKey: "custom_focus_duration") as? Int ?? Constants.focusDuration
        customBreakDuration = UserDefaults.standard.object(forKey: "custom_break_duration") as? Int ?? Constants.breakDuration
        customLongBreakDuration = UserDefaults.standard.object(forKey: "custom_long_break_duration") as? Int ?? Constants.longBreakDuration
        longBreakInterval = UserDefaults.standard.object(forKey: "long_break_interval") as? Int ?? Constants.longBreakInterval
    }
    
    // MARK: - Focus Session Management
    
    private func saveFocusSession(duration: Int) {
        guard let startTime = currentSessionStartTime else { return }
        
        let focusSession = FocusSession(
            startTime: startTime,
            duration: duration,
            taskName: "Focus Session"
        )
        
        // Load existing sessions
        var sessions = loadFocusSessions()
        sessions.append(focusSession)
        
        // Save updated sessions
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: "focus_sessions")
            print("Saved focus session: \(duration) seconds")
        } catch {
            print("Failed to save focus session: \(error.localizedDescription)")
        }
    }
    
    private func loadFocusSessions() -> [FocusSession] {
        guard let data = UserDefaults.standard.data(forKey: "focus_sessions") else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([FocusSession].self, from: data)
        } catch {
            print("Failed to load focus sessions: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Streak Management
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = Date()
        
        if let lastStreakDate = UserDefaults.standard.object(forKey: "last_streak_date") as? Date {
            if calendar.isDate(lastStreakDate, inSameDayAs: today) {
                // Same day, don't increment streak
                return
            } else if calendar.isDate(lastStreakDate, equalTo: calendar.date(byAdding: .day, value: -1, to: today) ?? today, toGranularity: .day) {
                // Yesterday, increment streak
                streakCount += 1
            } else {
                // Streak broken, reset
                streakCount = 1
            }
        } else {
            // First time
            streakCount = 1
        }
        
        UserDefaults.standard.set(today, forKey: "last_streak_date")
        UserDefaults.standard.set(streakCount, forKey: "current_streak")
    }
    
    private func loadStreakData() {
        streakCount = UserDefaults.standard.integer(forKey: "current_streak")
        
        // Check if streak is still valid
        if let lastStreakDate = UserDefaults.standard.object(forKey: "last_streak_date") as? Date {
            let calendar = Calendar.current
            let daysSinceLastStreak = calendar.dateComponents([.day], from: lastStreakDate, to: Date()).day ?? 0
            
            if daysSinceLastStreak > 1 {
                // Streak broken
                streakCount = 0
                UserDefaults.standard.set(0, forKey: "current_streak")
            }
        }
    }
    
    // MARK: - Timer Management
    
    private func startNewSession() {
        totalTime = customFocusDuration
        initialTime = totalTime
        isFocusPeriod = true
        timerState = .running
        currentSessionStartTime = Date() // Track session start
        
        startTimer()
        startBackgroundTask()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        timerState = .paused
        endBackgroundTask()
        
        // Cancel any background monitoring when manually paused
        backgroundPauseTimer?.invalidate()
        backgroundPauseTimer = nil
    }
    
    private func resumeTimer() {
        startTimer()
        timerState = .running
        startBackgroundTask()
        
        // Clear any background-related state
        backgroundPauseTimer?.invalidate()
        backgroundPauseTimer = nil
        cancelAllNotifications()
    }
    
    private func endSession() {
        // Save partial session if it was a focus period and some time was spent
        if isFocusPeriod && currentSessionStartTime != nil {
            let timeSpent = initialTime - totalTime
            if timeSpent >= 60 { // Only save if at least 1 minute was spent
                saveFocusSession(duration: timeSpent)
            }
        }
        
        timer?.invalidate()
        timer = nil
        timerState = .stopped
        resetTimer()
        endBackgroundTask()
        currentSessionStartTime = nil
        
        // Clean up background monitoring
        backgroundPauseTimer?.invalidate()
        backgroundPauseTimer = nil
        cancelAllNotifications()
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    private func resetTimer() {
        totalTime = 0
        initialTime = 0
        isFocusPeriod = true
        currentSessionStartTime = nil
        updateUI()
    }
    
    @objc private func updateTimer() {
        guard totalTime > 0 else {
            handleTimerCompletion()
            return
        }
        
        totalTime -= 1
        updateUI()
    }
    
    private func handleTimerCompletion() {
        playCompletionSound()
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        if isFocusPeriod {
            // Focus period completed - save full session
            saveFocusSession(duration: initialTime)
            
            // Update stats
            sessionCount += 1
            totalFocusTime += customFocusDuration / 60 // Convert to minutes
            updateStreak()
            saveSessionData()
            switchToBreakPeriod()
        } else {
            // Break period completed
            switchToFocusPeriod()
        }
    }
    
    private func switchToBreakPeriod() {
        isFocusPeriod = false
        currentSessionStartTime = nil // Reset for break
        
        // Determine break duration (long break every N sessions)
        let isLongBreak = sessionCount % longBreakInterval == 0
        totalTime = isLongBreak ? customLongBreakDuration : customBreakDuration
        initialTime = totalTime
        
        showPhaseTransitionAlert(isBreak: true, isLong: isLongBreak)
    }
    
    private func switchToFocusPeriod() {
        isFocusPeriod = true
        totalTime = customFocusDuration
        initialTime = totalTime
        currentSessionStartTime = Date() // Track new focus session start
        
        showPhaseTransitionAlert(isBreak: false, isLong: false)
    }
    
    private func showPhaseTransitionAlert(isBreak: Bool, isLong: Bool) {
        let title = isBreak ? (isLong ? "Long Break Time!" : "Break Time!") : "Focus Time!"
        let message = isBreak ?
            "Amazing work! Take a well-deserved break and recharge." :
            "Break's over! Time to dive deep into focused work again."
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Start", style: .default) { [weak self] _ in
            self?.timerState = .running
            self?.startTimer()
            self?.startBackgroundTask()
        })
        
        alert.addAction(UIAlertAction(title: "Skip", style: .cancel) { [weak self] _ in
            if isBreak {
                self?.switchToFocusPeriod()
            } else {
                self?.endSession()
            }
        })
        
        present(alert, animated: true)
    }
    
    private func handleUserExit() {
        // User exited during focus period - save partial session and reset
        if isFocusPeriod && timerState == .running && currentSessionStartTime != nil {
            let timeSpent = initialTime - totalTime
            if timeSpent >= 60 { // Only save if at least 1 minute was spent
                saveFocusSession(duration: timeSpent)
            }
            
            endSession()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let alert = UIAlertController(
                    title: "Focus Session Reset",
                    message: "Since you left during your focus time, the timer has been reset. Stay focused to build better habits!",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Got it", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        updateTimerLabel()
        updatePhaseLabel()
        updateProgressView()
        updateButtons()
        updateSessionCountLabel()
        updateStatsLabels()
    }
    
    private func updateTimerLabel() {
        let minutes = totalTime / 60
        let seconds = totalTime % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
        // Enhanced color coding with animation
        let newColor: UIColor
        if totalTime <= 60 && totalTime > 0 { // Last minute
            newColor = .systemRed
        } else if isFocusPeriod {
            newColor = .systemBlue
        } else {
            newColor = .systemGreen
        }
        
        UIView.transition(with: timerLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.timerLabel.textColor = newColor
        }
    }
    
    private func updatePhaseLabel() {
        let (text, color) = isFocusPeriod ?
            ("Work Time", UIColor.systemBlue) :
            (sessionCount % longBreakInterval == 0 ? "Long Break" : "Break Time", UIColor.systemGreen)
        
        UIView.transition(with: phaseLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.phaseLabel.text = text
            self.phaseLabel.textColor = color
        }
    }
    
    private func updateProgressView() {
        guard initialTime > 0 else { return }
        
        let progress = Float(initialTime - totalTime) / Float(initialTime)
        
        UIView.animate(withDuration: 0.3) {
            self.progressView.setProgress(progress, animated: true)
            
            // Change progress color based on phase
            if self.isFocusPeriod {
                self.progressView.progressTintColor = .systemBlue
            } else {
                self.progressView.progressTintColor = .systemGreen
            }
        }
    }
    
    private func updateButtons() {
        let (title, color, enabled) = getButtonConfiguration()
        
        UIView.animate(withDuration: 0.3) {
            self.startButton.setTitle(title, for: .normal)
            self.startButton.backgroundColor = color
            self.startButton.isEnabled = enabled
            self.endButton.isEnabled = self.timerState != .stopped
        }
    }
    
    private func getButtonConfiguration() -> (String, UIColor, Bool) {
        switch timerState {
        case .stopped:
            return ("Start Focus", .systemGreen, true)
        case .running:
            return ("Pause", .systemOrange, true)
        case .paused:
            return ("Resume", .systemBlue, true)
        }
    }
    
    private func updateSessionCountLabel() {
        let sessionsText = sessionCount == 1 ? "session" : "sessions"
        sessionCountLabel.text = "\(sessionCount) focus \(sessionsText) completed today"
    }
    
    private func updateStatsLabels() {
        let hours = totalFocusTime / 60
        let minutes = totalFocusTime % 60
        if hours > 0 {
            totalTimeLabel.text = "Total: \(hours)h \(minutes)m"
        } else {
            totalTimeLabel.text = "Total: \(minutes)m today"
        }
        
        streakLabel.text = "\(streakCount) day streak"
    }
    
    private func updateMotivationMessage() {
        let messages = isFocusPeriod ? focusMotivations : breakMotivations
        let randomMessage = messages.randomElement() ?? messages[0]
        
        UIView.transition(with: motivationLabel, duration: 0.5, options: .transitionCrossDissolve) {
            self.motivationLabel.text = randomMessage
        }
    }
    
    // MARK: - Background Task Management
    
    private func startBackgroundTask() {
        endBackgroundTask() // End any existing task first
        
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "FocusTimer") { [weak self] in
            // This block is called when background time is about to expire
            self?.endBackgroundTask()
            
            // If we're in a break period and time expired, pause the timer
            if self?.timerState == .running && self?.isFocusPeriod == false {
                DispatchQueue.main.async {
                    self?.pauseTimer()
                }
            }
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}

