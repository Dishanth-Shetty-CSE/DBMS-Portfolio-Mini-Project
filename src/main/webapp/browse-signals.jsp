<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Technical Signals & Momentum - FinManage</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="Resources/fintech-theme.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
                    <span class="fin-brand-sub">QUANTITATIVE LAB</span>
                </div>
            </a>
            <button class="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#sigNav">
                <i class="bi bi-list fs-2"></i>
            </button>
            <div class="collapse navbar-collapse" id="sigNav">
                <ul class="navbar-nav ms-auto align-items-center gap-1">
                    <li class="nav-item"><a class="fin-nav-link" href="customer-dashboard.jsp"><i class="bi bi-speedometer2"></i> Dashboard</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-company.jsp"><i class="bi bi-buildings"></i> Browse Companies</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-reports.jsp"><i class="bi bi-file-earmark-bar-graph"></i> Financial Reports</a></li>
                    <li class="nav-item"><a class="fin-nav-link active" href="browse-signals.jsp"><i class="bi bi-activity"></i> Technical Signals</a></li>
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

        <%
            DecimalFormat df = new DecimalFormat("#,##0.00");
            DecimalFormat dfInt = new DecimalFormat("#,##0");
            Connection conn = null;
            Statement st = null;
            ResultSet rsSignals = null;

            List<String> rawLabels = new ArrayList<String>();
            List<String> rawAdx = new ArrayList<String>();
            List<String> rawMacd = new ArrayList<String>();

            // Temporary list to hold records for table display
            List<Map<String, Object>> signalRecords = new ArrayList<Map<String, Object>>();

            try {
                String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                String user = "root";
                String pass = "trickortreat";
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, user, pass);
                st = conn.createStatement();
                rsSignals = st.executeQuery("SELECT c.CNAME, t.ADX, t.VOLUME, t.MACD FROM TECHNICAL_SIGNALS t JOIN COMPANY c ON t.CID = c.CID ORDER BY t.ADX DESC");

                while (rsSignals.next()) {
                    String cname = rsSignals.getString("CNAME");
                    double adx = rsSignals.getDouble("ADX");
                    int volume = rsSignals.getInt("VOLUME");
                    double macd = rsSignals.getDouble("MACD");

                    rawLabels.add(cname.split(" ")[0]);
                    rawAdx.add(String.valueOf(adx));
                    rawMacd.add(String.valueOf(macd));

                    Map<String, Object> rec = new HashMap<String, Object>();
                    rec.put("cname", cname);
                    rec.put("adx", adx);
                    rec.put("volume", volume);
                    rec.put("macd", macd);
                    signalRecords.add(rec);
                }
            } catch(Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    if (rsSignals != null) rsSignals.close();
                    if (st != null) st.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        %>

        <!-- Header & Toolbar -->
        <div class="d-flex justify-content-between align-items-center flex-wrap mb-4">
            <div>
                <h3 class="fw-bold mb-1 text-dark">
                    <i class="bi bi-radar text-primary me-2"></i>Quantitative Technical Signals
                </h3>
                <p class="text-muted small mb-0">Trend Strength (ADX), Momentum (MACD), and Liquidity Volume across listed stocks.</p>
            </div>
            <div class="mt-3 mt-md-0 d-flex gap-2">
                <div class="input-group" style="width: 280px;">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                    <input type="text" id="signalSearch" class="form-control border-start-0 fin-input" placeholder="Search signals...">
                </div>
                <a href="customer-dashboard.jsp" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left"></i> Dashboard
                </a>
            </div>
        </div>

        <!-- TECHNICAL INDICATORS COMPARISON CHART -->
        <div class="fin-card mb-4">
            <div class="fin-card-header">
                <h5 class="fin-card-title">
                    <i class="bi bi-bar-chart-fill text-primary"></i> ADX vs MACD Comparative Momentum Chart
                </h5>
                <span class="badge bg-light text-secondary border">Technical Analysis</span>
            </div>
            <div class="fin-card-body">
                <div style="height: 260px; position: relative;">
                    <canvas id="techChart" 
                            data-labels="<%= String.join(",", rawLabels) %>" 
                            data-adx="<%= String.join(",", rawAdx) %>" 
                            data-macd="<%= String.join(",", rawMacd) %>"></canvas>
                </div>
            </div>
        </div>

        <!-- SIGNALS DATA TABLE -->
        <div class="fin-card">
            <div class="fin-card-body p-0">
                <div class="table-responsive">
                    <table class="fin-table" id="signalTable">
                        <thead>
                            <tr>
                                <th>Company Name</th>
                                <th class="text-center">ADX (Trend Strength)</th>
                                <th class="text-end">Trading Volume</th>
                                <th class="text-center">MACD Indicator</th>
                                <th class="text-center">Trend Signal</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (!signalRecords.isEmpty()) {
                                    for (Map<String, Object> rec : signalRecords) {
                                        String cname = (String) rec.get("cname");
                                        double adx = (Double) rec.get("adx");
                                        int volume = (Integer) rec.get("volume");
                                        double macd = (Double) rec.get("macd");

                                        boolean isStrong = adx >= 25.0;
                                        boolean isBullish = macd >= 28.0;

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
                                                <div class="stock-name">Technical Signal ID</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge <%= isStrong ? "bg-primary text-white" : "bg-light text-dark border" %> px-3 py-2 text-mono fs-6">
                                            <%= df.format(adx) %>
                                        </span>
                                    </td>
                                    <td class="text-end text-mono fw-bold">
                                        <%= dfInt.format(volume) %>
                                        <span class="small text-muted d-block font-normal">shares</span>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge <%= isBullish ? "bg-success-subtle text-success border border-success-subtle" : "bg-warning-subtle text-warning border" %> px-3 py-2 text-mono fs-6">
                                            <%= df.format(macd) %>
                                        </span>
                                    </td>
                                    <td class="text-center">
                                        <% if (isStrong && isBullish) { %>
                                            <span class="badge bg-success text-white py-2 px-3">
                                                <i class="bi bi-lightning-charge-fill me-1"></i> STRONG BUY
                                            </span>
                                        <% } else if (isBullish) { %>
                                            <span class="badge bg-primary text-white py-2 px-3">
                                                <i class="bi bi-arrow-up-right me-1"></i> BULLISH
                                            </span>
                                        <% } else { %>
                                            <span class="badge bg-secondary text-white py-2 px-3">
                                                <i class="bi bi-dash me-1"></i> CONSOLIDATION
                                            </span>
                                        <% } %>
                                    </td>
                                </tr>
                            <%
                                    }
                                } else {
                            %>
                                <tr class="no-data-row">
                                    <td colspan="5" class="text-center py-4 text-muted">No technical signals available.</td>
                                </tr>
                            <%
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
            <p class="small text-secondary mb-0">Technical Signals • Quantitative Indicators & ADX Momentum • Connected to MySQL</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="Resources/fintech-charts.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            FinTechApp.filterTable('signalSearch', 'signalTable');

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

            const canvas = document.getElementById('techChart');
            if (canvas) {
                const labelsAttr = canvas.getAttribute('data-labels') || '';
                const adxAttr = canvas.getAttribute('data-adx') || '';
                const macdAttr = canvas.getAttribute('data-macd') || '';

                const labels = labelsAttr ? labelsAttr.split(',') : [];
                const adxData = adxAttr ? adxAttr.split(',').map(Number) : [];
                const macdData = macdAttr ? macdAttr.split(',').map(Number) : [];

                FinTechApp.renderTechnicalSignalsChart('techChart', labels, adxData, macdData);
            }
        });
    </script>
</body>
</html>