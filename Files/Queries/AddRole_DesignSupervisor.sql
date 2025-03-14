use J_AdakStudio
go
ALTER PROC [dbo].[usp_FactorChangeStatus]
@FactorId BIGINT,
@CurrentStatus BIGINT,
@NewStatus BIGINT,
@CauserId BIGINT,
@UpdateDesigner BIT,
@DesignerId BIGINT,
@Mes NVARCHAR(1001) OUT,
@HasError INT out
AS
SET @Mes=''
SET @HasError=0
DECLARE @RoleId BIGINT=0
SELECT @RoleId=P_RoleId FROM dbo.Vi_Personnel WHERE P_ID=@CauserId
DECLARE @CurrentDesignerId BIGINT=0
SELECT 
	@CurrentDesignerId=F_DesignerId
FROM dbo.Vi_Factor 
WHERE F_ID=@FactorId

IF @CurrentDesignerId=0 SET @CurrentDesignerId=null

DECLARE @NewStatPari INT=0
DECLARE @CurrentStatPari INT=0
SELECT @NewStatPari=D_Priority FROM dbo.Vi_Data WHERE D_ID=@NewStatus
SELECT @CurrentStatPari=D_Priority FROM dbo.Vi_Data WHERE D_ID=@CurrentStatus

--اینجا باید وضعیت پرداخت فاکتور چک شود
IF @RoleId IN(4,5) AND @NewStatus=26
	BEGIN
		DECLARE @PaidPrice DECIMAL(18,0)=0
		DECLARE @DiscountPrice DECIMAL(18,0)=0
		DECLARE @GiftPrice DECIMAL(18,0)=0
		DECLARE @SumPrice DECIMAL(18,0)=0
		SELECT 
			@PaidPrice=ISNULL(fs.PaidPrice,0),
			@DiscountPrice=ISNULL(f.F_SumDiscountPrice,0),
			@SumPrice=f.F_SumPrice
		FROM dbo.Vi_Factor f
		LEFT JOIN dbo.Vi_FactorSummery fs
		ON fs.FactorId=f.F_Id
		WHERE f.F_Id=@FactorId 

		SELECT @GiftPrice=SUM(FD_SumPrice) FROM dbo.Vi_FactorDetail WHERE FD_FactorId=@FactorId AND FD_IsGift=1

		SET @SumPrice=@SumPrice-ISNULL(@GiftPrice,0)
		SET @DiscountPrice=@DiscountPrice-ISNULL(@GiftPrice,0)

		IF (((@DiscountPrice+@PaidPrice)*100)/@SumPrice)<50
			BEGIN
				SET @Mes=N'باید 50 درصد فاکتور تسویه شده باشد تا بتونید وضعیت آن را به در دست طراحی تغییر بدین'
				SET @HasError=1
				RETURN 0
			END

	END
--بخوان وضعیت رو بعد از در دست طراحی بذارند
--و طراح مشخص نباشد
ELSE IF @RoleId IN(4,5) AND @NewStatPari>4 AND @CurrentDesignerId IS NULL
	BEGIN
		SET @Mes=N'طراحی فاکتور مشخص نیست'
		SET @HasError=1
		RETURN 0
	END
else if @RoleId in (3,5) and @CurrentDesignerId IS NULL and @NewStatPari>=4 --اگر طراح یا سرپرست طراحی بود نباید بتونه قبل از اینکه طراحیش مشخص نیست در وضعیت های بالاتر قرار بده
	begin
		SET @Mes=N'طراح فاکتور مشخص نیست امکان تغییر وضعیت را ندارید'
		SET @HasError=1
		RETURN 0
	end	
ELSE IF @RoleId in(3,6)--طراح
	BEGIN
		IF @CurrentStatus=29 AND @CurrentStatus!=@NewStatus
			BEGIN
				SET @Mes=N'طراح امکان تغییر وضعیت فاکتور از ارسال به چاپخانه به وضعیت های دیگر را ندارد'
				SET @HasError=1
				RETURN 0
			END
	END
--وضعیت های بیعانه نداده - فاکتور ناقص -- آماده برای طراحی
--IF @NewStatus in (26,24,25)
--	BEGIN
--		SET @UpdateDesigner=1
--		SET @DesignerId=null
--	END

IF @UpdateDesigner=1 AND (@DesignerId IS NULL OR @DesignerId=0)
	SET @DesignerId=@CauserId

IF @NewStatus IN (24,25,26) --وضعیت های بیعانه نداده - ناقص و در دست طراحی
	BEGIN 
		SET @UpdateDesigner=1
		SET @DesignerId=null
	END
