//
//  AddViewController.swift
//  XProcrastinate
//
//  Created by Nayan Kasireddi on 7/29/24.
//

import UIKit

class AddViewController: UIViewController {

    @IBOutlet var titleField: UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet weak var subjectSegmentedControl: UISegmentedControl! // Add to storyboard
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl! // Add to storyboard
    
    public var completion: ((String, String, Date) -> Void)?
    
    // MARK: - Properties
    
    private let subjects = ["Math", "Science", "English", "History", "Other"]
    private let priorities = ["Low", "Medium", "High", "Urgent"]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupNavigationBar()
        setupDatePicker() // Add this line to disable keyboard
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleField.becomeFirstResponder() // Auto-focus on title field
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Style text fields
        setupTextField(titleField, placeholder: "Assignment Title")
        setupTextField(bodyField, placeholder: "Description (optional)")
        
        // Setup segmented controls
        if subjectSegmentedControl != nil {
            setupSegmentedControl(subjectSegmentedControl, items: subjects)
        }
        
        if prioritySegmentedControl != nil {
            setupSegmentedControl(prioritySegmentedControl, items: priorities)
            prioritySegmentedControl.selectedSegmentIndex = 1 // Default to "Medium"
        }
        
        // Style the view
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupDatePicker() {
        // Setup date picker - ONLY allow future dates
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        
        // DISABLE KEYBOARD INPUT FOR DATE PICKER - This fixes the keyboard issue
        // The key is to use .wheels style which doesn't trigger keyboard
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        // Disable user interaction with any text input areas
        datePicker.subviews.forEach { subview in
            if let textField = subview as? UITextField {
                textField.isUserInteractionEnabled = false
            }
            subview.subviews.forEach { nestedSubview in
                if let textField = nestedSubview as? UITextField {
                    textField.isUserInteractionEnabled = false
                }
            }
        }
        
        // Set minimum date to current time + 1 minute to prevent past dates
        let oneMinuteFromNow = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
        datePicker.minimumDate = oneMinuteFromNow
        
        // Set default date to 1 hour from now
        let oneHourFromNow = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        datePicker.date = oneHourFromNow
        
        // Add target to handle date changes and ensure no past dates
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    @objc private func datePickerValueChanged() {
        // Ensure the selected date is not in the past
        let oneMinuteFromNow = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
        if datePicker.date <= oneMinuteFromNow {
            datePicker.date = Calendar.current.date(byAdding: .minute, value: 2, to: Date()) ?? Date()
        }
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 8
        textField.font = UIFont.systemFont(ofSize: 16)
        
        // Set text color to adapt to light/dark mode
        textField.textColor = .label  // This automatically adapts: black in light mode, white in dark mode
        
        // Set placeholder color to adapt to light/dark mode
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText]  // Also adapts automatically
        )
        
        // Add "Done" button to keyboard
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(dismissKeyboard)
        )
        
        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        toolbar.items = [flexSpace, doneButton]
        textField.inputAccessoryView = toolbar
        
        // Add padding
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.rightViewMode = .always
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupSegmentedControl(_ control: UISegmentedControl, items: [String]) {
        control.removeAllSegments()
        for (index, item) in items.enumerated() {
            control.insertSegment(withTitle: item, at: index, animated: false)
        }
        control.selectedSegmentIndex = 0
    }
    
    private func setupDelegates() {
        titleField.delegate = self
        bodyField.delegate = self
        titleField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(didTapSaveButton)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancelButton)
        )
        
        // Initially disable save button
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    // MARK: - Actions
    
    @objc private func didTapSaveButton() {
        guard validateInput() else { return }
        
        let titleText = titleField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let bodyText = generateDescription()
        let targetDate = datePicker.date
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        completion?(titleText, bodyText, targetDate)
    }
    
    @objc private func didTapCancelButton() {
        if hasUnsavedChanges() {
            showUnsavedChangesAlert()
        } else {
            dismissViewController()
        }
    }
    
    @objc private func textFieldDidChange() {
        updateSaveButtonState()
    }
    
    // MARK: - Validation & UI Updates
    
    private func validateInput() -> Bool {
        guard let titleText = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !titleText.isEmpty else {
            showValidationAlert(message: "Please enter an assignment title.")
            return false
        }
        
        if titleText.count > 100 {
            showValidationAlert(message: "Assignment title is too long (maximum 100 characters).")
            return false
        }
        
        // More strict future date validation
        let now = Date()
        let oneMinuteFromNow = Calendar.current.date(byAdding: .minute, value: 1, to: now) ?? now
        
        if datePicker.date <= oneMinuteFromNow {
            showValidationAlert(message: "Please select a time at least 1 minute in the future.")
            return false
        }
        
        return true
    }
    
    private func updateSaveButtonState() {
        let hasTitle = !(titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        navigationItem.rightBarButtonItem?.isEnabled = hasTitle
    }
    
    private func generateDescription() -> String {
        var description = bodyField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Add subject and priority info
        var additionalInfo: [String] = []
        
        if let subjectControl = subjectSegmentedControl,
           subjectControl.selectedSegmentIndex >= 0,
           subjectControl.selectedSegmentIndex < subjects.count {
            additionalInfo.append("Subject: \(subjects[subjectControl.selectedSegmentIndex])")
        }
        
        if let priorityControl = prioritySegmentedControl,
           priorityControl.selectedSegmentIndex >= 0,
           priorityControl.selectedSegmentIndex < priorities.count {
            let priority = priorities[priorityControl.selectedSegmentIndex]
            additionalInfo.append("Priority: \(priority)")
            
            // Add urgency indicators
            switch priority {
            case "High":
                additionalInfo.append("⚠️ High Priority Assignment")
            case "Urgent":
                additionalInfo.append("🚨 URGENT - Don't delay!")
            default:
                break
            }
        }
        
        if !additionalInfo.isEmpty {
            if !description.isEmpty {
                description += "\n\n"
            }
            description += additionalInfo.joined(separator: "\n")
        }
        
        if description.isEmpty {
            description = "Assignment reminder for \(titleField.text ?? "your task")"
        }
        
        return description
    }
    
    private func hasUnsavedChanges() -> Bool {
        let hasTitle = !(titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasBody = !(bodyField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        return hasTitle || hasBody
    }
    
    // MARK: - Alert Methods
    
    private func showValidationAlert(message: String) {
        let alert = UIAlertController(
            title: "Invalid Input",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showUnsavedChangesAlert() {
        let alert = UIAlertController(
            title: "Discard Changes?",
            message: "You have unsaved changes. Are you sure you want to discard them?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { [weak self] _ in
            self?.dismissViewController()
        })
        
        alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func dismissViewController() {
        titleField.resignFirstResponder()
        bodyField.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Quick Date Selection (Optional Enhancement)
    
    @IBAction func quickDateSelected(_ sender: UIButton) {
        let calendar = Calendar.current
        let now = Date()
        
        switch sender.tag {
        case 0: // Today evening
            datePicker.date = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now
        case 1: // Tomorrow
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) {
                datePicker.date = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: tomorrow) ?? tomorrow
            }
        case 2: // Next week
            if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: now) {
                datePicker.date = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: nextWeek) ?? nextWeek
            }
        default:
            break
        }
    }
    
    // Dismiss keyboard when tapping outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension AddViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField {
            bodyField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if validateInput() {
                didTapSaveButton()
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Limit title field to 100 characters
        if textField == titleField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 100
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
}
