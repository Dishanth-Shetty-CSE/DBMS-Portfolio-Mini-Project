<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrator Command Center - FinManage</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,400&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="Resources/fintech-theme.css">
</head>
<body style="background-color: #f8fafc;">

    <%
        String adminName = (String) session.getAttribute("loggedInAdminName");
        if (adminName == null || adminName.trim().isEmpty()) {
            response.sendRedirect("admin-login.jsp");
            return;
        }

        // Database Metrics
        int userCount = 0;
        int companyCount = 0;
        double totalCapital = 0.0;
        int reportCount = 0;
        int signalCount = 0;
        int transactionCount = 0;

        DecimalFormat df = new DecimalFormat("#,##0.00");

        Connection conn = null;
        try {
            String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
            String user = "root";
            String pass = "trickortreat";
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, pass);
            Statement st = conn.createStatement();

            ResultSet rsU = st.executeQuery("SELECT COUNT(*) FROM USER");
            if (rsU.next()) userCount = rsU.getInt(1);
            rsU.close();

            ResultSet rsC = st.executeQuery("SELECT COUNT(*), COALESCE(SUM(CAPITAL), 0) FROM COMPANY");
            if (rsC.next()) {
                companyCount = rsC.getInt(1);
                totalCapital = rsC.getDouble(2);
            }
            rsC.close();

            ResultSet rsR = st.executeQuery("SELECT COUNT(*) FROM REPORT");
            if (rsR.next()) reportCount = rsR.getInt(1);
            rsR.close();

            ResultSet rsS = st.executeQuery("SELECT COUNT(*) FROM TECHNICAL_SIGNALS");
            if (rsS.next()) signalCount = rsS.getInt(1);
            rsS.close();

            ResultSet rsT = st.executeQuery("SELECT COUNT(*) FROM TRANSACTION");
            if (rsT.next()) transactionCount = rsT.getInt(1);
            rsT.close();

            st.close();
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.close(); } catch(SQLException ex) { ex.printStackTrace(); }
            }
        }
    %>

    <!-- ADMIN NAVBAR -->
    <nav class="navbar navbar-expand-lg fin-navbar" style="background: #0f172a; border-bottom: 1px solid rgba(245, 158, 11, 0.2);">
        <div class="container-fluid px-lg-4">
            <a class="fin-brand" href="admin-dashboard.jsp">
                <div class="fin-brand-logo" style="background: linear-gradient(135deg, #f59e0b, #d97706);">
                    <i class="bi bi-shield-lock-fill"></i>
                </div>
                <div class="fin-brand-name">
                    <span>FinManage</span>
                    <span class="fin-brand-sub" style="color: #f59e0b;">SYSTEM ADMIN TERMINAL</span>
                </div>
            </a>
            <button class="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#adminNav">
                <i class="bi bi-list fs-2"></i>
            </button>
            <div class="collapse navbar-collapse" id="adminNav">
                <ul class="navbar-nav ms-auto align-items-center gap-1">
                    <li class="nav-item"><a class="fin-nav-link active" href="admin-dashboard.jsp"><i class="bi bi-speedometer2"></i> Overview</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-users.jsp"><i class="bi bi-people"></i> Users</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-companies.jsp"><i class="bi bi-buildings"></i> Companies</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-reports.jsp"><i class="bi bi-file-earmark-text"></i> Reports</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-signals.jsp"><i class="bi bi-activity"></i> Signals</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-transactions.jsp"><i class="bi bi-clock-history"></i> Orders</a></li>
                    
                    <!-- Admin User Pill -->
                    <li class="nav-item ms-lg-2">
                        <div class="fin-user-pill" style="border-color: rgba(245, 158, 11, 0.3);">
                            <div class="fin-user-avatar" style="background: linear-gradient(135deg, #f59e0b, #d97706);">
                                <i class="bi bi-shield-fill"></i>
                            </div>
                            <span class="fw-semibold"><%= adminName %> (Admin)</span>
                        </div>
                    </li>

                    <!-- Logout Button -->
                    <li class="nav-item ms-lg-2">
                        <a href="javascript:void(0)" id="adminLogoutBtn" class="fin-btn-logout">
                            <i class="bi bi-box-arrow-right"></i> Logout
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- ADMIN CONTENT -->
    <div class="container-fluid px-lg-4 py-4">

        <!-- Welcome Banner -->
        <div class="d-flex justify-content-between align-items-center flex-wrap mb-4">
            <div>
                <h3 class="fw-bold mb-1 text-dark">
                    Administrator Command Console
                    <span class="badge bg-warning-subtle text-warning border border-warning fs-6 fw-semibold ms-2 align-middle">
                        <i class="bi bi-shield-check"></i> Superuser Access
                    </span>
                </h3>
                <p class="text-muted mb-0 small">
                    Logged in as <strong><%= adminName %></strong> | Master DB: <span class="badge bg-dark">FINANCIAL_DB</span> | Host: localhost:3306
                </p>
            </div>
            <div class="mt-3 mt-md-0 d-flex gap-2">
                <span class="badge bg-success-subtle text-success p-2 px-3 border border-success d-flex align-items-center gap-2">
                    <span class="spinner-grow spinner-grow-sm text-success" role="status"></span>
                    MySQL Database Online
                </span>
            </div>
        </div>

        <!-- EXECUTIVE SUMMARY STAT CARDS -->
        <div class="row g-3 mb-4">
            <div class="col-xl-2 col-md-4 col-sm-6">
                <div class="kpi-card kpi-blue">
                    <div class="kpi-title">Total Users</div>
                    <div class="kpi-value text-primary"><%= userCount %></div>
                    <div class="small text-muted"><i class="bi bi-person-check text-success me-1"></i>Registered Accounts</div>
                </div>
            </div>
            <div class="col-xl-2 col-md-4 col-sm-6">
                <div class="kpi-card kpi-purple">
                    <div class="kpi-title">Listed Stocks</div>
                    <div class="kpi-value text-purple"><%= companyCount %></div>
                    <div class="small text-muted"><i class="bi bi-building text-info me-1"></i>Active Companies</div>
                </div>
            </div>
            <div class="col-xl-3 col-md-4 col-sm-6">
                <div class="kpi-card kpi-emerald">
                    <div class="kpi-title">Total Market Cap</div>
                    <div class="kpi-value text-success">
                        ₹<%= (totalCapital >= 10000000 ? (df.format(totalCapital / 10000000) + " Cr") : df.format(totalCapital)) %>
                    </div>
                    <div class="small text-muted"><i class="bi bi-cash-stack text-success me-1"></i>Aggregated Capital</div>
                </div>
            </div>
            <div class="col-xl-2 col-md-4 col-sm-6">
                <div class="kpi-card kpi-amber">
                    <div class="kpi-title">Financial Reports</div>
                    <div class="kpi-value text-warning"><%= reportCount %></div>
                    <div class="small text-muted"><i class="bi bi-file-earmark-bar-graph me-1"></i>LTP / EPS / ROE</div>
                </div>
            </div>
            <div class="col-xl-3 col-md-8 col-sm-12">
                <div class="kpi-card kpi-blue">
                    <div class="kpi-title">Order Book Transactions</div>
                    <div class="kpi-value text-dark"><%= transactionCount %></div>
                    <div class="small text-muted"><i class="bi bi-arrow-left-right text-primary me-1"></i>Executed BUY & SELL</div>
                </div>
            </div>
        </div>

        <!-- MANAGEMENT MODULES GRID -->
        <h5 class="fw-bold text-dark mb-3"><i class="bi bi-grid-fill text-primary me-2"></i>Database Entity Management Suites</h5>
        <div class="row g-4 mb-4">

            <!-- Manage Users -->
            <div class="col-lg-4 col-md-6">
                <div class="fin-card h-100">
                    <div class="fin-card-body d-flex flex-column justify-content-between p-4">
                        <div>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="kpi-icon-box kpi-icon-blue">
                                    <i class="bi bi-people-fill"></i>
                                </div>
                                <span class="badge bg-primary-subtle text-primary fs-6"><%= userCount %> Users</span>
                            </div>
                            <h5 class="fw-bold text-dark mb-2">Manage Customer Accounts</h5>
                            <p class="text-muted small mb-4">
                                Add new clients, modify contact phone numbers, view user IDs, and maintain client registry records.
                            </p>
                        </div>
                        <a href="manage-users.jsp" class="fin-btn fin-btn-primary w-100">
                            <i class="bi bi-gear-fill me-1"></i> Launch User Manager
                        </a>
                    </div>
                </div>
            </div>

            <!-- Manage Companies -->
            <div class="col-lg-4 col-md-6">
                <div class="fin-card h-100">
                    <div class="fin-card-body d-flex flex-column justify-content-between p-4">
                        <div>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="kpi-icon-box kpi-icon-purple">
                                    <i class="bi bi-buildings-fill"></i>
                                </div>
                                <span class="badge bg-purple-subtle text-purple fs-6"><%= companyCount %> Companies</span>
                            </div>
                            <h5 class="fw-bold text-dark mb-2">Manage Listed Companies</h5>
                            <p class="text-muted small mb-4">
                                Configure stock tickers, company names, market capitalization figures, and sector classifications.
                            </p>
                        </div>
                        <a href="manage-companies.jsp" class="fin-btn fin-btn-primary w-100">
                            <i class="bi bi-gear-fill me-1"></i> Launch Company Manager
                        </a>
                    </div>
                </div>
            </div>

            <!-- Manage Reports -->
            <div class="col-lg-4 col-md-6">
                <div class="fin-card h-100">
                    <div class="fin-card-body d-flex flex-column justify-content-between p-4">
                        <div>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="kpi-icon-box kpi-icon-emerald">
                                    <i class="bi bi-file-earmark-bar-graph-fill"></i>
                                </div>
                                <span class="badge bg-success-subtle text-success fs-6"><%= reportCount %> Reports</span>
                            </div>
                            <h5 class="fw-bold text-dark mb-2">Manage Financial Reports</h5>
                            <p class="text-muted small mb-4">
                                Input and adjust Last Traded Price (LTP), Earnings Per Share (EPS), and Return on Equity (ROE).
                            </p>
                        </div>
                        <a href="manage-reports.jsp" class="fin-btn fin-btn-emerald w-100">
                            <i class="bi bi-gear-fill me-1"></i> Launch Reports Manager
                        </a>
                    </div>
                </div>
            </div>

            <!-- Manage Signals -->
            <div class="col-lg-4 col-md-6">
                <div class="fin-card h-100">
                    <div class="fin-card-body d-flex flex-column justify-content-between p-4">
                        <div>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="kpi-icon-box kpi-icon-amber">
                                    <i class="bi bi-sliders"></i>
                                </div>
                                <span class="badge bg-warning-subtle text-warning fs-6"><%= signalCount %> Signals</span>
                            </div>
                            <h5 class="fw-bold text-dark mb-2">Manage Technical Signals</h5>
                            <p class="text-muted small mb-4">
                                Configure quantitative indicators including ADX trend strength, trading volume, and MACD momentum.
                            </p>
                        </div>
                        <a href="manage-signals.jsp" class="fin-btn fin-btn-primary w-100">
                            <i class="bi bi-gear-fill me-1"></i> Launch Signals Manager
                        </a>
                    </div>
                </div>
            </div>

            <!-- Manage Transactions -->
            <div class="col-lg-4 col-md-6">
                <div class="fin-card h-100">
                    <div class="fin-card-body d-flex flex-column justify-content-between p-4">
                        <div>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="kpi-icon-box kpi-icon-blue">
                                    <i class="bi bi-arrow-left-right"></i>
                                </div>
                                <span class="badge bg-dark text-white fs-6"><%= transactionCount %> Orders</span>
                            </div>
                            <h5 class="fw-bold text-dark mb-2">Manage Trade Orders</h5>
                            <p class="text-muted small mb-4">
                                Full order book administration: add manual settlements, edit trade quantities, or reverse transactions.
                            </p>
                        </div>
                        <a href="manage-transactions.jsp" class="fin-btn fin-btn-primary w-100">
                            <i class="bi bi-gear-fill me-1"></i> Launch Order Book
                        </a>
                    </div>
                </div>
            </div>

            <!-- Quick Client View Portal -->
            <div class="col-lg-4 col-md-6">
                <div class="fin-card h-100 border-primary" style="background: linear-gradient(135deg, #ffffff, #f0fdf4);">
                    <div class="fin-card-body d-flex flex-column justify-content-between p-4">
                        <div>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="kpi-icon-box kpi-icon-emerald">
                                    <i class="bi bi-eye-fill"></i>
                                </div>
                                <span class="badge bg-success text-white fs-6">Live Client View</span>
                            </div>
                            <h5 class="fw-bold text-dark mb-2">Client Terminal Simulation</h5>
                            <p class="text-muted small mb-4">
                                Preview the system as an active investor to inspect dashboard calculations, charts, and portfolio views.
                            </p>
                        </div>
                        <a href="customer-dashboard.jsp" class="fin-btn fin-btn-emerald w-100">
                            <i class="bi bi-speedometer2 me-1"></i> View Client Terminal
                        </a>
                    </div>
                </div>
            </div>

        </div>

    </div>

    <!-- FOOTER -->
    <footer class="fin-footer mt-5">
        <div class="container text-center">
            <p class="mb-1 text-muted">&copy; 2026 Financial Portfolio Management System. All Rights Reserved.</p>
            <p class="small text-secondary mb-0">Administrator Control Console • Connected to MySQL Database (FINANCIAL_DB)</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="Resources/fintech-charts.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const logoutBtn = document.getElementById('adminLogoutBtn');
            if (logoutBtn) {
                logoutBtn.addEventListener('click', function () {
                    FinTechApp.confirmAction(
                        'Administrator Sign Out',
                        'Are you sure you want to sign out of the Administrator Command Console?',
                        'Yes, Sign Out',
                        function () {
                            window.location.href = 'admin-login.jsp';
                        },
                        'warning'
                    );
                });
            }
        });
    </script>
</body>
</html>
