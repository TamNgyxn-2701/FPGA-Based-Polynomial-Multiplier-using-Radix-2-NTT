# Polynomial Multiplier NTT-256 Montgomery q=12289 on Cyclone II DE2

Project này triển khai bộ nhân hai đa thức bậc 127:

```text
A(x) = a0 + a1*x + ... + a127*x^127
B(x) = b0 + b1*x + ... + b127*x^127
```

Kết quả là phép nhân tuyến tính modulo `q=12289`:

```text
C(x) = A(x) * B(x) mod q
C có 255 hệ số: C[0]..C[254]
```

Thiết kế dùng:

```text
N_NTT      = 256
q          = 12289
omega      = 8340
omega^-1   = 1696
N^-1 mod q = 12241
R          = 2^16
R mod q    = 4091
R^2 mod q  = 10952
qinv       = -q^(-1) mod R = 12287
```

## Ý tưởng toán học

Hai đa thức 128 hệ số được zero-pad thành 256 hệ số. Vì tích thật có bậc tối đa `127+127=254`, NTT độ dài 256 không gây cuộn vòng kết quả. Luồng xử lý:

```text
A[0..127], B[0..127]
    -> zero-pad lên 256
    -> chuyển sang Montgomery domain
    -> Forward Radix-2 NTT DIF
    -> nhân pointwise bằng Montgomery
    -> Inverse Radix-2 NTT DIT
    -> nhân N^-1 trong NTT core
    -> chuyển khỏi Montgomery domain
    -> lưu C[0..254]
    -> hiển thị từng hệ số trên LCD 16x2
```

Forward NTT dùng DIF, inverse NTT dùng DIT để tránh phải thêm khối bit-reversal riêng.

## Cấu trúc thư mục

```text
rtl/
  mod_arith_q12289.v
  montgomery_mul_q12289.v
  twiddle_rom_256.v
  input_rom_128.v
  ntt_core_256.v
  poly_mul_ntt_core.v
  lcd_text_formatter.v
  lcd_16x2_driver.v
  top_poly_mul_lcd.v

tb/
  tb_poly_mul_ntt_core.v
  expected_c.mem

sim/
  run_modelsim.do

python/
  golden_model.py
  expected_c.txt

quartus/
  poly_ntt_lcd.qpf
  poly_ntt_lcd.qsf
  constraints.sdc
```

## Cách chạy mô phỏng ModelSim

Mở ModelSim, chuyển vào thư mục `sim/`, sau đó chạy:

```tcl
do run_modelsim.do
```

Kết quả đúng sẽ in:

```text
PASS: all 255 coefficients match golden model.
```

## Cách kiểm tra golden model Python

```bash
cd python
python golden_model.py
```

Script sẽ kiểm tra NTT so với nhân chập trực tiếp và in toàn bộ `C[0..254]`.

## Cách compile trên Quartus II

1. Mở Quartus II 13.1.
2. Open Project: `quartus/poly_ntt_lcd.qpf`.
3. Kiểm tra device là `Cyclone II EP2C35F672C6`.
4. Compile project.
5. Nạp `.sof` lên kit DE2.

## Cách chạy trên kit DE2

- `KEY[0]`: reset, active-low.
- `KEY[1]`: start, active-low.
- `SW[7:0]`: chọn chỉ số hệ số `C[index]`, từ 0 đến 254.
- LCD dòng 1: chỉ số hệ số.
- LCD dòng 2: giá trị hệ số và trạng thái `IDLE/BUSY/DONE`.
- `LEDR[0]`: busy.
- `LEDR[1]`: done.
- `LEDR[5:2]`: trạng thái FSM.
- `LEDR[17:10]`: index đang chọn.

## Thay đổi hệ số đầu vào

Sửa file:

```text
rtl/input_rom_128.v
```

Mỗi địa chỉ chứa một cặp hệ số `a_coeff`, `b_coeff`. Sau khi sửa, nên cập nhật lại golden result bằng `python/golden_model.py` hoặc chỉnh script để sinh vector mới.

## Ghi chú thiết kế

Thiết kế hiện tại dùng 3 lõi NTT nội bộ: một cho A, một cho B, một cho C/inverse. Cách này dễ hiểu, dễ mô phỏng, phù hợp báo cáo học thuật. Nếu cần tối ưu tài nguyên hơn, có thể tái sử dụng một lõi NTT duy nhất và thêm RAM trung gian/FSM điều phối.
