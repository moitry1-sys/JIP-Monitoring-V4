# CDS View SQL Console Test Queries

Replace `'BJM'` with your plant code. Run each query in SAP SQL Console.

---

## Test 1 — ZI_JIPV4_Reservation

```sql
SELECT
  ReservationNumber,
  WorkOrderNumber,
  MaterialNumber,
  RequirementQty
FROM ZI_JIPV4_Reservation
WHERE Plant = 'BJM'
ORDER BY ReservationNumber DESC
```

---

## Test 2 — ZI_JIPV4_WorkOrder

```sql
SELECT
  WorkOrderNumber,
  OrderType,
  ABCIndicator,
  WOReleaseDate,
  AppSDHDate
FROM ZI_JIPV4_WorkOrder
WHERE Plant = 'BJM'
ORDER BY WOCreationDate DESC
```
````
SELECT
  WorkOrderNumber
FROM ZI_JIPV4_WorkOrder
WHERE WorkOrderNumber = '000051365300'
ORDER BY WOCreationDate 
````
---

## Test 3 — ZI_JIPV4_TransferOrderWM

```sql
SELECT
  TransferOrderNo,
  MaterialNumber,
  ConfirmationDate
FROM ZI_JIPV4_TransferOrderWM
WHERE Plant = 'BJM'
ORDER BY TOCreationDate DESC
```

---

## Test 4 — ZI_JIPV4_GoodsMovement

```sql
SELECT
  MaterialDocNumber,
  MaterialNumber,
  MovementType,
  ReservationNumber,
  PostingDate
FROM ZI_JIPV4_GoodsMovement
WHERE Plant = 'BJM'
ORDER BY PostingDate DESC
```
```
SELECT mblnr, mjahr, matnr, werks, bwart, aufnr, 
       rsnum, rspos, budat, cancelled
FROM matdoc 
WHERE aufnr = '000051365300' 
  AND bwart = 'Z26'
```

---

## Test 5 — ZI_JIPV4_EWM_ProductMap

```sql
SELECT
  ProductGuid,
  MaterialNumber
FROM ZI_JIPV4_EWM_ProductMap
LIMIT 50
```

```sql
SELECT
  ProductGuid,
  MaterialNumber
FROM ZI_JIPV4_EWM_ProductMap
WHERE MaterialNumber = '02896-11008'
```

---

## Test 6 — ZI_JIPV4_EWM_WarehouseTask

```sql
SELECT
  WarehouseTaskNo,
  MaterialNumber,
  JipMilestone,
  IsConfirmed
FROM ZI_JIPV4_EWM_WarehouseTask
WHERE IsConfirmed = 'X'
LIMIT 50
```

```sql
SELECT
  WarehouseTaskNo,
  ProductGuid,
  ProcessType,
  JipMilestone,
  ConfirmedAt,
  Quantity,
  UnitOfMeasure
FROM ZI_JIPV4_EWM_WarehouseTask
WHERE WarehouseTaskNo = '000000300198'
```

---

## Test 7 — ZI_JIPV4_EWM_PlantMap

```sql
SELECT
  Plant,
  StorageLocation,
  WarehouseNumber
FROM ZI_JIPV4_EWM_PlantMap
WHERE Plant = 'BJM'
```

---

## Test 8 — ZI_JIPV4_PartsComposite

```sql
SELECT
  ReservationNumber,
  WorkOrderNumber,
  MaterialNumber,
  WmEwmType,
  CurrentMilestone,
  AgingBucket
FROM ZI_JIPV4_PartsComposite
WHERE Plant = 'BJM'
ORDER BY ReservationNumber DESC
```

```sql
SELECT
  ReservationNumber,
  WorkOrderNumber,
  MaterialNumber,
  WmEwmType,
  CurrentMilestone,
  AgingBucket,
  WarehouseNumber,
  EWM_WTNumber,
  WM_TRNumber,
  GINumber
FROM ZI_JIPV4_PartsComposite
WHERE WorkOrderNumber = '000051365300'
```

---

## Test 9 — ZC_JIPV4_AGING

```sql
SELECT
  ReservationNumber,
  WorkOrderNumber,
  MaterialNumber,
  CurrentMilestone,
  AgingBucket,
  AgingCriticality
FROM ZC_JIPV4_AGING
WHERE Plant = 'BJM'
ORDER BY AgingBucket DESC
```

```sql
SELECT
  ReservationNumber,
  WorkOrderNumber,
  MaterialNumber,
  CurrentMilestone,
  AgingBucket,
  AgingCriticality,
  GINumber,
  GIDate,
  Plant
FROM ZC_JIPV4_AGING
WHERE GINumber = '4928000136'
  AND MaterialNumber = '02896-11008'
```