--تغییر وضعیت
UPDATE dbo.Tb_Factor
	SET F_Status=@NewStatus,
		F_DesignerId=(CASE WHEN @UpdateDesigner=1 THEN @DesignerId ELSE F_DesignerId end)
WHERE F_ID=@FactorId

DECLARE @LogText NVARCHAR(1001)=N'تغییر وضعیت از '
SELECT @LogText+=D_Title+N' به ' FROM dbo.Vi_Data WHERE D_ID=@CurrentStatus
SELECT @LogText+=D_Title+N' توسط ' FROM dbo.Vi_Data WHERE D_ID=@NewStatus
SELECT @LogText+=FullName FROM dbo.Vi_Personnel WHERE P_ID=@CauserId

declare @LogId bigint
INSERT INTO dbo.Tb_FactorLog
(
    FL_FactorId,
    FL_LogText,
    FL_CauserId,
    FL_CreationTime
)
VALUES
(   @FactorId,        -- FL_FactorId - bigint
    @LogText,      -- FL_LogText - nvarchar(4000)
    @CauserId,        -- FL_CauserId - bigint
    GETDATE() -- FL_CreationTime - datetime
    )

set @LogId=scope_identity()

update dbo.Tb_Factor set F_LastLogId=@LogId where F_ID=@FactorId
go
ALTER PROC [dbo].[usp_FactorsNotArchive_For_Tracking]
@SearchText NVARCHAR(1001),
@FromDate VARCHAR(10),
@ToDate VARCHAR(10),
@CauserId BIGINT
AS
IF @CauserId=0 SET @CauserId=NULL
IF LEN(LTRIM(RTRIM(@FromDate)))<10 SET @FromDate=NULL
IF LEN(LTRIM(RTRIM(@ToDate)))<10 SET @ToDate=NULL
IF LEN(LTRIM(RTRIM(@SearchText)))=0 SET @SearchText=NULL

DECLARE @FD DATE=NULL
IF @FromDate IS NOT NULL SET @fd=dbo.ConvertShamsiToMiladi(@FromDate)

DECLARE @TD DATE=NULL
IF @ToDate IS NOT NULL SET @TD=dbo.ConvertShamsiToMiladi(@ToDate)

SELECT 
	f.F_Id FactorID,
	fa.f_ID FamilyId,
	f.F_Date FactorDate,
	f.F_SumPrice SumPrice,
	f.F_Status FactorStatus,
	st.D_Title StatusTitle,
	f.F_CauserId CauserId,
	ca.FullName CauserFullName,
	desi.FullName DesignerFullName,
	f.F_DesignerId DesignerId,
	f.F_PhotographerId PhotographerId,
	pho.FullName PhotographerFullName,
	f.F_TypePhotographyId TypePhotographyId,
	ty.D_Title TypePhotographTitle,
	f.F_ForceDesign ForceDesign,
	f.[F_Desc] FactorDesc,
	fa.F_Title FamilyTitle,
	(case when fl.FL_ID is null then f.F_Date else dbo.convertMiladiToShamsi(fl.[FL_CreationTime]) end) LastLogDate,
	(f.F_SumPrice - isnull(f.F_SumDiscountPrice,0) - isnull(finan.PaidPrice,0)) ModPrice
FROM dbo.Vi_Factor f
INNER JOIN dbo.Vi_Family fa
ON f.F_FamilyId=fa.F_Id
INNER JOIN dbo.Vi_Data st
ON st.D_ID=f.F_Status
INNER JOIN dbo.Vi_Personnel ca
ON ca.P_ID=f.F_CauserId
INNER JOIN dbo.Vi_Data ty
ON ty.D_ID=f.F_TypePhotographyId
left join dbo.Vi_FactorSummery finan
on finan.FactorId=f.F_Id
left join [dbo].[Tb_FactorLog] fl
on fl.[FL_Id]=f.[F_LastLogId]
left JOIN dbo.Vi_Personnel desi
ON desi.P_ID=f.F_DesignerId
left JOIN dbo.Vi_Personnel pho
ON pho.P_ID=f.F_PhotographerId
	WHERE ISNULL(f.F_Delivered,0)=0 AND
		  (@FD IS NULL OR f.F_DateMiladi>=@FD) AND
          (@TD IS NULL OR f.F_DateMiladi<=@TD) AND
		  (@CauserId IS NULL OR f.F_CauserId=@CauserId) and
          (
			@SearchText IS NULL OR 
			fa.F_Title LIKE N'%'+@SearchText+'%' OR
            fa.FatherFullName LIKE N'%'+@SearchText+'%' OR
            fa.MotherFullName LIKE N'%'+@SearchText+'%' OR
            fa.F_FatherMobile LIKE N'%'+@SearchText+'%' OR
            fa.F_MotherMobile LIKE N'%'+@SearchText+'%'
		  )
