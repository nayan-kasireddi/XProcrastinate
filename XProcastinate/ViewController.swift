//
//  ViewController.swift
//  XProcrastinate
//
//  Created by Nayan Kasireddi on 7/28/24.
//

import UserNotifications
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    
    private var models = [MyReminder]()
    private var completedReminders = [MyReminder]() // Store completed assignments
    private var sessionStartTime: Date?
    private var currentTaskName: String?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNotificationCenter()
        setupHelpButton()
        setupCompletedButton()
        setupAnalyticsGesture()
        loadReminders()
        loadCompletedReminders()
        requestNotificationPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()
    }
    
    // MARK: - Setup Methods
    
    private func setupTableView() {
        table.delegate = self
        table.dataSource = self
        
        // Performance improvements for table view
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        table.refreshControl = refreshControl
    }
    
    private func setupNotificationCenter() {
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if !granted {
                    self?.showNotificationPermissionAlert()
                }
            }
        }
    }
    
    private func showNotificationPermissionAlert() {
        let alert = UIAlertController(
            title: "Notifications Required",
            message: "XProcrastinate needs notification permission to remind you about your assignments. Please enable notifications in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Data Management
    
    @objc private func refreshData() {
        loadReminders()
        table.reloadData()
        table.refreshControl?.endRefreshing()
        
        // Update badge count based on current assignments
        updateBadgeCount()
        
        // CRITICAL: Only schedule motivational notifications if we have assignments
        if !models.isEmpty {
            scheduleMotivationalNotificationsForOverdueAssignments()
        } else {
            // Clear all notifications if no assignments exist
            clearAllMotivationalNotifications()
            print("No assignments - cleared all motivational notifications")
        }
        
        // Debug: Check pending notifications
        checkPendingNotifications()
    }
    
    private func updateBadgeCount() {
        let overdueCount = models.filter { $0.date < Date() }.count
        UIApplication.shared.applicationIconBadgeNumber = overdueCount
    }
    
    // MARK: - Debug Method
    
    private func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                print("=== PENDING NOTIFICATIONS ===")
                print("Total pending: \(requests.count)")
                for request in requests {
                    print("ID: \(request.identifier)")
                    print("Title: \(request.content.title)")
                    if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                        print("Time interval: \(trigger.timeInterval) seconds")
                        print("Repeats: \(trigger.repeats)")
                        print("Will fire at: \(Date().addingTimeInterval(trigger.timeInterval))")
                    } else if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                        print("Calendar trigger: \(trigger.dateComponents)")
                    }
                    print("---")
                }
                print("=============================")
            }
        }
    }
    
    private func addReminder(_ reminder: MyReminder) {
        models.append(reminder)
        models.sort { $0.date < $1.date } // Keep sorted by date
        
        // Animate insertion
        if let index = models.firstIndex(where: { $0.identifier == reminder.identifier }) {
            let indexPath = IndexPath(row: index, section: 0)
            table.insertRows(at: [indexPath], with: .automatic)
        }
        
        saveReminders()
        updateBadgeCount()
    }
    
    // MARK: - Actions
    
    @IBAction func didTapAdd() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "add") as? AddViewController else {
            return
        }
        
        vc.title = "New Assignment"
        vc.navigationItem.largeTitleDisplayMode = .never
        
        vc.completion = { [weak self] title, body, date in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                
                let newReminder = MyReminder(
                    title: title,
                    date: date,
                    identifier: UUID().uuidString
                )
                
                self.addReminder(newReminder)
                self.scheduleNotifications(for: newReminder, body: body)
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Fixed Notification Management Methods
    
    private let motivationalMessages = [
        "Whatever you want to do, do it now. There are only so many tomorrows.",
        "You need to stop watching TikTok and get off your bed to start your work!",
        "Stop being lazy and start doing your work!",
        "Things may come to those who wait, but only the things left by those who hustle.",
        "Never put off till tomorrow what may be done the day after tomorrow just as well.",
        "The future depends on what you do today!",
        "Success is the sum of small efforts repeated day in and day out.",
        "Don't wait for opportunity. Create it!",
        "Your future self is counting on you right now!",
        "Procrastination is the thief of time. Don't let it steal yours!",
        "The best time to start was yesterday. The second best time is now!",
        "You're stronger than your excuses!"
    ]
    
    private func scheduleNotifications(for reminder: MyReminder, body: String) {
        // Only schedule notifications if we have assignments
        guard !models.isEmpty else {
            print("No assignments to schedule notifications for")
            return
        }
        
        // Schedule initial notification
        scheduleInitialNotification(for: reminder, body: body)
        
        // Only schedule overdue notifications if date is in future
        if reminder.date > Date() {
            scheduleOverdueNotification(for: reminder)
        } else {
            // If already overdue, schedule immediate motivational notifications
            scheduleImmediateMotivationalNotifications(for: reminder)
        }
    }
    
    private func scheduleInitialNotification(for reminder: MyReminder, body: String) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = body
        content.sound = .default
        
        let timeInterval = reminder.date.timeIntervalSinceNow
        
        print("Scheduling initial notification for '\(reminder.title)' in \(timeInterval) seconds")
        
        if timeInterval > 0 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: reminder.identifier,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling initial notification: \(error.localizedDescription)")
                } else {
                    print("Successfully scheduled initial notification for: \(reminder.title)")
                }
            }
        }
    }
    
    // Schedule a single notification that will trigger when assignment becomes overdue
    private func scheduleOverdueNotification(for reminder: MyReminder) {
        guard reminder.date > Date() else { return }
        
        let timeUntilDue = reminder.date.timeIntervalSinceNow
        
        // Schedule notification for 1 minute after due date
        let overdueDelay = timeUntilDue + 60 // 1 minute after due date
        
        let content = UNMutableNotificationContent()
        content.title = "Assignment Overdue!"
        content.body = "\(reminder.title) is now overdue. " + (motivationalMessages.randomElement() ?? motivationalMessages[0])
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: overdueDelay, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "\(reminder.identifier)_overdue",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling overdue notification: \(error.localizedDescription)")
            } else {
                print("Successfully scheduled overdue notification for: \(reminder.title)")
            }
        }
    }
    
    private func deleteNotification(identifier: String) {
        // Remove ALL notifications associated with this identifier
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [
                identifier,
                "\(identifier)_overdue",
                "\(identifier)_motivational"
            ]
        )
        
        // Also remove delivered notifications
        UNUserNotificationCenter.current().removeDeliveredNotifications(
            withIdentifiers: [
                identifier,
                "\(identifier)_overdue",
                "\(identifier)_motivational"
            ]
        )
        
        print("Removed all notifications for identifier: \(identifier)")
    }
    
    // Fixed method to handle overdue assignments - only runs when assignments exist
    private func scheduleMotivationalNotificationsForOverdueAssignments() {
        // CRITICAL: Only run if we have assignments
        guard !models.isEmpty else {
            print("No assignments - clearing any existing motivational notifications")
            clearAllMotivationalNotifications()
            return
        }
        
        let overdueAssignments = models.filter { $0.date < Date() }
        
        // If no overdue assignments, clear motivational notifications
        guard !overdueAssignments.isEmpty else {
            print("No overdue assignments - clearing motivational notifications")
            clearAllMotivationalNotifications()
            return
        }
        
        print("Found \(overdueAssignments.count) overdue assignments")
        
        for assignment in overdueAssignments {
            scheduleImmediateMotivationalNotifications(for: assignment)
        }
    }
    
    private func scheduleImmediateMotivationalNotifications(for reminder: MyReminder) {
        // Clear any existing motivational notifications for this reminder first
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["\(reminder.identifier)_motivational"]
        )
        
        let content = UNMutableNotificationContent()
        content.title = "Still Procrastinating?"
        content.body = "\(reminder.title) is overdue! " + (motivationalMessages.randomElement() ?? motivationalMessages[0])
        content.sound = .default
        
        // Schedule repeating notifications every 5 minutes (less aggressive)
        let repeatingTrigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5 * 60, // Every 5 minutes
            repeats: true
        )
        
        let repeatingRequest = UNNotificationRequest(
            identifier: "\(reminder.identifier)_motivational",
            content: content,
            trigger: repeatingTrigger
        )
        
        UNUserNotificationCenter.current().add(repeatingRequest) { error in
            if let error = error {
                print("Error scheduling motivational notifications: \(error.localizedDescription)")
            } else {
                print("Successfully scheduled motivational notifications for: \(reminder.title)")
            }
        }
    }
    
    // Add this new method to clear all motivational notifications
    private func clearAllMotivationalNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let motivationalIds = requests
                .filter { $0.identifier.contains("_motivational") }
                .map { $0.identifier }
            
            if !motivationalIds.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: motivationalIds)
                print("Cleared \(motivationalIds.count) motivational notifications")
            }
        }
    }
    
    // MARK: - Test Method (for debugging)
    
    @IBAction func didTapTest() {
        // Test notification permission and fire a test notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    self?.fireTestNotification()
                } else {
                    print("Notification permission denied")
                    self?.showNotificationPermissionAlert()
                }
            }
        }
    }
    
    private func fireTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "XProcrastinate notifications are working!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled successfully")
            }
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveReminders() {
        do {
            let data = try JSONEncoder().encode(models)
            UserDefaults.standard.set(data, forKey: "reminders")
        } catch {
            print("Failed to save reminders: \(error.localizedDescription)")
        }
    }
    
    private func loadReminders() {
        guard let data = UserDefaults.standard.data(forKey: "reminders") else { return }
        
        do {
            models = try JSONDecoder().decode([MyReminder].self, from: data) // Fixed: removed .Type
            models.sort { $0.date < $1.date }
        } catch {
            print("Failed to load reminders: \(error.localizedDescription)")
            models = []
        }
    }
    
    // MARK: - Completed Assignments Management
    
    private func saveCompletedReminders() {
        do {
            let data = try JSONEncoder().encode(completedReminders)
            UserDefaults.standard.set(data, forKey: "completed_reminders")
        } catch {
            print("Failed to save completed reminders: \(error.localizedDescription)")
        }
    }
    
    private func loadCompletedReminders() {
        guard let data = UserDefaults.standard.data(forKey: "completed_reminders") else { return }
        
        do {
            completedReminders = try JSONDecoder().decode([MyReminder].self, from: data) // Fixed: removed .Type
            completedReminders.sort { $0.date > $1.date } // Sort by date descending (newest first)
        } catch {
            print("Failed to load completed reminders: \(error.localizedDescription)")
            completedReminders = []
        }
    }
    
    // Update the completeReminder method to ensure proper cleanup:
    private func completeReminder(at indexPath: IndexPath) {
        let reminder = models[indexPath.row]
        
        // Move to completed reminders
        var completedReminder = reminder
        completedReminders.insert(completedReminder, at: 0)
        
        // Remove from active reminders
        models.remove(at: indexPath.row)
        
        // Delete ALL notifications for this reminder (including motivational ones)
        deleteNotification(identifier: reminder.identifier)
        
        // Update persistence
        saveReminders()
        saveCompletedReminders()
        
        // Update badge count
        updateBadgeCount()
        
        // Animate removal
        table.deleteRows(at: [indexPath], with: .automatic)
        
        // CRITICAL: Re-check motivational notifications after completing assignment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.models.isEmpty {
                self.clearAllMotivationalNotifications()
                print("All assignments completed - cleared motivational notifications")
            } else {
                self.scheduleMotivationalNotificationsForOverdueAssignments()
            }
        }
        
        // Add haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        print("Completed assignment: \(reminder.title)")
    }
    
    // MARK: - Helper method for overdue indicator
    
    private func createOverdueIndicator() -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        
        let overdueLabel = UILabel(frame: containerView.bounds)
        overdueLabel.text = "OVERDUE"
        overdueLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        overdueLabel.textColor = .white
        overdueLabel.backgroundColor = .systemPurple
        overdueLabel.textAlignment = .center
        overdueLabel.layer.cornerRadius = 6
        overdueLabel.layer.masksToBounds = true
        
        containerView.addSubview(overdueLabel)
        
        return containerView
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Show assignment details or edit option
        showReminderDetails(at: indexPath)
    }
    
    private func showReminderDetails(at indexPath: IndexPath) {
        let reminder = models[indexPath.row]
        
        let alert = UIAlertController(
            title: reminder.title,
            message: "Due: \(DateFormatter.displayFormatter.string(from: reminder.date))",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Mark Complete", style: .default) { [weak self] _ in
            self?.completeReminder(at: indexPath)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = table
            popover.sourceRect = table.rectForRow(at: indexPath)
        }
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Complete") { [weak self] _, _, completion in
            self?.completeReminder(at: indexPath)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "checkmark.circle.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let reminder = models[indexPath.row]
        cell.textLabel?.text = reminder.title
        cell.detailTextLabel?.text = DateFormatter.displayFormatter.string(from: reminder.date)
        
        // Better visual indicators for overdue assignments with improved visibility
        if reminder.date < Date() {
            // Use purple background with black text for overdue items
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
            cell.accessoryType = .none
            
            // Add a subtle purple background with higher contrast
            cell.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.15)
            
            // Add a purple border for extra visibility
            cell.layer.borderWidth = 1.0
            cell.layer.borderColor = UIColor.systemPurple.cgColor
            cell.layer.cornerRadius = 8
            
            // Add an overdue indicator
            cell.accessoryView = createOverdueIndicator()
            
        } else {
            // Normal state for future assignments
            cell.textLabel?.textColor = .label
            cell.detailTextLabel?.textColor = .secondaryLabel
            cell.backgroundColor = .systemBackground
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension ViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // DO NOT DELETE the assignment when notification is tapped
        // Just open the app and show the assignments
        
        DispatchQueue.main.async {
            // Refresh the table to show current assignments
            self.refreshData()
            
            // Optional: Show an alert reminding user about overdue assignments
            self.showOverdueReminder()
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notifications even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    private func showOverdueReminder() {
        let overdueCount = models.filter { $0.date < Date() }.count
        
        if overdueCount > 0 {
            let message = overdueCount == 1 ?
                "You have 1 overdue assignment that needs your attention!" :
                "You have \(overdueCount) overdue assignments that need your attention!"
            
            let alert = UIAlertController(
                title: "⏰ Overdue Assignments",
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Got it!", style: .default))
            
            present(alert, animated: true)
        }
    }
}

// MARK: - Help Button Setup

extension ViewController {
    
    private func setupHelpButton() {
        let helpButton = UIButton(type: .system)
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.setTitle("?", for: .normal)
        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        helpButton.tintColor = .white
        helpButton.backgroundColor = .systemBlue
        helpButton.layer.cornerRadius = 25
        helpButton.layer.shadowColor = UIColor.black.cgColor
        helpButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        helpButton.layer.shadowRadius = 4
        helpButton.layer.shadowOpacity = 0.2
        
        helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        
        view.addSubview(helpButton)
        
        NSLayoutConstraint.activate([
            helpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            helpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            helpButton.widthAnchor.constraint(equalToConstant: 50),
            helpButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.bringSubviewToFront(helpButton)
    }
    
    @objc private func helpButtonTapped() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        showHelpScreen()
    }
    
    // MARK: - Completed Assignments Button Setup
    
    private func setupCompletedButton() {
        let completedButton = UIButton(type: .system)
        completedButton.translatesAutoresizingMaskIntoConstraints = false
        completedButton.setTitle("✓", for: .normal)
        completedButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        completedButton.tintColor = .white
        completedButton.backgroundColor = .systemGreen
        completedButton.layer.cornerRadius = 25
        completedButton.layer.shadowColor = UIColor.black.cgColor
        completedButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        completedButton.layer.shadowRadius = 4
        completedButton.layer.shadowOpacity = 0.2
        
        completedButton.addTarget(self, action: #selector(completedButtonTapped), for: .touchUpInside)
        
        view.addSubview(completedButton)
        
        NSLayoutConstraint.activate([
            completedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            completedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completedButton.widthAnchor.constraint(equalToConstant: 50),
            completedButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.bringSubviewToFront(completedButton)
    }
    
    @objc private func completedButtonTapped() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        showCompletedAssignments()
    }
    
    private func showCompletedAssignments() {
        let alert = UIAlertController(
            title: "📚 Completed Assignments",
            message: completedReminders.isEmpty ? "No completed assignments yet!" : "Great job! You've completed \(completedReminders.count) assignment(s):",
            preferredStyle: .alert
        )
        
        if !completedReminders.isEmpty {
            // Show up to 5 most recent completed assignments
            let recentCompleted = Array(completedReminders.prefix(5))
            var detailMessage = "\n"
            
            for (index, reminder) in recentCompleted.enumerated() {
                detailMessage += "• \(reminder.title)\n"
                if index == 4 && completedReminders.count > 5 {
                    detailMessage += "...and \(completedReminders.count - 5) more!"
                    break
                }
            }
            
            alert.message = "Great job! You've completed \(completedReminders.count) assignment(s):" + detailMessage
        }
        
        alert.addAction(UIAlertAction(title: "Awesome!", style: .default))
        
        if !completedReminders.isEmpty {
            alert.addAction(UIAlertAction(title: "Clear History", style: .destructive) { [weak self] _ in
                self?.clearCompletedHistory()
            })
        }
        
        present(alert, animated: true)
    }
    
    private func clearCompletedHistory() {
        let confirmAlert = UIAlertController(
            title: "Clear Completed History",
            message: "Are you sure you want to clear all completed assignments? This cannot be undone.",
            preferredStyle: .alert
        )
        
        confirmAlert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            self?.completedReminders.removeAll()
            self?.saveCompletedReminders()
            
            let successAlert = UIAlertController(
                title: "History Cleared",
                message: "All completed assignments have been cleared.",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(successAlert, animated: true)
        })
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(confirmAlert, animated: true)
    }
    
    private func showHelpScreen() {
        let helpViewController = HelpViewController()
        
        // Present it modally
        helpViewController.modalPresentationStyle = .pageSheet // or .formSheet for smaller size
        helpViewController.modalTransitionStyle = .coverVertical
        
        present(helpViewController, animated: true)
    }
}

// MARK: - Analytics Integration Extension

extension ViewController {
    
    // MARK: - Analytics Setup
    
    private func setupAnalyticsGesture() {
        // Add swipe left gesture to show analytics
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(showAnalytics))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)
        
        // Also add analytics button to navigation bar
        setupAnalyticsButton()
    }
    
    private func setupAnalyticsButton() {
        let analyticsButton = UIBarButtonItem(
            image: UIImage(systemName: "chart.bar.fill"),
            style: .plain,
            target: self,
            action: #selector(showAnalytics)
        )
        
        // Add to existing navigation items
        if let rightItems = navigationItem.rightBarButtonItems {
            navigationItem.rightBarButtonItems = rightItems + [analyticsButton]
        } else {
            navigationItem.rightBarButtonItem = analyticsButton
        }
    }
    
    @objc private func showAnalytics() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        let analyticsVC = AnalyticsViewController()
        analyticsVC.title = "Analytics"
        analyticsVC.modalPresentationStyle = .pageSheet
        analyticsVC.modalTransitionStyle = .coverVertical
        
        // For iOS 15+ - make it a large sheet
        if #available(iOS 15.0, *) {
            if let sheet = analyticsVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                sheet.prefersGrabberVisible = true
            }
        }
        
        present(analyticsVC, animated: true)
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy 'at' h:mm a"
        return formatter
    }()
}
