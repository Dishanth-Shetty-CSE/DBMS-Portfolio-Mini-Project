<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Fundamental Reports - FinManage</title>
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
            <div class="ticker-item"><span class="sym">WIPRO</span> <span class="val">₹1,315.00</span> <span class="chg down"><i class="bi bi-arrow-down-short"></i>-0.15%</span></div>
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
                    <span class="fin-brand-sub">FUNDAMENTAL RESEARCH</span>
                </div>
            </a>
            <button class="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#reportNav">
                <i class="bi bi-list fs-2"></i>
            </button>
            <div class="collapse navbar-collapse" id="reportNav">
                <ul class="navbar-nav ms-auto align-items-center gap-1">
                    <li class="nav-item"><a class="fin-nav-link" href="customer-dashboard.jsp"><i class="bi bi-speedometer2"></i> Dashboard</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-company.jsp"><i class="bi bi-buildings"></i> Browse Companies</a></li>
                    <li class="nav-item"><a class="fin-nav-link active" href="browse-reports.jsp"><i class="bi bi-file-earmark-bar-graph"></i> Financial Reports</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-signals.jsp"><i class="bi bi-activity"></i> Technical Signals</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-transaction.jsp"><i class="bi bi-clock-history"></i> Transactions</a></li>
                    <li class="nav-item ms-lg-2">
                        <a href="javascript:void(0)" id="clientLogoutBtn" class="fin-btn-logout"><i class="bi bi-box-arrow-right"></i> Logout</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- CONTENT -->
    <div class="container-fluid px-lg-4 py-4">

        <!-- Header & Toolbar -->
        <div class="d-flex justify-content-between align-items-center flex-wrap mb-4">
            <div>
                <h3 class="fw-bold mb-1 text-dark">
                    <i class="bi bi-file-earmark-bar-graph-fill text-primary me-2"></i>Fundamental Financial Reports
                </h3>
                <p class="text-muted small mb-0">Evaluate company valuations through Last Traded Price (LTP), Earnings Per Share (EPS), and Return on Equity (ROE).</p>
            </div>
            <div class="mt-3 mt-md-0 d-flex gap-2">
                <div class="input-group" style="width: 280px;">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                    <input type="text" id="reportSearch" class="form-control border-start-0 fin-input" placeholder="Search reports...">
                </div>
                <a href="customer-dashboard.jsp" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left"></i> Dashboard
                </a>
            </div>
        </div>

        <div class="fin-card">
            <div class="fin-card-body p-0">
                <div class="table-responsive">
                    <table class="fin-table" id="reportTable">
                        <thead>
                            <tr>
                                <th>Company / Asset</th>
                                <th class="text-end">Last Traded Price (LTP)</th>
                                <th class="text-end">Earnings Per Share (EPS)</th>
                                <th class="text-end">Return on Equity (ROE)</th>
                                <th class="text-end">P/E Ratio (Est.)</th>
                                <th class="text-center">Fundamental Assessment</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                DecimalFormat df = new DecimalFormat("#,##0.00");
                                Connection conn = null;
                                Statement st = null;
                                ResultSet rsReport = null;

                                try {
                                    String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                                    String user = "root";
                                    String pass = "trickortreat";
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    conn = DriverManager.getConnection(url, user, pass);
                                    st = conn.createStatement();
                                    rsReport = st.executeQuery("SELECT c.CNAME, r.LTP, r.EPS, r.ROE FROM REPORT r JOIN COMPANY c ON r.CID = c.CID ORDER BY r.ROE DESC");

                                    if (rsReport != null && rsReport.isBeforeFirst()) {
                                        while (rsReport.next()) {
                                            String cname = rsReport.getString("CNAME");
                                            double ltp = rsReport.getDouble("LTP");
                                            double eps = rsReport.getDouble("EPS");
                                            double roe = rsReport.getDouble("ROE");
                                            double peRatio = (eps > 0) ? (ltp / eps) : 0.0;

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
                                    <td>
                                        <div class="stock-info">
                                            <img src="Resources/stocks/<%= logo %>" class="stock-logo" alt="<%= cname %>">
                                            <div>
                                                <div class="stock-symbol"><%= cname %></div>
                                                <div class="stock-name">Equity Report</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="text-end text-mono fw-bold">₹<%= df.format(ltp) %></td>
                                    <td class="text-end text-mono fw-semibold text-primary">₹<%= df.format(eps) %></td>
                                    <td class="text-end text-mono fw-bold text-success"><%= df.format(roe) %>%</td>
                                    <td class="text-end text-mono"><%= df.format(peRatio) %>x</td>
                                    <td class="text-center">
                                        <% if (roe >= 20.0) { %>
                                            <span class="badge bg-success-subtle text-success border border-success-subtle">
                                                <i class="bi bi-stars me-1"></i> High Quality ROE
                                            </span>
                                        <% } else if (roe >= 16.0) { %>
                                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle">
                                                <i class="bi bi-check-circle me-1"></i> Stable Growth
                                            </span>
                                        <% } else { %>
                                            <span class="badge bg-secondary-subtle text-secondary border">
                                                Moderate
                                            </span>
                                        <% } %>
                                    </td>
                                </tr>
                            <%
                                        }
                                    } else {
                            %>
                                <tr class="no-data-row">
                                    <td colspan="6" class="text-center py-4 text-muted">No fundamental reports available in the database.</td>
                                </tr>
                            <%
                                    }
                                } catch(Exception e) {
                            %>
                                <tr>
                                    <td colspan="6" class="text-center text-danger py-4">Error loading reports: <%= e.getMessage() %></td>
                                </tr>
                            <%
                                } finally {
                                    try {
                                        if (rsReport != null) rsReport.close();
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

    <!-- FOOTER -->
    <footer class="fin-footer mt-5">
        <div class="container text-center">
            <p class="mb-1 text-muted">&copy; 2026 Financial Portfolio Management System. All Rights Reserved.</p>
            <p class="small text-secondary mb-0">Fundamental Reports • Equity Valuation Analysis • Connected to MySQL</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="Resources/fintech-charts.js"></script>
    <script>
        FinTechApp.filterTable('reportSearch', 'reportTable');

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