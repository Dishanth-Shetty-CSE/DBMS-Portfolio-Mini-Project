<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portfolio Dashboard - FinManage Wealth Terminal</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,400&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
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
                    <span class="fin-brand-sub">PORTFOLIO TERMINAL</span>
                </div>
            </a>
            <button class="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#dashNav">
                <i class="bi bi-list fs-2"></i>
            </button>
            <div class="collapse navbar-collapse" id="dashNav">
                <ul class="navbar-nav ms-auto align-items-center gap-1">
                    <li class="nav-item"><a class="fin-nav-link active" href="customer-dashboard.jsp"><i class="bi bi-speedometer2"></i> Dashboard</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-company.jsp"><i class="bi bi-buildings"></i> Browse Companies</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-reports.jsp"><i class="bi bi-file-earmark-bar-graph"></i> Financial Reports</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-signals.jsp"><i class="bi bi-activity"></i> Technical Signals</a></li>
                    <li class="nav-item"><a class="fin-nav-link" href="browse-transaction.jsp"><i class="bi bi-clock-history"></i> Transactions</a></li>
                    
                    <!-- Quick Trade Action Button -->
                    <li class="nav-item ms-xl-2">
                        <button type="button" class="fin-btn fin-btn-emerald py-1 px-3 text-nowrap" data-bs-toggle="modal" data-bs-target="#quickTradeModal">
                            <i class="bi bi-plus-circle"></i> Quick Trade
                        </button>
                    </li>

                    <!-- User Identity Pill -->
                    <li class="nav-item ms-lg-2">
                        <div class="fin-user-pill">
                            <div class="fin-user-avatar">
                                <i class="bi bi-person-fill"></i>
                            </div>
                            <span class="fw-semibold">
                                <%= (session.getAttribute("loggedInUserName") != null) ? session.getAttribute("loggedInUserName") : "Investor" %>
                            </span>
                        </div>
                    </li>

                    <!-- Logout Button -->
                    <li class="nav-item ms-lg-2">
                        <a href="javascript:void(0)" id="clientLogoutBtn" class="fin-btn-logout">
                            <i class="bi bi-box-arrow-right"></i> Logout
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- MAIN DASHBOARD CONTENT -->
    <div class="container-fluid px-lg-4 py-4">

        <%
            String url = "jdbc:mysql://localhost:3306/FINANCIAL_DB";
            String user = "root";
            String pass = "trickortreat";
            Connection conn = null;

            int uid = 1;
            if (session.getAttribute("loggedInUserId") != null) {
                try {
                    uid = Integer.parseInt(session.getAttribute("loggedInUserId").toString());
                } catch (NumberFormatException e) {
                    session.invalidate();
                    response.sendRedirect("login.jsp");
                    return;
                }
            }

            String currentUserName = "Investor";
            String currentUserPhone = "Not registered";

            double totalInvested = 0.0;
            double totalCurrentVal = 0.0;
            int totalTransactionsCount = 0;
            Map<String, Double> sectorWeights = new HashMap<String, Double>();
            List<Map<String, Object>> userHoldings = new ArrayList<Map<String, Object>>();

            DecimalFormat df = new DecimalFormat("#,##0.00");

            String currentUserEmail = (session.getAttribute("loggedInUserEmail") != null) ? session.getAttribute("loggedInUserEmail").toString() : "";

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, user, pass);

                PreparedStatement psUser = conn.prepareStatement("SELECT * FROM USER WHERE UID = ?");
                psUser.setInt(1, uid);
                ResultSet rsUser = psUser.executeQuery();
                if (rsUser.next()) {
                    currentUserName = rsUser.getString("USERNAME");
                    currentUserPhone = rsUser.getString("PHONE");
                    try {
                        String em = rsUser.getString("CUST_EMAIL");
                        if (em != null && !em.isEmpty()) currentUserEmail = em;
                    } catch (Exception ex) {}
                }
                rsUser.close();
                psUser.close();

                String transSql = "SELECT t.CID, c.CNAME, c.SECTOR, t.RATE, t.QUANTITY, t.BUY_SELL, " +
                                  "COALESCE(r.LTP, t.RATE) as CURRENT_LTP " +
                                  "FROM TRANSACTION t " +
                                  "JOIN COMPANY c ON t.CID = c.CID " +
                                  "LEFT JOIN REPORT r ON c.CID = r.CID " +
                                  "WHERE t.UID = ? ORDER BY t.TID ASC";
                PreparedStatement psMetrics = conn.prepareStatement(transSql);
                psMetrics.setInt(1, uid);
                ResultSet rsMetrics = psMetrics.executeQuery();

                Map<Integer, Integer> companyQtyMap = new HashMap<Integer, Integer>();
                Map<Integer, Double> companyCostMap = new HashMap<Integer, Double>();
                Map<Integer, String> companyNameMap = new HashMap<Integer, String>();
                Map<Integer, String> companySectorMap = new HashMap<Integer, String>();
                Map<Integer, Double> companyLtpMap = new HashMap<Integer, Double>();

                while (rsMetrics.next()) {
                    totalTransactionsCount++;
                    int cid = rsMetrics.getInt("CID");
                    String cname = rsMetrics.getString("CNAME");
                    String sector = rsMetrics.getString("SECTOR");
                    double rate = rsMetrics.getDouble("RATE");
                    int qty = rsMetrics.getInt("QUANTITY");
                    String buySell = rsMetrics.getString("BUY_SELL");
                    double currentLtp = rsMetrics.getDouble("CURRENT_LTP");

                    companyNameMap.put(cid, cname);
                    companySectorMap.put(cid, sector);
                    companyLtpMap.put(cid, currentLtp);

                    int prevQty = companyQtyMap.getOrDefault(cid, 0);
                    double prevCost = companyCostMap.getOrDefault(cid, 0.0);

                    if ("BUY".equalsIgnoreCase(buySell)) {
                        companyQtyMap.put(cid, prevQty + qty);
                        companyCostMap.put(cid, prevCost + (rate * qty));
                    } else {
                        companyQtyMap.put(cid, Math.max(0, prevQty - qty));
                        if (prevQty > 0) {
                            double avgCost = prevCost / prevQty;
                            companyCostMap.put(cid, Math.max(0.0, prevCost - (avgCost * qty)));
                        }
                    }
                }
                rsMetrics.close();
                psMetrics.close();

                for (Integer cid : companyQtyMap.keySet()) {
                    int qty = companyQtyMap.get(cid);
                    if (qty > 0) {
                        double cost = companyCostMap.get(cid);
                        double ltp = companyLtpMap.get(cid);
                        double currentVal = qty * ltp;

                        totalInvested += cost;
                        totalCurrentVal += currentVal;

                        String sector = companySectorMap.get(cid);
                        sectorWeights.put(sector, sectorWeights.getOrDefault(sector, 0.0) + currentVal);

                        Map<String, Object> holding = new HashMap<String, Object>();
                        holding.put("cid", cid);
                        holding.put("cname", companyNameMap.get(cid));
                        holding.put("sector", sector);
                        holding.put("qty", qty);
                        holding.put("avgRate", (cost / qty));
                        holding.put("ltp", ltp);
                        holding.put("currentVal", currentVal);
                        holding.put("pnl", (currentVal - cost));
                        holding.put("pnlPct", cost > 0 ? (((currentVal - cost) / cost) * 100) : 0.0);
                        userHoldings.add(holding);
                    }
                }

                if (totalInvested == 0.0 && totalCurrentVal == 0.0) {
                    totalInvested = 15000.00;
                    totalCurrentVal = 16850.00;
                }

                double totalPnl = totalCurrentVal - totalInvested;
                double totalReturnPct = totalInvested > 0 ? ((totalPnl / totalInvested) * 100) : 0.0;
                boolean isProfitable = totalPnl >= 0;

                // Prepare sector string data for HTML attribute
                List<String> secLabels = new ArrayList<String>();
                List<String> secVals = new ArrayList<String>();
                for (String sKey : sectorWeights.keySet()) {
                    secLabels.add(sKey);
                    secVals.add(String.valueOf(sectorWeights.get(sKey)));
                }
        %>

        <!-- WELCOME BANNER & STATUS -->
        <div class="row align-items-center mb-4">
            <div class="col-md-8">
                <h3 class="fw-bold mb-1 text-dark">
                    Welcome, <%= currentUserName %>! 
                    <span class="badge bg-success-subtle text-success fs-6 fw-semibold ms-2 align-middle">
                        <i class="bi bi-patch-check-fill"></i> Verified Portfolio
                    </span>
                </h3>
                <p class="text-muted mb-0 small">
                    <i class="bi bi-envelope text-primary me-1"></i> Email: <strong><%= (!currentUserEmail.isEmpty() ? currentUserEmail : "client" + uid + "@finmanage.com") %></strong> &nbsp;|&nbsp; 
                    <i class="bi bi-person-badge text-secondary me-1"></i> UID: <strong>#<%= uid %></strong> &nbsp;|&nbsp; 
                    <i class="bi bi-telephone text-secondary me-1"></i> Phone: <strong><%= currentUserPhone %></strong> &nbsp;|&nbsp; 
                    <i class="bi bi-shield-check text-success me-1"></i> Status: <strong class="text-success">Active Trading</strong>
                </p>
            </div>
            <div class="col-md-4 text-md-end mt-3 mt-md-0">
                <button type="button" class="fin-btn fin-btn-primary" data-bs-toggle="modal" data-bs-target="#quickTradeModal">
                    <i class="bi bi-lightning-charge-fill"></i> Place New Order
                </button>
            </div>
        </div>

        <!-- EXECUTIVE KPI METRIC CARDS -->
        <div class="row g-3 mb-4">
            <div class="col-xl-3 col-sm-6">
                <div class="kpi-card kpi-blue">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <div class="kpi-title">Current Portfolio Value</div>
                        <div class="kpi-icon-box kpi-icon-blue">
                            <i class="bi bi-wallet2"></i>
                        </div>
                    </div>
                    <div class="kpi-value">₹<%= df.format(totalCurrentVal) %></div>
                    <div class="kpi-badge <%= isProfitable ? "up" : "down" %>">
                        <i class="bi <%= isProfitable ? "bi-arrow-up-right" : "bi-arrow-down-right" %>"></i>
                        <%= isProfitable ? "+" : "" %><%= df.format(totalReturnPct) %>% Overall
                    </div>
                </div>
            </div>

            <div class="col-xl-3 col-sm-6">
                <div class="kpi-card kpi-purple">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <div class="kpi-title">Total Invested Capital</div>
                        <div class="kpi-icon-box kpi-icon-purple">
                            <i class="bi bi-safe2"></i>
                        </div>
                    </div>
                    <div class="kpi-value">₹<%= df.format(totalInvested) %></div>
                    <div class="small text-muted">
                        <i class="bi bi-cash-stack me-1"></i> In <%= userHoldings.size() %> Active Assets
                    </div>
                </div>
            </div>

            <div class="col-xl-3 col-sm-6">
                <div class="kpi-card <%= isProfitable ? "kpi-emerald" : "kpi-rose" %>">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <div class="kpi-title">Unrealized P&L</div>
                        <div class="kpi-icon-box <%= isProfitable ? "kpi-icon-emerald" : "kpi-icon-amber" %>">
                            <i class="bi <%= isProfitable ? "bi-graph-up-arrow" : "bi-graph-down-arrow" %>"></i>
                        </div>
                    </div>
                    <div class="kpi-value <%= isProfitable ? "text-success" : "text-danger" %>">
                        <%= isProfitable ? "+₹" : "-₹" %><%= df.format(Math.abs(totalPnl)) %>
                    </div>
                    <div class="kpi-badge <%= isProfitable ? "up" : "down" %>">
                        <i class="bi <%= isProfitable ? "bi-arrow-up" : "bi-arrow-down" %>"></i>
                        <%= isProfitable ? "+" : "" %><%= df.format(totalReturnPct) %>% Net Gain
                    </div>
                </div>
            </div>

            <div class="col-xl-3 col-sm-6">
                <div class="kpi-card kpi-amber">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <div class="kpi-title">Executed Trades</div>
                        <div class="kpi-icon-box kpi-icon-amber">
                            <i class="bi bi-arrow-left-right"></i>
                        </div>
                    </div>
                    <div class="kpi-value"><%= totalTransactionsCount %></div>
                    <div class="small text-muted">
                        <i class="bi bi-check-circle-fill text-success me-1"></i> Order Book Synced
                    </div>
                </div>
            </div>
        </div>

        <!-- CHARTS SECTION: PERFORMANCE & ASSET ALLOCATION -->
        <div class="row g-4 mb-4">
            <!-- Portfolio Growth Area Chart -->
            <div class="col-lg-8">
                <div class="fin-card h-100">
                    <div class="fin-card-header">
                        <h5 class="fin-card-title">
                            <i class="bi bi-graph-up text-primary"></i> Investment Valuation Over Time
                        </h5>
                        <div class="timeframe-group">
                            <button type="button" class="timeframe-btn" data-tf="1D">1D</button>
                            <button type="button" class="timeframe-btn" data-tf="1W">1W</button>
                            <button type="button" class="timeframe-btn active" data-tf="1M">1M</button>
                            <button type="button" class="timeframe-btn" data-tf="1Y">1Y</button>
                            <button type="button" class="timeframe-btn" data-tf="ALL">ALL</button>
                        </div>
                    </div>
                    <div class="fin-card-body">
                        <div style="height: 300px; position: relative;">
                            <canvas id="performanceChart" data-val="<%= totalCurrentVal %>"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Sector Allocation Donut Chart -->
            <div class="col-lg-4">
                <div class="fin-card h-100">
                    <div class="fin-card-header">
                        <h5 class="fin-card-title">
                            <i class="bi bi-pie-chart text-primary"></i> Sector Allocation
                        </h5>
                        <span class="badge bg-light text-secondary border">Diversification</span>
                    </div>
                    <div class="fin-card-body">
                        <div style="height: 270px; position: relative;">
                            <canvas id="allocationChart" 
                                    data-labels="<%= String.join(",", secLabels) %>" 
                                    data-values="<%= String.join(",", secVals) %>"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- CURRENT HOLDINGS TABLE -->
        <div class="fin-card mb-4">
            <div class="fin-card-header">
                <h5 class="fin-card-title">
                    <i class="bi bi-briefcase-fill text-primary"></i> Portfolio Holdings & Asset Summary
                </h5>
                <div class="d-flex gap-2">
                    <input type="text" id="holdingSearch" class="form-control form-control-sm" placeholder="Filter holdings..." style="width: 180px;">
                    <a href="browse-transaction.jsp" class="btn btn-sm btn-outline-primary">Order History</a>
                </div>
            </div>
            <div class="fin-card-body p-0">
                <div class="table-responsive">
                    <table class="fin-table" id="holdingsTable">
                        <thead>
                            <tr>
                                <th>Asset / Stock</th>
                                <th>Sector</th>
                                <th class="text-end">Quantity</th>
                                <th class="text-end">Avg Buy Price</th>
                                <th class="text-end">Current LTP</th>
                                <th class="text-end">Current Value</th>
                                <th class="text-end">Unrealized P&L</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (userHoldings.isEmpty()) {
                            %>
                                <tr class="no-data-row">
                                    <td colspan="7" class="text-center py-4 text-muted">
                                        <i class="bi bi-inbox fs-3 d-block mb-2"></i>
                                        No active holdings found in your portfolio. Use the "Quick Trade" button to place your first order.
                                    </td>
                                </tr>
                            <%
                                } else {
                                    for (Map<String, Object> h : userHoldings) {
                                        String hName = (String) h.get("cname");
                                        String hSector = (String) h.get("sector");
                                        int hQty = (Integer) h.get("qty");
                                        double hAvg = (Double) h.get("avgRate");
                                        double hLtp = (Double) h.get("ltp");
                                        double hVal = (Double) h.get("currentVal");
                                        double hPnl = (Double) h.get("pnl");
                                        double hPnlPct = (Double) h.get("pnlPct");
                                        boolean hProfitable = hPnl >= 0;

                                        String logoFile = "generic.svg";
                                        String hLower = hName.toLowerCase();
                                        if (hLower.contains("infosys")) logoFile = "infosys.svg";
                                        else if (hLower.contains("reliance")) logoFile = "reliance.svg";
                                        else if (hLower.contains("tata motors")) logoFile = "tatamotors.svg";
                                        else if (hLower.contains("hdfc")) logoFile = "hdfc.svg";
                                        else if (hLower.contains("wipro")) logoFile = "wipro.svg";
                                        else if (hLower.contains("tcs")) logoFile = "tcs.svg";
                                        else if (hLower.contains("icici")) logoFile = "icici.svg";
                                        else if (hLower.contains("sbi")) logoFile = "sbi.svg";
                            %>
                                <tr>
                                    <td>
                                        <div class="stock-info">
                                            <img src="Resources/stocks/<%= logoFile %>" class="stock-logo" alt="<%= hName %>">
                                            <div>
                                                <div class="stock-symbol"><%= hName %></div>
                                                <div class="stock-name">CID: #<%= h.get("cid") %></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td><span class="sector-pill"><%= hSector %></span></td>
                                    <td class="text-end text-mono fw-bold"><%= hQty %></td>
                                    <td class="text-end text-mono">₹<%= df.format(hAvg) %></td>
                                    <td class="text-end text-mono fw-bold">₹<%= df.format(hLtp) %></td>
                                    <td class="text-end text-mono fw-bold">₹<%= df.format(hVal) %></td>
                                    <td class="text-end">
                                        <div class="fw-bold text-mono <%= hProfitable ? "text-success" : "text-danger" %>">
                                            <%= hProfitable ? "+₹" : "-₹" %><%= df.format(Math.abs(hPnl)) %>
                                        </div>
                                        <div class="small <%= hProfitable ? "text-success" : "text-danger" %>">
                                            <%= hProfitable ? "+" : "" %><%= df.format(hPnlPct) %>%
                                        </div>
                                    </td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- MARKET STOCKS & TECHNICAL ANALYSIS SUMMARY -->
        <div class="row g-4 mb-4">
            <!-- Available Market Stocks Card -->
            <div class="col-lg-6">
                <div class="fin-card h-100">
                    <div class="fin-card-header">
                        <h5 class="fin-card-title">
                            <i class="bi bi-buildings text-primary"></i> Market Assets Directory
                        </h5>
                        <a href="browse-company.jsp" class="btn btn-sm btn-outline-primary">View All</a>
                    </div>
                    <div class="fin-card-body p-0">
                        <div class="list-group list-group-flush">
                            <%
                                Statement stComp = conn.createStatement();
                                ResultSet rsComp = stComp.executeQuery("SELECT c.*, COALESCE(r.LTP, 1000.0) as LTP FROM COMPANY c LEFT JOIN REPORT r ON c.CID = r.CID LIMIT 5");
                                while (rsComp.next()) {
                                    String cName = rsComp.getString("CNAME");
                                    String cSector = rsComp.getString("SECTOR");
                                    double cCap = rsComp.getDouble("CAPITAL");
                                    double cLtp = rsComp.getDouble("LTP");

                                    String compLogo = "generic.svg";
                                    String compLower = cName.toLowerCase();
                                    if (compLower.contains("infosys")) compLogo = "infosys.svg";
                                    else if (compLower.contains("reliance")) compLogo = "reliance.svg";
                                    else if (compLower.contains("tata motors")) compLogo = "tatamotors.svg";
                                    else if (compLower.contains("hdfc")) compLogo = "hdfc.svg";
                                    else if (compLower.contains("wipro")) compLogo = "wipro.svg";
                                    else if (compLower.contains("tcs")) compLogo = "tcs.svg";
                                    else if (compLower.contains("icici")) compLogo = "icici.svg";
                                    else if (compLower.contains("sbi")) compLogo = "sbi.svg";
                                    else if (compLower.contains("airtel") || compLower.contains("bharti")) compLogo = "airtel.svg";
                                    else if (compLower.contains("larsen") || compLower.contains("toubro") || compLower.contains("l&t")) compLogo = "lt.svg";
                            %>
                                <div class="list-group-item d-flex justify-content-between align-items-center py-3 px-4">
                                    <div class="d-flex align-items-center gap-3">
                                        <img src="Resources/stocks/<%= compLogo %>" class="stock-logo" alt="<%= cName %>">
                                        <div>
                                            <div class="fw-bold text-dark"><%= cName %></div>
                                            <div class="small text-muted">Sector: <span class="badge bg-light text-dark"><%= cSector %></span></div>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <div class="fw-bold text-mono">₹<%= df.format(cLtp) %></div>
                                        <div class="small text-muted">Cap: ₹<%= (cCap >= 10000000 ? (df.format(cCap / 10000000) + " Cr") : df.format(cCap)) %></div>
                                    </div>
                                </div>
                            <%
                                }
                                rsComp.close();
                                stComp.close();
                            %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Technical Signals Radar Card -->
            <div class="col-lg-6">
                <div class="fin-card h-100">
                    <div class="fin-card-header">
                        <h5 class="fin-card-title">
                            <i class="bi bi-radar text-primary"></i> Technical Signals & Momentum
                        </h5>
                        <a href="browse-signals.jsp" class="btn btn-sm btn-outline-primary">All Signals</a>
                    </div>
                    <div class="fin-card-body p-0">
                        <div class="table-responsive">
                            <table class="fin-table">
                                <thead>
                                    <tr>
                                        <th>Company</th>
                                        <th class="text-center">ADX (Strength)</th>
                                        <th class="text-center">MACD</th>
                                        <th class="text-center">Signal Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        Statement stSig = conn.createStatement();
                                        ResultSet rsSig = stSig.executeQuery(
                                            "SELECT t.*, c.CNAME FROM TECHNICAL_SIGNALS t JOIN COMPANY c ON t.CID = c.CID LIMIT 5");
                                        while (rsSig.next()) {
                                            String sCompName = rsSig.getString("CNAME");
                                            double adx = rsSig.getDouble("ADX");
                                            double macd = rsSig.getDouble("MACD");
                                            boolean isBullish = macd > 28;
                                    %>
                                        <tr>
                                            <td class="fw-semibold"><%= sCompName %></td>
                                            <td class="text-center text-mono">
                                                <span class="badge bg-primary-subtle text-primary"><%= df.format(adx) %></span>
                                            </td>
                                            <td class="text-center text-mono">
                                                <span class="badge <%= isBullish ? "bg-success-subtle text-success" : "bg-warning-subtle text-warning" %>">
                                                    <%= df.format(macd) %>
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge <%= isBullish ? "bg-success text-white" : "bg-secondary text-white" %>">
                                                    <i class="bi <%= isBullish ? "bi-arrow-up-circle-fill" : "bi-dash-circle" %> me-1"></i>
                                                    <%= isBullish ? "BULLISH" : "NEUTRAL" %>
                                                </span>
                                            </td>
                                        </tr>
                                    <%
                                        }
                                        rsSig.close();
                                        stSig.close();
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- RECENT EXECUTED TRANSACTIONS CARD -->
        <div class="fin-card mb-4">
            <div class="fin-card-header">
                <h5 class="fin-card-title">
                    <i class="bi bi-clock-history text-primary"></i> Your Recent Executed Trades
                </h5>
                <a href="browse-transaction.jsp" class="btn btn-sm btn-outline-primary">Full Order Ledger</a>
            </div>
            <div class="fin-card-body p-0">
                <div class="table-responsive">
                    <table class="fin-table">
                        <thead>
                            <tr>
                                <th>Trade ID</th>
                                <th>Company</th>
                                <th>Action</th>
                                <th class="text-end">Execution Rate</th>
                                <th class="text-end">Quantity</th>
                                <th class="text-end">Total Amount</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                PreparedStatement psTransList = conn.prepareStatement(
                                    "SELECT t.*, c.CNAME FROM TRANSACTION t JOIN COMPANY c ON t.CID = c.CID WHERE t.UID = ? ORDER BY t.TID DESC LIMIT 5");
                                psTransList.setInt(1, uid);
                                ResultSet rsTransList = psTransList.executeQuery();

                                if (!rsTransList.isBeforeFirst()) {
                            %>
                                <tr>
                                    <td colspan="7" class="text-center py-4 text-muted">
                                        No transactions recorded yet for this client account.
                                    </td>
                                </tr>
                            <%
                                } else {
                                    while (rsTransList.next()) {
                                        int tid = rsTransList.getInt("TID");
                                        String tcname = rsTransList.getString("CNAME");
                                        double rate = rsTransList.getDouble("RATE");
                                        int qty = rsTransList.getInt("QUANTITY");
                                        String action = rsTransList.getString("BUY_SELL");
                                        double tradeTotal = rate * qty;
                            %>
                                <tr>
                                    <td class="text-mono text-muted">#TRX-<%= tid %></td>
                                    <td class="fw-bold"><%= tcname %></td>
                                    <td>
                                        <span class="<%= "BUY".equalsIgnoreCase(action) ? "badge-buy" : "badge-sell" %>">
                                            <i class="bi <%= "BUY".equalsIgnoreCase(action) ? "bi-arrow-down-left" : "bi-arrow-up-right" %>"></i>
                                            <%= action %>
                                        </span>
                                    </td>
                                    <td class="text-end text-mono">₹<%= df.format(rate) %></td>
                                    <td class="text-end text-mono"><%= qty %></td>
                                    <td class="text-end text-mono fw-bold">₹<%= df.format(tradeTotal) %></td>
                                    <td>
                                        <span class="badge bg-success-subtle text-success border border-success-subtle">
                                            <i class="bi bi-check2-all"></i> Settled
                                        </span>
                                    </td>
                                </tr>
                            <%
                                    }
                                }
                                rsTransList.close();
                                psTransList.close();
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- QUICK TRADE MODAL -->
        <div class="modal fade" id="quickTradeModal" tabindex="-1" aria-labelledby="tradeModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow-lg rounded-4">
                    <div class="modal-header bg-dark text-white rounded-top-4 py-3">
                        <h5 class="modal-title fs-6 fw-bold" id="tradeModalLabel">
                            <i class="bi bi-lightning-charge-fill text-warning me-2"></i>Execute Market Order
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form id="quickTradeForm" action="manage-transactions.jsp" method="POST" novalidate>
                        <div class="modal-body p-4">
                            <input type="hidden" name="uid" value="<%= uid %>">
                            
                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">Select Stock / Asset</label>
                                <select name="cid" id="tradeCid" class="form-select fin-input" required>
                                    <option value="">-- Choose Company --</option>
                                    <%
                                        Statement stSelect = conn.createStatement();
                                        ResultSet rsSelect = stSelect.executeQuery("SELECT CID, CNAME, CAPITAL FROM COMPANY ORDER BY CNAME ASC");
                                        while (rsSelect.next()) {
                                    %>
                                        <option value="<%= rsSelect.getInt("CID") %>">
                                            <%= rsSelect.getString("CNAME") %> (CID: <%= rsSelect.getInt("CID") %>)
                                        </option>
                                    <%
                                        }
                                        rsSelect.close();
                                        stSelect.close();
                                    %>
                                </select>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-6">
                                    <label class="form-label small fw-bold text-secondary">Order Type</label>
                                    <select name="buy_sell" class="form-select fin-input" required>
                                        <option value="BUY" selected>BUY (Long)</option>
                                        <option value="SELL">SELL (Exit)</option>
                                    </select>
                                </div>
                                <div class="col-6">
                                    <label class="form-label small fw-bold text-secondary">Execution Rate (₹)</label>
                                    <input type="number" step="0.01" name="rate" id="tradeRate" class="form-control fin-input" placeholder="e.g. 1500" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">Quantity (Shares)</label>
                                <input type="number" name="quantity" id="tradeQty" class="form-control fin-input" placeholder="e.g. 10" min="1" required>
                            </div>

                            <!-- Live Value Estimation Box -->
                            <div class="p-3 bg-light rounded-3 border d-flex justify-content-between align-items-center">
                                <span class="small text-muted fw-semibold">Estimated Total Value:</span>
                                <span class="fw-bold fs-5 text-primary text-mono" id="tradeTotalDisplay">₹0.00</span>
                            </div>
                        </div>
                        <div class="modal-footer bg-light rounded-bottom-4 py-3">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="fin-btn fin-btn-emerald px-4">
                                <i class="bi bi-check2-circle"></i> Confirm & Execute
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%
                conn.close();
            } catch(Exception e) {
                out.println("<div class='alert alert-danger my-4'><i class='bi bi-exclamation-triangle-fill me-2'></i>Database Error: " + e.getMessage() + "</div>");
                e.printStackTrace();
            }
        %>

    </div>

    <!-- FOOTER -->
    <footer class="fin-footer mt-5">
        <div class="container text-center">
            <p class="mb-1 text-muted">&copy; 2026 Financial Portfolio Management System. All Rights Reserved.</p>
            <p class="small text-secondary mb-0">Client Dashboard • Institutional FinTech Execution Engine • Connected to MySQL</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="Resources/fintech-charts.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            // Initialize Performance Chart
            const perfCanvas = document.getElementById('performanceChart');
            const baseVal = perfCanvas ? parseFloat(perfCanvas.getAttribute('data-val')) || 45000 : 45000;
            FinTechApp.renderPerformanceChart('performanceChart', baseVal);

            // Initialize Sector Allocation Donut Chart
            const allocCanvas = document.getElementById('allocationChart');
            if (allocCanvas) {
                const labelsAttr = allocCanvas.getAttribute('data-labels') || '';
                const valsAttr = allocCanvas.getAttribute('data-values') || '';
                const sectorLabels = labelsAttr ? labelsAttr.split(',') : [];
                const sectorData = valsAttr ? valsAttr.split(',').map(Number) : [];
                FinTechApp.renderAllocationChart('allocationChart', sectorLabels, sectorData);
            }

            // Instant holdings search
            FinTechApp.filterTable('holdingSearch', 'holdingsTable');

            // Quick Trade Total Calculator
            FinTechApp.initTradeCalculator('tradeRate', 'tradeQty', 'tradeTotalDisplay');

            // Client Logout Confirmation
            const logoutBtn = document.getElementById('clientLogoutBtn');
            if (logoutBtn) {
                logoutBtn.addEventListener('click', function () {
                    FinTechApp.confirmAction(
                        'Sign Out Confirmation',
                        'Are you sure you want to log out of your wealth portfolio terminal?',
                        'Yes, Sign Out',
                        function () {
                            window.location.href = 'login.jsp';
                        },
                        'warning'
                    );
                });
            }

            // Quick Trade Form Validation & Confirmation
            const tradeForm = document.getElementById('quickTradeForm');
            if (tradeForm) {
                FinTechApp.bindLiveValidation(tradeForm);
                tradeForm.addEventListener('submit', function (e) {
                    e.preventDefault();
                    const cid = document.getElementById('tradeCid');
                    const rate = document.getElementById('tradeRate');
                    const qty = document.getElementById('tradeQty');
                    const buySell = tradeForm.querySelector('select[name="buy_sell"]').value;

                    FinTechApp.clearError(cid);
                    FinTechApp.clearError(rate);
                    FinTechApp.clearError(qty);

                    let isValid = true;
                    if (!cid.value) {
                        FinTechApp.showError(cid, 'Please select a company/stock.');
                        isValid = false;
                    }
                    if (!rate.value || parseFloat(rate.value) <= 0) {
                        FinTechApp.showError(rate, 'Please specify a valid execution rate greater than 0.');
                        isValid = false;
                    }
                    if (!qty.value || parseInt(qty.value, 10) <= 0) {
                        FinTechApp.showError(qty, 'Quantity must be at least 1 share.');
                        isValid = false;
                    }

                    if (isValid) {
                        const stockName = cid.options[cid.selectedIndex].text;
                        const totalVal = (parseFloat(rate.value) * parseInt(qty.value, 10)).toFixed(2);
                        FinTechApp.confirmAction(
                            'Confirm Market Order',
                            'Are you sure you want to place a ' + buySell + ' order for ' + qty.value + ' shares of ' + stockName + ' at ₹' + rate.value + ' (Total: ₹' + totalVal + ')?',
                            'Yes, Execute Order',
                            function () {
                                tradeForm.submit();
                            },
                            'question'
                        );
                    }
                });
            }
        });
    </script>
</body>
</html>