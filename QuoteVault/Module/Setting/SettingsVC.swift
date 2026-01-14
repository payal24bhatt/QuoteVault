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
                    } else {
                        // Default to system if no settings found
                        self.selectedTheme = "system"
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
                    accentColor: accentColor
                )
                DispatchQueue.main.async {
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
}

extension SettingsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        
        // Ensure cell is selectable
        cell.selectionStyle = .default
        cell.isUserInteractionEnabled = true
        
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
            cell.accessoryType = .disclosureIndicator
        case 2:
            cell.textLabel?.text = "Accent Color"
            cell.detailTextLabel?.text = accentColor.capitalized
            cell.accessoryType = .disclosureIndicator
        case 3:
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

