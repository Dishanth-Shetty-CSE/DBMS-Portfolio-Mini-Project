<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    String swalStatus = "";
    String swalTitle = "";
    String swalMessage = "";

    // Handle Add Report (POST without report_id)
    if ("POST".equals(request.getMethod()) && request.getParameter("ltp") != null && request.getParameter("eps") != null && request.getParameter("roe") != null && request.getParameter("cid") != null && request.getParameter("report_id") == null) {
        try {
            double ltp = Double.parseDouble(request.getParameter("ltp"));
            double eps = Double.parseDouble(request.getParameter("eps"));
            double roe = Double.parseDouble(request.getParameter("roe"));
            int cid = Integer.parseInt(request.getParameter("cid"));

            Connection connIns = null;
            PreparedStatement psIns = null;
            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connIns = DriverManager.getConnection(url, user, pass);
                String sql = "INSERT INTO REPORT (LTP, EPS, ROE, CID) VALUES (?, ?, ?, ?)";
                psIns = connIns.prepareStatement(sql);
                psIns.setDouble(1, ltp);
                psIns.setDouble(2, eps);
                psIns.setDouble(3, roe);
                psIns.setInt(4, cid);
                int rows = psIns.executeUpdate();
                if (rows > 0) {
                    swalStatus = "success";
                    swalTitle = "Success";
                    swalMessage = "Report added successfully!";
                } else {
                    swalStatus = "error";
                    swalTitle = "Failed";
                    swalMessage = "Failed to add report.";
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

    // Handle Update Report (POST with report_id)
    if ("POST".equals(request.getMethod()) && request.getParameter("ltp") != null && request.getParameter("eps") != null && request.getParameter("roe") != null && request.getParameter("cid") != null && request.getParameter("report_id") != null) {
        try {
            int reportId = Integer.parseInt(request.getParameter("report_id"));
            double ltp = Double.parseDouble(request.getParameter("ltp"));
            double eps = Double.parseDouble(request.getParameter("eps"));
            double roe = Double.parseDouble(request.getParameter("roe"));
            int cid = Integer.parseInt(request.getParameter("cid"));

            Connection connUp = null;
            PreparedStatement psUp = null;
            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connUp = DriverManager.getConnection(url, user, pass);
                String sql = "UPDATE REPORT SET LTP = ?, EPS = ?, ROE = ?, CID = ? WHERE REPORT_ID = ?";
                psUp = connUp.prepareStatement(sql);
                psUp.setDouble(1, ltp);
                psUp.setDouble(2, eps);
                psUp.setDouble(3, roe);
                psUp.setInt(4, cid);
                psUp.setInt(5, reportId);
                int rows = psUp.executeUpdate();
                if (rows > 0) {
                    swalStatus = "success";
                    swalTitle = "Success";
                    swalMessage = "Report updated successfully!";
                } else {
                    swalStatus = "error";
                    swalTitle = "Failed";
                    swalMessage = "Failed to update report.";
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

    // Handle Delete Report (GET with action=delete)
    if ("GET".equals(request.getMethod()) && "delete".equals(request.getParameter("action")) && request.getParameter("report_id") != null) {
        int reportId = Integer.parseInt(request.getParameter("report_id"));
        Connection connDel = null;
        PreparedStatement psDel = null;
        try {
            String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
            String user = "root";
            String pass = "trickortreat";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connDel = DriverManager.getConnection(url, user, pass);
            String sql = "DELETE FROM REPORT WHERE REPORT_ID = ?";
            psDel = connDel.prepareStatement(sql);
            psDel.setInt(1, reportId);
            int rows = psDel.executeUpdate();
            if (rows > 0) {
                swalStatus = "success";
                swalTitle = "Deleted";
                swalMessage = "Report removed successfully.";
            } else {
                swalStatus = "error";
                swalTitle = "Failed";
                swalMessage = "Failed to delete report.";
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

    boolean isUpdateReport = false;
    int updateReportId = -1;
    double updateLtp = 0.0;
    double updateEps = 0.0;
    double updateRoe = 0.0;
    int updateReportCid = 0;

    // Handle Update View Mode (GET)
    if ("GET".equals(request.getMethod()) && "update".equals(request.getParameter("action")) && request.getParameter("report_id") != null) {
        try {
            updateReportId = Integer.parseInt(request.getParameter("report_id"));
            Connection connGet = null;
            PreparedStatement psGet = null;
            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connGet = DriverManager.getConnection(url, user, pass);
                psGet = connGet.prepareStatement("SELECT LTP, EPS, ROE, CID FROM REPORT WHERE REPORT_ID = ?");
                psGet.setInt(1, updateReportId);
                ResultSet rsGet = psGet.executeQuery();
                if (rsGet.next()) {
                    isUpdateReport = true;
                    updateLtp = rsGet.getDouble("LTP");
                    updateEps = rsGet.getDouble("EPS");
                    updateRoe = rsGet.getDouble("ROE");
                    updateReportCid = rsGet.getInt("CID");
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
    <title>Manage Reports - FinManage Admin</title>
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
                    <span class="fin-brand-sub" style="color: #f59e0b;">REPORTS CONTROL</span>
                </div>
            </a>
            <button class="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#adminRepNav">
                <i class="bi bi-list fs-2"></i>
            </button>
            <div class="collapse navbar-collapse" id="adminRepNav">
                <ul class="navbar-nav ms-auto align-items-center gap-1">
                    <li class="nav-item"><a class="fin-nav-link" href="admin-dashboard.jsp"><i class="bi bi-speedometer2"></i> Overview</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-users.jsp"><i class="bi bi-people"></i> Users</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-companies.jsp"><i class="bi bi-buildings"></i> Companies</a></li>
                    <li class="nav-item"><a class="fin-nav-link active" href="manage-reports.jsp"><i class="bi bi-file-earmark-text"></i> Reports</a></li>
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
                    <i class="bi bi-file-earmark-bar-graph-fill text-primary me-2"></i>Financial Reports Management
                </h3>
                <p class="text-muted small mb-0">Maintain equity fundamental parameters: Last Traded Price, EPS, and Return on Equity.</p>
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
                    <div class="fin-card-header <%= isUpdateReport ? "bg-warning-subtle" : "" %>">
                        <h5 class="fin-card-title">
                            <i class="bi <%= isUpdateReport ? "bi-pencil-square text-warning" : "bi-plus-circle-fill text-success" %>"></i>
                            <%= isUpdateReport ? "Update Financial Report" : "Add Financial Report" %>
                        </h5>
                    </div>
                    <div class="fin-card-body">
                        <form id="reportManageForm" action="manage-reports.jsp" method="POST" novalidate>
                            <% if (isUpdateReport) { %>
                                <input type="hidden" name="report_id" value="<%= updateReportId %>">
                            <% } %>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">Last Traded Price (LTP in ₹)</label>
                                <input type="number" step="0.01" name="ltp" id="ltp" class="form-control fin-input" 
                                       placeholder="e.g. 1520.50" 
                                       value="<%= isUpdateReport ? updateLtp : "" %>" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">Earnings Per Share (EPS in ₹)</label>
                                <input type="number" step="0.01" name="eps" id="eps" class="form-control fin-input" 
                                       placeholder="e.g. 82.40" 
                                       value="<%= isUpdateReport ? updateEps : "" %>" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">Return on Equity (ROE in %)</label>
                                <input type="number" step="0.01" name="roe" id="roe" class="form-control fin-input" 
                                       placeholder="e.g. 21.50" 
                                       value="<%= isUpdateReport ? updateRoe : "" %>" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">Company ID (CID)</label>
                                <input type="number" name="cid" id="cid" class="form-control fin-input" 
                                       placeholder="e.g. 1" 
                                       value="<%= isUpdateReport ? updateReportCid : "" %>" required>
                            </div>

                            <div class="d-flex gap-2 mt-4">
                                <% if (isUpdateReport) { %>
                                    <button type="submit" class="fin-btn fin-btn-primary flex-fill">
                                        <i class="bi bi-check2-circle"></i> Save Report
                                    </button>
                                    <a href="manage-reports.jsp" class="btn btn-outline-secondary">Cancel</a>
                                <% } else { %>
                                    <button type="submit" class="fin-btn fin-btn-emerald w-100">
                                        <i class="bi bi-plus-lg"></i> Submit Report
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
                            <i class="bi bi-table text-primary"></i> Current Reports Database
                        </h5>
                        <div class="input-group" style="width: 220px;">
                            <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                            <input type="text" id="reportTableSearch" class="form-control form-control-sm border-start-0" placeholder="Filter table...">
                        </div>
                    </div>
                    <div class="fin-card-body p-0">
                        <div class="table-responsive">
                            <table class="fin-table" id="reportsTable">
                                <thead>
                                    <tr>
                                        <th>Report ID</th>
                                        <th>Company</th>
                                        <th class="text-end">LTP (₹)</th>
                                        <th class="text-end">EPS (₹)</th>
                                        <th class="text-end">ROE (%)</th>
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
                                            String sql = "SELECT r.REPORT_ID, r.LTP, r.EPS, r.ROE, c.CNAME, r.CID FROM REPORT r JOIN COMPANY c ON r.CID = c.CID ORDER BY r.REPORT_ID ASC";
                                            rs = st.executeQuery(sql);

                                            if (!rs.isBeforeFirst()) {
                                                out.println("<tr class='no-data-row'><td colspan='6' class='text-center py-4 text-muted'>No reports found.</td></tr>");
                                            } else {
                                                while (rs.next()) {
                                                    int rid = rs.getInt("REPORT_ID");
                                                    double ltp = rs.getDouble("LTP");
                                                    double eps = rs.getDouble("EPS");
                                                    double roe = rs.getDouble("ROE");
                                                    String cname = rs.getString("CNAME");
                                    %>
                                    <tr>
                                        <td class="text-mono text-muted">#REP-<%= rid %></td>
                                        <td class="fw-bold"><%= cname %></td>
                                        <td class="text-end text-mono fw-bold">₹<%= df.format(ltp) %></td>
                                        <td class="text-end text-mono text-primary">₹<%= df.format(eps) %></td>
                                        <td class="text-end text-mono fw-bold text-success"><%= df.format(roe) %>%</td>
                                        <td class="text-center">
                                            <a href="manage-reports.jsp?report_id=<%= rid %>&action=update" class="btn btn-sm btn-outline-primary me-1">
                                                <i class="bi bi-pencil"></i> Edit
                                            </a>
                                            <button type="button" class="btn btn-sm btn-outline-danger btn-delete-rep" data-id="<%= rid %>">
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
                 data-redirect="manage-reports.jsp" 
                 style="display:none;"></div>
        <% } %>

    </div>

    <!-- FOOTER -->
    <footer class="fin-footer mt-5">
        <div class="container text-center">
            <p class="mb-1 text-muted">&copy; 2026 Financial Portfolio Management System. All Rights Reserved.</p>
            <p class="small text-secondary mb-0">Financial Reports Entity Manager • Connected to MySQL (FINANCIAL_DB)</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="Resources/fintech-charts.js"></script>
    <script>
        FinTechApp.filterTable('reportTableSearch', 'reportsTable');

        document.addEventListener('DOMContentLoaded', function () {
            // Delete confirmation handlers
            document.querySelectorAll('.btn-delete-rep').forEach(btn => {
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

            // Report form validation & confirmation
            const form = document.getElementById('reportManageForm');
            if (form) {
                FinTechApp.bindLiveValidation(form);
                form.addEventListener('submit', function (e) {
                    e.preventDefault();
                    const ltp = document.getElementById('ltp');
                    const eps = document.getElementById('eps');
                    const roe = document.getElementById('roe');
                    const cid = document.getElementById('cid');

                    FinTechApp.clearError(ltp);
                    FinTechApp.clearError(eps);
                    FinTechApp.clearError(roe);
                    FinTechApp.clearError(cid);

                    let isValid = true;
                    if (!ltp.value || parseFloat(ltp.value) <= 0) {
                        FinTechApp.showError(ltp, 'LTP must be greater than ₹0.');
                        isValid = false;
                    }
                    if (!eps.value) {
                        FinTechApp.showError(eps, 'EPS is required.');
                        isValid = false;
                    }
                    if (!roe.value) {
                        FinTechApp.showError(roe, 'ROE is required.');
                        isValid = false;
                    }
                    if (!cid.value || parseInt(cid.value, 10) <= 0) {
                        FinTechApp.showError(cid, 'Valid Company ID is required.');
                        isValid = false;
                    }

                    if (isValid) {
                        FinTechApp.confirmAction(
                            'Save Financial Report?',
                            'Are you sure you want to save this fundamental report?',
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

        function showDeleteConfirmation(reportId) {
            Swal.fire({
                title: 'Delete this Financial Report?',
                text: "This operation will remove fundamental parameters for this company!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ef4444',
                cancelButtonColor: '#64748b',
                confirmButtonText: 'Yes, delete report'
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = "manage-reports.jsp?report_id=" + reportId + "&action=delete";
                }
            });
        }
    </script>
</body>
</html>