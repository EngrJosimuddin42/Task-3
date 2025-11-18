# 📝 Task 3 – Offline-First Note Taking App (Flutter + Hive)

A clean-architecture based **Offline-First Note App** built using Flutter.  
The app supports local persistence, color-tagged notes, editing, deleting,  
and offline → online background sync using a mock REST API.

This project was developed as part of **Task 3: Notes App With Offline Sync**.

---

## 🚀 Features

### 📌 Core Features
- Create, edit, and delete notes
- Local storage using **Hive**
- Offline-first saving
- Auto-sync with remote API  
  (`POST https://jsonplaceholder.typicode.com/posts`)
- Note color tags
- Soft delete with sync status flags
- Background retry logic with exponential backoff

### 🎨 UI
- Clean & minimal design
- Color-coded notes
- Dark mode support (Flutter’s theme)

---

## 🏛 Architecture

The project follows **Clean Architecture**:


### **Domain Layer**
- `NoteEntity`
- Defines pure business model

### **Data Layer**
- `NoteModel` (Hive model)
- `LocalNoteSource` (Hive)
- `RemoteNoteApi` (Mock API)
- `NoteRepoImpl` (offline-first logic + sync + retry loop)

### **Presentation Layer**
- `NoteProvider` (state management)
- UI screens (`HomePage`, `AddNotePage`, etc.)

---

## 🔗 API Sync Logic

Every time a note is added/updated:

1. Note is saved **locally first** using Hive
2. App attempts API sync:
   ```http
   POST https://jsonplaceholder.typicode.com/posts
   body: { title, body, localId }
