//
//  CollectionsVC.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit

class CollectionsVC: UIViewController {
    
    @IBOutlet weak var tblCollections: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    var collections: [Collection] = []
    var currentUserId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        loadCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCollections()
    }
    
    func loadCurrentUser() {
        currentUserId = SupabaseService.shared.userId
    }
    
    func prepareUI() {
        title = "Collections"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(createCollection)
        )
        
        tblCollections.delegate = self
        tblCollections.dataSource = self
        tblCollections.register(UITableViewCell.self, forCellReuseIdentifier: "CollectionCell")
        activityIndicator.hidesWhenStopped = true
        
        emptyStateLabel.text = "No collections yet.\nCreate a collection to organize your favorite quotes!"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateView.isHidden = true
    }
    
    @objc func createCollection() {
        let alert = UIAlertController(title: "New Collection", message: "Enter collection name", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Collection name"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self,
                  let userId = self.currentUserId,
                  let nameField = alert.textFields?[0],
                  let name = nameField.text,
                  !name.isEmpty else {
                return
            }
            
            Task {
                do {
                    _ = try await QuoteRepository.shared.createCollection(userId: userId, name: name)
                    DispatchQueue.main.async {
                        self.loadCollections()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.alertView(message: "Failed to create collection: \(error.localizedDescription)")
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    func loadCollections() {
        guard let userId = currentUserId else {
            emptyStateView.isHidden = false
            tblCollections.isHidden = true
            return
        }
        
        activityIndicator.startAnimating()
        
        Task {
            do {
                let collections = try await QuoteRepository.shared.fetchCollections(userId: userId)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.collections = collections
                    self.tblCollections.reloadData()
                    self.updateEmptyState()
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.alertView(message: "Failed to load collections: \(error.localizedDescription)")
                    self.updateEmptyState()
                }
            }
        }
    }
    
    func updateEmptyState() {
        let isEmpty = collections.isEmpty
        emptyStateView.isHidden = !isEmpty
        tblCollections.isHidden = isEmpty
    }
    
    func deleteCollection(_ collection: Collection, at indexPath: IndexPath) {
        let collectionId = collection.id
        
        let alert = UIAlertController(title: "Delete Collection", message: "Are you sure you want to delete '\(collection.name)'?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            Task {
                do {
                    try await QuoteRepository.shared.deleteCollection(collectionId: collectionId)
                    DispatchQueue.main.async {
                        self?.collections.remove(at: indexPath.row)
                        self?.tblCollections.deleteRows(at: [indexPath], with: .fade)
                        self?.updateEmptyState()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.alertView(message: "Failed to delete collection: \(error.localizedDescription)")
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
}

extension CollectionsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath)
        let collection = collections[indexPath.row]
        cell.textLabel?.text = collection.name
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let collection = collections[indexPath.row]
        let vc = CollectionDetailVC()
        vc.collection = collection
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let collection = collections[indexPath.row]
            deleteCollection(collection, at: indexPath)
        }
    }
}

