<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.nio.charset.StandardCharsets"%>

<%!
    public static String hashPassword(String password) {
        if (password == null || password.trim().isEmpty()) return "";
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            return "";
        }
    }

    public static void ensureCustomerSchema(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            try {
                stmt.executeQuery("SELECT CUST_EMAIL FROM USER LIMIT 1");
            } catch (Exception e) {
                try {
                    stmt.executeUpdate("ALTER TABLE USER ADD COLUMN CUST_EMAIL VARCHAR(100) UNIQUE");
                    stmt.executeUpdate("UPDATE USER SET CUST_EMAIL = CONCAT('client_', UID, '@finmanage.com') WHERE CUST_EMAIL IS NULL");
                } catch (Exception ex) {}
            }
            try {
                stmt.executeQuery("SELECT PASSWORD FROM USER LIMIT 1");
            } catch (Exception e) {
                try {
                    stmt.executeUpdate("ALTER TABLE USER ADD COLUMN PASSWORD VARCHAR(255) DEFAULT 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f'");
                } catch (Exception ex) {}
            }
        } catch (Exception e) {}
    }
%>

<%
    String swalStatus = "";
    String swalTitle = "";
    String swalMessage = "";

    // Handle Add User (POST without uid)
    if ("POST".equals(request.getMethod()) && request.getParameter("username") != null && request.getParameter("phone") != null && request.getParameter("uid") == null) {
        String uName = request.getParameter("username").trim();
        String uPhone = request.getParameter("phone").trim();
        String uEmail = request.getParameter("cust_email") != null ? request.getParameter("cust_email").trim().toLowerCase() : "";
        String uPass = request.getParameter("password") != null ? request.getParameter("password").trim() : "password123";

        Connection connIns = null;
        PreparedStatement psIns = null;
        try {
            String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
            String user = "root";
            String pass = "trickortreat";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connIns = DriverManager.getConnection(url, user, pass);
            ensureCustomerSchema(connIns);

            String hashPwd = hashPassword(uPass);
            String sql = "INSERT INTO USER (CUST_EMAIL, USERNAME, PHONE, PASSWORD) VALUES (?, ?, ?, ?)";
            psIns = connIns.prepareStatement(sql);
            psIns.setString(1, uEmail);
            psIns.setString(2, uName);
            psIns.setString(3, uPhone);
            psIns.setString(4, hashPwd);
            int rows = psIns.executeUpdate();
            if (rows > 0) {
                swalStatus = "success";
                swalTitle = "Success";
                swalMessage = "Client registered successfully!";
            } else {
                swalStatus = "error";
                swalTitle = "Failed";
                swalMessage = "Failed to add user.";
            }
        } catch (Exception e) {
            swalStatus = "error";
            swalTitle = "Error";
            swalMessage = e.getMessage();
        } finally {
            if (psIns != null) psIns.close();
            if (connIns != null) connIns.close();
        }
    }

    // Handle Update User (POST with uid)
    if ("POST".equals(request.getMethod()) && request.getParameter("username") != null && request.getParameter("phone") != null && request.getParameter("uid") != null) {
        int pUid = Integer.parseInt(request.getParameter("uid"));
        String uName = request.getParameter("username").trim();
        String uPhone = request.getParameter("phone").trim();
        String uEmail = request.getParameter("cust_email") != null ? request.getParameter("cust_email").trim().toLowerCase() : "";
        String uPass = request.getParameter("password") != null ? request.getParameter("password").trim() : "";

        Connection connUp = null;
        PreparedStatement psUp = null;
        try {
            String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
            String user = "root";
            String pass = "trickortreat";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connUp = DriverManager.getConnection(url, user, pass);
            ensureCustomerSchema(connUp);

            if (!uPass.isEmpty()) {
                String hashPwd = hashPassword(uPass);
                String sql = "UPDATE USER SET USERNAME = ?, PHONE = ?, CUST_EMAIL = ?, PASSWORD = ? WHERE UID = ?";
                psUp = connUp.prepareStatement(sql);
                psUp.setString(1, uName);
                psUp.setString(2, uPhone);
                psUp.setString(3, uEmail);
                psUp.setString(4, hashPwd);
                psUp.setInt(5, pUid);
            } else {
                String sql = "UPDATE USER SET USERNAME = ?, PHONE = ?, CUST_EMAIL = ? WHERE UID = ?";
                psUp = connUp.prepareStatement(sql);
                psUp.setString(1, uName);
                psUp.setString(2, uPhone);
                psUp.setString(3, uEmail);
                psUp.setInt(4, pUid);
            }

            int rows = psUp.executeUpdate();
            if (rows > 0) {
                swalStatus = "success";
                swalTitle = "Success";
                swalMessage = "Client details updated successfully!";
            } else {
                swalStatus = "error";
                swalTitle = "Failed";
                swalMessage = "Failed to update user.";
            }
        } catch (Exception e) {
            swalStatus = "error";
            swalTitle = "Error";
            swalMessage = e.getMessage();
        } finally {
            if (psUp != null) psUp.close();
            if (connUp != null) connUp.close();
        }
    }

    // Handle Delete User (GET with action=delete)
    if ("GET".equals(request.getMethod()) && "delete".equals(request.getParameter("action")) && request.getParameter("uid") != null) {
        int pUid = Integer.parseInt(request.getParameter("uid"));
        Connection connDel = null;
        PreparedStatement psDel = null;
        try {
            String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
            String user = "root";
            String pass = "trickortreat";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connDel = DriverManager.getConnection(url, user, pass);
            String sql = "DELETE FROM USER WHERE UID = ?";
            psDel = connDel.prepareStatement(sql);
            psDel.setInt(1, pUid);
            int rows = psDel.executeUpdate();
            if (rows > 0) {
                swalStatus = "success";
                swalTitle = "Deleted";
                swalMessage = "Client account removed.";
            } else {
                swalStatus = "error";
                swalTitle = "Failed";
                swalMessage = "Failed to delete user.";
            }
        } catch (Exception e) {
            swalStatus = "error";
            swalTitle = "Error";
            swalMessage = e.getMessage();
        } finally {
            if (psDel != null) psDel.close();
            if (connDel != null) connDel.close();
        }
    }

    boolean isUpdateUser = false;
    int updateUid = -1;
    String updateUname = "";
    String updatePhone = "";
    String updateEmail = "";

    // Handle Update View Mode (GET)
    if ("GET".equals(request.getMethod()) && "update".equals(request.getParameter("action")) && request.getParameter("uid") != null) {
        try {
            updateUid = Integer.parseInt(request.getParameter("uid"));
            Connection connGet = null;
            PreparedStatement psGet = null;
            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connGet = DriverManager.getConnection(url, user, pass);
                ensureCustomerSchema(connGet);
                psGet = connGet.prepareStatement("SELECT USERNAME, PHONE, CUST_EMAIL FROM USER WHERE UID = ?");
                psGet.setInt(1, updateUid);
                ResultSet rsGet = psGet.executeQuery();
                if (rsGet.next()) {
                    isUpdateUser = true;
                    updateUname = rsGet.getString("USERNAME");
                    updatePhone = rsGet.getString("PHONE");
                    try {
                        updateEmail = rsGet.getString("CUST_EMAIL");
                    } catch (Exception ex) {}
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
    <title>Manage Users - FinManage Admin</title>
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
                    <span class="fin-brand-sub" style="color: #f59e0b;">SYSTEM ADMIN TERMINAL</span>
                </div>
            </a>
            <button class="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#adminNav">
                <i class="bi bi-list fs-2"></i>
            </button>
            <div class="collapse navbar-collapse" id="adminNav">
                <ul class="navbar-nav ms-auto align-items-center gap-1">
                    <li class="nav-item"><a class="fin-nav-link" href="admin-dashboard.jsp"><i class="bi bi-speedometer2"></i> Overview</a></li>
                    <li class="nav-item"><a class="fin-nav-link active" href="manage-users.jsp"><i class="bi bi-people"></i> Users</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-companies.jsp"><i class="bi bi-buildings"></i> Companies</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-reports.jsp"><i class="bi bi-file-earmark-text"></i> Reports</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-signals.jsp"><i class="bi bi-activity"></i> Signals</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-transactions.jsp"><i class="bi bi-clock-history"></i> Orders</a></li>
                    <li class="nav-item ms-lg-2">
                        <a href="javascript:void(0)" id="adminLogoutBtn" class="fin-btn-logout">
                            <i class="bi bi-box-arrow-right"></i> Logout
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- MAIN BODY -->
    <div class="container-fluid px-lg-4 py-4">

        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
            <div>
                <h3 class="fw-bold mb-1 text-dark">Client Accounts Management</h3>
                <p class="text-muted mb-0 small">Onboard, update, or remove wealth client portfolios and authentication keys.</p>
            </div>
            <div>
                <a href="admin-dashboard.jsp" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left"></i> Back to Console
                </a>
            </div>
        </div>

        <div class="row g-4">
            <!-- Form Column -->
            <div class="col-lg-4">
                <div class="fin-card">
                    <div class="fin-card-header">
                        <h5 class="fin-card-title">
                            <i class="bi <%= isUpdateUser ? "bi-pencil-square text-primary" : "bi-person-plus text-success" %>"></i>
                            <%= isUpdateUser ? "Update Client Details" : "Register New Client" %>
                        </h5>
                    </div>
                    <div class="fin-card-body">
                        <form id="userManageForm" action="manage-users.jsp" method="POST" novalidate>
                            <% if (isUpdateUser) { %>
                                <input type="hidden" name="uid" id="formUid" value="<%= updateUid %>">
                                <div class="mb-3">
                                    <label class="form-label small fw-semibold text-secondary">Account UID</label>
                                    <input type="text" class="form-control fin-input" value="#<%= updateUid %>" disabled readonly>
                                </div>
                            <% } %>

                            <div class="mb-3">
                                <label for="username" class="form-label small fw-semibold text-secondary">Client Full Name</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="bi bi-person"></i></span>
                                    <input type="text" class="form-control fin-input" id="username" name="username" 
                                           placeholder="e.g. Ramesh Patel" value="<%= isUpdateUser ? updateUname : "" %>" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="cust_email" class="form-label small fw-semibold text-secondary">Email Address (Primary Key)</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="bi bi-envelope"></i></span>
                                    <input type="email" class="form-control fin-input" id="cust_email" name="cust_email" 
                                           placeholder="e.g. ramesh.patel@gmail.com" value="<%= isUpdateUser ? updateEmail : "" %>" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="phone" class="form-label small fw-semibold text-secondary">Phone Number (10 Digits)</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="bi bi-telephone"></i></span>
                                    <input type="tel" class="form-control fin-input" id="phone" name="phone" 
                                           placeholder="e.g. 9876543210" maxlength="10" value="<%= isUpdateUser ? updatePhone : "" %>" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="password" class="form-label small fw-semibold text-secondary">
                                    Password <%= isUpdateUser ? "(Leave blank to keep current)" : "" %>
                                </label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light"><i class="bi bi-key"></i></span>
                                    <input type="password" class="form-control fin-input" id="password" name="password" 
                                           placeholder="<%= isUpdateUser ? "••••••••" : "Min 6 characters" %>" <%= isUpdateUser ? "" : "required" %>>
                                </div>
                            </div>

                            <div class="d-flex gap-2 mt-4">
                                <% if (isUpdateUser) { %>
                                    <button type="submit" class="fin-btn fin-btn-primary flex-grow-1">
                                        <i class="bi bi-check2"></i> Save Client Changes
                                    </button>
                                    <a href="manage-users.jsp" class="btn btn-outline-secondary">Cancel</a>
                                <% } else { %>
                                    <button type="submit" class="fin-btn fin-btn-emerald w-100">
                                        <i class="bi bi-person-plus-fill"></i> Add Client Account
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
                            <i class="bi bi-table text-primary"></i> Client User Registry
                        </h5>
                        <div class="input-group" style="width: 220px;">
                            <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                            <input type="text" id="userTableSearch" class="form-control form-control-sm border-start-0" placeholder="Filter table...">
                        </div>
                    </div>
                    <div class="fin-card-body p-0">
                        <div class="table-responsive">
                            <table class="fin-table" id="usersTable">
                                <thead>
                                    <tr>
                                        <th>Account UID</th>
                                        <th>Client Name</th>
                                        <th>Email (PK)</th>
                                        <th>Phone Number</th>
                                        <th class="text-center">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        Connection conn = null;
                                        Statement st = null;
                                        ResultSet rs = null;
                                        try {
                                            String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                                            String user = "root";
                                            String pass = "trickortreat";
                                            Class.forName("com.mysql.cj.jdbc.Driver");
                                            conn = DriverManager.getConnection(url, user, pass);
                                            ensureCustomerSchema(conn);
                                            st = conn.createStatement();
                                            String sql = "SELECT UID, CUST_EMAIL, USERNAME, PHONE FROM USER ORDER BY UID ASC";
                                            rs = st.executeQuery(sql);

                                            if (!rs.isBeforeFirst()) {
                                                out.println("<tr class='no-data-row'><td colspan='5' class='text-center py-4 text-muted'>No user accounts found.</td></tr>");
                                            } else {
                                                while (rs.next()) {
                                                    int uId = rs.getInt("UID");
                                                    String uName = rs.getString("USERNAME");
                                                    String uPhone = rs.getString("PHONE");
                                                    String uEmail = rs.getString("CUST_EMAIL");
                                                    if (uEmail == null) uEmail = "N/A";
                                    %>
                                    <tr>
                                        <td class="text-mono text-muted">#<%= uId %></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="fin-user-avatar" style="width: 32px; height: 32px; font-size: 0.8rem;">
                                                    <%= uName.length() > 0 ? uName.substring(0, 1).toUpperCase() : "U" %>
                                                </div>
                                                <span class="fw-bold"><%= uName %></span>
                                            </div>
                                        </td>
                                        <td class="text-mono text-primary small"><%= uEmail %></td>
                                        <td class="text-mono"><%= uPhone %></td>
                                        <td class="text-center">
                                            <a href="manage-users.jsp?uid=<%= uId %>&action=update" class="btn btn-sm btn-outline-primary me-1">
                                                <i class="bi bi-pencil"></i> Edit
                                            </a>
                                            <button type="button" class="btn btn-sm btn-outline-danger btn-delete-user" data-id="<%= uId %>">
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
                 data-redirect="manage-users.jsp" 
                 style="display:none;"></div>
        <% } %>

    </div>

    <!-- FOOTER -->
    <footer class="fin-footer mt-5">
        <div class="container text-center">
            <p class="mb-1 text-muted">&copy; 2026 Financial Portfolio Management System. All Rights Reserved.</p>
            <p class="small text-secondary mb-0">Client User Registry Manager • Connected to MySQL (FINANCIAL_DB)</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="Resources/fintech-charts.js"></script>
    <script>
        FinTechApp.filterTable('userTableSearch', 'usersTable');

        document.addEventListener('DOMContentLoaded', function () {
            // Logout confirmation
            const logoutBtn = document.getElementById('adminLogoutBtn');
            if (logoutBtn) {
                logoutBtn.addEventListener('click', function () {
                    FinTechApp.confirmAction(
                        'Administrator Sign Out',
                        'Are you sure you want to exit the Administrator Console?',
                        'Yes, Sign Out',
                        function () {
                            window.location.href = 'admin-login.jsp';
                        },
                        'warning'
                    );
                });
            }

            // Delete confirmation handlers
            document.querySelectorAll('.btn-delete-user').forEach(btn => {
                btn.addEventListener('click', function () {
                    const id = this.getAttribute('data-id');
                    showDeleteConfirmation(id);
                });
            });

            // Form validation and confirmation
            const form = document.getElementById('userManageForm');
            if (form) {
                FinTechApp.bindLiveValidation(form);
                form.addEventListener('submit', function (e) {
                    e.preventDefault();
                    const name = document.getElementById('username');
                    const email = document.getElementById('cust_email');
                    const phone = document.getElementById('phone');
                    const pwd = document.getElementById('password');
                    const isUpdate = document.getElementById('formUid') !== null;

                    FinTechApp.clearError(name);
                    FinTechApp.clearError(email);
                    FinTechApp.clearError(phone);
                    FinTechApp.clearError(pwd);

                    let isValid = true;
                    if (!name.value.trim() || name.value.trim().length < 3) {
                        FinTechApp.showError(name, 'Full Name is required (min 3 characters).');
                        isValid = false;
                    }
                    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    if (!email.value.trim() || !emailRegex.test(email.value.trim())) {
                        FinTechApp.showError(email, 'Please enter a valid email address.');
                        isValid = false;
                    }
                    const phoneRegex = /^[0-9]{10}$/;
                    if (!phone.value.trim() || !phoneRegex.test(phone.value.trim())) {
                        FinTechApp.showError(phone, 'Phone number must be exactly 10 digits.');
                        isValid = false;
                    }
                    if (!isUpdate && (!pwd.value || pwd.value.length < 6)) {
                        FinTechApp.showError(pwd, 'Password is required (min 6 characters).');
                        isValid = false;
                    }

                    if (isValid) {
                        FinTechApp.confirmAction(
                            isUpdate ? 'Save Client Changes?' : 'Register Client Account?',
                            'Are you sure you want to ' + (isUpdate ? 'update' : 'create') + ' the account for ' + name.value.trim() + '?',
                            'Yes, Proceed',
                            function () {
                                form.submit();
                            },
                            'question'
                        );
                    }
                });
            }

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
        });

        function showDeleteConfirmation(uid) {
            Swal.fire({
                title: 'Delete this User Account?',
                text: "Deleting this client will cascade to their transactions!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ef4444',
                cancelButtonColor: '#64748b',
                confirmButtonText: 'Yes, delete user'
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = "manage-users.jsp?uid=" + uid + "&action=delete";
                }
            });
        }
    </script>
</body>
</html>