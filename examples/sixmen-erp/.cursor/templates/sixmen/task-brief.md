# Task Brief — SIXMEN ERP

| Field | Value |
|-------|-------|
| Task ID | |
| Artifact folder | `artifacts/{Task-ID}/` |
| Ngày | |
| Phase | GĐ 0 / GĐ 1 / ... |
| Priority | P0 / P1 / P2 |
| Human Owner | Khanh / QLVH / Vũ / CEO |
| Module chính | |

## Yêu cầu gốc

[Mô tả ngắn từ Human Owner]

## Mốc Sheet (cột C)

`M-ERP-xx · Giai đoạn X: ...`

*(Ref: `docs/ai-agent/reference/task-log-milestones.md`)*

## Dependencies

| Loại | Dependency | Status | Ghi chú |
|------|------------|--------|---------|
| Task trước | | `DONE` / `IN_PROGRESS` / `NOT_STARTED` | Task-ID nếu có |
| Phase | | `GĐ0 DONE` / `GĐ0 IN_PROGRESS` | GĐ1 cần GĐ0 xong |
| Schema (ERD) | | `EXISTS` / `MISSING` | Bảng/cột cần |
| Service | | `EXISTS` / `MISSING` | Critical service cần |

## Scope

### IN

- 

### OUT

- 

## Module ảnh hưởng

| Module | IN / OUT | Thay đổi | Lý do |
|--------|----------|----------|-------|
| | | | |

## Phân tích 4 lăng kính *(bắt buộc — scale theo Mức tư duy 0–3)*

> Áp cho MỌI task. Task vặt (Mức 0–1) ghi 1–2 dòng/lăng kính hoặc "N/A — task vặt".
> Mức 2–3 (đụng data/tiền/tồn/schema/quyền/prod) ghi đủ, **bắt buộc** bảng WBS + Rủi ro.

**Mức tư duy:** `0 / 1 / 2 / 3` *(theo `hethongtuduy` — Mức 3 nếu đụng data/tiền/tồn/schema/quyền/deploy)*

### 1. Tư duy hệ thống
- Chạm lớp nào: `lõi kỹ thuật / nền dùng chung / nghiệp vụ`
- Ảnh hưởng ngược–xuôi (task/báo cáo/GĐ sau nào bị tác động):
- Phần nào nên **dựng dùng chung** thay vì làm riêng:

### 2. Phản biện (red-team)
- Tại sao KHÔNG nên làm cách này / giả định nào có thể sai:
- Cách **tối giản hơn** (có nên làm bây giờ không):

#### 2b. Tình huống vận hành thực tế (what-if) *(bắt buộc ở task nghiệp vụ/data)*
> Chạy qua checklist — liệt kê cái nào XẢY RA THẬT với task này + xử lý (làm nay / bake schema / defer task nào).

| Tình huống | Có xảy ra? | Xử lý / để task nào |
|------------|:----------:|---------------------|
| **Trễ / chậm** (bên kia dời hẹn) | | |
| **Thiếu / dư** (nhận ≠ đặt, tồn không đủ) | | |
| **Lỗi / hỏng** (QC fail, hàng lỗi) | | |
| **Từng phần** (giao/làm/trả 1→n) | | |
| **Hủy / dừng giữa chừng** (ai được, lúc nào) | | |
| **Sửa / đổi sau khi đã duyệt / đã phát sinh** | | |
| **Hoàn / trả / đảo chiều** | | |
| **Gấp / chen ngang / ưu tiên** | | |
| **Trùng / sai / double-submit** | | |
| **Hết hạn** (HĐ, giá, giấy tờ) | | |
| **Đa chiều** (đa kho · đa pháp nhân CTY/HKD · đa đợt) | | |
| **Tranh chấp quyền / 2 người làm đồng thời** | | |

### 3. WBS (phân rã đợt kiểm được)

| Đợt | Nội dung | "Thấy được gì" | Cổng QA |
|-----|----------|----------------|---------|
| 1 | | | Pest/Pint/PHPStan |

### 4. Rủi ro

| Rủi ro | XS (T/V/C) | TĐ (T/V/C) | Giảm thiểu | Gate ai duyệt |
|--------|:--:|:--:|------------|---------------|
| | | | | |

## Definition of Done

> DoD phải pass/fail rõ, có evidence. Không dùng “dễ dùng”, “chạy mượt”, “ổn định” nếu không có cách đo.

| DoD ID | Điều kiện hoàn thành | Evidence | Owner |
|--------|----------------------|----------|-------|
| DoD-01 | | Pest / screenshot / log / checklist / approval | QA / HO |

## Envelope kiến trúc *(critical guards — tick khi domain đụng tới)*

- [ ] Policy + FormRequest; logic trong Service (không Filament/Controller/Livewire/Blade)
- [ ] **Critical only** — Tồn TP: `InventoryService` · NPL: `MaterialInventoryService` · Mã CT: `DocumentNumberService` · COGS: `CogsService`
- [ ] Movement append-only; audit khi cần; transaction khi multi-table
- [ ] Pest: happy path + **403** · PR: `architecture-compliance-checklist.md`
- [ ] **Mobile-ready** *(GĐ1+)*: endpoint tương lai → cùng Service

## Ràng buộc

- Không đổi behavior cũ (trừ khi Human Owner duyệt)
- Không đổi schema (trừ khi có migration note + duyệt)
- Chỉ 1 module chính (trừ khi task yêu cầu)
- Không mở task mốc sau nếu gate mốc trước chưa PASS

## Gate cần duyệt Human Owner

| Gate | Owner | Trạng thái | Evidence / ghi chú |
|------|-------|------------|--------------------|
| Đổi schema | Vũ + Database | N/A / PENDING / APPROVED | |
| Đổi business rule / workflow | Khanh + QLVH | N/A / PENDING / APPROVED | |
| ≥2 module | Vũ | N/A / PENDING / APPROVED | |
| Permission matrix change | QLVH | N/A / PENDING / APPROVED | |
| Data deletion / purge / retention | Human Owner | N/A / PENDING / APPROVED | |
| Production deploy | Vũ + Khanh | N/A / PENDING / APPROVED | |
| Không cần — scope đã duyệt | — | N/A / APPROVED | |

## Tài liệu tham chiếu *(schema → ERD canonical, không `03_SRS` §3 DDL)*

## Files đã đọc *(agent liệt kê trước implement — không quét toàn repo)*

- 
