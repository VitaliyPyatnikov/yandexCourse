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

// MARK: - TableViewAnimation

private enum TableViewAnimation {

    // MARK: - Cases

    case reload
    case delete(IndexPath)
}


// MARK: - NotesWorker

protocol NotesWorker: class {
    func addNew(_ note: Note)
    func updateNote(_ note: Note)
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
        runLoadOperation(animation: .reload)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isOpenForEditing = false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditNoteSegue" {
            guard let editNoteViewController = segue.destination as? EditNoteViewController else {
                return
            }
            editNoteViewController.notesWorker = self
            if isOpenForEditing {
                editNoteViewController.isEditNote = true
                editNoteViewController.note = editingNote
            }
        }
    }

    // MARK: - Private

    private let fileNotebook = FileNotebook()
    private var storedNotes: [Note]?
    private let backendQueue = OperationQueue()
    private let dbQueue = OperationQueue()
    private let notesOperationQueue = OperationQueue()
    private var loadNotesOperation: LoadNotesOperation?
    private var saveNoteOperation: SaveNoteOperation?
    private var removeNoteOperation: RemoveNoteOperation?
    private var isOpenForEditing: Bool = false
    private var editingNote: Note?
    private var indexPath: IndexPath?

    private func runLoadOperation(animation: TableViewAnimation) {
        let loadOperation = LoadNotesOperation(notebook: fileNotebook,
                                               backendQueue: backendQueue,
                                               dbQueue: dbQueue)
        loadOperation.completionBlock = {
            guard let result = loadOperation.result else {
                self.storedNotes = []
                return
            }
            switch (result, animation) {
            case (let .success(notes), .reload):
                self.storedNotes = notes
                self.reloadData()
            case (let .success(notes), let .delete(indexPath)):
                self.storedNotes = notes
                self.deleteRow(at: indexPath)
            default:
                self.storedNotes = []
                self.reloadData()
            }
            DispatchQueue.main.async {
                self.tableVIew.isUserInteractionEnabled = true
            }

        }
        loadNotesOperation = loadOperation
        notesOperationQueue.addOperation(loadOperation)
    }
    private func reloadData() {
        DispatchQueue.main.async {
            self.tableVIew.reloadData()
        }
    }
    private func deleteRow(at indexPath: IndexPath) {
        // TODO: - Check the problem with constrains while deleting cell
        DispatchQueue.main.async {
            self.tableVIew.deleteRows(at: [indexPath], with: .middle)
        }
    }
    private func runSaveNoteOperation(with note: Note) {
        let saveOperation = SaveNoteOperation(note: note,
                                              notebook: fileNotebook,
                                              backendQueue: backendQueue,
                                              dbQueue: dbQueue)
        saveOperation.completionBlock = {
            self.runLoadOperation(animation: .reload)
        }
        saveNoteOperation = saveOperation
        notesOperationQueue.addOperation(saveOperation)
    }
    private func runRemoveNoteOperation(with note: Note, at indexPath: IndexPath) {
        let removeOperation = RemoveNoteOperation(note: note,
                                                  notebook: fileNotebook,
                                                  backendQueue: backendQueue,
                                                  dbQueue: dbQueue)
        removeOperation.completionBlock = {
            self.runLoadOperation(animation: .delete(indexPath))
        }
        removeNoteOperation = removeOperation
        notesOperationQueue.addOperation(removeOperation)

    }
    private func setupNavigationBar() {
        title = "Notes"
        setupLeftBarButtonItem(to: .edit)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(openEditNote))
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
    @objc private func openEditNote() {
        performSegue(withIdentifier: "EditNoteSegue", sender: self)
    }
    private func removeNote(at indexPath: IndexPath) {
        guard let notes = storedNotes else {
            return
        }
        let note = notes[indexPath.row]
        tableVIew.isUserInteractionEnabled = false
        runRemoveNoteOperation(with: note, at: indexPath)
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
        return storedNotes?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableVIew.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as? NoteTableViewCell else {
            return UITableViewCell()
        }
        guard let notes = storedNotes else {
            return UITableViewCell()
        }
        let model = notes[indexPath.row]
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isOpenForEditing = true
        editingNote = storedNotes?[indexPath.row]
        self.indexPath = indexPath
        openEditNote()
    }
}

// MARK: - NotesWorker

extension NotesViewController: NotesWorker {
    func addNew(_ note: Note) {
        runSaveNoteOperation(with: note)
    }
    func updateNote(_ note: Note) {
        guard let indexPath = indexPath,
            isOpenForEditing else {
            Log.error("Can't update note")
            return
        }
        Log.info("Update note at: \(indexPath.row)")
        runSaveNoteOperation(with: note)
    }
}
