@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Parts Composite - WM and EWM'
@VDM.viewType: #COMPOSITE

define view entity ZI_JIPV4_PartsComposite
  as select from ZI_JIPV4_Reservation as Resv

  -- Work Order Header
  left outer join ZI_JIPV4_WorkOrder as WO
    on Resv.WorkOrderNumber = WO.WorkOrderNumber

  -- EWM Plant Detection (via /SCWM/TMAPSTLOC)
  left outer join ZI_JIPV4_EWM_PlantMap as PM
    on Resv.Plant = PM.Plant

  -- Classic WM Transfer Orders
  left outer join ZI_JIPV4_TransferOrderWM as WM
    on  Resv.Plant          = WM.Plant
    and Resv.MaterialNumber = WM.MaterialNumber

  -- Goods Movement (GI Z26)
  left outer join ZI_JIPV4_GoodsMovement as GI
    on  Resv.ReservationNumber = GI.ReservationNumber
    and Resv.ReservationItem   = GI.ReservationItem

  -- EWM Product Map (bridge for material resolution)
  left outer join ZI_JIPV4_EWM_ProductMap as BM
    on Resv.MaterialNumber = BM.MaterialNumber

  -- EWM Warehouse Tasks (linked via MATID from BINMAT)
  left outer join ZI_JIPV4_EWM_WarehouseTask as EWM
    on BM.ProductGuid = EWM.ProductGuid

{
  key Resv.ReservationNumber,
  key Resv.ReservationItem,
  key Resv.ReservationCategory,

      -- Material
      Resv.MaterialNumber,
      Resv.WorkOrderNumber,
      Resv.StorageLocation,

      -- Work Order Header
      WO.Plant,
      WO.OrderType,
      WO.ActivityType,
      WO.ABCIndicator,
      WO.EquipmentNumber,
      WO.WOCreationDate,
      WO.WOReleaseDate,
      WO.SalesOrderNumber,
      WO.AppSDHDate,
      WO.SoldToParty,

      -- Quantities
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      Resv.RequirementQty,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      Resv.QtyAvailCheck,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      Resv.QtyWithdrawn,
      Resv.BaseUnit,

      -- WM/EWM Type Detection (via /SCWM/TMAPSTLOC)
      case
        when PM.WarehouseNumber is not null then 'EWM'
        else 'WM'
      end                                     as WmEwmType,

      -- Warehouse Number
      case
        when PM.WarehouseNumber is not null then PM.WarehouseNumber
        else WM.WarehouseNumber
      end                                     as WarehouseNumber,

      -- Current Milestone
      case
        when GI.PostingDate is not null        then 'GI'
        when EWM.JipMilestone = 'NPB'         then 'NPB'
        when EWM.JipMilestone = 'RECEIVED'    then 'RECEIVED'
        when EWM.JipMilestone = 'TR_REQUEST'  then 'TR_REQUEST'
        when WM.ConfirmationDate is not null  then 'WM_CONFIRMED'
        when WM.TransferOrderNo is not null   then 'TR_REQUEST'
        else 'PENDING'
      end                                     as CurrentMilestone,

      -- Milestone Dates
      WO.AppSDHDate                           as SDHApprovalDate,
      WO.WOReleaseDate                        as ReleaseDate,
      WM.TOCreationDate                       as WM_TRDate,
      WM.ConfirmationDate                     as WM_ReceivedDate,
      WM.TransferOrderNo                     as WM_TRNumber,
      EWM.ConfirmedAt                         as EWM_ConfirmedAt,
      EWM.WarehouseTaskNo                     as EWM_WTNumber,
      GI.PostingDate                          as GIDate,
      GI.MaterialDocNumber                    as GINumber,

      -- Aging: Release (SDH Approved → WO Released via AFKO-FTRMI)
      -- cast to DEC(10,2) to prevent CONVT_OVERFLOW when SADL aggregates (SUM)
      cast( case
              when WO.AppSDHDate is not null and WO.WOReleaseDate is not null
              then dats_days_between(WO.AppSDHDate, WO.WOReleaseDate)
              else 0
            end as abap.dec(10,2) )            as AgingRelease,

      -- Aging Bucket
      case
        when dats_days_between(WO.AppSDHDate, $session.system_date) >= 70 then '70+'
        when dats_days_between(WO.AppSDHDate, $session.system_date) >= 60 then '60+'
        else 'OK'
      end                                     as AgingBucket,

      -- Target Aging Days per Activity Type (hardcoded — customize per ILART)
      -- cast to DEC(10,2) to prevent CONVT_OVERFLOW when SADL aggregates (SUM)
      cast( case WO.ActivityType
              when 'ADD' then 15
              when 'INS' then 15
              when 'LOG' then 15
              when 'MID' then 15
              when 'NME' then 15
              when 'OVH' then 15
              when 'PAP' then 15
              when 'PPM' then 15
              when 'SER' then 15
              when 'TRS' then 15
              when 'UIW' then 15
              when 'USN' then 15
              else 15
            end as abap.dec(10,2) )            as TargetAgingDays,

      -- Record Count (for chart aggregation — avoids CONVT_OVERFLOW on WorkOrderNumber)
      cast(1 as abap.int4)                    as RecordCount,

      -- Period Month (YYYY-MM)
      concat(left(cast(WO.WOCreationDate as abap.char(8)), 4),
        concat('-', substring(cast(WO.WOCreationDate as abap.char(8)), 5, 2))
      )                                       as PeriodMonth,

      -- Period Year (YYYY)
      left(cast(WO.WOCreationDate as abap.char(8)), 4)
                                              as PeriodYear
}
