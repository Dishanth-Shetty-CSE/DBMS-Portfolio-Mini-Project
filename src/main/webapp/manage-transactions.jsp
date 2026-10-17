<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    String swalStatus = "";
    String swalTitle = "";
    String swalMessage = "";

    // Handle Add Transaction (POST without tid)
    if ("POST".equals(request.getMethod()) && request.getParameter("uid") != null && request.getParameter("cid") != null && request.getParameter("rate") != null && request.getParameter("quantity") != null && request.getParameter("buy_sell") != null && request.getParameter("tid") == null) {
        try {
            int pUid = Integer.parseInt(request.getParameter("uid"));
            int pCid = Integer.parseInt(request.getParameter("cid"));
            double pRate = Double.parseDouble(request.getParameter("rate"));
            int pQty = Integer.parseInt(request.getParameter("quantity"));
            String pAction = request.getParameter("buy_sell");

            Connection connIns = null;
            PreparedStatement psIns = null;
            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connIns = DriverManager.getConnection(url, user, pass);
                String sql = "INSERT INTO TRANSACTION (UID, CID, RATE, QUANTITY, BUY_SELL) VALUES (?, ?, ?, ?, ?)";
                psIns = connIns.prepareStatement(sql);
                psIns.setInt(1, pUid);
                psIns.setInt(2, pCid);
                psIns.setDouble(3, pRate);
                psIns.setInt(4, pQty);
                psIns.setString(5, pAction);
                int rows = psIns.executeUpdate();
                if (rows > 0) {
                    swalStatus = "success";
                    swalTitle = "Success";
                    swalMessage = "Transaction recorded successfully!";
                } else {
                    swalStatus = "error";
                    swalTitle = "Failed";
                    swalMessage = "Failed to record transaction.";
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

    // Handle Update Transaction (POST with tid)
    if ("POST".equals(request.getMethod()) && request.getParameter("uid") != null && request.getParameter("cid") != null && request.getParameter("rate") != null && request.getParameter("quantity") != null && request.getParameter("buy_sell") != null && request.getParameter("tid") != null) {
        try {
            int pTid = Integer.parseInt(request.getParameter("tid"));
            int pUid = Integer.parseInt(request.getParameter("uid"));
            int pCid = Integer.parseInt(request.getParameter("cid"));
            double pRate = Double.parseDouble(request.getParameter("rate"));
            int pQty = Integer.parseInt(request.getParameter("quantity"));
            String pAction = request.getParameter("buy_sell");

            Connection connUp = null;
            PreparedStatement psUp = null;
            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connUp = DriverManager.getConnection(url, user, pass);
                String sql = "UPDATE TRANSACTION SET UID = ?, CID = ?, RATE = ?, QUANTITY = ?, BUY_SELL = ? WHERE TID = ?";
                psUp = connUp.prepareStatement(sql);
                psUp.setInt(1, pUid);
                psUp.setInt(2, pCid);
                psUp.setDouble(3, pRate);
                psUp.setInt(4, pQty);
                psUp.setString(5, pAction);
                psUp.setInt(6, pTid);
                int rows = psUp.executeUpdate();
                if (rows > 0) {
                    swalStatus = "success";
                    swalTitle = "Success";
                    swalMessage = "Transaction updated successfully!";
                } else {
                    swalStatus = "error";
                    swalTitle = "Failed";
                    swalMessage = "Failed to update transaction.";
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

    // Handle Delete Transaction (GET with action=delete)
    if ("GET".equals(request.getMethod()) && "delete".equals(request.getParameter("action")) && request.getParameter("tid") != null) {
        int pTid = Integer.parseInt(request.getParameter("tid"));
        Connection connDel = null;
        PreparedStatement psDel = null;
        try {
            String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
            String user = "root";
            String pass = "trickortreat";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connDel = DriverManager.getConnection(url, user, pass);
            String sql = "DELETE FROM TRANSACTION WHERE TID = ?";
            psDel = connDel.prepareStatement(sql);
            psDel.setInt(1, pTid);
            int rows = psDel.executeUpdate();
            if (rows > 0) {
                swalStatus = "success";
                swalTitle = "Deleted";
                swalMessage = "Transaction removed successfully.";
            } else {
                swalStatus = "error";
                swalTitle = "Failed";
                swalMessage = "Failed to delete transaction.";
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

    boolean isUpdateTx = false;
    int updateTid = -1;
    int updateUid = 0;
    int updateTxCid = 0;
    double updateRate = 0.0;
    int updateQty = 0;
    String updateBuySell = "BUY";

    // Handle Update View Mode (GET)
    if ("GET".equals(request.getMethod()) && "update".equals(request.getParameter("action")) && request.getParameter("tid") != null) {
        try {
            updateTid = Integer.parseInt(request.getParameter("tid"));
            Connection connGet = null;
            PreparedStatement psGet = null;
            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connGet = DriverManager.getConnection(url, user, pass);
                psGet = connGet.prepareStatement("SELECT UID, CID, RATE, QUANTITY, BUY_SELL FROM TRANSACTION WHERE TID = ?");
                psGet.setInt(1, updateTid);
                ResultSet rsGet = psGet.executeQuery();
                if (rsGet.next()) {
                    isUpdateTx = true;
                    updateUid = rsGet.getInt("UID");
                    updateTxCid = rsGet.getInt("CID");
                    updateRate = rsGet.getDouble("RATE");
                    updateQty = rsGet.getInt("QUANTITY");
                    updateBuySell = rsGet.getString("BUY_SELL");
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
    <title>Manage Transactions - FinManage Admin</title>
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
                    <span class="fin-brand-sub" style="color: #f59e0b;">ORDER BOOK CONTROL</span>
                </div>
            </a>
            <button class="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#adminTxNav">
                <i class="bi bi-list fs-2"></i>
            </button>
            <div class="collapse navbar-collapse" id="adminTxNav">
                <ul class="navbar-nav ms-auto align-items-center gap-1">
                    <li class="nav-item"><a class="fin-nav-link" href="admin-dashboard.jsp"><i class="bi bi-speedometer2"></i> Overview</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-users.jsp"><i class="bi bi-people"></i> Users</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-companies.jsp"><i class="bi bi-buildings"></i> Companies</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-reports.jsp"><i class="bi bi-file-earmark-text"></i> Reports</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="manage-signals.jsp"><i class="bi bi-activity"></i> Signals</a></li>
                    <li class="nav-item"><a class="fin-nav-link active" href="manage-transactions.jsp"><i class="bi bi-clock-history"></i> Orders</a></li>
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
                    <i class="bi bi-clock-history text-primary me-2"></i>Order Book & Trade Execution Administration
                </h3>
                <p class="text-muted small mb-0">Record institutional settlements, correct trade executions, or manage portfolio order entries.</p>
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
                    <div class="fin-card-header <%= isUpdateTx ? "bg-warning-subtle" : "" %>">
                        <h5 class="fin-card-title">
                            <i class="bi <%= isUpdateTx ? "bi-pencil-square text-warning" : "bi-plus-circle-fill text-success" %>"></i>
                            <%= isUpdateTx ? "Update Trade Execution" : "Record New Trade Order" %>
                        </h5>
                    </div>
                    <div class="fin-card-body">
                        <form id="txManageForm" action="manage-transactions.jsp" method="POST" novalidate>
                            <% if (isUpdateTx) { %>
                                <input type="hidden" name="tid" value="<%= updateTid %>">
                            <% } %>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">User Account ID (UID)</label>
                                <input type="number" name="uid" id="uid" class="form-control fin-input" 
                                       placeholder="e.g. 1" 
                                       value="<%= isUpdateTx ? updateUid : "" %>" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">Company ID (CID)</label>
                                <input type="number" name="cid" id="cid" class="form-control fin-input" 
                                       placeholder="e.g. 1" 
                                       value="<%= isUpdateTx ? updateTxCid : "" %>" required>
                            </div>

                            <div class="row g-2 mb-3">
                                <div class="col-6">
                                    <label class="form-label small fw-bold text-secondary">Execution Rate (₹)</label>
                                    <input type="number" step="0.01" name="rate" id="adminRate" class="form-control fin-input" 
                                           placeholder="e.g. 1500.00" 
                                           value="<%= isUpdateTx ? updateRate : "" %>" required>
                                </div>
                                <div class="col-6">
                                    <label class="form-label small fw-bold text-secondary">Quantity</label>
                                    <input type="number" name="quantity" id="adminQty" class="form-control fin-input" 
                                           placeholder="e.g. 10" 
                                           value="<%= isUpdateTx ? updateQty : "" %>" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">Order Action</label>
                                <select name="buy_sell" id="buy_sell" class="form-select fin-input" required>
                                    <option value="BUY" <%= "BUY".equalsIgnoreCase(updateBuySell) ? "selected" : "" %>>BUY (Long Entry)</option>
                                    <option value="SELL" <%= "SELL".equalsIgnoreCase(updateBuySell) ? "selected" : "" %>>SELL (Exit / Short)</option>
                                </select>
                            </div>

                            <!-- Live Value Estimation Box -->
                            <div class="p-3 bg-light rounded-3 border d-flex justify-content-between align-items-center mb-3">
                                <span class="small text-muted fw-semibold">Estimated Gross Total:</span>
                                <span class="fw-bold fs-6 text-primary text-mono" id="adminTxTotal">₹0.00</span>
                            </div>

                            <div class="d-flex gap-2">
                                <% if (isUpdateTx) { %>
                                    <button type="submit" class="fin-btn fin-btn-primary flex-fill">
                                        <i class="bi bi-check2-circle"></i> Save Trade
                                    </button>
                                    <a href="manage-transactions.jsp" class="btn btn-outline-secondary">Cancel</a>
                                <% } else { %>
                                    <button type="submit" class="fin-btn fin-btn-emerald w-100">
                                        <i class="bi bi-plus-lg"></i> Record Transaction
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
                            <i class="bi bi-table text-primary"></i> Master Order Book Ledger
                        </h5>
                        <div class="input-group" style="width: 220px;">
                            <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                            <input type="text" id="txTableSearch" class="form-control form-control-sm border-start-0" placeholder="Filter table...">
                        </div>
                    </div>
                    <div class="fin-card-body p-0">
                        <div class="table-responsive">
                            <table class="fin-table" id="transactionsTable">
                                <thead>
                                    <tr>
                                        <th>Trade Ref</th>
                                        <th>Client</th>
                                        <th>Company</th>
                                        <th>Type</th>
                                        <th class="text-end">Rate</th>
                                        <th class="text-end">Qty</th>
                                        <th class="text-end">Total</th>
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
                                            String sql = "SELECT t.TID, t.UID, t.CID, t.RATE, t.QUANTITY, t.BUY_SELL, u.USERNAME, c.CNAME " +
                                                         "FROM TRANSACTION t " +
                                                         "JOIN USER u ON t.UID = u.UID " +
                                                         "JOIN COMPANY c ON t.CID = c.CID ORDER BY t.TID DESC";
                                            rs = st.executeQuery(sql);

                                            if (!rs.isBeforeFirst()) {
                                                out.println("<tr class='no-data-row'><td colspan='8' class='text-center py-4 text-muted'>No transactions found.</td></tr>");
                                            } else {
                                                while (rs.next()) {
                                                    int tid = rs.getInt("TID");
                                                    String uname = rs.getString("USERNAME");
                                                    String cname = rs.getString("CNAME");
                                                    double rate = rs.getDouble("RATE");
                                                    int quantity = rs.getInt("QUANTITY");
                                                    String buySell = rs.getString("BUY_SELL");
                                                    double tradeTotal = rate * quantity;
                                    %>
                                    <tr>
                                        <td class="text-mono text-muted">#<%= tid %></td>
                                        <td class="fw-semibold"><%= uname %></td>
                                        <td class="fw-bold"><%= cname %></td>
                                        <td>
                                            <span class="<%= "BUY".equalsIgnoreCase(buySell) ? "badge-buy" : "badge-sell" %>">
                                                <%= buySell %>
                                            </span>
                                        </td>
                                        <td class="text-end text-mono">₹<%= df.format(rate) %></td>
                                        <td class="text-end text-mono fw-bold"><%= quantity %></td>
                                        <td class="text-end text-mono fw-bold">₹<%= df.format(tradeTotal) %></td>
                                        <td class="text-center">
                                            <a href="manage-transactions.jsp?tid=<%= tid %>&action=update" class="btn btn-sm btn-outline-primary me-1">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                            <button type="button" class="btn btn-sm btn-outline-danger btn-delete-tx" data-id="<%= tid %>">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                    <%
                                                }
                                            }
                                        } catch (Exception e) {
                                            out.println("<tr><td colspan='8' class='text-danger text-center'>Error: " + e.getMessage() + "</td></tr>");
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
                 data-redirect="manage-transactions.jsp" 
                 style="display:none;"></div>
        <% } %>

    </div>

    <!-- FOOTER -->
    <footer class="fin-footer mt-5">
        <div class="container text-center">
            <p class="mb-1 text-muted">&copy; 2026 Financial Portfolio Management System. All Rights Reserved.</p>
            <p class="small text-secondary mb-0">Order Book Entity Manager • Connected to MySQL (FINANCIAL_DB)</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="Resources/fintech-charts.js"></script>
    <script>
        FinTechApp.filterTable('txTableSearch', 'transactionsTable');
        FinTechApp.initTradeCalculator('adminRate', 'adminQty', 'adminTxTotal');

        document.addEventListener('DOMContentLoaded', function () {
            // Delete confirmation handlers
            document.querySelectorAll('.btn-delete-tx').forEach(btn => {
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

            // Transaction form validation & confirmation
            const form = document.getElementById('txManageForm');
            if (form) {
                FinTechApp.bindLiveValidation(form);
                form.addEventListener('submit', function (e) {
                    e.preventDefault();
                    const uid = document.getElementById('uid');
                    const cid = document.getElementById('cid');
                    const rate = document.getElementById('adminRate');
                    const qty = document.getElementById('adminQty');
                    const buySell = document.getElementById('buy_sell').value;

                    FinTechApp.clearError(uid);
                    FinTechApp.clearError(cid);
                    FinTechApp.clearError(rate);
                    FinTechApp.clearError(qty);

                    let isValid = true;
                    if (!uid.value || parseInt(uid.value, 10) <= 0) {
                        FinTechApp.showError(uid, 'Valid User ID is required.');
                        isValid = false;
                    }
                    if (!cid.value || parseInt(cid.value, 10) <= 0) {
                        FinTechApp.showError(cid, 'Valid Company ID is required.');
                        isValid = false;
                    }
                    if (!rate.value || parseFloat(rate.value) <= 0) {
                        FinTechApp.showError(rate, 'Rate must be greater than ₹0.');
                        isValid = false;
                    }
                    if (!qty.value || parseInt(qty.value, 10) <= 0) {
                        FinTechApp.showError(qty, 'Quantity must be at least 1.');
                        isValid = false;
                    }

                    if (isValid) {
                        FinTechApp.confirmAction(
                            'Record Trade Execution?',
                            'Are you sure you want to record this ' + buySell + ' order for User #' + uid.value + '?',
                            'Yes, Execute',
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

        function showDeleteConfirmation(tid) {
            Swal.fire({
                title: 'Cancel this Transaction?',
                text: "Removing this trade will alter the client's net portfolio balance!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ef4444',
                cancelButtonColor: '#64748b',
                confirmButtonText: 'Yes, remove trade'
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = "manage-transactions.jsp?tid=" + tid + "&action=delete";
                }
            });
        }
    </script>
</body>
</html>