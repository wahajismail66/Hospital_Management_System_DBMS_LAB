# 🏥 Hospital Management System – DBMS Final Project

A complete hospital management system with a modern GUI (Python + CustomTkinter) and a SQL Server backend.  
It supports **Admin**, **Doctor**, **Receptionist**, and **Patient** roles, with full CRUD operations, appointment scheduling, bed/ward management, laboratory test ordering, pharmacy inventory, prescription PDF generation, Excel export, and audit logging.

---

## 📋 Table of Contents

- [Features](#features)
- [Technologies Used](#technologies-used)
- [System Requirements](#system-requirements)
- [Installation & Setup (Step by Step)](#installation--setup-step-by-step)
- [Running the Application](#running-the-application)
- [Default Login Credentials](#default-login-credentials)
- [Project Structure](#project-structure)
- [Screenshots](#screenshots)
- [Contributors](#contributors)
- [License](#license)

---

## ✨ Features

- **Role‑based access** – Admin, Doctor, Receptionist, Patient each see only relevant modules.
- **Patient Management** – Add, edit, search, delete, export to Excel.
- **Doctor Management** – Add doctors, set weekly availability (day, start/end time, slot duration).
- **Nurse Management** – Assign nurses to doctors.
- **Appointment Scheduling** – Check doctor availability, display free time slots, book appointments.
- **Prescriptions** – Create, edit, and generate PDF prescriptions.
- **Billing** – Consultation fee + extra charges, record payments (paid/unpaid/partial).
- **Bed/Ward Management** – Admit / discharge patients, allocate beds, see bed occupancy.
- **Laboratory** – Order lab tests, enter results, track status.
- **Pharmacy** – Manage medicine stock, restock, low‑stock alerts.
- **Audit Logs** – Automatic logging of all insert/update/delete operations (database triggers).
- **Dashboard** – Real‑time statistics (patient/doctor counts, today’s appointments, revenue) and a 7‑day appointment chart.
- **Export to Excel** – Any table (patients, doctors, appointments, etc.) can be exported.
- **Email placeholders** – Code structure ready for SMTP integration (optional).

---

## 🛠️ Technologies Used

| Component       | Technology                              |
|----------------|-----------------------------------------|
| Frontend GUI   | Python 3.10+ with **CustomTkinter**     |
| Backend        | **pyodbc** (SQL Server connector)       |
| Database       | Microsoft SQL Server (Express or higher)|
| Charts         | **Matplotlib**                          |
| PDF Generation | **FPDF**                                |
| Excel Export   | **pandas** + **openpyxl**               |
| Audit Logging  | Database triggers (T‑SQL)               |

---

## 💻 System Requirements

- **Windows** (recommended) or macOS/Linux with a SQL Server instance.
- **Python 3.10 or higher** installed.
- **Microsoft SQL Server** (Express, Developer, or Standard) – must be running.
- **SQL Server Management Studio (SSMS)** – to run the database script.
- **ODBC Driver 18 or 17 for SQL Server** – installed (the code will try multiple drivers).

---

## 📦 Installation & Setup (Step by Step)

### 1. Clone or download the repository

```bash
git clone https://github.com/wahajismail66/Hospital_Management_System_DBMS_LAB.git
cd Hospital_Management_System_DBMS_LAB