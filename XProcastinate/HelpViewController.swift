//  HelpViewController.swift
//  XProcrastinate
//
//  Created by Nayan Kasireddi on 8/10/25.
//

import UIKit

class HelpViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let developerLabel = UILabel()
    
    // MARK: - Properties
    
    private let helpSections = [
        HelpSection(
            title: "📱 Getting Started",
            items: [
                HelpItem(title: "Welcome to XProcrastinate!",
                        description: "XProcrastinate is your ultimate productivity companion designed to help you overcome procrastination and achieve your academic goals. This app combines smart assignment tracking with the proven Pomodoro Technique to maximize your productivity."),
                HelpItem(title: "Creating Your First Assignment",
                        description: "Tap the '+' button on the main screen to create a new assignment. Enter a compelling title, optional description with details about the task, select your subject category, set priority level, and choose your deadline. The app will intelligently remind you when it's time to work!"),
                HelpItem(title: "Understanding Your Dashboard",
                        description: "Your main screen is your command center. All upcoming assignments are displayed and automatically sorted by due date for maximum urgency awareness. Overdue items appear with a distinctive purple background and border to immediately catch your attention. The dashboard also shows your daily progress and completion statistics."),
                HelpItem(title: "Quick Actions & Gestures",
                        description: "Master these time-saving shortcuts: Swipe left on any assignment to quickly mark it complete. Tap directly on an assignment to view detailed information or modify its status. Pull down on the main screen to refresh and sync your data. Use the checkmark button to view your achievement history."),
                HelpItem(title: "Navigation & Interface",
                        description: "The app features an intuitive interface: Main screen for assignment overview, Focus Mode for deep work sessions, Analytics for progress tracking, Help section (this screen) for guidance, and Settings for customization. Each screen is designed for quick access and minimal distractions to keep you focused on what matters most.")
            ]
        ),
        HelpSection(
            title: "⏰ Advanced Notification System",
            items: [
                HelpItem(title: "Smart Notification Intelligence",
                        description: "XProcrastinate features an advanced notification system that goes beyond simple reminders. It sends an initial alert at your set deadline, followed by carefully timed motivational messages every 3 minutes for overdue assignments. This persistent but respectful approach helps you stay accountable without being overwhelming."),
                HelpItem(title: "Permission Setup & Management",
                        description: "For optimal functionality, notification permissions are essential. If you initially declined, don't worry! Go to iOS Settings > Notifications > XProcrastinate and enable Allow Notifications, Sounds, and Badges. The app will guide you through this process and even test notifications to ensure everything works perfectly."),
                HelpItem(title: "Motivational Message System",
                        description: "Our carefully curated motivational quotes are designed by productivity experts to combat procrastination psychology. Messages range from gentle encouragement to firm motivation, adapted to your situation. Examples include 'Whatever you want to do, do it now. There are only so many tomorrows' and 'Your future self is counting on you right now!'"),
                HelpItem(title: "Intelligent Notification Management",
                        description: "Notifications automatically cease when you complete assignments, preventing unnecessary interruptions. The system also respects your device's Do Not Disturb settings and can be customized in iOS Settings. Background notifications work seamlessly even when the app isn't active."),
                HelpItem(title: "Overdue Assignment Handling",
                        description: "When assignments become overdue, the notification system activates enhanced alerting. You'll receive immediate overdue notifications, followed by regular motivational reminders. This system is designed to create healthy urgency without causing stress or anxiety.")
            ]
        ),
        HelpSection(
            title: "🎯 Enhanced Focus Mode",
            items: [
                HelpItem(title: "Pomodoro Technique Mastery",
                        description: "Focus Mode implements the scientifically-proven Pomodoro Technique: 30 minutes of intense, focused work followed by a 10-minute restorative break. After completing 4 focus sessions, you earn a longer 20-minute break. This method maximizes concentration while preventing mental fatigue and burnout."),
                HelpItem(title: "Customizable Timer Settings",
                        description: "Personalize your productivity! Tap the Settings button in Focus Mode to customize session lengths. Set focus periods from 1-120 minutes, adjust short break duration, modify long break length, and even change how often long breaks occur. Find your perfect rhythm and stick to it!"),
                HelpItem(title: "Starting & Managing Sessions",
                        description: "Begin your productivity journey by tapping 'Start Focus'. The elegant timer counts down with visual progress indicators and motivational messages. You can pause if necessary, but staying committed yields the best results. The app tracks your progress and celebrates your achievements."),
                HelpItem(title: "Session Tracking & Statistics",
                        description: "Your focus achievements are meticulously tracked! View daily completed sessions, total focus time accumulated, and your consecutive day streak. These metrics help you build consistent habits and visualize your productivity growth over time. Aim for at least 4 sessions daily for maximum effectiveness."),
                HelpItem(title: "Advanced Background Behavior",
                        description: "Focus Mode is designed to encourage genuine productivity. During focus periods, the timer pauses if you leave the app, preventing multitasking and maintaining focus integrity. Break timers continue running in the background, allowing you to step away guilt-free during rest periods."),
                HelpItem(title: "Motivational Integration",
                        description: "Experience dynamic motivation throughout your sessions! The app displays different encouraging messages for focus periods ('Stay focused, you've got this!') and breaks ('Rest your mind, you've earned it!'). These messages rotate to keep you inspired and engaged throughout your productivity journey.")
            ]
        ),
        HelpSection(
            title: "📊 Analytics & Progress Tracking",
            items: [
                HelpItem(title: "Comprehensive Progress Dashboard",
                        description: "Access your Analytics screen to view detailed insights into your productivity patterns. The dashboard provides a comprehensive overview of your task completion rates, focus session statistics, and progress trends over time. Use these insights to identify your most productive periods and optimize your study schedule."),
                HelpItem(title: "Task Completion Analytics",
                        description: "Monitor your task management effectiveness with detailed completion statistics. View your overall completion rate, track completed vs overdue assignments, and see visual progress indicators. The circular progress chart shows your completion percentage at a glance, helping you stay motivated and accountable."),
                HelpItem(title: "Focus Time Analysis",
                        description: "Track your focus session performance with detailed time analytics. View total focus time accumulated, average session duration, session count, and weekly progress toward your focus goals. The app sets a default weekly goal of 2 hours of focused work, with visual progress indicators to keep you motivated."),
                HelpItem(title: "Weekly Progress Visualization",
                        description: "The weekly stats view shows your daily task completion over the past 7 days, helping you identify patterns in your productivity. Each day displays the number of tasks completed, allowing you to see trends and adjust your schedule accordingly. This helps maintain consistency and build sustainable habits."),
                HelpItem(title: "Smart Summary Cards",
                        description: "Three key summary cards provide instant insights: Tasks Completed (showing total completed tasks and completion rate), Overdue Tasks (highlighting items needing attention), and Focus Time (displaying total focus time, session count, and averages). These cards use color coding for quick visual understanding."),
                HelpItem(title: "Data Refresh & Accuracy",
                        description: "Analytics data updates automatically when you complete tasks or finish focus sessions. Use the refresh button in the Analytics screen to manually update all statistics. The system tracks completion dates, focus session durations, and maintains accurate historical data for meaningful trend analysis."),
                HelpItem(title: "Goal Setting & Achievement",
                        description: "Use analytics to set realistic goals and track achievement over time. The weekly focus goal system encourages consistent practice, while completion rate tracking helps maintain task management discipline. Regular review of your analytics helps identify areas for improvement and celebrate progress milestones.")
            ]
        ),
        HelpSection(
            title: "🗂️ Advanced Assignment Management",
            items: [
                HelpItem(title: "Completing & Organizing Tasks",
                        description: "Multiple ways to mark assignments complete: swipe left and tap 'Complete', or tap the assignment and select 'Mark Complete'. Completed items are instantly moved to your achievement history, stopping all related notifications and updating your success statistics."),
                HelpItem(title: "Assignment Categories & Priorities",
                        description: "Organize your academic life effectively! When creating assignments, choose from subject categories: Math, Science, English, History, and Other. Set priority levels from Low to Urgent to help focus on what matters most. This categorization helps you balance your workload strategically."),
                HelpItem(title: "Deadline Management & Planning",
                        description: "Set realistic deadlines at least 1 minute in the future (though we recommend much longer for effective planning!). The app helps you avoid procrastination by encouraging earlier deadlines and provides visual cues for urgency. Plan backwards from major deadlines to create manageable milestones."),
                HelpItem(title: "Overdue Item Handling",
                        description: "Overdue assignments receive special treatment with purple highlighting, border emphasis, and 'OVERDUE' badges. These visual cues create healthy urgency without overwhelming you. Focus on completing overdue items first to get back on track and reduce stress."),
                HelpItem(title: "Data Security & Privacy",
                        description: "Your academic data is completely private and secure. All assignments are stored locally on your device only - nothing is sent to external servers. This ensures your academic information remains confidential while being instantly accessible whenever you need it."),
                HelpItem(title: "Achievement History",
                        description: "Track your success story! Tap the green checkmark button to view all completed assignments, sorted by completion date. See your productivity patterns, celebrate your achievements, and maintain motivation by reviewing how much you've accomplished.")
            ]
        ),
        HelpSection(
            title: "🧠 Psychology & Productivity Tips",
            items: [
                HelpItem(title: "Understanding Procrastination",
                        description: "Procrastination often stems from fear of failure, perfectionism, or feeling overwhelmed. XProcrastinate combats these issues by breaking work into manageable sessions, providing positive reinforcement, and creating accountability through notifications and tracking."),
                HelpItem(title: "Building Consistent Habits",
                        description: "Use the streak system to build momentum! Aim to complete at least one focus session daily to maintain your streak. Consistency beats intensity - it's better to do 25 minutes daily than 3 hours once a week. The app rewards consistent behavior to reinforce positive habits."),
                HelpItem(title: "Effective Study Environment",
                        description: "Optimize your workspace for focus sessions: find a quiet location, eliminate distractions, keep necessary materials nearby, ensure good lighting, and inform others about your focus time. The physical environment significantly impacts your ability to concentrate."),
                HelpItem(title: "Priority & Time Management",
                        description: "Master the art of prioritization: use the Urgent/Important matrix when setting priorities, tackle difficult tasks during your peak energy hours, break large projects into smaller assignments, and always include buffer time in your planning for unexpected challenges."),
                HelpItem(title: "Dealing with Setbacks",
                        description: "Everyone has off days! If you miss sessions or fall behind, don't give up. Use the reset feature, start with shorter sessions to rebuild momentum, focus on progress rather than perfection, and remember that consistency over time matters more than perfect daily execution."),
                HelpItem(title: "Advanced Productivity Strategies",
                        description: "Enhance your productivity further: batch similar tasks together, use the two-minute rule (if it takes less than 2 minutes, do it now), implement the 'eat the frog' principle (tackle hardest tasks first), and regularly review and adjust your systems for maximum effectiveness.")
            ]
        ),
        HelpSection(
            title: "⚙️ Settings & Customization",
            items: [
                HelpItem(title: "Focus Timer Customization",
                        description: "Personalize your Pomodoro experience in Focus Mode settings. Adjust focus duration (1-120 minutes), customize short break length, modify long break duration, and set long break frequency. Experiment to find your optimal rhythm - some people work better with 45-minute sessions, others with 20-minute bursts."),
                HelpItem(title: "Notification Preferences",
                        description: "Fine-tune your notification experience in iOS Settings > Notifications > XProcrastinate. Enable or disable sounds, choose notification styles (banners vs alerts), control badge app icons, and set quiet hours. The app respects your Do Not Disturb settings automatically."),
                HelpItem(title: "Data Management Options",
                        description: "Manage your app data effectively: completed assignments can be cleared from history if desired, session statistics reset daily but maintain long-term trends, and all data remains local to your device. Consider backing up important assignment information separately for major projects."),
                HelpItem(title: "Accessibility Features",
                        description: "XProcrastinate supports iOS accessibility features including VoiceOver, larger text sizes, reduced motion, and high contrast modes. The app is designed to be inclusive and usable by everyone, regardless of visual or motor abilities."),
                HelpItem(title: "Performance Optimization",
                        description: "Keep the app running smoothly: close and reopen if it becomes unresponsive, restart your device for persistent issues, ensure adequate device storage for data saving, and update to the latest iOS version for optimal compatibility.")
            ]
        ),
        HelpSection(
            title: "🎯 Best Practices & Advanced Strategies",
            items: [
                HelpItem(title: "Daily Routine Integration",
                        description: "Integrate XProcrastinate into your daily routine: check assignments every morning, plan focus sessions around your energy levels, use breaks for light physical activity, review progress before bed, and adjust your schedule based on what you learn about your productivity patterns."),
                HelpItem(title: "Academic Success Strategies",
                        description: "Maximize academic performance: create assignments for each study session, not just final deadlines, use focus mode for reading, writing, and problem-solving, take advantage of the Pomodoro breaks to process information, and track which subjects require more focus time."),
                HelpItem(title: "Long-term Goal Achievement",
                        description: "Transform big goals into achievable steps: break semester projects into weekly milestones, create assignments for research, drafting, and revision phases, use the priority system to balance multiple courses, and celebrate small wins to maintain motivation throughout long projects."),
                HelpItem(title: "Collaboration & Study Groups",
                        description: "While XProcrastinate is personal, you can coordinate with study partners: share your focus session times, use group study sessions with synchronized Pomodoro timers, create individual assignments for group project components, and maintain accountability with friends using similar productivity systems."),
                HelpItem(title: "Exam Preparation Excellence",
                        description: "Optimize exam preparation: create multiple assignments leading up to exams (review notes, practice problems, final review), use shorter focus sessions for memorization-heavy subjects, schedule longer sessions for complex problem-solving, and track your study hours to ensure adequate preparation."),
                HelpItem(title: "Habit Maintenance & Growth",
                        description: "Build lasting productivity habits: start with achievable goals (1 focus session daily), gradually increase session length or frequency, use the streak counter as motivation, forgive yourself for missed days while getting back on track quickly, and regularly evaluate and adjust your approach based on results.")
            ]
        ),
        HelpSection(
            title: "🔧 Troubleshooting & Support",
            items: [
                HelpItem(title: "Notification Issues Resolution",
                        description: "If notifications aren't working: First, check Settings > Notifications > XProcrastinate and ensure all options are enabled. Try the test notification feature in the app. Restart your device if issues persist. Check Do Not Disturb settings and Focus modes that might block notifications."),
                HelpItem(title: "Focus Timer Problems",
                        description: "For timer-related issues: Ensure you don't minimize or leave the app during focus sessions (this is by design to maintain focus). If the timer becomes unresponsive, force-close and reopen the app. Check that your device has adequate battery and isn't in low-power mode during sessions."),
                HelpItem(title: "Analytics Data Issues",
                        description: "If analytics seem incorrect or missing: Use the refresh button in the Analytics screen to update data. Check that you've completed tasks and focus sessions recently - analytics reflect actual usage. Ensure adequate device storage for data saving. If data appears lost, restart the app to reload from storage."),
                HelpItem(title: "Performance & Stability",
                        description: "If the app becomes slow or unresponsive: Close other apps to free up memory, restart the XProcrastinate app, reboot your device if problems continue, ensure you have adequate storage space (at least 100MB free), and check for iOS updates that might resolve compatibility issues."),
                HelpItem(title: "Data Sync & Recovery",
                        description: "If assignments seem missing: Pull down on the main screen to refresh data, check if items were accidentally marked complete (view completed assignments), verify the date range you're viewing, and remember that the app resets daily statistics but maintains assignment data until completion."),
                HelpItem(title: "Common Usage Questions",
                        description: "Frequently asked questions: Assignments cannot be edited after creation (delete and recreate if needed), notifications stop automatically when assignments are completed, focus session data resets daily but streaks are maintained, analytics update automatically with usage, and all data remains local to your device for privacy."),
                HelpItem(title: "Getting Additional Help",
                        description: "If you need further assistance: Review this help section thoroughly, try the app's built-in features like test notifications, check the iOS Settings for app-specific permissions, consider reaching out through the App Store review system, or contact support through official channels if available.")
            ]
        ),
        HelpSection(
            title: "🏆 Success Stories & Motivation",
            items: [
                HelpItem(title: "Building Your Success Story",
                        description: "Every productivity journey is unique, but XProcrastinate provides the framework for success. Start small with just one focus session daily, celebrate completing overdue assignments, use the streak counter to build momentum, and remember that consistency matters more than perfection."),
                HelpItem(title: "Academic Achievement Benefits",
                        description: "Students using structured productivity systems report: improved grades through consistent study habits, reduced stress from better deadline management, enhanced focus and concentration abilities, better work-life balance, and increased confidence in tackling challenging academic tasks."),
                HelpItem(title: "Long-term Habit Formation",
                        description: "XProcrastinate helps build life-long skills: time management expertise that extends beyond academics, self-discipline and accountability habits, stress management through proactive planning, and productivity systems that adapt to professional environments after graduation."),
                HelpItem(title: "Using Analytics for Motivation",
                        description: "Leverage your analytics data for sustained motivation: celebrate completion rate improvements, set weekly focus time goals and track achievement, identify your most productive days and schedule important tasks accordingly, and use trend data to maintain accountability during challenging periods."),
                HelpItem(title: "Overcoming Common Challenges",
                        description: "Remember that everyone faces productivity challenges. Use XProcrastinate's features to combat perfectionism (start with imperfect action), overwhelm (break tasks into smaller pieces), distraction (focus mode limitations), and inconsistency (streak tracking and daily goals)."),
                HelpItem(title: "Your Productivity Journey",
                        description: "Success with XProcrastinate comes from consistent use rather than perfect execution. Embrace the process, learn from setbacks, adjust your approach based on what works, celebrate small victories, and remember that building productive habits is a marathon, not a sprint.")
            ]
        ),
        HelpSection(
            title: "📞 App Information & Credits",
            items: [
                HelpItem(title: "About XProcrastinate",
                        description: "XProcrastinate is a comprehensive productivity application designed specifically for students and academics who struggle with procrastination. It combines proven time management techniques with modern app design to create a supportive, non-judgmental environment for building better study habits."),
                HelpItem(title: "Developer Information",
                        description: "XProcrastinate was developed by Nayan Kasireddi, a passionate developer committed to helping students achieve their academic goals through better productivity tools. The app reflects a deep understanding of student challenges and incorporates research-based productivity methodologies."),
                HelpItem(title: "Privacy & Data Policy",
                        description: "Your privacy is paramount. XProcrastinate stores all data locally on your device and does not transmit any personal information to external servers. Your assignments, study habits, and productivity data remain completely private and under your control."),
                HelpItem(title: "App Updates & Future Features",
                        description: "XProcrastinate continues to evolve based on user feedback and productivity research. Future updates may include additional customization options, expanded statistics, collaborative features, and integration with other productivity tools while maintaining the app's core simplicity and effectiveness."),
                HelpItem(title: "Feedback & Community",
                        description: "Your experience and suggestions matter! Consider leaving reviews in the App Store to help other students discover XProcrastinate. Share your productivity success stories and help build a community of students committed to overcoming procrastination and achieving academic excellence."),
                HelpItem(title: "Technical Information",
                        description: "XProcrastinate is built using modern iOS development practices, ensuring optimal performance, security, and compatibility. The app is designed to work seamlessly across different iPhone and iPad models while maintaining a consistent, intuitive user experience.")
            ]
        )
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupContent()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        // Setup content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup close button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        closeButton.tintColor = .systemBlue
        closeButton.backgroundColor = UIColor.systemGray6
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        // Setup title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "📚 XProcrastinate Complete Guide"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        // Setup developer label
        developerLabel.translatesAutoresizingMaskIntoConstraints = false
        developerLabel.text = "Developed by Nayan Kasireddi"
        developerLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        developerLabel.textAlignment = .center
        developerLabel.textColor = .systemBlue
        contentView.addSubview(developerLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Developer label
            developerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            developerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            developerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupContent() {
        var previousView: UIView = developerLabel
        
        for (index, section) in helpSections.enumerated() {
            let sectionView = createSectionView(section: section)
            contentView.addSubview(sectionView)
            
            NSLayoutConstraint.activate([
                sectionView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 30),
                sectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                sectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            ])
            
            previousView = sectionView
            
            if index == helpSections.count - 1 {
                // Add bottom constraint to last section
                NSLayoutConstraint.activate([
                    sectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
                ])
            }
        }
    }
    
    private func createSectionView(section: HelpSection) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = false
        
        // Add subtle shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        
        // Section title
        let sectionTitleLabel = UILabel()
        sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionTitleLabel.text = section.title
        sectionTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        sectionTitleLabel.textColor = .systemBlue
        sectionTitleLabel.numberOfLines = 0
        containerView.addSubview(sectionTitleLabel)
        
        var previousView: UIView = sectionTitleLabel
        
        for item in section.items {
            let itemView = createItemView(item: item)
            containerView.addSubview(itemView)
            
            NSLayoutConstraint.activate([
                itemView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 16),
                itemView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                itemView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
            ])
            
            previousView = itemView
        }
        
        NSLayoutConstraint.activate([
            sectionTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            sectionTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            previousView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        return containerView
    }
    
    private func createItemView(item: HelpItem) -> UIView {
        let itemContainerView = UIView()
        itemContainerView.translatesAutoresizingMaskIntoConstraints = false
        itemContainerView.backgroundColor = UIColor.systemBackground
        itemContainerView.layer.cornerRadius = 8
        
        // Item title
        let itemTitleLabel = UILabel()
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        itemTitleLabel.text = item.title
        itemTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        itemTitleLabel.textColor = .label
        itemTitleLabel.numberOfLines = 0
        itemContainerView.addSubview(itemTitleLabel)
        
        // Item description
        let itemDescriptionLabel = UILabel()
        itemDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        itemDescriptionLabel.text = item.description
        itemDescriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        itemDescriptionLabel.textColor = .secondaryLabel
        itemDescriptionLabel.numberOfLines = 0
        itemDescriptionLabel.lineBreakMode = .byWordWrapping
        itemContainerView.addSubview(itemDescriptionLabel)
        
        NSLayoutConstraint.activate([
            itemTitleLabel.topAnchor.constraint(equalTo: itemContainerView.topAnchor, constant: 12),
            itemTitleLabel.leadingAnchor.constraint(equalTo: itemContainerView.leadingAnchor, constant: 12),
            itemTitleLabel.trailingAnchor.constraint(equalTo: itemContainerView.trailingAnchor, constant: -12),
            
            itemDescriptionLabel.topAnchor.constraint(equalTo: itemTitleLabel.bottomAnchor, constant: 8),
            itemDescriptionLabel.leadingAnchor.constraint(equalTo: itemContainerView.leadingAnchor, constant: 12),
            itemDescriptionLabel.trailingAnchor.constraint(equalTo: itemContainerView.trailingAnchor, constant: -12),
            itemDescriptionLabel.bottomAnchor.constraint(equalTo: itemContainerView.bottomAnchor, constant: -12)
        ])
        
        return itemContainerView
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Help Data Models

struct HelpSection {
    let title: String
    let items: [HelpItem]
}

struct HelpItem {
    let title: String
    let description: String
}

// MARK: - Presentation Extension

extension UIViewController {
    func presentHelp() {
        let helpVC = HelpViewController()
        helpVC.modalPresentationStyle = .pageSheet
        helpVC.modalTransitionStyle = .coverVertical
        
        // Configure sheet presentation for iOS 15+
        if let sheet = helpVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(helpVC, animated: true)
    }
}
