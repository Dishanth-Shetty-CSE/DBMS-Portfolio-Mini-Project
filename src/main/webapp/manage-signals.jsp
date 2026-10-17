<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    String swalStatus = "";
    String swalTitle = "";
    String swalMessage = "";

    // Handle Add Signal (POST without stock_id)
    if ("POST".equals(request.getMethod()) && request.getParameter("adx") != null && request.getParameter("volume") != null && request.getParameter("macd") != null && request.getParameter("cid") != null && request.getParameter("stock_id") == null) {
        try {
            double adx = Double.parseDouble(request.getParameter("adx"));
            int volume = Integer.parseInt(request.getParameter("volume"));
            double macd = Double.parseDouble(request.getParameter("macd"));
            int cid = Integer.parseInt(request.getParameter("cid"));

            Connection connIns = null;
            PreparedStatement psIns = null;
            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connIns = DriverManager.getConnection(url, user, pass);
                String sql = "INSERT INTO TECHNICAL_SIGNALS (ADX, VOLUME, MACD, CID) VALUES (?, ?, ?, ?)";
                psIns = connIns.prepareStatement(sql);
                psIns.setDouble(1, adx);
                psIns.setInt(2, volume);
                psIns.setDouble(3, macd);
                psIns.setInt(4, cid);
                int rows = psIns.executeUpdate();
                if (rows > 0) {
                    swalStatus = "success";
                    swalTitle = "Success";
                    swalMessage = "Technical signal registered successfully!";
                } else {
                    swalStatus = "error";
                    swalTitle = "Failed";
                    swalMessage = "Failed to register signal.";
                }
            } catch (Exception e) {
                swalStatus = "error";
                swalTitle = "Error";
                swalMessage = e.getMessage();
            } finally {
                if (psIns != null) psIns.close();
                if (connIns != null) connIns.close();
            }
        } catch(NumberFormatException e) {
            swalStatus = "error";
            swalTitle = "Invalid Format";
            swalMessage = "Invalid numerical format in inputs.";
        }
    }

    // Handle Update Signal (POST with stock_id)
    if ("POST".equals(request.getMethod()) && request.getParameter("adx") != null && request.getParameter("volume") != null && request.getParameter("macd") != null && request.getParameter("cid") != null && request.getParameter("stock_id") != null) {
        try {
            int stockId = Integer.parseInt(request.getParameter("stock_id"));
            double adx = Double.parseDouble(request.getParameter("adx"));
            int volume = Integer.parseInt(request.getParameter("volume"));
            double macd = Double.parseDouble(request.getParameter("macd"));
            int cid = Integer.parseInt(request.getParameter("cid"));

            Connection connUp = null;
            PreparedStatement psUp = null;
            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connUp = DriverManager.getConnection(url, user, pass);
                String sql = "UPDATE TECHNICAL_SIGNALS SET ADX = ?, VOLUME = ?, MACD = ?, CID = ? WHERE STOCK_ID = ?";
                psUp = connUp.prepareStatement(sql);
                psUp.setDouble(1, adx);
                psUp.setInt(2, volume);
                psUp.setDouble(3, macd);
                psUp.setInt(4, cid);
                psUp.setInt(5, stockId);
                int rows = psUp.executeUpdate();
                if (rows > 0) {
                    swalStatus = "success";
                    swalTitle = "Success";
                    swalMessage = "Signal updated successfully!";
                } else {
                    swalStatus = "error";
                    swalTitle = "Failed";
                    swalMessage = "Failed to update signal.";
                }
            } catch (Exception e) {
                swalStatus = "error";
                swalTitle = "Error";
                swalMessage = e.getMessage();
            } finally {
                if (psUp != null) psUp.close();
                if (connUp != null) connUp.close();
            }
        } catch(NumberFormatException e) {
            swalStatus = "error";
            swalTitle = "Invalid Format";
            swalMessage = "Invalid numerical format in inputs.";
        }
    }

    // Handle Delete Signal (GET with action=delete)
    if ("GET".equals(request.getMethod()) && "delete".equals(request.getParameter("action")) && request.getParameter("stock_id") != null) {
        int stockId = Integer.parseInt(request.getParameter("stock_id"));
        Connection connDel = null;
        PreparedStatement psDel = null;
        try {
            String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
            String user = "root";
            String pass = "trickortreat";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connDel = DriverManager.getConnection(url, user, pass);
            String sql = "DELETE FROM TECHNICAL_SIGNALS WHERE STOCK_ID = ?";
            psDel = connDel.prepareStatement(sql);
            psDel.setInt(1, stockId);
            int rows = psDel.executeUpdate();
            if (rows > 0) {
                swalStatus = "success";
                swalTitle = "Deleted";
                swalMessage = "Technical signal removed successfully.";
            } else {
                swalStatus = "error";
                swalTitle = "Failed";
                swalMessage = "Failed to delete signal.";
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

    boolean isUpdateSig = false;
    int updateStockId = -1;
    double updateAdx = 0.0;
    int updateVolume = 0;
    double updateMacd = 0.0;
    int updateSigCid = 0;

    // Handle Update View Mode (GET)
    if ("GET".equals(request.getMethod()) && "update".equals(request.getParameter("action")) && request.getParameter("stock_id") != null) {
        try {
            updateStockId = Integer.parseInt(request.getParameter("stock_id"));
            Connection connGet = null;
            PreparedStatement psGet = null;
            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connGet = DriverManager.getConnection(url, user, pass);
                psGet = connGet.prepareStatement("SELECT ADX, VOLUME, MACD, CID FROM TECHNICAL_SIGNALS WHERE STOCK_ID = ?");
                psGet.setInt(1, updateStockId);
                ResultSet rsGet = psGet.executeQuery();
                if (rsGet.next()) {
                    isUpdateSig = true;
                    updateAdx = rsGet.getDouble("ADX");
                    updateVolume = rsGet.getInt("VOLUME");
                    updateMacd = rsGet.getDouble("MACD");
                    updateSigCid = rsGet.getInt("CID");
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
    <title>Manage Technical Signals - FinManage Admin</title>
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
                    <span class="fin-brand-sub" style="color: #f59e0b;">SIGNALS CONTROL</span>
                </div>
            </a>
            <button class="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#adminSigNav">
                <i class="bi bi-list fs-2"></i>
            </button>
            <div class="collapse navbar-collapse" id="adminSigNav">
                <ul class="navbar-nav ms-auto align-items-center gap-1">
                    <li class="nav-item"><a class="fin-nav-link" href="admin-dashboard.jsp"><i class="bi bi-speedometer2"></i> Overview</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-users.jsp"><i class="bi bi-people"></i> Users</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-companies.jsp"><i class="bi bi-buildings"></i> Companies</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-reports.jsp"><i class="bi bi-file-earmark-text"></i> Reports</a></li>
                    <li class="nav-item"><a class="fin-nav-link active" href="manage-signals.jsp"><i class="bi bi-activity"></i> Signals</a></li>
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
                    <i class="bi bi-sliders text-primary me-2"></i>Technical Signals & Indicators Management
                </h3>
                <p class="text-muted small mb-0">Configure Average Directional Index (ADX), trading volume, and MACD indicators.</p>
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
                    <div class="fin-card-header <%= isUpdateSig ? "bg-warning-subtle" : "" %>">
                        <h5 class="fin-card-title">
                            <i class="bi <%= isUpdateSig ? "bi-pencil-square text-warning" : "bi-plus-circle-fill text-success" %>"></i>
                            <%= isUpdateSig ? "Update Technical Signal" : "Add Technical Signal" %>
                        </h5>
                    </div>
                    <div class="fin-card-body">
                        <form id="signalManageForm" action="manage-signals.jsp" method="POST" novalidate>
                            <% if (isUpdateSig) { %>
                                <input type="hidden" name="stock_id" value="<%= updateStockId %>">
                            <% } %>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">ADX (Trend Strength Indicator)</label>
                                <input type="number" step="0.01" name="adx" id="adx" class="form-control fin-input" 
                                       placeholder="e.g. 26.50" 
                                       value="<%= isUpdateSig ? updateAdx : "" %>" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">Trading Volume (Shares)</label>
                                <input type="number" name="volume" id="volume" class="form-control fin-input" 
                                       placeholder="e.g. 15000" 
                                       value="<%= isUpdateSig ? updateVolume : "" %>" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">MACD (Momentum Indicator)</label>
                                <input type="number" step="0.01" name="macd" id="macd" class="form-control fin-input" 
                                       placeholder="e.g. 32.40" 
                                       value="<%= isUpdateSig ? updateMacd : "" %>" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">Company ID (CID)</label>
                                <input type="number" name="cid" id="cid" class="form-control fin-input" 
                                       placeholder="e.g. 1" 
                                       value="<%= isUpdateSig ? updateSigCid : "" %>" required>
                            </div>

                            <div class="d-flex gap-2 mt-4">
                                <% if (isUpdateSig) { %>
                                    <button type="submit" class="fin-btn fin-btn-primary flex-fill">
                                        <i class="bi bi-check2-circle"></i> Save Signal
                                    </button>
                                    <a href="manage-signals.jsp" class="btn btn-outline-secondary">Cancel</a>
                                <% } else { %>
                                    <button type="submit" class="fin-btn fin-btn-emerald w-100">
                                        <i class="bi bi-plus-lg"></i> Register Signal
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
                            <i class="bi bi-table text-primary"></i> Configured Technical Signals
                        </h5>
                        <div class="input-group" style="width: 220px;">
                            <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                            <input type="text" id="sigTableSearch" class="form-control form-control-sm border-start-0" placeholder="Filter table...">
                        </div>
                    </div>
                    <div class="fin-card-body p-0">
                        <div class="table-responsive">
                            <table class="fin-table" id="signalsTable">
                                <thead>
                                    <tr>
                                        <th>Signal ID</th>
                                        <th>Company</th>
                                        <th class="text-center">ADX</th>
                                        <th class="text-end">Volume</th>
                                        <th class="text-center">MACD</th>
                                        <th class="text-center">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        DecimalFormat df = new DecimalFormat("#,##0.00");
                                        DecimalFormat dfInt = new DecimalFormat("#,##0");
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
                                            String sql = "SELECT t.STOCK_ID, t.ADX, t.VOLUME, t.MACD, c.CNAME, t.CID FROM TECHNICAL_SIGNALS t JOIN COMPANY c ON t.CID = c.CID ORDER BY t.STOCK_ID ASC";
                                            rs = st.executeQuery(sql);

                                            if (!rs.isBeforeFirst()) {
                                                out.println("<tr class='no-data-row'><td colspan='6' class='text-center py-4 text-muted'>No technical signals found.</td></tr>");
                                            } else {
                                                while (rs.next()) {
                                                    int sid = rs.getInt("STOCK_ID");
                                                    double adx = rs.getDouble("ADX");
                                                    int volume = rs.getInt("VOLUME");
                                                    double macd = rs.getDouble("MACD");
                                                    String cname = rs.getString("CNAME");
                                    %>
                                    <tr>
                                        <td class="text-mono text-muted">#SIG-<%= sid %></td>
                                        <td class="fw-bold"><%= cname %></td>
                                        <td class="text-center">
                                            <span class="badge bg-primary-subtle text-primary text-mono"><%= df.format(adx) %></span>
                                        </td>
                                        <td class="text-end text-mono fw-bold"><%= dfInt.format(volume) %></td>
                                        <td class="text-center">
                                            <span class="badge bg-success-subtle text-success text-mono"><%= df.format(macd) %></span>
                                        </td>
                                        <td class="text-center">
                                            <a href="manage-signals.jsp?stock_id=<%= sid %>&action=update" class="btn btn-sm btn-outline-primary me-1">
                                                <i class="bi bi-pencil"></i> Edit
                                            </a>
                                            <button type="button" class="btn btn-sm btn-outline-danger btn-delete-sig" data-id="<%= sid %>">
                                                <i class="bi bi-trash"></i> Delete
                                            </button>
                                        </td>
                                    </tr>
                                    <%
                                                }
                                            }
                                        } catch (Exception e) {
                                            out.println("<tr><td colspan='6' class='text-danger text-center'>Error: " + e.getMessage() + "</td></tr>");
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
                 data-redirect="manage-signals.jsp" 
                 style="display:none;"></div>
        <% } %>

    </div>

    <!-- FOOTER -->
    <footer class="fin-footer mt-5">
        <div class="container text-center">
            <p class="mb-1 text-muted">&copy; 2026 Financial Portfolio Management System. All Rights Reserved.</p>
            <p class="small text-secondary mb-0">Technical Signals Entity Manager • Connected to MySQL (FINANCIAL_DB)</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="Resources/fintech-charts.js"></script>
    <script>
        FinTechApp.filterTable('sigTableSearch', 'signalsTable');

        document.addEventListener('DOMContentLoaded', function () {
            // Delete confirmation handlers
            document.querySelectorAll('.btn-delete-sig').forEach(btn => {
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

            // Signal form validation & confirmation
            const form = document.getElementById('signalManageForm');
            if (form) {
                FinTechApp.bindLiveValidation(form);
                form.addEventListener('submit', function (e) {
                    e.preventDefault();
                    const adx = document.getElementById('adx');
                    const vol = document.getElementById('volume');
                    const macd = document.getElementById('macd');
                    const cid = document.getElementById('cid');

                    FinTechApp.clearError(adx);
                    FinTechApp.clearError(vol);
                    FinTechApp.clearError(macd);
                    FinTechApp.clearError(cid);

                    let isValid = true;
                    if (!adx.value || parseFloat(adx.value) <= 0) {
                        FinTechApp.showError(adx, 'ADX must be greater than 0.');
                        isValid = false;
                    }
                    if (!vol.value || parseInt(vol.value, 10) <= 0) {
                        FinTechApp.showError(vol, 'Trading volume must be at least 1.');
                        isValid = false;
                    }
                    if (!macd.value) {
                        FinTechApp.showError(macd, 'MACD value is required.');
                        isValid = false;
                    }
                    if (!cid.value || parseInt(cid.value, 10) <= 0) {
                        FinTechApp.showError(cid, 'Valid Company ID is required.');
                        isValid = false;
                    }

                    if (isValid) {
                        FinTechApp.confirmAction(
                            'Save Technical Signal?',
                            'Are you sure you want to save these indicator metrics?',
                            'Yes, Save',
                            function () { form.submit(); },
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

        function showDeleteConfirmation(stockId) {
            Swal.fire({
                title: 'Delete this Technical Signal?',
                text: "This operation will remove indicator metrics for this company!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ef4444',
                cancelButtonColor: '#64748b',
                confirmButtonText: 'Yes, delete signal'
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = "manage-signals.jsp?stock_id=" + stockId + "&action=delete";
                }
            });
        }
    </script>
</body>
</html>