# Acceptance Criteria — SIXMEN ERP

| Field | Value |
|-------|-------|
| Task ID | |
| BA | AI Business Analyst |
| Ngày | |
| Use case / UC | |

## User story

Là [role], tôi muốn [action], để [benefit].

## Acceptance Criteria

> AC phải đo được. Với mutation, cột **Then** phải ghi rõ model/chứng từ/movement/audit nào thay đổi khi thành công và Custom Exception / fail condition khi vi phạm nghiệp vụ. Nếu chưa chốt tên exception, tạo OQ thay vì tự đặt class.

| AC ID | Given (Bối cảnh) | When (Hành động) | Then (Kết quả / Exception throw nếu fail) | Evidence (Bằng chứng) | Owner |
|-------|------------------|------------------|-------------------------------------------|-----------------------|-------|
| AC-01 | | | | | |

## Mutation / Exception mapping *(nếu có ghi dữ liệu)*

| AC ID | Model / chứng từ / movement ảnh hưởng | Exception / fail condition | HTTP mapping | Ghi chú |
|-------|---------------------------------------|----------------------------|--------------|---------|
| AC-01 | | | 422 / 409 / N/A | |

## Open questions

| OQ ID | Question | Blocker | Owner | Deadline | Decision needed |
|-------|----------|---------|-------|----------|-----------------|
| OQ-01 | | Có / Không | | | |

## Tài liệu cần cập nhật

- [ ] BRD (`docs/erp/core/02_BRD.md`) — chỉ khi Human Owner yêu cầu
- [ ] SRS (`docs/erp/core/03_SRS.md`) — API/tổng quan; **schema** theo ERD canonical
- [ ] ERD (`docs/erp/phases/GD0_Nen_tang/ERD.md` hoặc `docs/erp/phases/GD1_Kho_SX/ERD.md`) — nếu đổi data shape
- [ ] Screen spec (`docs/erp/core/05_Screen_Specs.md`)
- [ ] Checklist phase (`docs/erp/phases/...`)

## User guide (nếu có)

[Mô tả ngắn thao tác cho end-user]

## Human Owner approval (business rule change)

- [ ] Đã duyệt AC / business rule
