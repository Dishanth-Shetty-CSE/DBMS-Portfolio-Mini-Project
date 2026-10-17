<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>FinManage - Institutional & Retail Portfolio Management System</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link
            href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,400&family=JetBrains+Mono:wght@400;500;600;700&display=swap"
            rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="Resources/fintech-theme.css">
        <style>
            .hero-banner {
                background: linear-gradient(135deg, rgba(10, 25, 47, 0.95), rgba(7, 13, 30, 0.97)), url('Resources/Land-Image.jpg') center/cover no-repeat;
                min-height: 85vh;
                display: flex;
                align-items: center;
                position: relative;
                padding: 90px 0 60px;
                color: #ffffff;
            }

            .hero-pill {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                background: rgba(2, 132, 199, 0.15);
                border: 1px solid rgba(56, 189, 248, 0.3);
                color: #38bdf8;
                padding: 6px 16px;
                border-radius: 50px;
                font-size: 0.82rem;
                font-weight: 600;
                margin-bottom: 20px;
            }

            .hero-title {
                font-size: 3.4rem;
                font-weight: 800;
                letter-spacing: -0.03em;
                line-height: 1.15;
                margin-bottom: 20px;
            }

            .hero-title span {
                background: linear-gradient(135deg, #38bdf8, #10b981);
                background-clip: text;
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }

            .hero-lead {
                font-size: 1.25rem;
                color: #94a3b8;
                max-width: 620px;
                margin-bottom: 35px;
            }

            .stat-badge {
                background: rgba(255, 255, 255, 0.05);
                border: 1px solid rgba(255, 255, 255, 0.1);
                border-radius: 12px;
                padding: 16px 20px;
                color: #fff;
            }

            .stat-badge-num {
                font-size: 1.5rem;
                font-weight: 800;
                color: #38bdf8;
                font-family: 'JetBrains Mono', monospace;
            }

            .stat-badge-lbl {
                font-size: 0.78rem;
                color: #94a3b8;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }

            .market-card {
                background: rgba(255, 255, 255, 0.04);
                border: 1px solid rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(10px);
                border-radius: 16px;
                padding: 24px;
                box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            }

            .market-subtext {
                color: #93c5fd !important;
                font-size: 0.85rem;
                font-weight: 500;
                letter-spacing: 0.02em;
            }
        </style>
    </head>

    <body>

        <!-- LIVE MARKET TICKER TAPE -->
        <div class="ticker-wrap">
            <div class="ticker-inner">
                <div class="ticker-item"><span class="sym">NIFTY 50</span> <span class="val">24,850.30</span> <span
                        class="chg up"><i class="bi bi-arrow-up-short"></i>+142.15 (+0.58%)</span></div>
                <div class="ticker-item"><span class="sym">SENSEX</span> <span class="val">81,224.75</span> <span
                        class="chg up"><i class="bi bi-arrow-up-short"></i>+488.30 (+0.60%)</span></div>
                <div class="ticker-item"><span class="sym">INFY</span> <span class="val">₹1,520.50</span> <span
                        class="chg up"><i class="bi bi-arrow-up-short"></i>+1.85%</span></div>
                <div class="ticker-item"><span class="sym">RELIANCE</span> <span class="val">₹2,580.00</span> <span
                        class="chg up"><i class="bi bi-arrow-up-short"></i>+0.92%</span></div>
                <div class="ticker-item"><span class="sym">TATAMOTORS</span> <span class="val">₹745.20</span> <span
                        class="chg down"><i class="bi bi-arrow-down-short"></i>-0.45%</span></div>
                <div class="ticker-item"><span class="sym">HDFCBANK</span> <span class="val">₹1,640.00</span> <span
                        class="chg up"><i class="bi bi-arrow-up-short"></i>+1.20%</span></div>
                <div class="ticker-item"><span class="sym">WIPRO</span> <span class="val">₹1,315.00</span> <span
                        class="chg down"><i class="bi bi-arrow-down-short"></i>-0.15%</span></div>
                <div class="ticker-item"><span class="sym">TCS</span> <span class="val">₹3,850.00</span> <span
                        class="chg up"><i class="bi bi-arrow-up-short"></i>+2.10%</span></div>
                <!-- Duplicate for seamless continuous ticker loop -->
                <div class="ticker-item"><span class="sym">NIFTY 50</span> <span class="val">24,850.30</span> <span
                        class="chg up"><i class="bi bi-arrow-up-short"></i>+142.15 (+0.58%)</span></div>
                <div class="ticker-item"><span class="sym">SENSEX</span> <span class="val">81,224.75</span> <span
                        class="chg up"><i class="bi bi-arrow-up-short"></i>+488.30 (+0.60%)</span></div>
                <div class="ticker-item"><span class="sym">INFY</span> <span class="val">₹1,520.50</span> <span
                        class="chg up"><i class="bi bi-arrow-up-short"></i>+1.85%</span></div>
                <div class="ticker-item"><span class="sym">RELIANCE</span> <span class="val">₹2,580.00</span> <span
                        class="chg up"><i class="bi bi-arrow-up-short"></i>+0.92%</span></div>
            </div>
        </div>

        <!-- MAIN NAVBAR -->
        <nav class="navbar navbar-expand-lg fin-navbar">
            <div class="container">
                <a class="fin-brand" href="index.jsp">
                    <div class="fin-brand-logo">
                        <i class="bi bi-graph-up-arrow"></i>
                    </div>
                    <div class="fin-brand-name">
                        <span>FinManage</span>
                        <span class="fin-brand-sub">PORTFOLIO INTELLIGENCE</span>
                    </div>
                </a>
                <button class="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse"
                    data-bs-target="#mainNav">
                    <i class="bi bi-list fs-2"></i>
                </button>
                <div class="collapse navbar-collapse" id="mainNav">
                    <ul class="navbar-nav ms-auto align-items-center gap-1">
                        <li class="nav-item"><a class="fin-nav-link active" href="index.jsp"><i
                                    class="bi bi-house-door"></i> Home</a></li>
                        <li class="nav-item"><a class="fin-nav-link" href="#features"><i class="bi bi-cpu"></i>
                                Features</a></li>
                        <li class="nav-item"><a class="fin-nav-link" href="#why"><i class="bi bi-shield-check"></i> Why
                                Us</a></li>
                        <li class="nav-item ms-lg-2"><a class="fin-btn fin-btn-outline py-2 px-3 text-white"
                                style="background: rgba(255,255,255,0.08); border-color: rgba(255,255,255,0.15);"
                                href="login.jsp"><i class="bi bi-box-arrow-in-right"></i> Client Login</a></li>
                        <li class="nav-item ms-lg-1"><a class="fin-btn fin-btn-emerald py-2 px-3" href="register.jsp"><i
                                    class="bi bi-person-plus"></i> Open Account</a></li>
                        <li class="nav-item ms-lg-1"><a
                                class="fin-btn fin-btn-outline py-2 px-3 text-warning border-warning"
                                style="background: rgba(245,158,11,0.08);" href="admin-login.jsp"><i
                                    class="bi bi-shield-lock"></i> Admin</a></li>
                    </ul>
                </div>
            </div>
        </nav>

        <!-- HERO SECTION -->
        <header class="hero-banner" id="home">
            <div class="container">
                <div class="row align-items-center gy-5">
                    <div class="col-lg-7">
                        <div class="hero-pill">
                            <i class="bi bi-lightning-charge-fill"></i> Next-Gen Institutional Wealth Engine
                        </div>
                        <h1 class="hero-title">
                            Smarter Portfolio Management, <span>Real-Time Edge.</span>
                        </h1>
                        <p class="hero-lead">
                            Track live holdings, analyze technical indicators (ADX, MACD, Volume), evaluate fundamentals
                            (EPS, ROE), and execute transactions with bank-grade security.
                        </p>
                        <div class="d-flex flex-wrap gap-3 mb-5">
                            <a href="login.jsp" class="fin-btn fin-btn-primary px-4 py-3 fs-6">
                                <i class="bi bi-speedometer2"></i> Launch Client Terminal
                            </a>
                            <a href="register.jsp" class="fin-btn fin-btn-outline px-4 py-3 fs-6 text-white"
                                style="background: rgba(255,255,255,0.08); border-color: rgba(255,255,255,0.2);">
                                <i class="bi bi-person-check"></i> Register Free
                            </a>
                            <a href="admin-login.jsp" class="fin-btn fin-btn-outline px-4 py-3 fs-6 text-warning"
                                style="background: rgba(245,158,11,0.1); border-color: rgba(245,158,11,0.3);">
                                <i class="bi bi-key-fill"></i> Administrator
                            </a>
                        </div>
                        <div class="row g-3">
                            <div class="col-sm-4">
                                <div class="stat-badge">
                                    <div class="stat-badge-num">₹240Cr+</div>
                                    <div class="stat-badge-lbl">Market Capital Tracked</div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="stat-badge">
                                    <div class="stat-badge-num">99.99%</div>
                                    <div class="stat-badge-lbl">System Reliability</div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="stat-badge">
                                    <div class="stat-badge-num">256-Bit</div>
                                    <div class="stat-badge-lbl">Encrypted Database</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-5">
                        <div class="market-card">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5 class="m-0 text-white font-weight-bold"><i
                                        class="bi bi-graph-up text-info me-2"></i>Live Market Pulse</h5>
                                <span class="badge bg-success"><i class="bi bi-circle-fill me-1"
                                        style="font-size: 6px;"></i> MARKET OPEN</span>
                            </div>
                            <div class="list-group list-group-flush bg-transparent">
                                <div
                                    class="list-group-item bg-transparent text-white border-secondary d-flex justify-content-between align-items-center py-3">
                                    <div class="d-flex align-items-center gap-3">
                                        <img src="Resources/stocks/infosys.svg" width="36" height="36" class="rounded"
                                            alt="INFY">
                                        <div>
                                            <div class="fw-bold">Infosys Ltd</div>
                                            <div class="market-subtext" style="color: #93c5fd !important; font-size: 0.85rem; font-weight: 500;">IT • NSE: INFY</div>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <div class="fw-bold text-mono">₹1,520.50</div>
                                        <span class="badge bg-success-subtle text-success">+1.85%</span>
                                    </div>
                                </div>
                                <div
                                    class="list-group-item bg-transparent text-white border-secondary d-flex justify-content-between align-items-center py-3">
                                    <div class="d-flex align-items-center gap-3">
                                        <img src="Resources/stocks/reliance.svg" width="36" height="36" class="rounded"
                                            alt="RIL">
                                        <div>
                                            <div class="fw-bold">Reliance Industries</div>
                                            <div class="market-subtext" style="color: #93c5fd !important; font-size: 0.85rem; font-weight: 500;">Energy • NSE: RELIANCE</div>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <div class="fw-bold text-mono">₹2,580.00</div>
                                        <span class="badge bg-success-subtle text-success">+0.92%</span>
                                    </div>
                                </div>
                                <div
                                    class="list-group-item bg-transparent text-white border-secondary d-flex justify-content-between align-items-center py-3">
                                    <div class="d-flex align-items-center gap-3">
                                        <img src="Resources/stocks/tatamotors.svg" width="36" height="36"
                                            class="rounded" alt="TATAMOTORS">
                                        <div>
                                            <div class="fw-bold">Tata Motors</div>
                                            <div class="market-subtext" style="color: #93c5fd !important; font-size: 0.85rem; font-weight: 500;">Automobile • NSE: TATAMTR</div>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <div class="fw-bold text-mono">₹745.20</div>
                                        <span class="badge bg-danger-subtle text-danger">-0.45%</span>
                                    </div>
                                </div>
                                <div
                                    class="list-group-item bg-transparent text-white border-0 d-flex justify-content-between align-items-center py-3">
                                    <div class="d-flex align-items-center gap-3">
                                        <img src="Resources/stocks/hdfc.svg" width="36" height="36" class="rounded"
                                            alt="HDFCBANK">
                                        <div>
                                            <div class="fw-bold">HDFC Bank</div>
                                            <div class="market-subtext" style="color: #93c5fd !important; font-size: 0.85rem; font-weight: 500;">Banking • NSE: HDFCBANK</div>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <div class="fw-bold text-mono">₹1,640.00</div>
                                        <span class="badge bg-success-subtle text-success">+1.20%</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <!-- KEY FEATURES SECTION -->
        <section class="py-5 bg-white" id="features">
            <div class="container py-4">
                <div class="text-center max-w-700 mx-auto mb-5">
                    <span class="text-primary fw-bold text-uppercase small tracking-wide">Integrated Capabilities</span>
                    <h2 class="fw-bold mt-1">Institutional-Grade FinTech Ecosystem</h2>
                    <p class="text-muted">Designed for wealth managers, high-net-worth investors, and financial
                        analysts.</p>
                </div>

                <div class="row g-4">
                    <div class="col-lg-4 col-md-6">
                        <div class="kpi-card h-100">
                            <div class="kpi-icon-box kpi-icon-blue mb-3">
                                <i class="bi bi-activity"></i>
                            </div>
                            <h5 class="fw-bold mb-2">Live Portfolio Valuation</h5>
                            <p class="text-muted mb-0">Real-time calculations of invested capital, total market value,
                                unrealized profit & loss, and percentage return.</p>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="kpi-card h-100">
                            <div class="kpi-icon-box kpi-icon-emerald mb-3">
                                <i class="bi bi-pie-chart-fill"></i>
                            </div>
                            <h5 class="fw-bold mb-2">Asset Allocation Analytics</h5>
                            <p class="text-muted mb-0">Dynamic interactive visual donuts revealing exposure across
                                Information Technology, Energy, Automobile, and Banking sectors.</p>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="kpi-card h-100">
                            <div class="kpi-icon-box kpi-icon-purple mb-3">
                                <i class="bi bi-sliders"></i>
                            </div>
                            <h5 class="fw-bold mb-2">Technical Signals Radar</h5>
                            <p class="text-muted mb-0">Monitor Trend Strength with Average Directional Index (ADX),
                                Momentum via MACD, and real-time market volume indicators.</p>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="kpi-card h-100">
                            <div class="kpi-icon-box kpi-icon-amber mb-3">
                                <i class="bi bi-file-earmark-bar-graph"></i>
                            </div>
                            <h5 class="fw-bold mb-2">Fundamental Reports</h5>
                            <p class="text-muted mb-0">Deep financial metrics including Last Traded Price (LTP),
                                Earnings Per Share (EPS), and Return on Equity (ROE).</p>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="kpi-card h-100">
                            <div class="kpi-icon-box kpi-icon-blue mb-3">
                                <i class="bi bi-arrow-left-right"></i>
                            </div>
                            <h5 class="fw-bold mb-2">Instant Order Execution</h5>
                            <p class="text-muted mb-0">Execute BUY and SELL transactions with real-time rate validation,
                                quantity accounting, and transaction auditing.</p>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="kpi-card h-100">
                            <div class="kpi-icon-box kpi-icon-emerald mb-3">
                                <i class="bi bi-shield-check"></i>
                            </div>
                            <h5 class="fw-bold mb-2">Admin Command Center</h5>
                            <p class="text-muted mb-0">Dedicated management suite for companies, technical indicators,
                                fundamental balance sheets, and user management.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- WHY CHOOSE FINMANAGE -->
        <section class="py-5" id="why" style="background: #f8fafc;">
            <div class="container py-4">
                <div class="text-center max-w-700 mx-auto mb-5">
                    <span class="text-primary fw-bold text-uppercase small tracking-wide">Enterprise Quality</span>
                    <h2 class="fw-bold mt-1">Why Leading Investors Trust FinManage</h2>
                    <p class="text-muted">Built with robust database integrity, modern security standards, and
                        crystal-clear analytics.</p>
                </div>

                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="fin-card h-100">
                            <img src="Resources/Data-Security.jpg" class="card-img-top"
                                style="height: 220px; object-fit: cover;" alt="Data Security">
                            <div class="fin-card-body">
                                <h5 class="fw-bold text-dark"><i class="bi bi-lock-fill text-primary me-2"></i>Data
                                    Security First</h5>
                                <p class="text-muted mb-0">Parameterized SQL transactions, strict role isolation,
                                    session integrity, and encrypted database connections keep every rupee secure.</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="fin-card h-100">
                            <img src="Resources/Real-Time-Analytics.jpg" class="card-img-top"
                                style="height: 220px; object-fit: cover;" alt="Real-Time Analytics">
                            <div class="fin-card-body">
                                <h5 class="fw-bold text-dark"><i class="bi bi-cpu-fill text-success me-2"></i>Real-Time
                                    Insights</h5>
                                <p class="text-muted mb-0">Gain immediate visual clarity through interactive trading
                                    charts, live asset allocation donuts, and automatic sector exposure breakdowns.</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="fin-card h-100">
                            <img src="Resources/Expert-Support.avif" class="card-img-top"
                                style="height: 220px; object-fit: cover;" alt="Expert Support">
                            <div class="fin-card-body">
                                <h5 class="fw-bold text-dark"><i class="bi bi-headset text-warning me-2"></i>Continuous
                                    Reliability</h5>
                                <p class="text-muted mb-0">Engineered with MySQL database relational constraints,
                                    foreign keys, cascading integrity, and high-performance querying.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- CALL TO ACTION BANNER -->
        <section class="py-5" style="background: linear-gradient(135deg, #0a192f, #0f2444); color: white;">
            <div class="container py-4 text-center">
                <h2 class="fw-bold mb-3">Ready to Elevate Your Investment Management?</h2>
                <p class="lead text-light mb-4 max-w-600 mx-auto" style="opacity: 0.9;">Join today or launch the
                    terminal to experience institutional-grade portfolio oversight.</p>
                <div class="d-flex justify-content-center gap-3 flex-wrap">
                    <a href="register.jsp" class="fin-btn fin-btn-emerald px-4 py-3 fs-6">
                        <i class="bi bi-person-plus-fill"></i> Create Free Account
                    </a>
                    <a href="login.jsp" class="fin-btn fin-btn-outline px-4 py-3 fs-6 text-white"
                        style="background: rgba(255,255,255,0.1); border-color: rgba(255,255,255,0.2);">
                        <i class="bi bi-box-arrow-in-right"></i> Sign In to Dashboard
                    </a>
                </div>
            </div>
        </section>

        <!-- FOOTER -->
        <footer class="fin-footer mt-0">
            <div class="container text-center">
                <div class="d-flex align-items-center justify-content-center gap-2 mb-3">
                    <div class="fin-brand-logo" style="width: 32px; height: 32px; font-size: 1rem;">
                        <i class="bi bi-graph-up-arrow"></i>
                    </div>
                    <span class="text-white fw-bold fs-5">FinManage</span>
                </div>
                <p class="mb-2 text-muted">&copy; 2026 Financial Portfolio Management System. All Rights Reserved.</p>
                <p class="small text-secondary mb-0">Empowered by MySQL Relational Database • Java Servlets & JSP •
                    FinTech Elite UI</p>
            </div>
        </footer>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="Resources/fintech-charts.js"></script>
    </body>

    </html>