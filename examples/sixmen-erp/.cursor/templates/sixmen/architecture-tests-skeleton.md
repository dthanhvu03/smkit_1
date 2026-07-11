# Architecture Tests Skeleton — SIXMEN ERP

| | |
|---|---|
| **Mục đích** | Mô tả test kiến trúc cần tạo **khi có repo Laravel** — repo doc này **chưa** chứa file PHP |
| **Tham chiếu** | `docs/erp/core/04_Architecture.md` §13.4 · `architecture-compliance-checklist.md` |

---

## Khi nào scaffold

- **GĐ0 xong UC-00** — trước khi merge feature GĐ1 đầu tiên (GRN, LSX, …)
- Chạy cùng CI §13.3: Pint + PHPStan + Pest

---

## Cấu trúc đề xuất (repo code)

```
tests/
├── Architecture/
│   ├── InventoryGuardTest.php      # Cấm bypass InventoryService
│   ├── EnvelopeComplianceTest.php  # GRN/PO sample gọi Policy + Service
│   └── ForbiddenPatternsTest.php     # Static scan pattern cấm
├── Feature/
└── Unit/
scripts/
└── architecture-lint.sh            # grep pattern cấm trên PR
```

---

## Test case bắt buộc (mô tả — implement sau)

### InventoryGuardTest *(critical domain)*

> Chỉ guard services được ADR đánh dấu single-entry — không scaffold test cho mọi CRUD service.

- Mock `InventoryService` khi confirm GRN / adjust stock — assert service được gọi
- Fail nếu phát hiện `Inventory::where(...)->update(` trong `Filament/` hoặc `Livewire/` *(hoặc deptrac)*

### MaterialInventoryGuardTest

- NPL mutation chỉ qua `MaterialInventoryService`
- Fail pattern: `material_inventory_balances` direct update ngoài Service

### DocumentNumberGuardTest

- PO/GRN/LSX code chỉ qua `DocumentNumberService`
- Concurrency test: không duplicate code under parallel requests

### EnvelopeComplianceTest

- User không quyền → 403 trên route Filament + API tương ứng
- User branch A → không thấy/sửa record branch B (IDOR)

### ForbiddenPatternsTest / architecture-lint.sh

| Pattern cấm | Lý do |
|-------------|--------|
| `Inventory::query()->update(` | ADR-003 |
| `material_inventory_balances` direct update | MaterialInventoryService only |
| Manual PO/GRN/LSX string concat | DocumentNumberService only |
| `$request->all()` trong Controller mutation | Mass assignment |
| `DB::raw(` + nối biến request | SQL injection risk |
| Mutation on `pgsql_reporting` | ADR-009 |

---

## CI bổ sung (snippet)

```yaml
# .github/workflows/ci.yml — sau bước php artisan test
- name: Architecture lint
  run: bash scripts/architecture-lint.sh
```

---

## Definition of Done (scaffold)

- [ ] Folder `tests/Architecture/` có ít nhất 2 test mô tả trên
- [ ] `scripts/architecture-lint.sh` chạy trên PR
- [ ] Doc link trong README repo code → `docs/sixmen/docs/erp/core/04_Architecture.md` §13.4
