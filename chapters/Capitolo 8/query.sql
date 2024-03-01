USE DB;

WITH AllDatas_CTE ([ServiceId], [DeliveryDate])
AS
(
	SELECT		[pmdm_Service_c]		AS [ServiceId]
				,[pmdm_DeliveryDate_c]	AS [DeliveryDate]
	FROM		[ServiceDelivery]
	WHERE		[IsDeleted]	= 0
	GROUP BY	[pmdm_DeliveryDate_c]
				,[pmdm_Service_c]
)
, 
Present_CTE ([ServiceId], [DeliveryDate], [PresentCount])
AS
(
	SELECT		[pmdm_Service_c]		AS [ServiceId]
				,[pmdm_DeliveryDate_c]	AS [DeliveryDate]
				,COUNT(*) AS [PresentCount]
	FROM		[ServiceDelivery]
	WHERE		[pmdm_AttendanceStatus_c] = 'Present'
	AND			[IsDeleted]	= 0
	GROUP BY	[ServiceDelivery].[pmdm_DeliveryDate_c]
				,[pmdm_Service_c]
)
, 
ExcusedAbsence_CTE ([ServiceId], [DeliveryDate], [ExcusedAbsenceCount])
AS
(
	SELECT		[pmdm_Service_c]		AS [ServiceId]
				,[pmdm_DeliveryDate_c]	AS [DeliveryDate]
				,COUNT(*) AS [ExcusedAbsenceCount]
	FROM		[ServiceDelivery]
	WHERE		[pmdm_AttendanceStatus_c] = 'Excused Absence'
	AND			[IsDeleted]	= 0
	GROUP BY	[ServiceDelivery].[pmdm_DeliveryDate_c]
				,[pmdm_Service_c]
)
, 
UnexcusedAbsence_CTE ([ServiceId], [DeliveryDate], [UnexcusedAbsenceCount])
AS
(
	SELECT		[pmdm_Service_c]		AS [ServiceId]
				,[pmdm_DeliveryDate_c]	AS [DeliveryDate]
				,COUNT(*) AS [UnexcusedAbsenceCount]
	FROM		[ServiceDelivery]
	WHERE		[pmdm_AttendanceStatus_c] = 'Unexcused Absence'
	AND			[IsDeleted]	= 0
	GROUP BY	[ServiceDelivery].[pmdm_DeliveryDate_c]
				,[pmdm_Service_c]
)
, 
Service_CTE ([ServiceId], [ProgramID], [ServiceName], [Convenzione], [TargetValueReference])
AS
(
	SELECT		[Id]						AS [ServiceId]
				,[pmdm_Program_c]			AS [ProgramID]
				,[Name]						AS [ServiceName]
				,[Convenzione_c]			AS [Convenzione]
				,[TargetValueReference_c]	AS [TargetValueReference]
	FROM		[Service]
	WHERE		[IsDeleted]	= 0
)
, 
Program_CTE ([ProgramId], [ProgramName])
AS
(
	SELECT		[Id]						AS [ProgramID]
				,[Name]						AS [ProgramName]
	FROM		[Program]
	WHERE		[IsDeleted]	= 0
)
SELECT		[Program_CTE].[ProgramName]											AS [ProgramName]
			,[Service_CTE].[ServiceName]										AS [ServiceName]
			,[Service_CTE].[Convenzione]										AS [Convenzione]
			,[Service_CTE].[TargetValueReference]								AS [TargetValueReference]
			,[AllDatas_CTE].[DeliveryDate]										AS [DeliveryDate]
			,ISNULL([Present_CTE].[PresentCount],0)								AS [PresentCount]
			,ISNULL([ExcusedAbsence_CTE].[ExcusedAbsenceCount],0)				AS [ExcusedAbsenceCount]
			,ISNULL([UnexcusedAbsence_CTE].[UnexcusedAbsenceCount],0)			AS [UnexcusedAbsenceCount]
			,(	ISNULL([Present_CTE].[PresentCount],0)
				+ ISNULL([ExcusedAbsence_CTE].[ExcusedAbsenceCount],0)
				+ ISNULL([UnexcusedAbsence_CTE].[UnexcusedAbsenceCount],0))		AS [Total]
			,[2024_Sostegno_Adulti].[TargetValue]								AS [TargetValue]
FROM		[AllDatas_CTE]
LEFT JOIN	[Present_CTE]			ON	([Present_CTE].[DeliveryDate] = [AllDatas_CTE].[DeliveryDate]
										AND [Present_CTE].[ServiceId] = [AllDatas_CTE].[ServiceId])
LEFT JOIN	[ExcusedAbsence_CTE]	ON	([ExcusedAbsence_CTE].[DeliveryDate] = [AllDatas_CTE].[DeliveryDate]
										AND [ExcusedAbsence_CTE].[ServiceId] = [AllDatas_CTE].[ServiceId])
LEFT JOIN	[UnexcusedAbsence_CTE]	ON	([UnexcusedAbsence_CTE].[DeliveryDate] = [AllDatas_CTE].[DeliveryDate]
										AND [UnexcusedAbsence_CTE].[ServiceId] = [AllDatas_CTE].[ServiceId]) 
INNER JOIN	[Service_CTE]			ON	[Service_CTE].[ServiceId] = [AllDatas_CTE].[ServiceId]
INNER JOIN	[Program_CTE]			ON	[Program_CTE].[ProgramID] = [Service_CTE].[ProgramID]
LEFT JOIN	[2024_Sostegno_Adulti]	ON	([2024_Sostegno_Adulti].[ID] = [Service_CTE].[TargetValueReference]
										AND [2024_Sostegno_Adulti].[Data] = [AllDatas_CTE].[DeliveryDate])
