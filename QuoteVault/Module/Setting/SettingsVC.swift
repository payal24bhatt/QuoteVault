//
//  SettingsVC.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var tblSettings: UITableView!
    private var programmaticTableView: UITableView?
    
    var currentUserId: UUID?
    var currentSettings: UserSettings?
    var selectedTheme: String = "system"
    var fontSize: Int = 16
    var accentColor: String = "blue"
    var notificationEnabled: Bool = false
    var notificationTime: String = "09:00" // Default 9 AM
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        loadCurrentUser()
        loadSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure tab bar is visible when returning to settings
        tabBarController?.tabBar.isHidden = false
    }
    
    func loadCurrentUser() {
        currentUserId = SupabaseService.shared.userId
    }
    
    func prepareUI() {
        title = "Settings"
        
        // Add logout button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(onClickLogoutButton)
        )
        
        // Check if table view outlet is connected
        guard let tblSettings = tblSettings else {
            print("⚠️ Error: tblSettings outlet not connected in XIB")
            // Create table view programmatically if outlet is not connected
            setupTableViewProgrammatically()
            return
        }
        
        // Configure table view
        tblSettings.delegate = self
        tblSettings.dataSource = self
        tblSettings.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        tblSettings.isUserInteractionEnabled = true
        tblSettings.allowsSelection = true
        tblSettings.backgroundColor = .systemGroupedBackground
    }
    
    func setupTableViewProgrammatically() {
        let tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        tableView.isUserInteractionEnabled = true
        tableView.allowsSelection = true
        tableView.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Store reference
        self.tblSettings = tableView
        self.programmaticTableView = tableView
    }
    
    @objc func onClickLogoutButton() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            Task {
                do {
                    try await SupabaseService.shared.signOut()
                    DispatchQueue.main.async {
                        Constants.appDelegate.redirectToLogin()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.alertView(message: "Failed to logout: \(error.localizedDescription)")
                    }
                }
            }
        })
        present(alert, animated: true)
    }
    
    func loadSettings() {
        guard let userId = currentUserId else {
            // Default to system theme if not logged in
            selectedTheme = "system"
            tblSettings?.reloadData()
            return
        }
        
        Task {
            do {
                let settings = try await QuoteRepository.shared.fetchSettings(userId: userId)
                DispatchQueue.main.async {
                    self.currentSettings = settings
                    if let settings = settings {
                        self.selectedTheme = settings.theme.isEmpty ? "system" : settings.theme
                        self.fontSize = settings.fontSize
                        self.accentColor = settings.accentColor
                        self.notificationEnabled = settings.notificationEnabled ?? false
                        self.notificationTime = settings.notificationTime ?? "09:00"
                        
                        // Update notification schedule when settings are loaded
                        NotificationService.shared.updateNotificationSchedule(
                            enabled: self.notificationEnabled,
                            time: self.notificationEnabled ? self.notificationTime : nil
                        )
                    } else {
                        // Default to system if no settings found
                        self.selectedTheme = "system"
                        self.notificationEnabled = false
                        self.notificationTime = "09:00"
                    }
                    self.tblSettings?.reloadData()
                    // Apply theme when settings are loaded
                    ThemeManager.shared.applyTheme(self.selectedTheme)
                    // Update SettingsManager cache
                    SettingsManager.shared.refreshSettings()
                }
            } catch {
                print("Failed to load settings: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    // Default to system on error
                    self.selectedTheme = "system"
                    self.tblSettings?.reloadData()
                    ThemeManager.shared.applyTheme("system")
                }
            }
        }
    }
    
    func saveSettings() {
        guard let userId = currentUserId else { return }
        
        Task {
            do {
                try await QuoteRepository.shared.upsertSettings(
                    userId: userId,
                    theme: selectedTheme,
                    fontSize: fontSize,
                    accentColor: accentColor,
                    notificationEnabled: notificationEnabled,
                    notificationTime: notificationEnabled ? notificationTime : nil
                )
                DispatchQueue.main.async {
                    // Update notification schedule
                    NotificationService.shared.updateNotificationSchedule(
                        enabled: self.notificationEnabled,
                        time: self.notificationEnabled ? self.notificationTime : nil
                    )
                    
                    self.alertView(message: "Settings saved!")
                    // Apply theme globally using ThemeManager
                    ThemeManager.shared.applyTheme(self.selectedTheme)
                    // Refresh settings cache
                    SettingsManager.shared.refreshSettings()
                    // Post notification to update UI
                    NotificationCenter.default.post(name: NSNotification.Name("SettingsUpdated"), object: nil)
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertView(message: "Failed to save settings: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func showThemePicker() {
        let alert = UIAlertController(title: "Select Theme", message: nil, preferredStyle: .actionSheet)
        
        let themes = [
            ("system", "System (Follow Device)"),
            ("light", "Light"),
            ("dark", "Dark")
        ]
        
        for (value, name) in themes {
            let action = UIAlertAction(title: name, style: .default) { [weak self] _ in
                self?.selectedTheme = value
                self?.saveSettings()
                self?.tblSettings?.reloadData()
            }
            
            // Mark current selection with checkmark
            if value == self.selectedTheme {
                action.setValue(true, forKey: "checked")
            }
            
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    func showFontSizePicker() {
        let alert = UIAlertController(title: "Font Size", message: "Select font size for quotes", preferredStyle: .actionSheet)
        
        let sizes = [14, 16, 18, 20, 22]
        
        for size in sizes {
            alert.addAction(UIAlertAction(title: "\(size)pt", style: .default) { [weak self] _ in
                self?.fontSize = size
                self?.saveSettings()
                self?.tblSettings?.reloadData()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    func showAccentColorPicker() {
        let alert = UIAlertController(title: "Select Accent Color", message: nil, preferredStyle: .actionSheet)
        
        let colors = ["blue", "purple", "teal", "orange", "pink"]
        
        for color in colors {
            alert.addAction(UIAlertAction(title: color.capitalized, style: .default) { [weak self] _ in
                self?.accentColor = color
                self?.saveSettings()
                self?.tblSettings?.reloadData()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    func toggleNotifications() {
        let alert = UIAlertController(title: "Daily Quote Notifications", message: "Receive a daily quote notification?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Enable", style: .default) { [weak self] _ in
            self?.notificationEnabled = true
            self?.saveSettings()
            self?.tblSettings?.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Disable", style: .destructive) { [weak self] _ in
            self?.notificationEnabled = false
            self?.saveSettings()
            self?.tblSettings?.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func showNotificationTimePicker() {
        let alert = UIAlertController(title: "Notification Time", message: "Select time for daily quote notification", preferredStyle: .actionSheet)
        
        // Common times
        let times = ["06:00", "07:00", "08:00", "09:00", "10:00", "12:00", "18:00", "20:00", "21:00"]
        
        for time in times {
            let timeDisplay = formatTime(time)
            alert.addAction(UIAlertAction(title: timeDisplay, style: .default) { [weak self] _ in
                self?.notificationTime = time
                self?.saveSettings()
                self?.tblSettings?.reloadData()
            })
        }
        
        // Custom time option
        alert.addAction(UIAlertAction(title: "Custom Time", style: .default) { [weak self] _ in
            self?.showCustomTimePicker()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    func showCustomTimePicker() {
        let alert = UIAlertController(title: "Custom Time", message: "Enter time in HH:mm format (24-hour)", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "09:00"
            textField.text = self.notificationTime
            textField.keyboardType = .numbersAndPunctuation
        }
        
        alert.addAction(UIAlertAction(title: "Set", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let timeString = textField.text,
                  self?.isValidTime(timeString) == true else {
                self?.alertView(message: "Invalid time format. Please use HH:mm (e.g., 09:00)")
                return
            }
            
            self?.notificationTime = timeString
            self?.saveSettings()
            self?.tblSettings?.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func formatTime(_ time: String) -> String {
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return time
        }
        
        let hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        let amPm = hour < 12 ? "AM" : "PM"
        return String(format: "%d:%02d %@", hour12, minute, amPm)
    }
    
    func isValidTime(_ time: String) -> Bool {
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return false
        }
        
        return hour >= 0 && hour < 24 && minute >= 0 && minute < 60
    }
}

extension SettingsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        
        // Reset cell state
        cell.selectionStyle = .default
        cell.isUserInteractionEnabled = true
        cell.textLabel?.alpha = 1.0
        cell.detailTextLabel?.alpha = 1.0
        cell.textLabel?.textColor = .label
        cell.detailTextLabel?.textColor = .secondaryLabel
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Theme"
            let themeDisplayName: String
            switch selectedTheme.lowercased() {
            case "system":
                themeDisplayName = "System (Follow Device)"
            case "light":
                themeDisplayName = "Light"
            case "dark":
                themeDisplayName = "Dark"
            default:
                themeDisplayName = selectedTheme.capitalized
            }
            cell.detailTextLabel?.text = themeDisplayName
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.textLabel?.text = "Font Size"
            cell.detailTextLabel?.text = "\(fontSize)pt"
            cell.detailTextLabel?.textColor = .secondaryLabel // Ensure proper color
            cell.accessoryType = .disclosureIndicator
        case 2:
            cell.textLabel?.text = "Accent Color"
            cell.detailTextLabel?.text = accentColor.capitalized
            cell.accessoryType = .disclosureIndicator
        case 3:
            cell.textLabel?.text = "Daily Quote Notifications"
            cell.detailTextLabel?.text = notificationEnabled ? "On" : "Off"
            cell.accessoryType = .disclosureIndicator
        case 4:
            cell.textLabel?.text = "Notification Time"
            cell.detailTextLabel?.text = formatTime(notificationTime)
            cell.accessoryType = .disclosureIndicator
            // Only disable interaction if notifications are off
            if !notificationEnabled {
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                cell.textLabel?.alpha = 0.5
                cell.detailTextLabel?.alpha = 0.5
            } else {
                cell.isUserInteractionEnabled = true
                cell.selectionStyle = .default
                cell.textLabel?.alpha = 1.0
                cell.detailTextLabel?.alpha = 1.0
            }
        case 5:
            cell.textLabel?.text = "Profile"
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .disclosureIndicator
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        print("✅ Table view cell tapped at row: \(indexPath.row)")
        
        switch indexPath.row {
        case 0:
            print("✅ Showing theme picker")
            showThemePicker()
        case 1:
            print("✅ Showing font size picker")
            showFontSizePicker()
        case 2:
            print("✅ Showing accent color picker")
            showAccentColorPicker()
        case 3:
            print("✅ Toggling notifications")
            toggleNotifications()
        case 4:
            print("✅ Showing notification time picker")
            if notificationEnabled {
                showNotificationTimePicker()
            } else {
                // Show alert to enable notifications first
                alertView(message: "Please enable Daily Quote Notifications first")
            }
        case 5:
            print("✅ Navigating to profile")
            let vc = ProfileVC.loadFromNib()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        print("✅ Will select row: \(indexPath.row)")
        return indexPath
    }
}

