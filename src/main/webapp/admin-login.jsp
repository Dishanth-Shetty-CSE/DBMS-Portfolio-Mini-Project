<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.nio.charset.StandardCharsets"%>

<%!
    // SHA-256 password hashing helper
    public static String hashPassword(String password) {
        if (password == null) return "";
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

    // Auto-migration helper to ensure ADMIN_EMAIL and PASSWORD columns exist
    public static void ensureAdminSchema(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            try {
                stmt.executeQuery("SELECT ADMIN_EMAIL FROM ADMIN LIMIT 1");
            } catch (Exception e) {
                try {
                    stmt.executeUpdate("ALTER TABLE ADMIN ADD COLUMN ADMIN_EMAIL VARCHAR(100) UNIQUE");
                    stmt.executeUpdate("UPDATE ADMIN SET ADMIN_EMAIL = 'admin@portfolio.com' WHERE ADMIN_EMAIL IS NULL");
                } catch (Exception ex) {}
            }
            try {
                stmt.executeQuery("SELECT PASSWORD FROM ADMIN LIMIT 1");
            } catch (Exception e) {
                try {
                    stmt.executeUpdate("ALTER TABLE ADMIN ADD COLUMN PASSWORD VARCHAR(255) DEFAULT 'e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7'");
                } catch (Exception ex) {}
            }
        } catch (Exception e) {}
    }
%>

