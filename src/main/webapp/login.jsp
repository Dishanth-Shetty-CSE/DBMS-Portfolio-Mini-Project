<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.nio.charset.StandardCharsets"%>

<%!
    // Secure SHA-256 password hashing helper
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

    // Auto-migration helper to ensure CUST_EMAIL and PASSWORD columns exist seamlessly
    public static void ensureCustomerSchema(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            try {
                stmt.executeQuery("SELECT CUST_EMAIL FROM USER LIMIT 1");
            } catch (Exception e) {
                try {
                    stmt.executeUpdate("ALTER TABLE USER ADD COLUMN CUST_EMAIL VARCHAR(100) UNIQUE");
                    stmt.executeUpdate("UPDATE USER SET CUST_EMAIL = CONCAT('client_', UID, '@portfolio.com') WHERE CUST_EMAIL IS NULL");
                } catch (Exception ex) {}
            }
            try {
                stmt.executeQuery("SELECT PASSWORD FROM USER LIMIT 1");
            } catch (Exception e) {
                try {
                    stmt.executeUpdate("ALTER TABLE USER ADD COLUMN PASSWORD VARCHAR(255) DEFAULT 'a01649699f5501489183d6c9b83d503699fe17329dcfc733f52d83aa58befcfc'");
                } catch (Exception ex) {}
            }
        } catch (Exception e) {}
    }
%>

<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String emailError = "";
    String passwordError = "";
    String generalError = "";
    boolean loginSuccess = false;

    if (email != null && password != null) {
        email = email.trim();
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

            ensureCustomerSchema(conn);

            String hashedInput = hashPassword(password);

            // Authenticate by CUST_EMAIL and SHA-256 HASHED PASSWORD
            String sql = "SELECT UID, CUST_EMAIL, USERNAME, PASSWORD FROM USER WHERE LOWER(CUST_EMAIL) = LOWER(?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("PASSWORD");
                if (storedHash != null && storedHash.equalsIgnoreCase(hashedInput)) {
                    // Password matches
                    session.setAttribute("loggedInUserId", rs.getInt("UID"));
                    session.setAttribute("loggedInUserEmail", rs.getString("CUST_EMAIL"));
                    session.setAttribute("loggedInUserName", rs.getString("USERNAME"));
                    loginSuccess = true;
                } else {
                    passwordError = "Incorrect password. Please verify and try again.";
                }
            } else {
                emailError = "No client account found registered with this email.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            generalError = "Database Connection Error: " + e.getMessage();
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
        response.sendRedirect("customer-dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Client Sign In - Financial Portfolio Management</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,400&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="Resources/fintech-theme.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body class="fin-auth-container">

    <div class="fin-auth-card">
        <!-- Logo & Header -->
        <div class="text-center mb-4">
            <a href="index.jsp" class="fin-brand justify-content-center mb-3">
                <div class="fin-brand-logo">
                    <i class="bi bi-graph-up-arrow"></i>
                </div>
                <div class="fin-brand-name text-start">
                    <span class="text-dark">FinManage</span>
                    <span class="fin-brand-sub" style="color: #0284c7;">WEALTH CLIENT PORTAL</span>
                </div>
            </a>
            <h4 class="fw-bold text-dark mt-2">Welcome Back</h4>
            <p class="text-muted small">Sign in using your registered email and secure password.</p>
        </div>

        <% if (!generalError.isEmpty()) { %>
            <div class="alert alert-danger py-2 small mb-3">
                <i class="bi bi-exclamation-triangle-fill me-1"></i> <%= generalError %>
            </div>
        <% } %>

        <!-- Login Form -->
        <form id="clientLoginForm" action="login.jsp" method="POST" novalidate>
            <div class="mb-3">
                <label for="email" class="form-label fw-semibold small text-secondary">
                    <i class="bi bi-envelope-at text-primary me-1"></i> Email Address
                </label>
                <div class="input-group <%= !emailError.isEmpty() ? "is-invalid" : "" %>">
                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-envelope"></i></span>
                    <input type="email" id="email" name="email" 
                           class="form-control fin-input border-start-0 <%= !emailError.isEmpty() ? "is-invalid" : "" %>" 
                           placeholder="e.g. ravi.kumar@portfolio.com" 
                           value="<%= (email != null) ? email : "" %>" required>
                </div>
                <% if (!emailError.isEmpty()) { %>
                    <div class="fin-field-error">
                        <i class="bi bi-exclamation-circle-fill"></i> <%= emailError %>
                    </div>
                <% } %>
            </div>

            <div class="mb-3">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <label for="password" class="form-label fw-semibold small text-secondary mb-0">
                        <i class="bi bi-shield-lock text-primary me-1"></i> Password
                    </label>
                </div>
                <div class="input-group <%= !passwordError.isEmpty() ? "is-invalid" : "" %>">
                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-key"></i></span>
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

            <button type="submit" id="submitBtn" class="fin-btn fin-btn-primary w-100 py-3 mt-3">
                <i class="bi bi-box-arrow-in-right me-1"></i> Access Portfolio Terminal
            </button>
        </form>

        <!-- Links Footer -->
        <div class="text-center mt-4 pt-3 border-top">
            <p class="text-muted small mb-2">
                New investor? <a href="register.jsp" class="fw-bold text-primary text-decoration-none">Open an Account</a>
            </p>
            <div class="d-flex justify-content-center gap-3 small">
                <a href="index.jsp" class="text-secondary text-decoration-none"><i class="bi bi-house me-1"></i>Home</a>
                <span class="text-muted">•</span>
                <a href="admin-login.jsp" class="text-warning text-decoration-none"><i class="bi bi-shield-lock me-1"></i>Admin Portal</a>
            </div>
        </div>
    </div>

    <script src="Resources/fintech-charts.js"></script>
    <script>
        const form = document.getElementById('clientLoginForm');
        const emailInput = document.getElementById('email');
        const pwdInput = document.getElementById('password');

        FinTechApp.bindLiveValidation(form);

        function validateForm() {
            let isValid = true;
            FinTechApp.clearError(emailInput);
            FinTechApp.clearError(pwdInput);

            const emailVal = emailInput.value.trim();
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailVal) {
                FinTechApp.showError(emailInput, 'Email address is required.');
                isValid = false;
            } else if (!emailRegex.test(emailVal)) {
                FinTechApp.showError(emailInput, 'Please enter a valid email address (e.g., name@domain.com).');
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
            if (validateForm()) {
                FinTechApp.confirmAction(
                    'Are you sure?',
                    'Do you want to sign in with ' + emailInput.value.trim() + '?',
                    'Yes, Sign In',
                    function () {
                        form.submit();
                    },
                    'question'
                );
            }
        });
    </script>
</body>
</html>
