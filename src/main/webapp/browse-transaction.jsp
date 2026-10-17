<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Trade Orders - FinManage</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="Resources/fintech-theme.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

    <!-- LIVE MARKET TICKER TAPE -->
    <div class="ticker-wrap">
        <div class="ticker-inner">
            <div class="ticker-item"><span class="sym">NIFTY 50</span> <span class="val">24,850.30</span> <span class="chg up"><i class="bi bi-arrow-up-short"></i>+0.58%</span></div>
            <div class="ticker-item"><span class="sym">SENSEX</span> <span class="val">81,224.75</span> <span class="chg up"><i class="bi bi-arrow-up-short"></i>+0.60%</span></div>
            <div class="ticker-item"><span class="sym">INFY</span> <span class="val">₹1,520.50</span> <span class="chg up"><i class="bi bi-arrow-up-short"></i>+1.85%</span></div>
            <div class="ticker-item"><span class="sym">RELIANCE</span> <span class="val">₹2,580.00</span> <span class="chg up"><i class="bi bi-arrow-up-short"></i>+0.92%</span></div>
            <div class="ticker-item"><span class="sym">TATAMOTORS</span> <span class="val">₹745.20</span> <span class="chg down"><i class="bi bi-arrow-down-short"></i>-0.45%</span></div>
            <div class="ticker-item"><span class="sym">HDFCBANK</span> <span class="val">₹1,640.00</span> <span class="chg up"><i class="bi bi-arrow-up-short"></i>+1.20%</span></div>
        </div>
    </div>

    <!-- MAIN NAVBAR -->
    <nav class="navbar navbar-expand-xl fin-navbar">
        <div class="container-fluid px-lg-4">
            <a class="fin-brand" href="customer-dashboard.jsp">
                <div class="fin-brand-logo">
                    <i class="bi bi-graph-up-arrow"></i>
                </div>
                <div class="fin-brand-name">
                    <span>FinManage</span>
                    <span class="fin-brand-sub">TRANSACTION AUDIT</span>
                </div>
            </a>
            <button class="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#transNav">
                <i class="bi bi-list fs-2"></i>
            </button>
            <div class="collapse navbar-collapse" id="transNav">
                <ul class="navbar-nav ms-auto align-items-center gap-1">
                    <li class="nav-item"><a class="fin-nav-link" href="customer-dashboard.jsp"><i class="bi bi-speedometer2"></i> Dashboard</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-company.jsp"><i class="bi bi-buildings"></i> Browse Companies</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-reports.jsp"><i class="bi bi-file-earmark-bar-graph"></i> Financial Reports</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-signals.jsp"><i class="bi bi-activity"></i> Technical Signals</a></li>
                    <li class="nav-item"><a class="fin-nav-link active" href="browse-transaction.jsp"><i class="bi bi-clock-history"></i> Transactions</a></li>
                    <li class="nav-item ms-lg-2">
                        <a href="javascript:void(0)" id="clientLogoutBtn" class="fin-btn-logout"><i class="bi bi-box-arrow-right"></i> Logout</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- CONTENT -->
    <div class="container-fluid px-lg-4 py-4">

        <%
            String loggedInUserName = (String) session.getAttribute("loggedInUserName");
            if (loggedInUserName == null || loggedInUserName.isEmpty()) {
                response.sendRedirect("login.jsp");
                return;
            }

            DecimalFormat df = new DecimalFormat("#,##0.00");
            Connection conn = null;
            Statement st = null;
            ResultSet rsTransactions = null;

            int totalTrades = 0;
            double totalBuyVal = 0.0;
            double totalSellVal = 0.0;

            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, user, pass);

                String sql = "SELECT t.TID, c.CNAME, t.RATE, t.QUANTITY, t.BUY_SELL " +
                             "FROM TRANSACTION t " +
                             "JOIN USER u ON t.UID = u.UID " +
                             "JOIN COMPANY c ON t.CID = c.CID " +
                             "WHERE u.USERNAME = ? ORDER BY t.TID DESC";

                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, loggedInUserName);
                rsTransactions = pstmt.executeQuery();
        %>

        <!-- Header & Summary Toolbar -->
        <div class="d-flex justify-content-between align-items-center flex-wrap mb-4">
            <div>
                <h3 class="fw-bold mb-1 text-dark">
                    <i class="bi bi-clock-history text-primary me-2"></i>Personal Order Ledger
                </h3>
                <p class="text-muted small mb-0">
                    Client Account: <strong><%= loggedInUserName %></strong> • Real-time order book execution records.
                </p>
            </div>
            <div class="mt-3 mt-md-0 d-flex gap-2">
                <div class="input-group" style="width: 280px;">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                    <input type="text" id="tradeSearch" class="form-control border-start-0 fin-input" placeholder="Search orders...">
                </div>
                <a href="customer-dashboard.jsp" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left"></i> Dashboard
                </a>
            </div>
        </div>

        <div class="fin-card">
            <div class="fin-card-body p-0">
                <div class="table-responsive">
                    <table class="fin-table" id="tradeTable">
                        <thead>
                            <tr>
                                <th>Order Ref</th>
                                <th>Company / Asset</th>
                                <th>Execution Type</th>
                                <th class="text-end">Execution Rate</th>
                                <th class="text-end">Shares Traded</th>
                                <th class="text-end">Gross Transaction Value</th>
                                <th class="text-center">Settlement</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (rsTransactions != null && rsTransactions.isBeforeFirst()) {
                                    while (rsTransactions.next()) {
                                        totalTrades++;
                                        int tid = rsTransactions.getInt("TID");
                                        String cname = rsTransactions.getString("CNAME");
                                        double rate = rsTransactions.getDouble("RATE");
                                        int quantity = rsTransactions.getInt("QUANTITY");
                                        String buySell = rsTransactions.getString("BUY_SELL");
                                        double totalVal = rate * quantity;

                                        if ("BUY".equalsIgnoreCase(buySell)) {
                                            totalBuyVal += totalVal;
                                        } else {
                                            totalSellVal += totalVal;
                                        }

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
                                    <td class="text-mono text-muted">#ORD-<%= tid %></td>
                                    <td>
                                        <div class="stock-info">
                                            <img src="Resources/stocks/<%= logo %>" class="stock-logo" alt="<%= cname %>">
                                            <div>
                                                <div class="stock-symbol"><%= cname %></div>
                                                <div class="stock-name">Equity Trade</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="<%= "BUY".equalsIgnoreCase(buySell) ? "badge-buy" : "badge-sell" %>">
                                            <i class="bi <%= "BUY".equalsIgnoreCase(buySell) ? "bi-arrow-down-left" : "bi-arrow-up-right" %>"></i>
                                            <%= buySell %>
                                        </span>
                                    </td>
                                    <td class="text-end text-mono">₹<%= df.format(rate) %></td>
                                    <td class="text-end text-mono fw-bold"><%= quantity %></td>
                                    <td class="text-end text-mono fw-bold fs-6">₹<%= df.format(totalVal) %></td>
                                    <td class="text-center">
                                        <span class="badge bg-success-subtle text-success border border-success-subtle">
                                            <i class="bi bi-check-circle-fill me-1"></i> Executed
                                        </span>
                                    </td>
                                </tr>
                            <%
                                    }
                                } else {
                            %>
                                <tr class="no-data-row">
                                    <td colspan="7" class="text-center py-4 text-muted">
                                        <i class="bi bi-clock-history fs-3 d-block mb-2"></i>
                                        No transactions found for user account "<%= loggedInUserName %>".
                                    </td>
                                </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <%
            } catch(Exception e) {
        %>
            <div class="alert alert-danger my-4">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> Error loading transactions: <%= e.getMessage() %>
            </div>
        <%
            } finally {
                try {
                    if (rsTransactions != null) rsTransactions.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        %>

    </div>

    <!-- FOOTER -->
    <footer class="fin-footer mt-5">
        <div class="container text-center">
            <p class="mb-1 text-muted">&copy; 2026 Financial Portfolio Management System. All Rights Reserved.</p>
            <p class="small text-secondary mb-0">Transaction Audit & Order Book • Connected to MySQL (FINANCIAL_DB)</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="Resources/fintech-charts.js"></script>
    <script>
        FinTechApp.filterTable('tradeSearch', 'tradeTable');

        const logoutBtn = document.getElementById('clientLogoutBtn');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', function () {
                FinTechApp.confirmAction(
                    'Sign Out Confirmation',
                    'Are you sure you want to log out of your wealth portfolio terminal?',
                    'Yes, Sign Out',
                    function () { window.location.href = 'login.jsp'; },
                    'warning'
                );
            });
        }
    </script>
</body>
</html>
