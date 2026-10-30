# TaskFlow Pro 🚀

[![TaskFlow Pro CI](https://github.com/priya-darji-dev/taskflow-pro/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/priya-darji-dev/taskflow-pro/actions/workflows/flutter_ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![SQLite](https://img.shields.io/badge/SQLite-Offline--First-003B57?logo=sqlite)

> An enterprise-grade, offline-first Project & Task Management SaaS application built with **Flutter**, **GetX**, and a high-performance relational **SQLite** storage engine.

---

## 📱 App Preview & Highlights

**TaskFlow Pro** is engineered to mirror modern desktop-class productivity tools (like Linear and Notion) on mobile. It features a sleek dark obsidian SaaS design system, reactive state management, and optimized database queries that run entirely offline.

---

## 🛠️ Architecture & Tech Stack

* **Framework:** Flutter & Dart (Material 3)
* **State Management & Routing:** GetX (`GetXController`, reactive `.obs`, dependency injection)
* **Local Database:** `sqflite` with relational integrity (`PRAGMA foreign_keys = ON` for cascade deletions)
* **Typography & UI:** `google_fonts` (Plus Jakarta Sans), custom bottom sheets, and 1px border cards
* **Utilities:** `uuid` for collision-free primary keys, `intl` for date formatting

---

## 💡 Key Technical Features

### 1. High-Performance SQL Aggregate Queries
Instead of performing N+1 Dart loops to calculate board progress and task counts, `TaskFlow Pro` utilizes a single optimized SQL query featuring `LEFT JOIN`, `COUNT`, and `SUM(CASE WHEN ...)` aggregations directly inside SQLite.

### 2. Reactive Search & Multi-Criteria Filtering
* **Debounced Search:** User inputs are debounced by 250ms using GetX workers to eliminate UI frame drops during rapid typing.
* **Combined Filters:** Instantly filters tasks by Status (*To Do, In Progress, Done*), Priority (*Urgent, High, Medium, Low*), and search query keywords simultaneously.

### 3. Cross-Controller Synchronization
Changes in tasks or subtasks automatically trigger reactive updates across controllers, ensuring dashboard analytics rings and progress bars stay perfectly synchronized in real time.

---

## 📂 Project Structure

```tree
lib/
├── core/
│   ├── constants/       # App colors & design tokens
│   ├── database/        # SQLite helper & schema migrations
│   └── theme/           # Dark/Light theme engine & controller
└── features/
    ├── boards/          # Workspace boards (Models, Repositories, Controllers, Views)
    └── tasks/           # Kanban boards & subtask checklists (Models, Repositories, Controllers, Views)
