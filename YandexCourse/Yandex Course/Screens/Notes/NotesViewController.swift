//
//  NotesViewController.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 28.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

// MARK: - TableViewButtonMode

private enum TableViewButtonMode {
    case edit
    case done
}

// MARK: - NotesWorker

protocol NotesWorker: class {
    func addNew(_ note: Note)
}

// MARK: - NotesViewController

final class NotesViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var tableVIew: UITableView!

    // MARK: - IBActions

    @IBAction func unwindToNotes(segue: UIStoryboardSegue) { }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditNoteSegue" {
            guard let editNoteViewController = segue.destination as? EditNoteViewController else {
                return
            }
            editNoteViewController.notesWorker = self
        }
    }

    // MARK: - Private

    private let fileNotebook: FileNotebookHandler = FileNotebook()

    private func setupNavigationBar() {
        title = "Notes"
        setupLeftBarButtonItem(to: .edit)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addNewNote))
    }
    private func setupLeftBarButtonItem(to mode: TableViewButtonMode) {
        let leftBarButton: UIBarButtonItem
        switch mode {
        case .edit:
            leftBarButton = UIBarButtonItem(barButtonSystemItem: .edit,
                                             target: self,
                                             action: #selector(editMode))
        case .done:
            leftBarButton = UIBarButtonItem(barButtonSystemItem: .done,
                                             target: self,
                                             action: #selector(editMode))
        }
        navigationItem.leftBarButtonItem = leftBarButton
    }
    @objc private func addNewNote() {
        performSegue(withIdentifier: "EditNoteSegue", sender: self)
    }
    private func removeNote(at indexPath: IndexPath) {
        let uid = fileNotebook.notes[indexPath.row].uid
        fileNotebook.remove(with: uid)
        // TODO: - Check the problem with constrains while deleting cell
        tableVIew.deleteRows(at: [indexPath], with: .middle)
    }
    @objc private func editMode() {
        if tableVIew.isEditing {
            tableVIew.setEditing(false, animated: true)
            setupLeftBarButtonItem(to: .edit)
        } else {
            tableVIew.setEditing(true, animated: true)
            setupLeftBarButtonItem(to: .done)
        }
    }
    private func setupTableView() {
        tableVIew.delegate = self
        tableVIew.dataSource = self
        tableVIew.rowHeight = UITableView.automaticDimension
        tableVIew.estimatedRowHeight = 100
        let nib = UINib(nibName: "NoteTableViewCell", bundle: nil)
        tableVIew.register(nib, forCellReuseIdentifier: "NoteCell")
    }
}

// MARK: - UITableViewDataSource

extension NotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileNotebook.notes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableVIew.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as? NoteTableViewCell else {
            return UITableViewCell()
        }
        let model = fileNotebook.notes[indexPath.row]
        let cellModel = NoteCellModel(title: model.title,
                                      description: model.content,
                                      color: model.color)
        cell.setup(with: cellModel)

        return cell
    }
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

// MARK: - UITableViewDelegate

extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeNote(at: indexPath)
        }
    }
}

// MARK: - NotesWorker

extension NotesViewController: NotesWorker {
    func addNew(_ note: Note) {
        fileNotebook.add(note)
        tableVIew.reloadData()
    }
}
