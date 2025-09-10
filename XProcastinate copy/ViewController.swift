//
//  ViewController.swift
//  XProcastinate
//
//  Created by Nayan Kasireddi on 7/28/24.
//
import UserNotifications
import UIKit


class ViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    
    var models = [MyReminder]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        UNUserNotificationCenter.current().delegate = self
        loadReminders()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Reload or refresh your data
        loadReminders()
        table.reloadData()
    }

    
    
    @IBAction func didTapAdd() {
        // show add vc
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "add") as? AddViewController else {
            return
        }
        vc.title = "New Assignment"
        
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { title, body, date in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                let new = MyReminder(title: title, date: date, identifier: "id_\(title)")
                self.models.append(new)
                self.table.reloadData()
                self.saveReminders()
                
                let content = UNMutableNotificationContent()
                content.title = title
                content.sound = .default
                content.body = body
                
                let targetDate = date
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
                
                

                
                let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                    if error != nil {
                        print("something went wrong")
                    }
                })
                
                self.scheduleRepeatingNotification(identifier: new.identifier, content: content, startAfter: date)
                
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    let motivationalMessages = [
        "Whatever you want to do, do it now. There are only so many tomorrows.",
        "You need to stop watching Tiktok and get off your bed to start your work!",
        "Stop being lazy and start doing your work!",
        "Things may come to those who wait, but only the things left by those who hustle.",
        "Never put off till tomorrow what may be done the day after tomorrow just as well."
    ]
    
    func scheduleRepeatingNotification(identifier: String, content: UNMutableNotificationContent, startAfter date: Date) {
        
        let randomIndex = Int(arc4random_uniform(UInt32(motivationalMessages.count)))
            content.title = "Stop Procastinating!!"
            content.body = motivationalMessages[randomIndex]
            content.sound = .default
        
        let repeatingInterval: TimeInterval = 180 // 3 minutes
        let repeatingTrigger = UNTimeIntervalNotificationTrigger(timeInterval: repeatingInterval, repeats: true)
        
        let repeatingRequest = UNNotificationRequest(identifier: identifier + "_repeat", content: content, trigger: repeatingTrigger)
        
        UNUserNotificationCenter.current().add(repeatingRequest) { error in
            if let error = error {
                print("Error scheduling repeating notification: \(error)")
            }
        }
    }
    
    
    
    @IBAction func didTapTest() {
        // fire test notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
            if success {
                //schedule test
                print("Notification permission granted")
            }
            else if error != nil {
                print("error occured")
            }
            
        })
            
        
    }
    
    

}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Set the editing style for each row (in this case, delete)
        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            return .delete
        }
    
    func deleteNotification(identifier: String) {
        // Remove both initial and repeating notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier, identifier + "_repeat"])
    }

    
        // Handle the commit action (deleting the row)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the identifier of the reminder to delete
            let identifier = models[indexPath.row].identifier
            
            // Remove the reminder from the models array
            models.remove(at: indexPath.row)
            
            // Delete notifications associated with the reminder
            deleteNotification(identifier: identifier)
            
            // Save updated reminders
            saveReminders()
            
            // Remove the row from the table view with a fade animation
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row].title
        let date = models[indexPath.row].date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, dd, YYYY 'at' hh:mm a"
        cell.detailTextLabel?.text = formatter.string(from: date)
        return cell
        
    }
    
    struct MyReminder: Codable {
        let title: String
        let date: Date
        let identifier: String
    }
    
    func saveReminders() {
        let data = models.map { try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(data, forKey: "reminders")
    }
    
    func loadReminders() {
        guard let savedData = UserDefaults.standard.array(forKey: "reminders") as? [Data] else {
            return
        }
        models = savedData.compactMap { try? JSONDecoder().decode(MyReminder.self, from: $0) }
    }
    
    
}
extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Extract identifier from notification
        let id = response.notification.request.identifier

        // Find and remove the corresponding reminder
        if let index = models.firstIndex(where: { $0.identifier == id }) {
            models.remove(at: index)
            saveReminders()
            loadReminders()
            table.reloadData()
        }

        // Call completion handler
        completionHandler()
    }
}