<%
    String adminEmail = request.getParameter("adminEmail");
    String password = request.getParameter("password");
    String emailError = "";
    String passwordError = "";
    String generalError = "";
    boolean loginSuccess = false;

    if (adminEmail != null && password != null) {
        adminEmail = adminEmail.trim();
        password = password.trim();

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
            String user = "root";
            String pass = "trickortreat";
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, pass);

            ensureAdminSchema(conn);

            String hashedInput = hashPassword(password);

            String sql = "SELECT ADMINID, ADMIN_EMAIL, ADMINNAME, PASSWORD FROM ADMIN WHERE LOWER(ADMIN_EMAIL) = LOWER(?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, adminEmail);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("PASSWORD");
                if (storedHash != null && storedHash.equalsIgnoreCase(hashedInput)) {
                    session.setAttribute("loggedInAdminId", rs.getInt("ADMINID"));
                    session.setAttribute("loggedInAdminEmail", rs.getString("ADMIN_EMAIL"));
                    session.setAttribute("loggedInAdminName", rs.getString("ADMINNAME"));
                    loginSuccess = true;
                } else {
                    passwordError = "Incorrect administrator password. Access denied.";
                }
            } else {
                emailError = "Invalid administrative email. Record not found.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            generalError = "Database Error: " + e.getMessage();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    if (loginSuccess) {
        response.sendRedirect("admin-dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrator Sign In - Financial Portfolio Management</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,400&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="Resources/fintech-theme.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body class="fin-auth-container" style="background: radial-gradient(circle at top center, #1e1b4b 0%, #0a192f 60%, #060d1b 100%);">

    <div class="fin-auth-card">
        <!-- Logo & Header -->
        <div class="text-center mb-4">
            <a href="index.jsp" class="fin-brand justify-content-center mb-3">
                <div class="fin-brand-logo" style="background: linear-gradient(135deg, #f59e0b, #d97706);">
                    <i class="bi bi-shield-lock-fill"></i>
                </div>
                <div class="fin-brand-name text-start">
                    <span class="text-dark">FinManage</span>
                    <span class="fin-brand-sub" style="color: #f59e0b;">SYSTEM CONTROL CENTER</span>
                </div>
            </a>
            <h4 class="fw-bold text-dark mt-2">Administrator Sign In</h4>
            <p class="text-muted small">Enter master credentials to access the administrative control center.</p>
        </div>

        <% if (!generalError.isEmpty()) { %>
            <div class="alert alert-danger py-2 small mb-3">
                <i class="bi bi-exclamation-triangle-fill me-1"></i> <%= generalError %>
            </div>
        <% } %>

        <!-- Login Form -->
        <form id="adminLoginForm" action="admin-login.jsp" method="POST" novalidate>
            <div class="mb-3">
                <label for="adminEmail" class="form-label fw-semibold small text-secondary">
                    <i class="bi bi-shield-check text-warning me-1"></i> Administrator Email
                </label>
                <div class="input-group <%= !emailError.isEmpty() ? "is-invalid" : "" %>">
                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-envelope-at"></i></span>
                    <input type="email" id="adminEmail" name="adminEmail" 
                           class="form-control fin-input border-start-0 <%= !emailError.isEmpty() ? "is-invalid" : "" %>" 
                           placeholder="e.g. admin@portfolio.com" 
                           value="<%= (adminEmail != null) ? adminEmail : "" %>" required>
                </div>
                <% if (!emailError.isEmpty()) { %>
                    <div class="fin-field-error">
                        <i class="bi bi-exclamation-circle-fill"></i> <%= emailError %>
                    </div>
                <% } %>
            </div>

            <div class="mb-3">
                <label for="password" class="form-label fw-semibold small text-secondary">
                    <i class="bi bi-key-fill text-warning me-1"></i> Master Password
                </label>
                <div class="input-group <%= !passwordError.isEmpty() ? "is-invalid" : "" %>">
                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-lock"></i></span>
                    <input type="password" id="password" name="password" 
                           class="form-control fin-input border-start-0 <%= !passwordError.isEmpty() ? "is-invalid" : "" %>" 
                           placeholder="••••••••" required>
                </div>
                <% if (!passwordError.isEmpty()) { %>
                    <div class="fin-field-error">
                        <i class="bi bi-exclamation-circle-fill"></i> <%= passwordError %>
                    </div>
                <% } %>
            </div>

            <button type="submit" id="adminSubmitBtn" class="fin-btn w-100 py-3 mt-3 text-white" 
                    style="background: linear-gradient(135deg, #d97706, #b45309); box-shadow: 0 4px 12px rgba(217, 119, 6, 0.3);">
                <i class="bi bi-shield-lock me-1"></i> Access Master Terminal
            </button>
        </form>

        <!-- Links Footer -->
        <div class="text-center mt-4 pt-3 border-top">
            <div class="d-flex justify-content-center gap-3 small">
                <a href="index.jsp" class="text-secondary text-decoration-none"><i class="bi bi-house me-1"></i>Home</a>
                <span class="text-muted">•</span>
                <a href="login.jsp" class="text-primary text-decoration-none"><i class="bi bi-box-arrow-in-right me-1"></i>Client Login</a>
            </div>
        </div>
    </div>

    <script src="Resources/fintech-charts.js"></script>
    <script>
        const form = document.getElementById('adminLoginForm');
        const emailInput = document.getElementById('adminEmail');
        const pwdInput = document.getElementById('password');

        FinTechApp.bindLiveValidation(form);

        function validateAdminForm() {
            let isValid = true;
            FinTechApp.clearError(emailInput);
            FinTechApp.clearError(pwdInput);

            const emailVal = emailInput.value.trim();
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailVal) {
                FinTechApp.showError(emailInput, 'Admin email address is required.');
                isValid = false;
            } else if (!emailRegex.test(emailVal)) {
                FinTechApp.showError(emailInput, 'Please enter a valid administrative email.');
                isValid = false;
            }

            const pwdVal = pwdInput.value;
            if (!pwdVal) {
                FinTechApp.showError(pwdInput, 'Password is required.');
                isValid = false;
            }

            return isValid;
        }

        form.addEventListener('submit', function (e) {
            e.preventDefault();
            if (validateAdminForm()) {
                FinTechApp.confirmAction(
                    'Administrator Verification',
                    'Are you sure you want to log in to the System Control Center?',
                    'Yes, Sign In',
                    function () {
                        form.submit();
                    },
                    'warning'
                );
            }
        });
    </script>
</body>
</html>
