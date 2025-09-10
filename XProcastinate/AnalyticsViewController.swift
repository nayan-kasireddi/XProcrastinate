//
//  AnalyticsViewController.swift
//  XProcrastinate
//
//  Analytics without external dependencies - using native iOS components
//

import UIKit

class AnalyticsViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.backgroundColor = UIColor.systemGroupedBackground
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "📊 Analytics & Progress"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Track your productivity and progress over time"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    // Summary Cards
    private lazy var summaryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }()
    
    // Progress Views
    private lazy var completionProgressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var weeklyStatsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var focusStatsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    // MARK: - Data Properties
    
    private var completedReminders: [MyReminder] = []
    private var currentReminders: [MyReminder] = []
    private var focusSessions: [FocusSession] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        updateAnalytics()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        updateAnalytics()
    }
    
    // MARK: - Setup Methods
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .refresh,
            primaryAction: UIAction { [weak self] _ in
                self?.refreshAnalytics()
            }
        )
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        setupConstraints()
        setupContent()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupContent() {
        // Add header
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(summaryStackView)
        
        // Add progress views
        contentView.addSubview(completionProgressView)
        contentView.addSubview(weeklyStatsView)
        contentView.addSubview(focusStatsView)
        
        NSLayoutConstraint.activate([
            // Header
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Summary cards
            summaryStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            summaryStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summaryStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            summaryStackView.heightAnchor.constraint(equalToConstant: 120),
            
            // Progress views
            completionProgressView.topAnchor.constraint(equalTo: summaryStackView.bottomAnchor, constant: 32),
            completionProgressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            completionProgressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            completionProgressView.heightAnchor.constraint(equalToConstant: 220),
            
            weeklyStatsView.topAnchor.constraint(equalTo: completionProgressView.bottomAnchor, constant: 24),
            weeklyStatsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            weeklyStatsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            weeklyStatsView.heightAnchor.constraint(equalToConstant: 240),
            
            focusStatsView.topAnchor.constraint(equalTo: weeklyStatsView.bottomAnchor, constant: 24),
            focusStatsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            focusStatsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            focusStatsView.heightAnchor.constraint(equalToConstant: 220),
            
            contentView.bottomAnchor.constraint(equalTo: focusStatsView.bottomAnchor, constant: 40)
        ])
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        loadCompletedReminders()
        loadCurrentReminders()
        loadFocusSessions()
    }
    
    private func loadCompletedReminders() {
        guard let data = UserDefaults.standard.data(forKey: "completed_reminders") else {
            completedReminders = []
            return
        }
        
        do {
            completedReminders = try JSONDecoder().decode([MyReminder].self, from: data)
        } catch {
            print("Failed to load completed reminders: \(error.localizedDescription)")
            completedReminders = []
        }
    }

    private func loadCurrentReminders() {
        guard let data = UserDefaults.standard.data(forKey: "reminders") else {
            currentReminders = []
            return
        }
        
        do {
            currentReminders = try JSONDecoder().decode([MyReminder].self, from: data)
        } catch {
            print("Failed to load current reminders: \(error.localizedDescription)")
            currentReminders = []
        }
    }

    private func loadFocusSessions() {
        guard let data = UserDefaults.standard.data(forKey: "focus_sessions") else {
            focusSessions = []
            return
        }
        
        do {
            focusSessions = try JSONDecoder().decode([FocusSession].self, from: data)
            print("Loaded \(focusSessions.count) focus sessions")
        } catch {
            print("Failed to load focus sessions: \(error.localizedDescription)")
            focusSessions = []
        }
    }
    
    // MARK: - Analytics Updates
    
    @objc private func refreshAnalytics() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        loadData()
        updateAnalytics()
        
        let alert = UIAlertController(title: "📊 Updated!", message: "Analytics data refreshed", preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true)
        }
    }
    
    private func updateAnalytics() {
        updateSummaryCards()
        updateCompletionProgress()
        updateWeeklyStats()
        updateFocusStats()
    }
    
    private func updateSummaryCards() {
        summaryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let totalCompleted = completedReminders.count
        let totalOverdue = currentReminders.filter { $0.date < Date() }.count
        let totalFocusTime = focusSessions.reduce(0) { $0 + $1.duration }
        
        let totalTasks = totalCompleted + currentReminders.count
        let completionRate = totalTasks > 0 ? Int((Double(totalCompleted) / Double(totalTasks)) * 100) : 0
        
        let completedCard = createSummaryCard(
            title: "Tasks Completed",
            value: "\(totalCompleted)",
            subtitle: "\(completionRate)% completion rate",
            color: .systemGreen,
            icon: "✅"
        )
        
        let overdueCard = createSummaryCard(
            title: "Overdue Tasks",
            value: "\(totalOverdue)",
            subtitle: totalOverdue > 0 ? "Need attention!" : "All caught up!",
            color: totalOverdue > 0 ? .systemRed : .systemGreen,
            icon: totalOverdue > 0 ? "⚠️" : "✨"
        )
        
        let focusCard = createSummaryCard(
            title: "Focus Time",
            value: formatTime(totalFocusTime),
            subtitle: "\(focusSessions.count) sessions",
            color: .systemBlue,
            icon: "🎯"
        )
        
        summaryStackView.addArrangedSubview(completedCard)
        summaryStackView.addArrangedSubview(overdueCard)
        summaryStackView.addArrangedSubview(focusCard)
    }
    
    private func createSummaryCard(title: String, value: String, subtitle: String, color: UIColor, icon: String) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor.systemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOpacity = 0.1
        
        let iconLabel = UILabel()
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 24)
        iconLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        subtitleLabel.textColor = .tertiaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2
        
        cardView.addSubview(iconLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(valueLabel)
        cardView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            iconLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4),
            
            subtitleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -8)
        ])
        
        return cardView
    }
    
    private func updateCompletionProgress() {
        completionProgressView.subviews.forEach { $0.removeFromSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "📈 Task Completion Overview"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        
        let totalCompleted = completedReminders.count
        let totalOverdue = currentReminders.filter { $0.date < Date() }.count
        let totalOnTime = currentReminders.filter { $0.date >= Date() }.count
        let totalTasks = totalCompleted + totalOverdue + totalOnTime
        
        let completionRate = totalTasks > 0 ? Double(totalCompleted) / Double(totalTasks) : 0
        
        // Create circular progress container
        let progressContainer = UIView()
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let progressView = createCircularProgress(
            progress: Float(completionRate),
            title: "Completion",
            subtitle: "\(Int(completionRate * 100))%",
            color: .systemGreen
        )
        
        let statsLabel = UILabel()
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        statsLabel.text = "✅ Completed: \(totalCompleted)\n📋 On Track: \(totalOnTime)\n⚠️ Overdue: \(totalOverdue)"
        statsLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        statsLabel.textColor = .secondaryLabel
        statsLabel.numberOfLines = 0
        statsLabel.textAlignment = .center
        
        progressContainer.addSubview(progressView)
        completionProgressView.addSubview(titleLabel)
        completionProgressView.addSubview(progressContainer)
        completionProgressView.addSubview(statsLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: completionProgressView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: completionProgressView.centerXAnchor),
            
            progressContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            progressContainer.centerXAnchor.constraint(equalTo: completionProgressView.centerXAnchor),
            progressContainer.widthAnchor.constraint(equalToConstant: 120),
            progressContainer.heightAnchor.constraint(equalToConstant: 120),
            
            progressView.centerXAnchor.constraint(equalTo: progressContainer.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: progressContainer.centerYAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 120),
            progressView.heightAnchor.constraint(equalToConstant: 120),
            
            statsLabel.topAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: 20),
            statsLabel.centerXAnchor.constraint(equalTo: completionProgressView.centerXAnchor),
            statsLabel.leadingAnchor.constraint(greaterThanOrEqualTo: completionProgressView.leadingAnchor, constant: 16),
            statsLabel.trailingAnchor.constraint(lessThanOrEqualTo: completionProgressView.trailingAnchor, constant: -16),
            statsLabel.bottomAnchor.constraint(lessThanOrEqualTo: completionProgressView.bottomAnchor, constant: -16)
        ])
    }
    
    private func updateWeeklyStats() {
        weeklyStatsView.subviews.forEach { $0.removeFromSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "📅 7-Day Task Progress"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        
        let calendar = Calendar.current
        let now = Date()
        var dailyStats: [(day: String, completed: Int, date: Date)] = []
        
        // Get last 7 days
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "EEE"
                let dayName = dayFormatter.string(from: date)
                
                // Count completed reminders for this day
                var completed = 0
                for reminder in completedReminders {
                    // Use the reminder's date to check if it was completed on this day
                    if calendar.isDate(reminder.date, inSameDayAs: date) {
                        completed += 1
                    }
                }
                
                dailyStats.append((day: dayName, completed: completed, date: date))
            }
        }
        
        let statsStackView = UIStackView()
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 4
        
        let maxCompleted = dailyStats.map { $0.completed }.max() ?? 1
        
        for stat in dailyStats.reversed() {
            let isToday = calendar.isDateInToday(stat.date)
            let dayView = createDayStatView(
                day: stat.day,
                completed: stat.completed,
                maxCompleted: maxCompleted,
                isToday: isToday
            )
            statsStackView.addArrangedSubview(dayView)
        }
        
        // Add summary at bottom - calculate properly
        let totalWeekCompleted = dailyStats.reduce(0) { $0 + $1.completed }
        let avgDaily = Double(totalWeekCompleted) / 7.0
        
        let summaryLabel = UILabel()
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.text = "This Week: \(totalWeekCompleted) tasks • Daily Average: \(String(format: "%.1f", avgDaily)) tasks"
        summaryLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.textAlignment = .center
        
        weeklyStatsView.addSubview(titleLabel)
        weeklyStatsView.addSubview(statsStackView)
        weeklyStatsView.addSubview(summaryLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: weeklyStatsView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: weeklyStatsView.centerXAnchor),
            
            statsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            statsStackView.leadingAnchor.constraint(equalTo: weeklyStatsView.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: weeklyStatsView.trailingAnchor, constant: -16),
            statsStackView.heightAnchor.constraint(equalToConstant: 120),
            
            summaryLabel.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 16),
            summaryLabel.centerXAnchor.constraint(equalTo: weeklyStatsView.centerXAnchor),
            summaryLabel.leadingAnchor.constraint(greaterThanOrEqualTo: weeklyStatsView.leadingAnchor, constant: 16),
            summaryLabel.trailingAnchor.constraint(lessThanOrEqualTo: weeklyStatsView.trailingAnchor, constant: -16),
            summaryLabel.bottomAnchor.constraint(lessThanOrEqualTo: weeklyStatsView.bottomAnchor, constant: -16)
        ])
    }
    
    private func updateFocusStats() {
        focusStatsView.subviews.forEach { $0.removeFromSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "🎯 Focus Time Analysis"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        
        let totalFocusTime = focusSessions.reduce(0) { $0 + $1.duration }
        let sessionCount = focusSessions.count
        let avgSession = sessionCount > 0 ? totalFocusTime / sessionCount : 0
        
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        let recentSessions = focusSessions.filter { $0.startTime >= weekAgo }
        let weeklyFocusTime = recentSessions.reduce(0) { $0 + $1.duration }
        
        let statsLabel = UILabel()
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        statsLabel.text = """
        Total Focus Time: \(formatTime(totalFocusTime))
        Total Sessions: \(sessionCount)
        Average Session: \(formatTime(avgSession))
        This Week: \(formatTime(weeklyFocusTime))
        """
        statsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        statsLabel.textColor = .label
        statsLabel.numberOfLines = 0
        statsLabel.textAlignment = .left
        
        // Create circular progress container
        let progressContainer = UIView()
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Weekly goal: 5 hours (18000 seconds) - A healthy amount for focused work
        let weeklyGoal = 18000 // 5 hours per week
        let progressValue = min(1.0, Float(weeklyFocusTime) / Float(weeklyGoal))
        let progressPercentage = Int((Double(weeklyFocusTime) / Double(weeklyGoal)) * 100)
        
        let progressView = createCircularProgress(
            progress: progressValue,
            title: "5hr Goal",
            subtitle: "\(progressPercentage)%",
            color: .systemBlue
        )
        
        // Add goal description
        let goalLabel = UILabel()
        goalLabel.translatesAutoresizingMaskIntoConstraints = false
        goalLabel.text = "Weekly Goal: 5 hours of focused work\n(~45 min daily for productivity)"
        goalLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        goalLabel.textColor = .tertiaryLabel
        goalLabel.numberOfLines = 0
        goalLabel.textAlignment = .center
        
        progressContainer.addSubview(progressView)
        focusStatsView.addSubview(titleLabel)
        focusStatsView.addSubview(statsLabel)
        focusStatsView.addSubview(progressContainer)
        focusStatsView.addSubview(goalLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: focusStatsView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: focusStatsView.centerXAnchor),
            
            statsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            statsLabel.leadingAnchor.constraint(equalTo: focusStatsView.leadingAnchor, constant: 20),
            statsLabel.trailingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: -20),
            
            progressContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            progressContainer.trailingAnchor.constraint(equalTo: focusStatsView.trailingAnchor, constant: -20),
            progressContainer.widthAnchor.constraint(equalToConstant: 100),
            progressContainer.heightAnchor.constraint(equalToConstant: 100),
            
            progressView.centerXAnchor.constraint(equalTo: progressContainer.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: progressContainer.centerYAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 100),
            progressView.heightAnchor.constraint(equalToConstant: 100),
            
            goalLabel.topAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: 12),
            goalLabel.centerXAnchor.constraint(equalTo: focusStatsView.centerXAnchor),
            goalLabel.leadingAnchor.constraint(greaterThanOrEqualTo: focusStatsView.leadingAnchor, constant: 20),
            goalLabel.trailingAnchor.constraint(lessThanOrEqualTo: focusStatsView.trailingAnchor, constant: -20),
            goalLabel.bottomAnchor.constraint(lessThanOrEqualTo: focusStatsView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Helper Views
    
    private func createCircularProgress(progress: Float, title: String, subtitle: String, color: UIColor) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the progress layers after the view is laid out
        DispatchQueue.main.async {
            // Clear existing layers
            containerView.layer.sublayers?.forEach { layer in
                if layer is CAShapeLayer {
                    layer.removeFromSuperlayer()
                }
            }
            
            let progressLayer = CAShapeLayer()
            let trackLayer = CAShapeLayer()
            
            let bounds = containerView.bounds
            let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            let radius: CGFloat = min(bounds.width, bounds.height) / 2 - 10
            let startAngle = -CGFloat.pi / 2
            let endAngle = startAngle + 2 * CGFloat.pi
            
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            trackLayer.path = path.cgPath
            trackLayer.fillColor = UIColor.clear.cgColor
            trackLayer.strokeColor = UIColor.systemGray5.cgColor
            trackLayer.lineWidth = 8
            trackLayer.strokeEnd = 1.0
            
            progressLayer.path = path.cgPath
            progressLayer.fillColor = UIColor.clear.cgColor
            progressLayer.strokeColor = color.cgColor
            progressLayer.lineWidth = 8
            progressLayer.strokeEnd = CGFloat(progress)
            progressLayer.lineCap = .round
            
            containerView.layer.addSublayer(trackLayer)
            containerView.layer.addSublayer(progressLayer)
        }
        
        let circleTitleLabel = UILabel()
        circleTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        circleTitleLabel.text = title
        circleTitleLabel.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
        circleTitleLabel.textColor = .secondaryLabel
        circleTitleLabel.textAlignment = .center
        circleTitleLabel.numberOfLines = 1
        circleTitleLabel.adjustsFontSizeToFitWidth = true
        circleTitleLabel.minimumScaleFactor = 0.8
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = subtitle
        valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7
        
        containerView.addSubview(circleTitleLabel)
        containerView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            circleTitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            circleTitleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -8),
            circleTitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 12),
            circleTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12),
            
            valueLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12)
        ])
        
        return containerView
    }
    
    private func createDayStatView(day: String, completed: Int, maxCompleted: Int, isToday: Bool) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = isToday ? UIColor.systemBlue.withAlphaComponent(0.2) : UIColor.systemGray6
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = isToday ? 2 : 0
        containerView.layer.borderColor = isToday ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        
        let dayLabel = UILabel()
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.text = day
        dayLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        dayLabel.textColor = isToday ? .systemBlue : .secondaryLabel
        dayLabel.textAlignment = .center
        
        let countLabel = UILabel()
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.text = "\(completed)"
        countLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        countLabel.textColor = completed > 0 ? .systemGreen : .systemGray3
        countLabel.textAlignment = .center
        
        // Create progress bar
        let progressContainer = UIView()
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.backgroundColor = UIColor.systemGray5
        progressContainer.layer.cornerRadius = 2
        
        let progressBar = UIView()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.backgroundColor = completed > 0 ? UIColor.systemGreen : UIColor.clear
        progressBar.layer.cornerRadius = 2
        
        progressContainer.addSubview(progressBar)
        
        let progressHeight = maxCompleted > 0 ? CGFloat(completed) / CGFloat(maxCompleted) : 0
        
        containerView.addSubview(dayLabel)
        containerView.addSubview(countLabel)
        containerView.addSubview(progressContainer)
        
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            dayLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dayLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 4),
            dayLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -4),
            
            countLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 8),
            countLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            countLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 4),
            countLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -4),
            
            progressContainer.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 8),
            progressContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            progressContainer.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            progressContainer.heightAnchor.constraint(equalToConstant: 4),
            progressContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            progressBar.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor),
            progressBar.topAnchor.constraint(equalTo: progressContainer.topAnchor),
            progressBar.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor),
            progressBar.widthAnchor.constraint(equalTo: progressContainer.widthAnchor, multiplier: progressHeight),
            
            containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        return containerView
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes)m"
        } else {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
    }
}
