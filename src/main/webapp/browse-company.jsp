<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Companies - FinManage</title>
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
            <div class="ticker-item"><span class="sym">TCS</span> <span class="val">₹3,850.00</span> <span class="chg up"><i class="bi bi-arrow-up-short"></i>+2.10%</span></div>
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
                    <span class="fin-brand-sub">MARKET DIRECTORY</span>
                </div>
            </a>
            <button class="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#compNav">
                <i class="bi bi-list fs-2"></i>
            </button>
            <div class="collapse navbar-collapse" id="compNav">
                <ul class="navbar-nav ms-auto align-items-center gap-1">
                    <li class="nav-item"><a class="fin-nav-link" href="customer-dashboard.jsp"><i class="bi bi-speedometer2"></i> Dashboard</a></li>
                    <li class="nav-item"><a class="fin-nav-link active" href="browse-company.jsp"><i class="bi bi-buildings"></i> Browse Companies</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-reports.jsp"><i class="bi bi-file-earmark-bar-graph"></i> Financial Reports</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-signals.jsp"><i class="bi bi-activity"></i> Technical Signals</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-transaction.jsp"><i class="bi bi-clock-history"></i> Transactions</a></li>
                    <li class="nav-item ms-lg-2">
                        <a href="javascript:void(0)" id="clientLogoutBtn" class="fin-btn-logout"><i class="bi bi-box-arrow-right"></i> Logout</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- PAGE CONTENT -->
    <div class="container-fluid px-lg-4 py-4">

        <!-- Header & Search Toolbar -->
        <div class="d-flex justify-content-between align-items-center flex-wrap mb-4">
            <div>
                <h3 class="fw-bold mb-1 text-dark">
                    <i class="bi bi-buildings text-primary me-2"></i>Listed Companies Directory
                </h3>
                <p class="text-muted small mb-0">Explore registered enterprises, sector categorizations, and capital valuations.</p>
            </div>
            <div class="mt-3 mt-md-0 d-flex gap-2">
                <div class="input-group" style="width: 280px;">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                    <input type="text" id="companySearch" class="form-control border-start-0 fin-input" placeholder="Search company or sector...">
                </div>
                <a href="customer-dashboard.jsp" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left"></i> Dashboard
                </a>
            </div>
        </div>

        <div class="row g-4" id="companyGrid">
            <%
                DecimalFormat df = new DecimalFormat("#,##0.00");
                Connection conn = null;
                Statement st = null;
                ResultSet rsCompany = null;

                try {
                    String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
                    String user = "root";
                    String pass = "trickortreat";
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(url, user, pass);
                    st = conn.createStatement();
                    rsCompany = st.executeQuery("SELECT c.CID, c.CNAME, c.SECTOR, c.CAPITAL, COALESCE(r.LTP, 1500.0) as LTP FROM COMPANY c LEFT JOIN REPORT r ON c.CID = r.CID ORDER BY c.CAPITAL DESC");

                    while (rsCompany.next()) {
                        int cid = rsCompany.getInt("CID");
                        String cname = rsCompany.getString("CNAME");
                        String sector = rsCompany.getString("SECTOR");
                        double capital = rsCompany.getDouble("CAPITAL");
                        double ltp = rsCompany.getDouble("LTP");

                        // Logo mapping
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
                        else if (lower.contains("airtel") || lower.contains("bharti")) logo = "airtel.svg";
                        else if (lower.contains("larsen") || lower.contains("toubro") || lower.contains("l&t")) logo = "lt.svg";
            %>
                <div class="col-xl-3 col-lg-4 col-md-6 company-card-item" data-text="<%= cname.toLowerCase() %> <%= sector.toLowerCase() %>">
                    <div class="fin-card h-100">
                        <div class="fin-card-body p-4 d-flex flex-column justify-content-between">
                            <div>
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <img src="Resources/stocks/<%= logo %>" class="stock-logo" style="width: 46px; height: 46px;" alt="<%= cname %>">
                                    <span class="sector-pill"><%= sector %></span>
                                </div>
                                <h5 class="fw-bold text-dark mb-1"><%= cname %></h5>
                                <div class="text-muted small mb-3">Asset ID: #<%= cid %></div>

                                <div class="p-3 bg-light rounded-3 mb-3">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span class="text-muted small">Indicative LTP:</span>
                                        <span class="fw-bold text-dark text-mono">₹<%= df.format(ltp) %></span>
                                    </div>
                                    <div class="d-flex justify-content-between">
                                        <span class="text-muted small">Market Capital:</span>
                                        <span class="fw-bold text-primary text-mono">
                                            ₹<%= (capital >= 10000000 ? (df.format(capital / 10000000) + " Cr") : df.format(capital)) %>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex gap-2 pt-2 border-top">
                                <a href="browse-reports.jsp" class="btn btn-sm btn-outline-primary flex-fill">
                                    <i class="bi bi-file-earmark-text"></i> Reports
                                </a>
                                <a href="browse-signals.jsp" class="btn btn-sm btn-outline-success flex-fill">
                                    <i class="bi bi-activity"></i> Signals
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            <%
                    }
                } catch(Exception e) {
            %>
                <div class="col-12">
                    <div class="alert alert-danger">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i> Error loading companies: <%= e.getMessage() %>
                    </div>
                </div>
            <%
                } finally {
                    try {
                        if (rsCompany != null) rsCompany.close();
                        if (st != null) st.close();
                        if (conn != null) conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            %>
        </div>

    </div>

    <!-- FOOTER -->
    <footer class="fin-footer mt-5">
        <div class="container text-center">
            <p class="mb-1 text-muted">&copy; 2026 Financial Portfolio Management System. All Rights Reserved.</p>
            <p class="small text-secondary mb-0">Browse Companies • Real-Time Stock Analytics • Connected to MySQL</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="Resources/fintech-charts.js"></script>
    <script>
        // Instant search for card items
        const searchInput = document.getElementById('companySearch');
        if (searchInput) {
            searchInput.addEventListener('input', function() {
                const query = this.value.toLowerCase().trim();
                const cards = document.querySelectorAll('.company-card-item');
                cards.forEach(card => {
                    const text = card.getAttribute('data-text');
                    if (text.includes(query)) {
                        card.style.display = '';
                    } else {
                        card.style.display = 'none';
                    }
                });
            });
        }

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