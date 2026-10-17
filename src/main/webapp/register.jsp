<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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

    // Auto-migration helper to ensure CUST_EMAIL and PASSWORD columns exist
    public static void ensureCustomerSchema(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            try {
                stmt.executeQuery("SELECT CUST_EMAIL FROM USER LIMIT 1");
            } catch (Exception e) {
                try {
                    stmt.executeUpdate("ALTER TABLE USER ADD COLUMN CUST_EMAIL VARCHAR(100) UNIQUE");
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
    String username = request.getParameter("username");
    String custEmail = request.getParameter("cust_email");
    String phone = request.getParameter("phone");
    String password = request.getParameter("password");
    String errorMessage = "";
    int generatedUserId = -1;
    String registeredEmail = "";

    if (username != null && custEmail != null && phone != null && password != null) {
        username = username.trim();
        custEmail = custEmail.trim().toLowerCase();
        phone = phone.trim();
        password = password.trim();

        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement insertStmt = null;
        ResultSet rsCheck = null;
        ResultSet rsKey = null;

        try {
            String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
            String user = "root";
            String pass = "trickortreat";
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, pass);

            ensureCustomerSchema(conn);

            // Check if email already registered
            String checkSql = "SELECT CUST_EMAIL FROM USER WHERE LOWER(CUST_EMAIL) = LOWER(?)";
            checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, custEmail);
            rsCheck = checkStmt.executeQuery();

            if (rsCheck.next()) {
                errorMessage = "An account with the email '" + custEmail + "' already exists. Please log in.";
            } else {
                String hashedPassword = hashPassword(password);
                String insertSql = "INSERT INTO USER (CUST_EMAIL, USERNAME, PHONE, PASSWORD) VALUES (?, ?, ?, ?)";
                insertStmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
                insertStmt.setString(1, custEmail);
                insertStmt.setString(2, username);
                insertStmt.setString(3, phone);
                insertStmt.setString(4, hashedPassword);
                int rows = insertStmt.executeUpdate();

                if (rows > 0) {
                    rsKey = insertStmt.getGeneratedKeys();
                    if (rsKey.next()) {
                        generatedUserId = rsKey.getInt(1);
                    } else {
                        // Fallback lookup
                        PreparedStatement getUid = conn.prepareStatement("SELECT UID FROM USER WHERE CUST_EMAIL = ?");
                        getUid.setString(1, custEmail);
                        ResultSet rsUid = getUid.executeQuery();
                        if (rsUid.next()) {
                            generatedUserId = rsUid.getInt("UID");
                        }
                        rsUid.close();
                        getUid.close();
                    }
                    registeredEmail = custEmail;
                } else {
                    errorMessage = "Failed to create account. Please try again.";
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            errorMessage = "Database Error: " + e.getMessage();
        } finally {
            try {
                if (rsKey != null) rsKey.close();
                if (rsCheck != null) rsCheck.close();
                if (checkStmt != null) checkStmt.close();
                if (insertStmt != null) insertStmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Open Account - Financial Portfolio Management</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,400&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="Resources/fintech-theme.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body class="fin-auth-container">

    <div class="fin-auth-card" style="max-width: 520px;">
        <!-- Logo & Header -->
        <div class="text-center mb-4">
            <a href="index.jsp" class="fin-brand justify-content-center mb-3">
                <div class="fin-brand-logo">
                    <i class="bi bi-graph-up-arrow"></i>
                </div>
                <div class="fin-brand-name text-start">
                    <span class="text-dark">FinManage</span>
                    <span class="fin-brand-sub" style="color: #10b981;">NEW CLIENT REGISTRATION</span>
                </div>
            </a>
            <h4 class="fw-bold text-dark mt-2">Open Portfolio Account</h4>
            <p class="text-muted small">Register your investor profile to begin managing equities and orders.</p>
        </div>

        <% if (generatedUserId != -1) { %>
            <div id="regSuccess" data-uid="<%= generatedUserId %>" data-email="<%= registeredEmail %>" style="display:none;"></div>
        <% } %>

        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger py-2 small mb-3">
                <i class="bi bi-exclamation-triangle-fill me-1"></i> <%= errorMessage %>
            </div>
        <% } %>

        <!-- Registration Form -->
        <form id="registerForm" action="register.jsp" method="POST" novalidate>
            <div class="mb-3">
                <label for="username" class="form-label fw-semibold small text-secondary">
                    <i class="bi bi-person-fill text-primary me-1"></i> Full Name
                </label>
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-person"></i></span>
                    <input type="text" class="form-control fin-input border-start-0" id="username" name="username" 
                           placeholder="e.g. Ramesh Patel" value="<%= username != null ? username : "" %>" required>
                </div>
            </div>

            <div class="mb-3">
                <label for="cust_email" class="form-label fw-semibold small text-secondary">
                    <i class="bi bi-envelope-at-fill text-primary me-1"></i> Email Address (Primary Login ID)
                </label>
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-envelope"></i></span>
                    <input type="email" class="form-control fin-input border-start-0" id="cust_email" name="cust_email" 
                           placeholder="e.g. ramesh.patel@gmail.com" value="<%= custEmail != null ? custEmail : "" %>" required>
                </div>
            </div>

            <div class="mb-3">
                <label for="phone" class="form-label fw-semibold small text-secondary">
                    <i class="bi bi-telephone-fill text-primary me-1"></i> Phone Number (10 Digits)
                </label>
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-phone"></i></span>
                    <input type="tel" class="form-control fin-input border-start-0" id="phone" name="phone" 
                           placeholder="e.g. 9876543210" maxlength="10" value="<%= phone != null ? phone : "" %>" required>
                </div>
            </div>

            <div class="row g-2 mb-3">
                <div class="col-md-6">
                    <label for="password" class="form-label fw-semibold small text-secondary">
                        <i class="bi bi-lock-fill text-primary me-1"></i> Password
                    </label>
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-key"></i></span>
                        <input type="password" class="form-control fin-input border-start-0" id="password" name="password" 
                               placeholder="Min 6 characters" required>
                    </div>
                </div>
                <div class="col-md-6">
                    <label for="confirmPassword" class="form-label fw-semibold small text-secondary">
                        <i class="bi bi-shield-check text-primary me-1"></i> Confirm Password
                    </label>
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-check2-circle"></i></span>
                        <input type="password" class="form-control fin-input border-start-0" id="confirmPassword" name="confirmPassword" 
                               placeholder="Re-enter password" required>
                    </div>
                </div>
            </div>

            <button type="submit" id="regSubmitBtn" class="fin-btn fin-btn-emerald w-100 py-3 mt-2">
                <i class="bi bi-person-check-fill me-1"></i> Create Investor Account
            </button>
        </form>

        <!-- Links Footer -->
        <div class="text-center mt-4 pt-3 border-top">
            <p class="text-muted small mb-2">
                Already registered? <a href="login.jsp" class="fw-bold text-primary text-decoration-none">Sign In Here</a>
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
        const form = document.getElementById('registerForm');
        const nameInput = document.getElementById('username');
        const emailInput = document.getElementById('cust_email');
        const phoneInput = document.getElementById('phone');
        const pwdInput = document.getElementById('password');
        const cpwdInput = document.getElementById('confirmPassword');

        FinTechApp.bindLiveValidation(form);

        document.addEventListener('DOMContentLoaded', function () {
            const regElem = document.getElementById('regSuccess');
            if (regElem) {
                const uid = regElem.getAttribute('data-uid');
                const email = regElem.getAttribute('data-email');
                Swal.fire({
                    title: 'Account Registered Successfully!',
                    html: '<p class="text-muted mb-2">Your investor profile has been created.</p>' +
                          '<div class="p-3 bg-light rounded text-start mb-3">' +
                          '<div><strong>Login Email:</strong> <span class="text-primary">' + email + '</span></div>' +
                          '<div><strong>Account UID:</strong> <span class="text-mono fw-bold">#' + uid + '</span></div>' +
                          '</div>' +
                          '<p class="small text-secondary mb-0">Use your email and password to access your terminal.</p>',
                    icon: 'success',
                    confirmButtonColor: '#10b981',
                    confirmButtonText: 'Proceed to Sign In'
                }).then(() => {
                    window.location.href = 'login.jsp';
                });
            }
        });

        function validateForm() {
            let isValid = true;
            FinTechApp.clearError(nameInput);
            FinTechApp.clearError(emailInput);
            FinTechApp.clearError(phoneInput);
            FinTechApp.clearError(pwdInput);
            FinTechApp.clearError(cpwdInput);

            const nameVal = nameInput.value.trim();
            if (!nameVal) {
                FinTechApp.showError(nameInput, 'Full Name is required.');
                isValid = false;
            } else if (nameVal.length < 3) {
                FinTechApp.showError(nameInput, 'Name must be at least 3 characters.');
                isValid = false;
            }

            const emailVal = emailInput.value.trim();
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailVal) {
                FinTechApp.showError(emailInput, 'Email Address is required.');
                isValid = false;
            } else if (!emailRegex.test(emailVal)) {
                FinTechApp.showError(emailInput, 'Please enter a valid email address (e.g., name@domain.com).');
                isValid = false;
            }

            const phoneVal = phoneInput.value.trim();
            const phoneRegex = /^[0-9]{10}$/;
            if (!phoneVal) {
                FinTechApp.showError(phoneInput, 'Phone number is required.');
                isValid = false;
            } else if (!phoneRegex.test(phoneVal)) {
                FinTechApp.showError(phoneInput, 'Phone number must be exactly 10 digits.');
                isValid = false;
            }

            const pwdVal = pwdInput.value;
            if (!pwdVal) {
                FinTechApp.showError(pwdInput, 'Password is required.');
                isValid = false;
            } else if (pwdVal.length < 6) {
                FinTechApp.showError(pwdInput, 'Password must be at least 6 characters long.');
                isValid = false;
            }

            const cpwdVal = cpwdInput.value;
            if (!cpwdVal) {
                FinTechApp.showError(cpwdInput, 'Please confirm your password.');
                isValid = false;
            } else if (pwdVal !== cpwdVal) {
                FinTechApp.showError(cpwdInput, 'Passwords do not match.');
                isValid = false;
            }

            return isValid;
        }

        form.addEventListener('submit', function (e) {
            e.preventDefault();
            if (validateForm()) {
                FinTechApp.confirmAction(
                    'Are you sure?',
                    'Do you want to create an account for ' + nameInput.value.trim() + '?',
                    'Yes, Register',
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