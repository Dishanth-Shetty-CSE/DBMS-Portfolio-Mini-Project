# Institutional & Retail Financial Portfolio Management System (FinManage)

[![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)](https://www.oracle.com/java/)
[![JSP](https://img.shields.io/badge/JSP%20%2F%20Servlet-007396?style=for-the-badge&logo=java&logoColor=white)](https://tomcat.apache.org/)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Bootstrap 5](https://img.shields.io/badge/Bootstrap%205-7952B3?style=for-the-badge&logo=bootstrap&logoColor=white)](https://getbootstrap.com/)
[![Chart.js](https://img.shields.io/badge/Chart.js-FF6384?style=for-the-badge&logo=chartdotjs&logoColor=white)](https://www.chartjs.org/)
[![SweetAlert2](https://img.shields.io/badge/SweetAlert2-8549BA?style=for-the-badge&logo=sweetalert2&logoColor=white)](https://sweetalert2.github.io/)

A modern, institutional-grade **Financial Portfolio Management System (FinTech Application)** designed for wealth asset management, stock analysis, automated transaction reconciliation, and real-time equity market tracking. Engineered using Java Server Pages (JSP), MySQL, and modern front-end technologies with a refined dark-navy institutional theme.

---

## 🌟 Executive Highlights

- **Executive Client Wealth Dashboard**: Real-time KPI metrics (Net Portfolio Value, Total Realized/Unrealized Gain, Asset Diversity Index), interactive Chart.js portfolio performance graph with multi-timeframe toggles (`1D`, `1W`, `1M`, `1Y`, `ALL`), sector allocation donut charts, and live order execution.
- **Administrator Command Console**: System-wide database analytics, aggregated market valuation, and centralized CRUD entity management across Users, Listed Enterprises, Fundamental Reports, Technical Signals, and Transaction Books.
- **Institutional FinTech Aesthetics**: Unified typography using **Google Fonts Poppins** (`300` through `800`) with **JetBrains Mono** for monetary figures, live market ticker tape with marquee animation, custom vector SVG enterprise emblems, and responsive layouts.
- **Enterprise Security**:
  - Secure **SHA-256 Cryptographic Password Hashing** before database persistence.
  - Email-based authentication for both Clients and Administrators (`CUST_EMAIL` and `ADMIN_EMAIL` as Primary Keys).
  - SQL injection immunity utilizing parameterized `PreparedStatement` interfaces.
- **Interactive UX & Validations**:
  - Real-time client-side JavaScript validation with high-visibility red borders (`#ef4444`) and contextual error feedback.
  - Interactive **SweetAlert2 "Are you sure?" confirmation dialogs** preceding critical actions (Sign In, Registration, Quick Trades, Entity Creation/Modifications, and System Sign-Out).

---

## 📐 Relational Database Schema & Entities

The system interfaces with MySQL (`FINANCIAL_DB`). The database schema enforces relational integrity with cascading updates and deletions.

```mermaid
erDiagram
    ADMIN {
        varchar(100) ADMIN_EMAIL PK
        int ADMINID UK
        varchar(100) ADMINNAME
        varchar(255) PASSWORD
    }
    USER {
        varchar(100) CUST_EMAIL PK
        int UID UK
        varchar(100) USERNAME
        varchar(15) PHONE
        varchar(255) PASSWORD
    }
    COMPANY {
        int CID PK
        varchar(100) CNAME
        decimal CAPITAL
        varchar(100) SECTOR
    }
    REPORT {
        int REPORT_ID PK
        decimal LTP
        decimal EPS
        decimal ROE
        int CID FK
    }
    TECHNICAL_SIGNALS {
        int STOCK_ID PK
        decimal ADX
        int VOLUME
        decimal MACD
        int CID FK
    }
    TRANSACTION {
        int TID PK
        int UID FK
        int CID FK
        decimal RATE
        int QUANTITY
        varchar(10) BUY_SELL
    }

    COMPANY ||--|| REPORT : "fundamental data"
    COMPANY ||--|| TECHNICAL_SIGNALS : "momentum signals"
    USER ||--o{ TRANSACTION : "executes"
    COMPANY ||--o{ TRANSACTION : "traded in"
```

---

## 🔑 Pre-Seeded Authorized Accounts

The database initialization script (`Financial-Portfolio-DB.sql`) populates **1 Administrator** and **10 Wealth Investor Accounts** with secure SHA-256 hashed passwords following standard enterprise credentials:

### 1. Master Administrator Account
| Attribute | Credential |
| :--- | :--- |
| **Portal URL** | `admin-login.jsp` |
| **Email Address** | `admin@portfolio.com` |
| **Admin Name** | System Administrator |
| **Raw Password** | `Admin@123` |
| **SHA-256 Hash** | `e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7` |

### 2. Client Wealth Investor Accounts (10 Valid Accounts)
| UID | Client Name | Email (Primary Key) | Raw Password | Phone Number |
| :---: | :--- | :--- | :---: | :---: |
| **1** | Ravi Kumar | `ravi.kumar@portfolio.com` | `Ravi@123` | `9876543210` |
| **2** | Sneha Reddy | `sneha.reddy@portfolio.com` | `Sneha@123` | `9123456789` |
| **3** | Amit Singh | `amit.singh@portfolio.com` | `Amit@123` | `9012345678` |
| **4** | Divya Sharma | `divya.sharma@portfolio.com` | `Divya@123` | `9988776655` |
| **5** | Manoj Shetty | `manoj.shetty@portfolio.com` | `Manoj@123` | `9090909090` |
| **6** | Priya Nair | `priya.nair@portfolio.com` | `Priya@123` | `9845012345` |
| **7** | Vikram Malhotra | `vikram.malhotra@portfolio.com` | `Vikram@123` | `9820011223` |
| **8** | Ananya Iyer | `ananya.iyer@portfolio.com` | `Ananya@123` | `9741122334` |
| **9** | Rajesh Verma | `rajesh.verma@portfolio.com` | `Rajesh@123` | `9811234567` |
| **10** | Pooja Joshi | `pooja.joshi@portfolio.com` | `Pooja@123` | `9867012345` |

*(Password Pattern: First name capitalized + `@123`, e.g., `Ravi@123`)*

---

## 🏛️ Listed Equities & Fundamental Assets (10 Real-World Bluechips)

| CID | Company Name | Sector | Market Capitalization | Last Traded Price (LTP) | EPS | ROE |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: |
| **1** | Infosys Ltd | IT | ₹5.00 Cr | ₹1,520.50 | ₹82.40 | 21.50% |
| **2** | Reliance Industries | Energy | ₹12.00 Cr | ₹2,580.00 | ₹105.20 | 26.00% |
| **3** | Tata Motors | Automobile | ₹8.00 Cr | ₹745.20 | ₹52.80 | 16.40% |
| **4** | HDFC Bank | Banking | ₹9.50 Cr | ₹1,640.00 | ₹64.10 | 19.20% |
| **5** | Wipro Ltd | IT | ₹6.00 Cr | ₹1,315.00 | ₹56.30 | 22.80% |
| **6** | Tata Consultancy Services | IT | ₹14.00 Cr | ₹3,850.00 | ₹128.50 | 28.40% |
| **7** | ICICI Bank | Banking | ₹8.50 Cr | ₹1,080.00 | ₹48.60 | 17.80% |
| **8** | State Bank of India | Banking | ₹7.50 Cr | ₹620.00 | ₹38.20 | 15.60% |
| **9** | Bharti Airtel | Telecom | ₹7.00 Cr | ₹1,460.00 | ₹44.50 | 18.20% |
| **10** | Larsen & Toubro | Infrastructure | ₹8.80 Cr | ₹3,490.00 | ₹112.00 | 23.60% |

---

## 💻 Tech Stack Architecture

- **Backend Runtime**: Java 8+ / Java 17 (JSP 2.3, Servlets 3.1)
- **Database Engine**: MySQL 8.0+ / MariaDB (`FINANCIAL_DB`)
- **Connection Driver**: MySQL Connector/J (`com.mysql.cj.jdbc.Driver`)
- **Web Application Server**: Apache Tomcat 9.0 / 10.1
- **Styling Architecture**: Custom FinTech Elite CSS (`Resources/fintech-theme.css`) with CSS custom properties
- **Typography**: Google Fonts **Poppins** (Primary UI) & **JetBrains Mono** (Metrics)
- **Data Visualization**: Chart.js v4.4
- **Modals & Dialogs**: SweetAlert2 v11
- **Icons**: Bootstrap Icons v1.11 & FontAwesome 6

---

## 📁 Project Directory Structure

```text
DBMS-PORTFOLIO-MANAGEMENT-SYSTEM/
├── Financial-Portfolio-DB.sql     # Database schema, tables, views & seed records
├── pom.xml                        # Maven dependency descriptor
├── README.md                      # Comprehensive documentation
└── src/
    └── main/
        └── webapp/
            ├── index.jsp                  # Landing page with ticker tape & market pulse
            ├── login.jsp                  # Client sign in (email & password)
            ├── register.jsp               # New client onboarding (with hashing & validation)
            ├── customer-dashboard.jsp     # Investor wealth terminal & Quick Trade
            ├── admin-login.jsp            # Superuser access portal
            ├── admin-dashboard.jsp        # Administrative command console
            ├── browse-company.jsp         # Listed equities market directory
            ├── browse-reports.jsp         # Fundamental financial reports
            ├── browse-signals.jsp         # Technical quantitative indicators
            ├── browse-transaction.jsp     # Transaction audit trail & order book
            ├── manage-companies.jsp       # Admin company CRUD manager
            ├── manage-reports.jsp         # Admin fundamental report CRUD manager
            ├── manage-signals.jsp         # Admin technical signals CRUD manager
            ├── manage-transactions.jsp    # Admin order book CRUD manager
            ├── manage-users.jsp           # Admin client registry CRUD manager
            └── Resources/
                ├── fintech-theme.css      # Core FinTech Design System & Poppins typography
                ├── fintech-charts.js      # Chart.js engine, live calculation & validation
                ├── Land-Image.jpg         # Hero visual asset
                └── stocks/                # Vector SVG corporate emblems
                    ├── airtel.svg
                    ├── generic.svg
                    ├── hdfc.svg
                    ├── icici.svg
                    ├── infosys.svg
                    ├── lt.svg
                    ├── reliance.svg
                    ├── sbi.svg
                    ├── tatamotors.svg
                    ├── tcs.svg
                    └── wipro.svg
```

---

## 🚀 Setup & Execution Guide

### 1. Database Setup
1. Launch your MySQL Server (via MySQL Workbench, Command Line, or XAMPP).
2. Execute the initialization script:
   ```sql
   SOURCE Financial-Portfolio-DB.sql;
   ```
   *This automatically creates `FINANCIAL_DB`, configures all tables, primary keys, foreign key constraints, and seeds all 10 records per entity.*

3. Verify database configuration credentials in your deployment if modified:
   - **JDBC URL**: `jdbc:mysql://localhost:3306/FINANCIAL_DB`
   - **User**: `root`
   - **Password**: `trickortreat`

### 2. Application Deployment

#### Via Eclipse IDE / Spring Tool Suite:
1. Open Eclipse and choose **File > Import > Existing Projects into Workspace** (or **Existing Maven Projects**).
2. Right-click the project folder and select **Configure > Convert to Dynamic Web Project** (if not already detected).
3. Target runtime: **Apache Tomcat v9.0** (or compatible).
4. Right-click the project > **Run As > Run on Server**.
5. Navigate to: `http://localhost:8080/DBMS-PORTFOLIO-MANAGEMENT-SYSTEM/` (or configured context path).

#### Via Standalone Apache Tomcat:
1. Package the web application into a `.war` file (or deploy the `webapp` folder).
2. Copy into `$TOMCAT_HOME/webapps/portfolio.war`.
3. Start Tomcat using `bin/startup.bat` (Windows) or `bin/startup.sh` (Linux/macOS).
4. Access via browser: `http://localhost:8080/portfolio/`.

---

## 🛡️ Security & Validation Highlights

- **Hashing Standard**: Passwords are never stored in plain text. Registration and login calculate standard `SHA-256` 64-character hexadecimal digests using `java.security.MessageDigest`.
- **Primary Key Constraints**: `CUST_EMAIL` is enforced as the unique Primary Key on client user profiles; `ADMIN_EMAIL` is enforced on administrative accounts.
- **Relational Integrity**: Foreign key links to `COMPANY(CID)` and `USER(UID)` use `ON DELETE CASCADE ON UPDATE CASCADE` to prevent orphaned records.
- **Form Verification**: Client forms feature instant inline JavaScript verification displaying red borders (`.is-invalid`) and alert dialogs before processing database mutations.

---

## 📄 License & Attribution

Developed for Academic Demonstration, DBMS Mini-Project Evaluation, and Portfolio Management Demonstration.
All corporate logos and ticker references are utilized under educational Fair Use guidelines.
