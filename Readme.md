# Mairies Scrapper - Val d'Oise

This project is a **scrapping** tool built with Ruby. It extracts names and email addresses of town halls in the Val d'Oise department from the official public service directory, then saves the data into three different formats.

## 🚀 Features

The program performs the following actions:
1. **Scrapping**: Collects real-time data from `service-public.gouv.fr`.
2. **JSON Storage**: Generates a `db/emails.json` file.
3. **CSV Storage**: Generates a `db/emails.csv` file.
4. **Google Sheets Storage**: Sends data to a remote spreadsheet via the Google Drive API.

## 📋 Prerequisites

* **Ruby** (version 2.5 or higher)
* **Bundler** installed (`gem install bundler`)
* A **Google Cloud Console** account with **Google Drive** and **Google Sheets** APIs enabled.

## 🛠️ Installation

1. Clone the repository to your local machine:
   ```bash
   git clone [https://github.com/your-username/google_spreadsheet_project.git](https://github.com/your-username/google_spreadsheet_project.git)
   cd google_spreadsheet_project