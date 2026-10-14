%% Sallen-Key Filters: Each Plotted in Its Own Separate Figure
clear; clc; close all;

%% --- Low-Pass Filter (f0 target = 1 kHz) ---
R = 16e3; C = 10e-9; Rf = 5.6e3; Rg = 10e3;
K_lpf  = 1 + Rf/Rg;
w0_lpf = 1/(R*C);
f0_lpf = w0_lpf/(2*pi);
Q_lpf  = 1/(3 - K_lpf);
H_lpf  = tf(K_lpf*w0_lpf^2, [1, w0_lpf/Q_lpf, w0_lpf^2]);

%% --- High-Pass Filter (same R, C, Rf, Rg) ---
K_hpf  = K_lpf;
w0_hpf = w0_lpf;
f0_hpf = f0_lpf;
Q_hpf  = Q_lpf;
H_hpf  = tf(K_hpf*[1 0 0], [1, w0_hpf/Q_hpf, w0_hpf^2]);

%% --- Band-Pass Filter (cascaded HPF stage + LPF stage) ---
R_hp = 51e3;  K_bp_hp = 1 + 5.6e3/10e3;  w0_bp_hp = 1/(R_hp*C);  Q_bp_hp = 1/(3-K_bp_hp);
R_lp = 5.1e3; K_bp_lp = 1 + 5.6e3/10e3;  w0_bp_lp = 1/(R_lp*C);  Q_bp_lp = 1/(3-K_bp_lp);
f0_bp_hp = w0_bp_hp/(2*pi);
f0_bp_lp = w0_bp_lp/(2*pi);

H_bp_hp = tf(K_bp_hp*[1 0 0], [1, w0_bp_hp/Q_bp_hp, w0_bp_hp^2]);
H_bp_lp = tf(K_bp_lp*w0_bp_lp^2, [1, w0_bp_lp/Q_bp_lp, w0_bp_lp^2]);
H_bpf   = H_bp_hp * H_bp_lp;

%% --- Frequency sweep ---
f = logspace(1, 5, 1000);   % 10 Hz to 100 kHz
w = 2*pi*f;

mag_lpf = 20*log10(abs(squeeze(freqresp(H_lpf, w))));
mag_hpf = 20*log10(abs(squeeze(freqresp(H_hpf, w))));
mag_bpf = 20*log10(abs(squeeze(freqresp(H_bpf, w))));

%% ================= FIGURE 1: LOW-PASS ALONE =================
figure('Name', 'Low-Pass Filter');
semilogx(f, mag_lpf, 'b-', 'LineWidth', 2); hold on;
yline(20*log10(K_lpf) - 3, 'k--', '-3 dB line');
xline(f0_lpf, 'r--', sprintf('f_0 = %.1f Hz', f0_lpf));
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title(sprintf('Sallen-Key Low-Pass Filter (f_0 = %.1f Hz, Q = %.3f)', f0_lpf, Q_lpf));
xlim([10, 1e5]);

%% ================= FIGURE 2: HIGH-PASS ALONE =================
figure('Name', 'High-Pass Filter');
semilogx(f, mag_hpf, 'r-', 'LineWidth', 2); hold on;
yline(20*log10(K_hpf) - 3, 'k--', '-3 dB line');
xline(f0_hpf, 'b--', sprintf('f_0 = %.1f Hz', f0_hpf));
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title(sprintf('Sallen-Key High-Pass Filter (f_0 = %.1f Hz, Q = %.3f)', f0_hpf, Q_hpf));
xlim([10, 1e5]);

%% ================= FIGURE 3: BAND-PASS ALONE =================
figure('Name', 'Band-Pass Filter');
semilogx(f, mag_bpf, 'g-', 'LineWidth', 2); hold on;
peak_dB = max(mag_bpf);
yline(peak_dB - 3, 'k--', '-3 dB line');
xline(f0_bp_hp, 'b--', sprintf('f_{low} = %.0f Hz', f0_bp_hp));
xline(f0_bp_lp, 'r--', sprintf('f_{high} = %.0f Hz', f0_bp_lp));
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title(sprintf('Cascaded Band-Pass Filter (%.0f Hz - %.0f Hz)', f0_bp_hp, f0_bp_lp));
xlim([10, 1e5]);


figure;
semilogx(f, mag_lpf, 'b-', 'LineWidth', 1.8); hold on;
semilogx(f, mag_hpf, 'r-', 'LineWidth', 1.8);
semilogx(f, mag_bpf, 'g-', 'LineWidth', 1.8);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Sallen-Key Butterworth Filters: Low-Pass, High-Pass, Band-Pass');
legend('Low-Pass (f_0 \approx 995 Hz)', 'High-Pass (f_0 \approx 995 Hz)', ...
       'Band-Pass (312 Hz - 3.12 kHz)', 'Location', 'Best');
xlim([10, 1e5]);