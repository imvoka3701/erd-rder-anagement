-- =====================================================================
-- BÀI THỰC HÀNH: QUẢN LÝ ĐƠN ĐẶT HÀNG
-- HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU: MySQL / MariaDB
-- =====================================================================

DROP DATABASE IF EXISTS quan_ly_don_hang;
CREATE DATABASE quan_ly_don_hang CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE quan_ly_don_hang;

-- ---------------------------------------------------------------------
-- 1. Bảng ĐƠN VỊ KHÁCH (Đã gộp từ Đơn vị đặt hàng và Đơn vị khách hàng)
-- ---------------------------------------------------------------------
CREATE TABLE don_vi_khach (
    ma_dv VARCHAR(20) NOT NULL PRIMARY KEY,
    ten_dv VARCHAR(150) NOT NULL,
    dia_chi VARCHAR(255) NOT NULL,
    dien_thoai VARCHAR(20)
);

-- ---------------------------------------------------------------------
-- 2. Bảng NGƯỜI ĐẶT (Đại diện cho đơn vị khách đặt hàng)
-- ---------------------------------------------------------------------
CREATE TABLE nguoi_dat (
    ma_nd VARCHAR(20) NOT NULL PRIMARY KEY,
    ho_ten_nd VARCHAR(100) NOT NULL,
    ma_dv VARCHAR(20) NOT NULL,
    CONSTRAINT fk_nguoidat_donvikhach FOREIGN KEY (ma_dv) 
        REFERENCES don_vi_khach(ma_dv) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
-- 3. Bảng NGƯỜI NHẬN (Đại diện cho đơn vị khách nhận hàng)
-- ---------------------------------------------------------------------
CREATE TABLE nguoi_nhan (
    ma_nn VARCHAR(20) NOT NULL PRIMARY KEY,
    ho_ten_nn VARCHAR(100) NOT NULL,
    ma_dv VARCHAR(20) NOT NULL,
    CONSTRAINT fk_nguoinhan_donvikhach FOREIGN KEY (ma_dv) 
        REFERENCES don_vi_khach(ma_dv) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
-- 4. Bảng NGƯỜI GIAO (Nhân viên giao nhận của bên bán / kho)
-- ---------------------------------------------------------------------
CREATE TABLE nguoi_giao (
    ma_ng VARCHAR(20) NOT NULL PRIMARY KEY,
    ho_ten_ng VARCHAR(100) NOT NULL
);

-- ---------------------------------------------------------------------
-- 5. Bảng NƠI GIAO (Địa điểm giao hàng thực tế)
-- ---------------------------------------------------------------------
CREATE TABLE noi_giao (
    ma_ddg VARCHAR(20) NOT NULL PRIMARY KEY,
    ten_noi_giao VARCHAR(255) NOT NULL
);

-- ---------------------------------------------------------------------
-- 6. Bảng HÀNG (Danh mục hàng hóa)
-- ---------------------------------------------------------------------
CREATE TABLE hang (
    ma_hang VARCHAR(20) NOT NULL PRIMARY KEY,
    ten_hang VARCHAR(150) NOT NULL,
    dv_tinh VARCHAR(50) NOT NULL,
    mo_ta_hang TEXT
);

-- ---------------------------------------------------------------------
-- 7. Bảng ĐƠN ĐẶT HÀNG
-- ---------------------------------------------------------------------
CREATE TABLE don_dat_hang (
    so_dh VARCHAR(20) NOT NULL PRIMARY KEY,
    ngay_dat DATE NOT NULL,
    ma_nd VARCHAR(20) NOT NULL,
    CONSTRAINT fk_dondathang_nguoidat FOREIGN KEY (ma_nd) 
        REFERENCES nguoi_dat(ma_nd) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
-- 8. Bảng CHI TIẾT ĐƠN ĐẶT HÀNG (Giải quyết quan hệ N-N giữa Đơn hàng và Hàng)
-- ---------------------------------------------------------------------
CREATE TABLE chi_tiet_don_hang (
    so_dh VARCHAR(20) NOT NULL,
    ma_hang VARCHAR(20) NOT NULL,
    so_luong_dat INT NOT NULL CHECK (so_luong_dat > 0),
    PRIMARY KEY (so_dh, ma_hang),
    CONSTRAINT fk_ctdh_dondathang FOREIGN KEY (so_dh) 
        REFERENCES don_dat_hang(so_dh) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ctdh_hang FOREIGN KEY (ma_hang) 
        REFERENCES hang(ma_hang) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
-- 9. Bảng PHIẾU GIAO HÀNG
-- ---------------------------------------------------------------------
CREATE TABLE phieu_giao_hang (
    so_pg VARCHAR(20) NOT NULL PRIMARY KEY,
    ngay_giao DATE NOT NULL,
    so_dh VARCHAR(20) NOT NULL,
    ma_ng VARCHAR(20) NOT NULL,
    ma_nn VARCHAR(20) NOT NULL,
    ma_ddg VARCHAR(20) NOT NULL,
    CONSTRAINT fk_phieugiao_dondat FOREIGN KEY (so_dh) 
        REFERENCES don_dat_hang(so_dh) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_phieugiao_nguoigiao FOREIGN KEY (ma_ng) 
        REFERENCES nguoi_giao(ma_ng) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_phieugiao_nguoinhan FOREIGN KEY (ma_nn) 
        REFERENCES nguoi_nhan(ma_nn) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_phieugiao_noigiao FOREIGN KEY (ma_ddg) 
        REFERENCES noi_giao(ma_ddg) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
-- 10. Bảng CHI TIẾT PHIẾU GIAO (Giải quyết quan hệ N-N giữa Phiếu giao và Hàng)
-- ---------------------------------------------------------------------
CREATE TABLE chi_tiet_phieu_giao (
    so_pg VARCHAR(20) NOT NULL,
    ma_hang VARCHAR(20) NOT NULL,
    so_luong_giao INT NOT NULL CHECK (so_luong_giao > 0),
    don_gia_giao DECIMAL(15, 2) NOT NULL CHECK (don_gia_giao >= 0),
    thanh_tien DECIMAL(15, 2) GENERATED ALWAYS AS (so_luong_giao * don_gia_giao) STORED,
    PRIMARY KEY (so_pg, ma_hang),
    CONSTRAINT fk_ctpg_phieugiao FOREIGN KEY (so_pg) 
        REFERENCES phieu_giao_hang(so_pg) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ctpg_hang FOREIGN KEY (ma_hang) 
        REFERENCES hang(ma_hang) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =====================================================================
-- DỮ LIỆU MẪU (TEST DATA)
-- =====================================================================

-- 1. Đơn vị khách
INSERT INTO don_vi_khach (ma_dv, ten_dv, dia_chi, dien_thoai) VALUES
('DV01', 'Công ty TNHH Công nghệ Alpha', '123 Đường Cầu Giấy, Hà Nội', '02431234567'),
('DV02', 'Công ty Cổ phần Thương mại Beta', '456 Đường Lê Lợi, TP. Hồ Chí Minh', '02839876543'),
('DV03', 'Tập đoàn Bán lẻ Gamma', '789 Đường Nguyễn Huệ, Đà Nẵng', '02363555777');

-- 2. Người đặt
INSERT INTO nguoi_dat (ma_nd, ho_ten_nd, ma_dv) VALUES
('ND01', 'Nguyễn Văn An', 'DV01'),
('ND02', 'Trần Thị Bình', 'DV02'),
('ND03', 'Lê Hoàng Cường', 'DV03');

-- 3. Người nhận
INSERT INTO nguoi_nhan (ma_nn, ho_ten_nn, ma_dv) VALUES
('NN01', 'Phạm Minh Đức', 'DV01'),
('NN02', 'Hoàng Thu Trang', 'DV02'),
('NN03', 'Vũ Hải Đăng', 'DV03');

-- 4. Người giao
INSERT INTO nguoi_giao (ma_ng, ho_ten_ng) VALUES
('NG01', 'Đỗ Trọng Hiếu'),
('NG02', 'Ngô Quốc Tuấn');

-- 5. Nơi giao
INSERT INTO noi_giao (ma_ddg, ten_noi_giao) VALUES
('DDG01', 'Kho tổng Cầu Giấy - Tầng 1, Tòa nhà Alpha, Hà Nội'),
('DDG02', 'Trung tâm phân phối Quận 1 - TP. Hồ Chí Minh'),
('DDG03', 'Kho cảng Tiên Sa - Sơn Trà, Đà Nẵng');

-- 6. Hàng hóa
INSERT INTO hang (ma_hang, ten_hang, dv_tinh, mo_ta_hang) VALUES
('H01', 'Máy tính xách tay Dell XPS 15', 'Chiếc', 'Core i7, RAM 16GB, SSD 512GB'),
('H02', 'Màn hình Dell UltraSharp 27 inch', 'Chiếc', 'Độ phân giải 4K, IPS'),
('H03', 'Bàn phím cơ Logitech MX Mechanical', 'Cái', 'Bàn phím không dây tactile switch'),
('H04', 'Chuột Logitech MX Master 3S', 'Cái', 'Cảm biến 8000 DPI siêu êm');

-- 7. Đơn đặt hàng
INSERT INTO don_dat_hang (so_dh, ngay_dat, ma_nd) VALUES
('DH001', '2026-10-10', 'ND01'),
('DH002', '2026-10-12', 'ND02'),
('DH003', '2026-10-15', 'ND03');

-- 8. Chi tiết đơn hàng
INSERT INTO chi_tiet_don_hang (so_dh, ma_hang, so_luong_dat) VALUES
('DH001', 'H01', 5),
('DH001', 'H02', 10),
('DH002', 'H03', 20),
('DH002', 'H04', 20),
('DH003', 'H01', 3),
('DH003', 'H03', 5);

-- 9. Phiếu giao hàng
INSERT INTO phieu_giao_hang (so_pg, ngay_giao, so_dh, ma_ng, ma_nn, ma_ddg) VALUES
('PG001', '2026-10-12', 'DH001', 'NG01', 'NN01', 'DDG01'),
('PG002', '2026-10-14', 'DH001', 'NG02', 'NN01', 'DDG01'),
('PG003', '2026-10-16', 'DH002', 'NG01', 'NN02', 'DDG02');

-- 10. Chi tiết phiếu giao hàng
INSERT INTO chi_tiet_phieu_giao (so_pg, ma_hang, so_luong_giao, don_gia_giao) VALUES
('PG001', 'H01', 5, 32000000.00),
('PG002', 'H02', 10, 11500000.00),
('PG003', 'H03', 20, 3100000.00),
('PG003', 'H04', 20, 2400000.00);

-- =====================================================================
-- CÁC TRUY VẤN MẪU KIỂM TRA HỆ THỐNG
-- =====================================================================

-- 1. Xem danh sách đơn hàng cùng đơn vị và người đặt
SELECT 
    dh.so_dh AS 'Số ĐH',
    dh.ngay_dat AS 'Ngày đặt',
    nd.ho_ten_nd AS 'Người đặt',
    dv.ten_dv AS 'Đơn vị đặt hàng',
    dv.dien_thoai AS 'Điện thoại'
FROM don_dat_hang dh
JOIN nguoi_dat nd ON dh.ma_nd = nd.ma_nd
JOIN don_vi_khach dv ON nd.ma_dv = dv.ma_dv
ORDER BY dh.ngay_dat DESC;

-- 2. Xem chi tiết các mặt hàng trong Đơn đặt hàng DH001
SELECT 
    ct.so_dh AS 'Số ĐH',
    h.ma_hang AS 'Mã hàng',
    h.ten_hang AS 'Tên hàng',
    h.dv_tinh AS 'ĐVT',
    ct.so_luong_dat AS 'Số lượng đặt'
FROM chi_tiet_don_hang ct
JOIN hang h ON ct.ma_hang = h.ma_hang
WHERE ct.so_dh = 'DH001';

-- 3. Xem tổng giá trị giao theo từng Phiếu giao hàng
SELECT 
    pg.so_pg AS 'Số PG',
    pg.ngay_giao AS 'Ngày giao',
    pg.so_dh AS 'Căn cứ đơn hàng',
    ng.ho_ten_ng AS 'Người giao',
    nn.ho_ten_nn AS 'Người nhận',
    ddg.ten_noi_giao AS 'Nơi giao',
    SUM(ct.thanh_tien) AS 'Tổng tiền (VND)'
FROM phieu_giao_hang pg
JOIN nguoi_giao ng ON pg.ma_ng = ng.ma_ng
JOIN nguoi_nhan nn ON pg.ma_nn = nn.ma_nn
JOIN noi_giao ddg ON pg.ma_ddg = ddg.ma_ddg
JOIN chi_tiet_phieu_giao ct ON pg.so_pg = ct.so_pg
GROUP BY pg.so_pg, pg.ngay_giao, pg.so_dh, ng.ho_ten_ng, nn.ho_ten_nn, ddg.ten_noi_giao;
