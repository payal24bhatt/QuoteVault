//
//  ProfileVC.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit
import PhotosUI
import Supabase

class ProfileVC: UIViewController {
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnEditProfile: UIButton!
    
    var currentUserId: UUID?
    var profile: UserProfile?
    var isEditingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide tab bar when this view controller is pushed
        hidesBottomBarWhenPushed = true
        prepareUI()
        loadCurrentUser()
        loadProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Tab bar is automatically hidden by hidesBottomBarWhenPushed
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Tab bar will be automatically shown when we pop
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update avatar corner radius after layout
        if let imgAvatar = imgAvatar {
            imgAvatar.layer.cornerRadius = imgAvatar.frame.width / 2
            imgAvatar.clipsToBounds = true
        }
    }
    
    func loadCurrentUser() {
        currentUserId = SupabaseService.shared.userId
    }
    
    func prepareUI() {
        title = "Profile"
        
        // Configure avatar image view
        if let imgAvatar = imgAvatar {
            imgAvatar.clipsToBounds = true
            imgAvatar.backgroundColor = .systemGray5
            imgAvatar.contentMode = .scaleAspectFill
        }
        
        // Configure avatar button
        btnAvatar?.addTarget(self, action: #selector(editAvatar), for: .touchUpInside)
        
        // Configure text fields - initially read-only
        txtName?.isEnabled = false
        txtName?.borderStyle = .none
        txtEmail?.isEnabled = false
        txtEmail?.borderStyle = .none
        
        // Configure edit profile button
        btnEditProfile?.addTarget(self, action: #selector(toggleEditMode), for: .touchUpInside)
        updateEditButtonTitle()
    }
    
    func updateEditButtonTitle() {
        btnEditProfile?.setTitle(isEditingMode ? "Save" : "Edit Profile", for: .normal)
    }
    
    func loadProfile() {
        guard let userId = currentUserId else { return }
        
        Task {
            do {
                // Load profile from database
                let profile = try await QuoteRepository.shared.fetchProfile(userId: userId)
                
                // Get email from Supabase Auth
                let email = SupabaseService.shared.client.auth.currentUser?.email ?? ""
                
                DispatchQueue.main.async {
                    self.profile = profile
                    self.updateUI(email: email)
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertView(message: "Failed to load profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateUI(email: String) {
        guard let profile = profile else { return }
        
        // Update text fields
        txtName?.text = profile.name ?? "User"
        txtEmail?.text = email
        
        // Load avatar image if URL exists
        if let avatarUrl = profile.avatarUrl, !avatarUrl.isEmpty {
            loadAvatarImage(from: avatarUrl)
        } else {
            // Show initials if no avatar
            showInitials(name: profile.name ?? "User")
        }
    }
    
    func loadAvatarImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imgAvatar?.image = image
                    }
                }
            } catch {
                print("Failed to load avatar image: \(error.localizedDescription)")
                // Fallback to initials
                DispatchQueue.main.async {
                    self.showInitials(name: self.profile?.name ?? "User")
                }
            }
        }
    }
    
    func showInitials(name: String) {
        guard let imgAvatar = imgAvatar else { return }
        
        let initials = name.components(separatedBy: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map { String($0).uppercased() }
            .joined()
        
        if let image = Global.getIntialsImage(name: initials, size: imgAvatar.frame.size) {
            imgAvatar.image = image
        }
    }
    
    // MARK: - Avatar Editing
    
    @objc func editAvatar() {
        let alert = UIAlertController(title: "Change Avatar", message: "Select an option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentImagePicker()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = btnAvatar
            popover.sourceRect = btnAvatar?.bounds ?? .zero
        }
        
        present(alert, animated: true)
    }
    
    func presentImagePicker() {
        if #available(iOS 14.0, *) {
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 1
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        }
    }
    
    func uploadAvatarImage(_ image: UIImage) {
        guard let userId = currentUserId else { return }
        
        // Show loading indicator
        let alert = UIAlertController(title: "Uploading...", message: "Please wait", preferredStyle: .alert)
        present(alert, animated: true)
        
        Task {
            do {
                // Convert image to data
                guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                    throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
                }
                
                // Create unique filename
                let fileName = "\(userId.uuidString)_\(UUID().uuidString).jpg"
                
                // Upload to Supabase Storage
                _ = try await SupabaseService.shared.client.storage.from("avatars").upload(
                    path: fileName,
                    file: imageData,
                    options: FileOptions(cacheControl: "3600", upsert: true)
                )
                
                // Get public URL
                let publicURL = try SupabaseService.shared.client.storage.from("avatars").getPublicURL(path: fileName)
                
                // Update profile with avatar URL
                try await QuoteRepository.shared.upsertProfile(
                    userId: userId,
                    name: profile?.name,
                    avatarUrl: publicURL.absoluteString
                )
                
                DispatchQueue.main.async {
                    alert.dismiss(animated: true) {
                        self.imgAvatar?.image = image
                        self.alertView(message: "Avatar updated successfully!")
                        // Reload profile to get updated data
                        self.loadProfile()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    alert.dismiss(animated: true) {
                        var errorMessage = error.localizedDescription
                        var errorTitle = "Upload Failed"
                        
                        // Provide more helpful error messages
                        if errorMessage.contains("bucket") || errorMessage.contains("Bucket") || errorMessage.contains("not found") {
                            errorTitle = "Storage Bucket Not Found"
                            errorMessage = "The 'avatars' bucket doesn't exist in Supabase Storage.\n\nTo fix this:\n1. Go to Supabase Dashboard\n2. Navigate to Storage\n3. Create a new bucket named 'avatars'\n4. Set it to Public\n5. Try uploading again"
                        } else if errorMessage.contains("permission") || errorMessage.contains("Permission") || errorMessage.contains("policy") {
                            errorTitle = "Permission Denied"
                            errorMessage = "You don't have permission to upload files.\n\nPlease check your Supabase Storage policies for the 'avatars' bucket."
                        }
                        
                        let errorAlert = UIAlertController(
                            title: errorTitle,
                            message: errorMessage,
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Profile Editing
    
    @objc func toggleEditMode() {
        if isEditingMode {
            // Save changes
            saveProfile()
        } else {
            // Enable editing
            isEditingMode = true
            txtName?.isEnabled = true
            txtName?.borderStyle = .roundedRect
            txtName?.becomeFirstResponder()
            updateEditButtonTitle()
        }
    }
    
    func saveProfile() {
        guard let userId = currentUserId,
              let name = txtName?.text?.trimmingCharacters(in: .whitespaces),
              !name.isEmpty else {
            alertView(message: "Please enter a valid name")
            return
        }
        
        Task {
            do {
                try await QuoteRepository.shared.upsertProfile(
                    userId: userId,
                    name: name,
                    avatarUrl: profile?.avatarUrl
                )
                
                DispatchQueue.main.async {
                    self.isEditingMode = false
                    self.txtName?.isEnabled = false
                    self.txtName?.borderStyle = .none
                    self.updateEditButtonTitle()
                    self.alertView(message: "Profile updated!")
                    // Reload profile
                    self.loadProfile()
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertView(message: "Failed to update profile: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
@available(iOS 14.0, *)
extension ProfileVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.uploadAvatarImage(image)
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self?.alertView(message: "Failed to load image: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let editedImage = info[.editedImage] as? UIImage {
            uploadAvatarImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            uploadAvatarImage(originalImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
