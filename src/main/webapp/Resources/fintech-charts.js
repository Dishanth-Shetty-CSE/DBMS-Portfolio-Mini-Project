/**
 * FinTech Elite JavaScript Engine
 * Financial Portfolio Management System
 * Chart.js Integration, Timeframe Switching, Live Search & Calculations
 */

(function (window) {
  'use strict';

  const FinTechApp = {
    // Logo mapping for recognized stock symbols and company names
    getStockLogo: function (companyName) {
      if (!companyName) return 'Resources/stocks/generic.svg';
      const name = companyName.toLowerCase();
      if (name.includes('infosys') || name.includes('infy')) return 'Resources/stocks/infosys.svg';
      if (name.includes('reliance') || name.includes('ril')) return 'Resources/stocks/reliance.svg';
      if (name.includes('tata motors') || name.includes('tatamotors')) return 'Resources/stocks/tatamotors.svg';
      if (name.includes('hdfc')) return 'Resources/stocks/hdfc.svg';
      if (name.includes('wipro')) return 'Resources/stocks/wipro.svg';
      if (name.includes('tcs') || name.includes('consultancy')) return 'Resources/stocks/tcs.svg';
      if (name.includes('icici')) return 'Resources/stocks/icici.svg';
      if (name.includes('sbi') || name.includes('state bank')) return 'Resources/stocks/sbi.svg';
      if (name.includes('airtel') || name.includes('bharti')) return 'Resources/stocks/airtel.svg';
      if (name.includes('larsen') || name.includes('toubro') || name.includes('l&t')) return 'Resources/stocks/lt.svg';
      return 'Resources/stocks/generic.svg';
    },

    // Stock ticker symbol lookup
    getStockSymbol: function (companyName) {
      if (!companyName) return 'STK';
      const name = companyName.toLowerCase();
      if (name.includes('infosys')) return 'INFY';
      if (name.includes('reliance')) return 'RELIANCE';
      if (name.includes('tata motors')) return 'TATAMOTORS';
      if (name.includes('hdfc')) return 'HDFCBANK';
      if (name.includes('wipro')) return 'WIPRO';
      if (name.includes('tcs')) return 'TCS';
      if (name.includes('icici')) return 'ICICIBANK';
      if (name.includes('sbi')) return 'SBIN';
      if (name.includes('airtel') || name.includes('bharti')) return 'BHARTIARTL';
      if (name.includes('larsen') || name.includes('toubro') || name.includes('l&t')) return 'LT';
      return companyName.split(' ')[0].toUpperCase();
    },

    // Format Indian Rupees currency format
    formatCurrency: function (num) {
      const val = parseFloat(num) || 0;
      return new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR',
        maximumFractionDigits: 2
      }).format(val);
    },

    // Format number with standard abbreviations (K, L, Cr)
    formatCompactNumber: function (num) {
      const val = parseFloat(num) || 0;
      if (val >= 10000000) return '₹' + (val / 10000000).toFixed(2) + ' Cr';
      if (val >= 100000) return '₹' + (val / 100000).toFixed(2) + ' L';
      if (val >= 1000) return '₹' + (val / 1000).toFixed(2) + ' K';
      return '₹' + val.toFixed(2);
    },

    // Instant table search
    filterTable: function (inputId, tableId) {
      const input = document.getElementById(inputId);
      const table = document.getElementById(tableId);
      if (!input || !table) return;

      input.addEventListener('keyup', function () {
        const query = input.value.toLowerCase().trim();
        const tbody = table.querySelector('tbody');
        if (!tbody) return;
        const rows = tbody.getElementsByTagName('tr');

        let matchCount = 0;
        for (let i = 0; i < rows.length; i++) {
          const row = rows[i];
          if (row.classList.contains('no-data-row')) continue;
          const text = row.textContent.toLowerCase();
          if (text.includes(query)) {
            row.style.display = '';
            matchCount++;
          } else {
            row.style.display = 'none';
          }
        }
      });
    },

    // Initialize trade total calculator in real time
    initTradeCalculator: function (rateId, qtyId, totalId) {
      const rateInput = document.getElementById(rateId);
      const qtyInput = document.getElementById(qtyId);
      const totalDisplay = document.getElementById(totalId);

      if (!rateInput || !qtyInput || !totalDisplay) return;

      function update() {
        const rate = parseFloat(rateInput.value) || 0;
        const qty = parseInt(qtyInput.value, 10) || 0;
        const total = rate * qty;
        totalDisplay.textContent = FinTechApp.formatCurrency(total);
      }

      rateInput.addEventListener('input', update);
      qtyInput.addEventListener('input', update);
      update();
    },

    // Portfolio Growth Chart with Timeframe Switcher
    renderPerformanceChart: function (canvasId, baseValue) {
      const canvas = document.getElementById(canvasId);
      if (!canvas || typeof Chart === 'undefined') return;

      const ctx = canvas.getContext('2d');
      const gradient = ctx.createLinearGradient(0, 0, 0, 320);
      gradient.addColorStop(0, 'rgba(2, 132, 199, 0.35)');
      gradient.addColorStop(1, 'rgba(2, 132, 199, 0.00)');

      const v = parseFloat(baseValue) || 45000;

      // Realistic historical variations for each timeframe
      const timeframeDatasets = {
        '1D': {
          labels: ['09:15', '10:30', '11:45', '13:00', '14:15', '15:30'],
          data: [v * 0.985, v * 0.991, v * 0.989, v * 1.002, v * 1.008, v]
        },
        '1W': {
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
          data: [v * 0.962, v * 0.974, v * 0.981, v * 0.995, v]
        },
        '1M': {
          labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
          data: [v * 0.92, v * 0.945, v * 0.975, v]
        },
        '1Y': {
          labels: ['Q1', 'Q2', 'Q3', 'Q4'],
          data: [v * 0.82, v * 0.88, v * 0.94, v]
        },
        'ALL': {
          labels: ['2023', '2024', '2025', 'Current'],
          data: [v * 0.65, v * 0.78, v * 0.91, v]
        }
      };

      const chart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: timeframeDatasets['1M'].labels,
          datasets: [{
            label: 'Portfolio Valuation (₹)',
            data: timeframeDatasets['1M'].data,
            borderColor: '#0284c7',
            borderWidth: 2.5,
            fill: true,
            backgroundColor: gradient,
            pointBackgroundColor: '#0284c7',
            pointBorderColor: '#ffffff',
            pointBorderWidth: 2,
            pointRadius: 4,
            pointHoverRadius: 6,
            tension: 0.35
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { display: false },
            tooltip: {
              backgroundColor: '#0f172a',
              titleColor: '#94a3b8',
              bodyColor: '#ffffff',
              padding: 12,
              borderRadius: 8,
              callbacks: {
                label: function (context) {
                  return 'Value: ' + FinTechApp.formatCurrency(context.parsed.y);
                }
              }
            }
          },
          scales: {
            x: {
              grid: { display: false },
              ticks: { color: '#64748b', font: { family: 'Plus Jakarta Sans', size: 11 } }
            },
            y: {
              grid: { color: '#f1f5f9' },
              ticks: {
                color: '#64748b',
                font: { family: 'Plus Jakarta Sans', size: 11 },
                callback: function (val) {
                  return FinTechApp.formatCompactNumber(val);
                }
              }
            }
          }
        }
      });

      // Bind timeframe buttons
      const buttons = document.querySelectorAll('.timeframe-btn[data-tf]');
      buttons.forEach(btn => {
        btn.addEventListener('click', function () {
          buttons.forEach(b => b.classList.remove('active'));
          this.classList.add('active');
          const tf = this.getAttribute('data-tf');
          if (timeframeDatasets[tf]) {
            chart.data.labels = timeframeDatasets[tf].labels;
            chart.data.datasets[0].data = timeframeDatasets[tf].data;
            chart.update();
          }
        });
      });

      return chart;
    },

    // Sector Allocation Donut Chart
    renderAllocationChart: function (canvasId, labels, dataValues) {
      const canvas = document.getElementById(canvasId);
      if (!canvas || typeof Chart === 'undefined') return;

      const fallbackLabels = ['IT & Tech', 'Energy & Power', 'Automobile', 'Banking & Finance'];
      const fallbackData = [35, 25, 20, 20];

      const chartLabels = labels && labels.length ? labels : fallbackLabels;
      const chartData = dataValues && dataValues.length ? dataValues : fallbackData;

      const colors = ['#0284c7', '#f59e0b', '#8b5cf6', '#10b981', '#ec4899', '#3b82f6'];

      return new Chart(canvas, {
        type: 'doughnut',
        data: {
          labels: chartLabels,
          datasets: [{
            data: chartData,
            backgroundColor: colors.slice(0, chartLabels.length),
            borderColor: '#ffffff',
            borderWidth: 3,
            hoverOffset: 6
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              position: 'bottom',
              labels: {
                boxWidth: 12,
                padding: 14,
                font: { family: 'Plus Jakarta Sans', size: 11, weight: '500' },
                color: '#475569'
              }
            },
            tooltip: {
              callbacks: {
                label: function (ctx) {
                  const val = ctx.parsed;
                  return ' ' + ctx.label + ': ' + val + '%';
                }
              }
            }
          },
          cutout: '72%'
        }
      });
    },

    // Technical Signals Comparison Chart
    renderTechnicalSignalsChart: function (canvasId, labels, adxData, macdData) {
      const canvas = document.getElementById(canvasId);
      if (!canvas || typeof Chart === 'undefined') return;

      return new Chart(canvas, {
        type: 'bar',
        data: {
          labels: labels || ['INFY', 'RIL', 'TATAMOTORS', 'HDFCBANK', 'WIPRO'],
          datasets: [
            {
              label: 'ADX (Trend Strength)',
              data: adxData || [25, 20, 22, 27, 23],
              backgroundColor: '#0284c7',
              borderRadius: 6
            },
            {
              label: 'MACD (Momentum)',
              data: macdData || [30, 28, 26, 32, 29],
              backgroundColor: '#10b981',
              borderRadius: 6
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              position: 'top',
              labels: { font: { family: 'Plus Jakarta Sans', size: 11 } }
            }
          },
          scales: {
            x: { grid: { display: false } },
            y: { grid: { color: '#f1f5f9' } }
          }
        }
      });
    },

    // Validation and confirmation utilities
    showError: function (inputElement, message) {
      if (!inputElement) return;
      inputElement.classList.add('is-invalid');
      const group = inputElement.closest('.input-group');
      if (group) group.classList.add('is-invalid');

      const targetContainer = group || inputElement;
      let errDiv = targetContainer.nextElementSibling;
      if (!errDiv || !errDiv.classList.contains('fin-field-error')) {
        errDiv = document.createElement('div');
        errDiv.className = 'fin-field-error';
        targetContainer.parentNode.insertBefore(errDiv, targetContainer.nextSibling);
      }
      errDiv.innerHTML = '<i class="bi bi-exclamation-circle-fill"></i> ' + message;
      errDiv.style.display = 'flex';
    },

    clearError: function (inputElement) {
      if (!inputElement) return;
      inputElement.classList.remove('is-invalid');
      const group = inputElement.closest('.input-group');
      if (group) group.classList.remove('is-invalid');

      const targetContainer = group || inputElement;
      const errDiv = targetContainer.nextElementSibling;
      if (errDiv && errDiv.classList.contains('fin-field-error')) {
        errDiv.remove();
      }
    },

    bindLiveValidation: function (formElement) {
      if (!formElement) return;
      const inputs = formElement.querySelectorAll('input, select, textarea');
      inputs.forEach(input => {
        const handler = () => FinTechApp.clearError(input);
        input.addEventListener('input', handler);
        input.addEventListener('change', handler);
      });
    },

    confirmAction: function (title, text, confirmBtnText, onConfirm, icon) {
      if (typeof Swal !== 'undefined') {
        Swal.fire({
          title: title || 'Are you sure?',
          text: text || 'Please confirm to continue with this action.',
          icon: icon || 'question',
          showCancelButton: true,
          confirmButtonColor: '#0284c7',
          cancelButtonColor: '#64748b',
          confirmButtonText: confirmBtnText || 'Yes, proceed'
        }).then((result) => {
          if (result.isConfirmed && typeof onConfirm === 'function') {
            onConfirm();
          }
        });
      } else {
        if (confirm((title ? title + "\n" : "") + (text || "Are you sure you want to proceed?"))) {
          if (typeof onConfirm === 'function') onConfirm();
        }
      }
    }
  };

  window.FinTechApp = FinTechApp;
})(window);
