<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    String swalStatus = "";
    String swalTitle = "";
    String swalMessage = "";

    // Handle Add Company (POST without cid)
    if ("POST".equals(request.getMethod()) && request.getParameter("companyName") != null && request.getParameter("capital") != null && request.getParameter("sector") != null && request.getParameter("cid") == null) {
        String companyName = request.getParameter("companyName");
        String capitalStr = request.getParameter("capital");
        String sector = request.getParameter("sector");

        try {
            double capital = Double.parseDouble(capitalStr);
            Connection connInsert = null;
            PreparedStatement ps = null;
            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connInsert = DriverManager.getConnection(url, user, pass);
                String sql = "INSERT INTO COMPANY (CNAME, CAPITAL, SECTOR) VALUES (?, ?, ?)";
                ps = connInsert.prepareStatement(sql);
                ps.setString(1, companyName);
                ps.setDouble(2, capital);
                ps.setString(3, sector);

                int rowsInserted = ps.executeUpdate();
                if (rowsInserted > 0) {
                    swalStatus = "success";
                    swalTitle = "Success";
                    swalMessage = "Company registered successfully!";
                } else {
                    swalStatus = "error";
                    swalTitle = "Failed";
                    swalMessage = "Failed to add company.";
                }
            } catch (Exception e) {
                swalStatus = "error";
                swalTitle = "Error";
                swalMessage = e.getMessage();
            } finally {
                if (ps != null) ps.close();
                if (connInsert != null) connInsert.close();
            }
        } catch(NumberFormatException e) {
            swalStatus = "error";
            swalTitle = "Invalid Format";
            swalMessage = "Invalid capital format. Please enter a valid number.";
        }
    }

    // Handle Update Company (POST with cid)
    if ("POST".equals(request.getMethod()) && request.getParameter("companyName") != null && request.getParameter("capital") != null && request.getParameter("sector") != null && request.getParameter("cid") != null) {
        int companyId = Integer.parseInt(request.getParameter("cid"));
        String companyName = request.getParameter("companyName");
        String capitalStr = request.getParameter("capital");
        String sector = request.getParameter("sector");

        try {
            double capital = Double.parseDouble(capitalStr);
            Connection connUpdate = null;
            PreparedStatement psUpdate = null;
            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connUpdate = DriverManager.getConnection(url, user, pass);
                String sql = "UPDATE COMPANY SET CNAME = ?, CAPITAL = ?, SECTOR = ? WHERE CID = ?";
                psUpdate = connUpdate.prepareStatement(sql);
                psUpdate.setString(1, companyName);
                psUpdate.setDouble(2, capital);
                psUpdate.setString(3, sector);
                psUpdate.setInt(4, companyId);

                int rowsUpdated = psUpdate.executeUpdate();
                if (rowsUpdated > 0) {
                    swalStatus = "success";
                    swalTitle = "Success";
                    swalMessage = "Company updated successfully!";
                } else {
                    swalStatus = "error";
                    swalTitle = "Failed";
                    swalMessage = "Failed to update company.";
                }
            } catch (Exception e) {
                swalStatus = "error";
                swalTitle = "Error";
                swalMessage = e.getMessage();
            } finally {
                if (psUpdate != null) psUpdate.close();
                if (connUpdate != null) connUpdate.close();
            }
        } catch(NumberFormatException e) {
            swalStatus = "error";
            swalTitle = "Invalid Format";
            swalMessage = "Invalid capital format. Please enter a valid number.";
        }
    }

    // Handle Delete Company (GET with action=delete)
    if ("GET".equals(request.getMethod()) && "delete".equals(request.getParameter("action")) && request.getParameter("cid") != null) {
        int companyId = Integer.parseInt(request.getParameter("cid"));
        Connection connDelete = null;
        PreparedStatement psDelete = null;
        try {
            String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
            String user = "root";
            String pass = "trickortreat";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connDelete = DriverManager.getConnection(url, user, pass);
            String sql = "DELETE FROM COMPANY WHERE CID = ?";
            psDelete = connDelete.prepareStatement(sql);
            psDelete.setInt(1, companyId);
            int rowsDeleted = psDelete.executeUpdate();
            if (rowsDeleted > 0) {
                swalStatus = "success";
                swalTitle = "Deleted";
                swalMessage = "Company removed successfully.";
            } else {
                swalStatus = "error";
                swalTitle = "Failed";
                swalMessage = "Failed to delete company.";
            }
        } catch (Exception e) {
            swalStatus = "error";
            swalTitle = "Error";
            swalMessage = e.getMessage();
        } finally {
            if (psDelete != null) psDelete.close();
            if (connDelete != null) connDelete.close();
        }
    }

    boolean isUpdateMode = false;
    int updateCid = -1;
    String updateCname = "";
    double updateCapital = 0.0;
    String updateSector = "";

    // Handle Edit View mode (GET with action=update)
    if ("GET".equals(request.getMethod()) && "update".equals(request.getParameter("action")) && request.getParameter("cid") != null) {
        try {
            updateCid = Integer.parseInt(request.getParameter("cid"));
            Connection connGet = null;
            PreparedStatement psGet = null;
            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connGet = DriverManager.getConnection(url, user, pass);
                psGet = connGet.prepareStatement("SELECT CNAME, CAPITAL, SECTOR FROM COMPANY WHERE CID = ?");
                psGet.setInt(1, updateCid);
                ResultSet rsGet = psGet.executeQuery();
                if (rsGet.next()) {
                    isUpdateMode = true;
                    updateCname = rsGet.getString("CNAME");
                    updateCapital = rsGet.getDouble("CAPITAL");
                    updateSector = rsGet.getString("SECTOR");
                }
                rsGet.close();
            } finally {
                if (psGet != null) psGet.close();
                if (connGet != null) connGet.close();
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Companies - FinManage Admin</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="Resources/fintech-theme.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body style="background-color: #f8fafc;">

    <!-- ADMIN NAVBAR -->
    <nav class="navbar navbar-expand-lg fin-navbar" style="background: #0f172a; border-bottom: 1px solid rgba(245, 158, 11, 0.2);">
        <div class="container-fluid px-lg-4">
            <a class="fin-brand" href="admin-dashboard.jsp">
                <div class="fin-brand-logo" style="background: linear-gradient(135deg, #f59e0b, #d97706);">
                    <i class="bi bi-shield-lock-fill"></i>
                </div>
                <div class="fin-brand-name">
                    <span>FinManage</span>
                    <span class="fin-brand-sub" style="color: #f59e0b;">COMPANY CONTROL</span>
                </div>
            </a>
            <button class="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#adminCompNav">
                <i class="bi bi-list fs-2"></i>
            </button>
            <div class="collapse navbar-collapse" id="adminCompNav">
                <ul class="navbar-nav ms-auto align-items-center gap-1">
                    <li class="nav-item"><a class="fin-nav-link" href="admin-dashboard.jsp"><i class="bi bi-speedometer2"></i> Overview</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-users.jsp"><i class="bi bi-people"></i> Users</a></li>
                    <li class="nav-item"><a class="fin-nav-link active" href="manage-companies.jsp"><i class="bi bi-buildings"></i> Companies</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-reports.jsp"><i class="bi bi-file-earmark-text"></i> Reports</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-signals.jsp"><i class="bi bi-activity"></i> Signals</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-transactions.jsp"><i class="bi bi-clock-history"></i> Orders</a></li>
                    <li class="nav-item ms-lg-2">
                        <a href="javascript:void(0)" id="adminLogoutBtn" class="fin-btn-logout"><i class="bi bi-box-arrow-right"></i> Logout</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- CONTENT -->
    <div class="container-fluid px-lg-4 py-4">

        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center flex-wrap mb-4">
            <div>
                <h3 class="fw-bold mb-1 text-dark">
                    <i class="bi bi-buildings-fill text-primary me-2"></i>Stock & Company Management
                </h3>
                <p class="text-muted small mb-0">Register new stocks, modify capitalizations, or remove delisted entities.</p>
            </div>
            <div class="mt-3 mt-md-0 d-flex gap-2">
                <a href="admin-dashboard.jsp" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left"></i> Admin Console
                </a>
            </div>
        </div>

        <div class="row g-4">
            <!-- Add / Update Form Column -->
            <div class="col-lg-4">
                <div class="fin-card">
                    <div class="fin-card-header <%= isUpdateMode ? "bg-warning-subtle" : "" %>">
                        <h5 class="fin-card-title">
                            <i class="bi <%= isUpdateMode ? "bi-pencil-square text-warning" : "bi-plus-circle-fill text-success" %>"></i>
                            <%= isUpdateMode ? "Update Listed Company" : "Add New Listed Company" %>
                        </h5>
                    </div>
                    <div class="fin-card-body">
                        <form id="companyManageForm" action="manage-companies.jsp" method="POST" novalidate>
                            <% if (isUpdateMode) { %>
                                <input type="hidden" name="cid" value="<%= updateCid %>">
                            <% } %>

                            <div class="mb-3">
                                <label for="companyName" class="form-label small fw-bold text-secondary">Company Name</label>
                                <input type="text" id="companyName" name="companyName" class="form-control fin-input" 
                                       placeholder="e.g. Tata Consultancy Services" 
                                       value="<%= isUpdateMode ? updateCname : "" %>" required>
                            </div>

                            <div class="mb-3">
                                <label for="capital" class="form-label small fw-bold text-secondary">Market Capitalization (₹)</label>
                                <input type="number" step="0.01" id="capital" name="capital" class="form-control fin-input" 
                                       placeholder="e.g. 100000000" 
                                       value="<%= isUpdateMode ? updateCapital : "" %>" required>
                            </div>

                            <div class="mb-3">
                                <label for="sector" class="form-label small fw-bold text-secondary">Industry Sector</label>
                                <input type="text" id="sector" name="sector" class="form-control fin-input" 
                                       placeholder="e.g. IT, Energy, Banking, Automobile" 
                                       value="<%= isUpdateMode ? updateSector : "" %>" required>
                            </div>

                            <div class="d-flex gap-2 mt-4">
                                <% if (isUpdateMode) { %>
                                    <button type="submit" class="fin-btn fin-btn-primary flex-fill">
                                        <i class="bi bi-check2-circle"></i> Save Updates
                                    </button>
                                    <a href="manage-companies.jsp" class="btn btn-outline-secondary">Cancel</a>
                                <% } else { %>
                                    <button type="submit" class="fin-btn fin-btn-emerald w-100">
                                        <i class="bi bi-plus-lg"></i> Register Company
                                    </button>
                                <% } %>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Table Column -->
            <div class="col-lg-8">
                <div class="fin-card">
                    <div class="fin-card-header">
                        <h5 class="fin-card-title">
                            <i class="bi bi-table text-primary"></i> Registered Companies List
                        </h5>
                        <div class="input-group" style="width: 220px;">
                            <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                            <input type="text" id="compTableSearch" class="form-control form-control-sm border-start-0" placeholder="Filter table...">
                        </div>
                    </div>
                    <div class="fin-card-body p-0">
                        <div class="table-responsive">
                            <table class="fin-table" id="companiesTable">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Company Name</th>
                                        <th class="text-end">Capital (₹)</th>
                                        <th>Sector</th>
                                        <th class="text-center">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        DecimalFormat df = new DecimalFormat("#,##0.00");
                                        Connection conn = null;
                                        Statement st = null;
                                        ResultSet rs = null;
                                        try {
                                            String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                                            String user = "root";
                                            String pass = "trickortreat";
                                            Class.forName("com.mysql.cj.jdbc.Driver");
                                            conn = DriverManager.getConnection(url, user, pass);
                                            st = conn.createStatement();
                                            String sql = "SELECT CID, CNAME, CAPITAL, SECTOR FROM COMPANY ORDER BY CID ASC";
                                            rs = st.executeQuery(sql);

                                            if (!rs.isBeforeFirst()) {
                                                out.println("<tr class='no-data-row'><td colspan='5' class='text-center py-4 text-muted'>No companies found.</td></tr>");
                                            } else {
                                                while (rs.next()) {
                                                    int cid = rs.getInt("CID");
                                                    String cname = rs.getString("CNAME");
                                                    double capital = rs.getDouble("CAPITAL");
                                                    String sector = rs.getString("SECTOR");

                                                    String logo = "generic.svg";
                                                    String lower = cname.toLowerCase();
                                                    if (lower.contains("infosys")) logo = "infosys.svg";
                                                    else if (lower.contains("reliance")) logo = "reliance.svg";
                                                    else if (lower.contains("tata motors")) logo = "tatamotors.svg";
                                                    else if (lower.contains("hdfc")) logo = "hdfc.svg";
                                                    else if (lower.contains("wipro")) logo = "wipro.svg";
                                                    else if (lower.contains("tcs")) logo = "tcs.svg";
                                                    else if (lower.contains("icici")) logo = "icici.svg";
                                                    else if (lower.contains("sbi")) logo = "sbi.svg";
                                    %>
                                    <tr>
                                        <td class="text-mono text-muted">#<%= cid %></td>
                                        <td>
                                            <div class="stock-info">
                                                <img src="Resources/stocks/<%= logo %>" class="stock-logo" style="width: 34px; height: 34px;" alt="<%= cname %>">
                                                <span class="fw-bold"><%= cname %></span>
                                            </div>
                                        </td>
                                        <td class="text-end text-mono fw-bold">₹<%= (capital >= 10000000 ? (df.format(capital / 10000000) + " Cr") : df.format(capital)) %></td>
                                        <td><span class="sector-pill"><%= sector %></span></td>
                                        <td class="text-center">
                                            <a href="manage-companies.jsp?cid=<%= cid %>&action=update" class="btn btn-sm btn-outline-primary me-1">
                                                <i class="bi bi-pencil"></i> Edit
                                            </a>
                                            <button type="button" class="btn btn-sm btn-outline-danger btn-delete-comp" data-id="<%= cid %>">
                                                <i class="bi bi-trash"></i> Delete
                                            </button>
                                        </td>
                                    </tr>
                                    <%
                                                }
                                            }
                                        } catch (Exception e) {
                                            out.println("<tr><td colspan='5' class='text-danger text-center'>Error: " + e.getMessage() + "</td></tr>");
                                        } finally {
                                            try {
                                                if (rs != null) rs.close();
                                                if (st != null) st.close();
                                                if (conn != null) conn.close();
                                            } catch (SQLException e) {
                                                e.printStackTrace();
                                            }
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <% if (!swalStatus.isEmpty()) { %>
            <div id="swalFeedback" 
                 data-status="<%= swalStatus %>" 
                 data-title="<%= swalTitle %>" 
                 data-message="<%= swalMessage %>" 
                 data-redirect="manage-companies.jsp" 
                 style="display:none;"></div>
        <% } %>

    </div>

    <!-- FOOTER -->
    <footer class="fin-footer mt-5">
        <div class="container text-center">
            <p class="mb-1 text-muted">&copy; 2026 Financial Portfolio Management System. All Rights Reserved.</p>
            <p class="small text-secondary mb-0">Company Entity Manager • Connected to MySQL (FINANCIAL_DB)</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="Resources/fintech-charts.js"></script>
    <script>
        FinTechApp.filterTable('compTableSearch', 'companiesTable');

        document.addEventListener('DOMContentLoaded', function () {
            const feedback = document.getElementById('swalFeedback');
            if (feedback) {
                const status = feedback.getAttribute('data-status');
                const title = feedback.getAttribute('data-title');
                const msg = feedback.getAttribute('data-message');
                const redirectUrl = feedback.getAttribute('data-redirect');

                Swal.fire({
                    title: title,
                    text: msg,
                    icon: status
                }).then(() => {
                    if (status === 'success' && redirectUrl) {
                        window.location.href = redirectUrl;
                    }
                });
            }

            document.querySelectorAll('.btn-delete-comp').forEach(btn => {
                btn.addEventListener('click', function () {
                    const id = this.getAttribute('data-id');
                    showDeleteConfirmation(id);
                });
            });

            // Logout handler
            const logoutBtn = document.getElementById('adminLogoutBtn');
            if (logoutBtn) {
                logoutBtn.addEventListener('click', function () {
                    FinTechApp.confirmAction(
                        'Administrator Sign Out',
                        'Are you sure you want to sign out?',
                        'Yes, Sign Out',
                        function () { window.location.href = 'admin-login.jsp'; },
                        'warning'
                    );
                });
            }

            // Company form validation and confirmation
            const form = document.getElementById('companyManageForm');
            if (form) {
                FinTechApp.bindLiveValidation(form);
                form.addEventListener('submit', function (e) {
                    e.preventDefault();
                    const name = document.getElementById('companyName');
                    const cap = document.getElementById('capital');
                    const sec = document.getElementById('sector');

                    FinTechApp.clearError(name);
                    FinTechApp.clearError(cap);
                    FinTechApp.clearError(sec);

                    let isValid = true;
                    if (!name.value.trim() || name.value.trim().length < 2) {
                        FinTechApp.showError(name, 'Company name is required (min 2 characters).');
                        isValid = false;
                    }
                    if (!cap.value || parseFloat(cap.value) <= 0) {
                        FinTechApp.showError(cap, 'Market capitalization must be greater than ₹0.');
                        isValid = false;
                    }
                    if (!sec.value.trim()) {
                        FinTechApp.showError(sec, 'Industry sector is required (e.g. IT, Banking).');
                        isValid = false;
                    }

                    if (isValid) {
                        FinTechApp.confirmAction(
                            'Save Company Profile?',
                            'Are you sure you want to save ' + name.value.trim() + '?',
                            'Yes, Save',
                            function () { form.submit(); },
                            'question'
                        );
                    }
                });
            }
        });

        function showDeleteConfirmation(companyId) {
            Swal.fire({
                title: 'Delete this Company?',
                text: "Deleting this company will cascade to associated reports and transactions!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ef4444',
                cancelButtonColor: '#64748b',
                confirmButtonText: 'Yes, delete entity'
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = "manage-companies.jsp?cid=" + companyId + "&action=delete";
                }
            });
        }
    </script>
</body>
</html>