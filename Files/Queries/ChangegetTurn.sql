ALTER TABLE [dbo].[Tb_Request] ADD R_Location BIGINT,R_Duration INT,R_Cost DECIMAL(18,0)
GO
ALTER VIEW [dbo].[Vi_Request]
AS
SELECT 
	[R_Id],
	[R_FamilyId],
	[R_FamilyChildId],
	[R_TurnDate],
	[R_TurnDateMiladi],
	[R_TurnTime],
	[R_TurnerId],
	[R_PhotographerId],
	[R_DesignerId],
	[R_FactorId],
	[R_Desc],
	[R_Status],
	[R_CauserId],
	[R_CreationTime],
	R_Type,
	R_Location,
	R_Duration,
	R_Cost
FROM [dbo].[Tb_Request]
WHERE [R_Deleted]=0
go
create PROC [dbo].[usp_RequestTurn_Add]
@FamilyId bigint,
@TurnDate Varchar(10),
@TurnTime time(0),
@TurnerId bigint,
@PhotographerId bigint,
@Desc NVARCHAR(4000),
@CauserId BIGINT,
@Message NVARCHAR(1001) OUT,
@HasError INT OUT,
@RersultId BIGINT OUT,
@Type BIGINT,
@LocationId BIGINT,
@Duration INT,
@Cost DECIMAL(18,0)
AS
BEGIN TRY
	IF @LocationId=0 SET @LocationId=null
	if @TurnDate is not null and 
	   @TurnTime is not null and
	   exists(select 1 from dbo.Vi_Request 
				WHERE @TurnTime>'00:00' and 
					  [R_TurnTime]=@TurnTime and 
					  [R_TurnDate]=@TurnDate and 
					  (@LocationId IS NULL OR R_Location=@LocationId)
					)--کنسل نشده باشه و همینطور تحویل نشده باشه
		begin
			set @Message=N'این تاریخ و ساعت برای خانواده ای دیگری رزرو شده است'
			set @HasError=1
			return 0
		end	

	INSERT INTO [dbo].[Tb_Request]
	(
	   [R_FamilyId],
	   [R_TurnDate],
	   [R_TurnDateMiladi],
	   [R_TurnTime],
	   [R_TurnerId],
	   [R_PhotographerId],
	   [R_Desc],
	   [R_CauserId],
	   [R_CreationTime],
	   R_Type,
	   R_Location,
	   R_Duration,
	   R_Cost
	)
	VALUES
	(   
		@FamilyId,
		@TurnDate,
		dbo.convertShamsiToMiladi(@TurnDate),
		@TurnTime,
		@TurnerId,
		@PhotographerId,
		@Desc,
		@CauserId,
		getdate(),
		@Type,
		@LocationId,
		@Duration,
		@Cost
	   )
	
	SET @RersultId=SCOPE_IDENTITY()
	SET @HasError=0
	RETURN 1
END TRY	
BEGIN CATCH
	SET @Message=ERROR_MESSAGE()
	DECLARE @ProcName NVARCHAR(1001)=OBJECT_NAME(@@PROCID)
	EXEC dbo.usp_ErrorAdd @ProcName,@Message
	SET @HasError=1
	RETURN 0
END CATCH
GO
create PROC [dbo].[usp_RequestTurn_Edit]
@TurnId BIGINT,
@FamilyId bigint,
@TurnDate Varchar(10),
@TurnTime time(0),
@PhotographerId bigint,
@Desc NVARCHAR(4000),
@CauserId BIGINT,
@Message NVARCHAR(1001) OUT,
@HasError INT OUT,
@Type BIGINT,
@LocationId BIGINT,
@Duration INT,
@Cost DECIMAL(18,0)
AS
BEGIN TRY
	IF @LocationId=0 SET @LocationId=NULL
    
	if @TurnDate is not null and 
	   @TurnTime is not null and
	   exists(select 1 from dbo.Vi_Request 
				WHERE @TurnTime>'00:00' and 
					  [R_TurnTime]=@TurnTime and 
					  [R_TurnDate]=@TurnDate and 
					  R_Id!=@TurnId AND
                      (@LocationId IS NULL OR R_Location=@LocationId)
					)--کنسل نشده باشه و همینطور تحویل نشده باشه
		begin
			set @Message=N'این تاریخ و ساعت برای خانواده ای دیگری رزرو شده است'
			set @HasError=1
			return 0
		end	

	update [dbo].[Tb_Request]
		set
		   [R_FamilyId]=@FamilyId,
		   [R_TurnDate]=@TurnDate,
		   [R_TurnDateMiladi]=dbo.convertShamsiToMiladi(@TurnDate),
		   [R_TurnTime]=@TurnTime,
		   [R_PhotographerId]=@PhotographerId,
		   [R_Desc]=@Desc,
		   R_Type=@Type,
		   R_Location=@LocationId,
		   R_Duration=@Duration,
		   R_Cost=@Cost
	WHERE R_ID=@TurnId

	SET @HasError=0
	RETURN 1
END TRY	
BEGIN CATCH
	SET @Message=ERROR_MESSAGE()
	DECLARE @ProcName NVARCHAR(1001)=OBJECT_NAME(@@PROCID)
	EXEC dbo.usp_ErrorAdd @ProcName,@Message
	SET @HasError=1
	RETURN 0
END CATCH
GO
IF OBJECT_ID('Tb_Paids') IS NULL	
	BEGIN
		CREATE TABLE [dbo].[Tb_Paids](
			[Pa_Id] [BIGINT] IDENTITY(1,1) NOT NULL,
			[Pa_FamilyId] [BIGINT] NOT NULL,
			[Pa_SubjectId] [BIGINT] NOT NULL,
			[Pa_SubjectType] tinyint NOT NULL,
			[Pa_DateS] [VARCHAR](10) NULL,
			[Pa_DateM] [DATE] NULL,
			[Pa_Price] [DECIMAL](18, 0) NULL,
			[Pa_PaidType] [INT] NULL,
			[Pa_CauserId] [BIGINT] NULL,
			[Pa_CreationTime] [DATETIME] NOT NULL,
			[Pa_Deleted] [BIT] NOT NULL,
			[Pa_DeletedBy] [BIGINT] NULL,
			[Pa_DeletedTime] [DATETIME] NULL,
			[Pa_RefNumber] [VARCHAR](50) NULL,
			[Pa_Desc] [NVARCHAR](1001) NULL,
		 CONSTRAINT [PK_Tb_Paids] PRIMARY KEY CLUSTERED 
		(
			[Pa_Id] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]
		ALTER TABLE [dbo].[Tb_Paids] ADD  CONSTRAINT [DF_Tb_Paids_Pa_CreationTime]  DEFAULT (GETDATE()) FOR [Pa_CreationTime]
		ALTER TABLE [dbo].[Tb_Paids] ADD  CONSTRAINT [DF_Tb_Paids_Pa_Deleted]  DEFAULT ((0)) FOR [Pa_Deleted]
	END
GO
create VIEW [dbo].[Vi_Paids]
AS
SELECT 
	  Pa_Id,
      Pa_FamilyId,
      Pa_DateS,
      Pa_DateM,
      Pa_Price,
      Pa_PaidType,
      Pa_CauserId,
      Pa_CreationTime,
      Pa_RefNumber,
      Pa_Desc,
	  Pa_SubjectId,
	  --1=>Factor
	  --2=>Turn
	  Pa_SubjectType
FROM dbo.Tb_Paids
WHERE Pa_Deleted=0
GO
IF NOT EXISTS(SELECT 1 FROM dbo.Tb_Paids)
	begin
		INSERT INTO dbo.Tb_Paids
		(
			Pa_FamilyId,
			Pa_SubjectId,
			Pa_SubjectType,
			Pa_DateS,
			Pa_DateM,
			Pa_Price,
			Pa_PaidType,
			Pa_CauserId,
			Pa_CreationTime,
			Pa_Deleted,
			Pa_DeletedBy,
			Pa_DeletedTime,
			Pa_RefNumber,
			Pa_Desc
		)
		SELECT 
			f.F_FamilyId,
			pa.FP_FactorId,
			1,
			FP_DateS,
			FP_DateM,
			FP_Price,
			FP_PaidType,
			FP_CauserId,
			FP_CreationTime,
			0,
			null,
			null,
			FP_RefNumber,
			FP_Desc
		FROM dbo.Vi_FactorPaid pa
		inner JOIN dbo.Vi_Factor f
		ON f.F_Id=pa.FP_FactorId
	end
go
alter PROC [dbo].[usp_Paids_Add]
@SubjectId BIGINT,
@SubjectType TINYINT,
@Date VARCHAR(10),
@Price DECIMAL(18,0),
@PaidType INT,
@RefNumber VARCHAR(50),
@Desc NVARCHAR(1001),
@Time TIME(0),
@CauserId BIGINT,
@Message NVARCHAR(1001) OUT,
@HasError INT OUT,
@RersultId BIGINT OUT
AS
BEGIN TRY
	DECLARE @FamilyId BIGINT

	IF @SubjectType=1
		BEGIN
			SELECT @FamilyId=F_FamilyId FROM dbo.Vi_Factor WHERE F_ID=@SubjectId
		END
	ELSE IF @SubjectType=2
		BEGIN
			SELECT @FamilyId=R_FamilyId FROM dbo.Vi_Request WHERE R_Id=@SubjectId
		END

	INSERT INTO dbo.Tb_Paids
	(
	    Pa_FamilyId,
		Pa_SubjectId,
		Pa_SubjectType,
	    Pa_DateS,
	    Pa_DateM,
	    Pa_Price,
	    Pa_PaidType,
	    Pa_CauserId,
	    Pa_RefNumber,
	    Pa_Desc,
	    Pa_CreationTime
	)
	VALUES
	(   @FamilyId,
		@SubjectId,
		@SubjectType,
		@Date,
		dbo.ConvertShamsiToMiladi(@Date),
		@Price,
		@PaidType,
		@CauserId,
		@RefNumber,
		@Desc,
	    GETDATE() -- D_CreationTime - datetime
	    )
	SET @RersultId=SCOPE_IDENTITY()
	SET @HasError=0
	RETURN 1
END TRY	
BEGIN CATCH
	SET @Message=ERROR_MESSAGE()
	DECLARE @ProcName NVARCHAR(1001)=OBJECT_NAME(@@PROCID)
	EXEC dbo.usp_ErrorAdd @ProcName,@Message
	SET @HasError=1
	RETURN 0
END CATCH
GO
create PROC [dbo].[usp_Paids_Delete]
@Id BIGINT,
@CauserId BIGINT,
@Message NVARCHAR(1001) OUT,
@HasError INT OUT
AS
BEGIN TRY
	UPDATE dbo.Tb_Paids
		SET Pa_Deleted=1,
			Pa_DeletedBy=@CauserId,
			Pa_DeletedTime=GETDATE()
	WHERE Pa_Id=@Id

	SET @HasError=0
	RETURN 1
END TRY	
BEGIN CATCH
	SET @Message=ERROR_MESSAGE()
	DECLARE @ProcName NVARCHAR(1001)=OBJECT_NAME(@@PROCID)
	EXEC dbo.usp_ErrorAdd @ProcName,@Message
	SET @HasError=1
	RETURN 0
END CATCH
GO
alter PROC [dbo].[usp_Paids_Select_Grid]
@SearchText NVARCHAR(1001),
@FromDate varchar(10),
@ToDate varchar(10),
@FamilyId bigint,
@PaidType BIGINT,
@Page INT,
@PerPage INT,
@OutCount INT OUT,
@CauserId BIGINT
AS

IF LEN(LTRIM(rtrim(@SearchText)))=0 SET @SearchText=NULL
if len(@FromDate)<10 set @FromDate=null
if len(@ToDate)<10 set @ToDate=null
if @FamilyId<=0 set @FamilyId=NULL
if @PaidType<=0 set @PaidType=NULL
DECLARE @Paids TABLE(Id BIGINT,rown int)

INSERT INTO @Paids
(
    Id,
    rown
)
SELECT 
	[Pa_Id],
	ROW_NUMBER()OVER(ORDER BY fp.[Pa_CreationTime] desc)
FROM dbo.Vi_Paids fp
INNER JOIN dbo.Vi_Data d
ON d.D_ID=fp.Pa_PaidType
INNER JOIN dbo.Vi_Personnel p
ON p.P_ID=Pa_CauserId
WHERE (
		@SearchText IS NULL OR
        fp.Pa_Desc LIKE N'%'+@SearchText+'%'
	  ) and
	  (@FromDate is null or fp.[Pa_DateS]>=@FromDate) and
	  (@ToDate is null or fp.[Pa_DateS]<=@ToDate) and
	  (@FamilyId is null or fp.Pa_FamilyId=@FamilyId) AND
      (@PaidType IS NULL OR fp.[Pa_PaidType]=@PaidType)

SELECT @OutCount=COUNT(1) FROM Vi_Paids
SELECT 
	[Pa_Id],
	[Pa_DateS],
	[Pa_Price],
	[Pa_PaidType],
	[Pa_RefNumber],
	[Pa_CauserId],
	[Pa_CreationTime],
	[Pa_Desc],
	d.D_Title PaidTypeTitle,
	p.FullName CauserName,
	fp.Pa_SubjectId SubjectId,
	fp.Pa_SubjectType SubjectType,
	(CASE fp.Pa_SubjectType WHEN 1 THEN N'فاکتور '+CONVERT(VARCHAR(110),fp.Pa_SubjectId) WHEN 2 THEN N'نوبت در تاریخ '+r.R_TurnDate+N' ساعت '+CONVERT(VARCHAR(5),r.R_TurnTime) ELSE N'نامشخص' end) SubjectTypeText,
	fam.F_Title FamilyTiyle
FROM @Paids ff
INNER JOIN dbo.vi_Paids fp
ON ff.Id=fp.pa_ID
INNER JOIN dbo.Vi_Family fam
ON fam.F_Id=fp.Pa_FamilyId
INNER JOIN dbo.Vi_Data d
ON d.D_ID=fp.pa_PaidType
INNER JOIN dbo.Vi_Personnel p
ON p.P_ID=pa_CauserId
LEFT JOIN dbo.Vi_Request r
ON r.R_ID=fp.Pa_SubjectId
ORDER BY ff.rown
OFFSET @PerPage * (@Page - 1) ROWS
FETCH NEXT @PerPage ROWS ONLY
GO
ALTER VIEW [dbo].[Vi_FactorSummery]
WITH SCHEMABINDING AS
SELECT 
	  fp.Pa_SubjectId FactorId,
      SUM(ISNULL(Pa_Price,0)) PaidPrice,
	  f.F_SumPrice SumPriceFactor,
	  ISNULL(f.F_SumDiscountPrice,0) SumDiscountPrice,
	  f.F_TaxPrice TaxPrice,
	  COUNT_BIG(*) CountRecord
FROM dbo.Tb_Factor f
INNER JOIN dbo.Tb_Paids fp
ON f.F_Id=fp.Pa_SubjectId AND fp.Pa_SubjectType=1
WHERE f.F_Deleted=0 AND 
	  fp.Pa_Deleted=0
GROUP BY fp.Pa_SubjectId,f.F_SumPrice,ISNULL(f.F_SumDiscountPrice,0),f.F_TaxPrice
GO
create VIEW [dbo].[Vi_TurnSummery]
WITH SCHEMABINDING AS
SELECT 
	  fp.Pa_SubjectId TurnId,
      SUM(ISNULL(Pa_Price,0)) PaidPrice,
	  r.R_Cost TurnPrice,
	  COUNT_BIG(*) CountRecord
FROM dbo.Tb_Request r
INNER JOIN dbo.Tb_Paids fp
ON r.R_Id=fp.Pa_SubjectId AND fp.Pa_SubjectType=2
WHERE r.R_Deleted=0 AND 
	  fp.Pa_Deleted=0
GROUP BY fp.Pa_SubjectId,r.R_Cost
go
ALTER PROC [dbo].[usp_Request_Select_By_Date_For_Dashboard]
@Date DATE
AS
SELECT r.R_Id,
	   r.R_TurnTime,
	   r.R_TurnerId,
	   p.FullName TurnerName,
	   r.R_CauserId,
	   c.FullName CauserName,
	   r.R_FamilyId,
	   f.F_Title FamilyTitle,
	   r.R_Type,
	   dt.D_Title TypeTitle,
	   r.R_Desc,
	   r.R_Cost,
	   r.R_Duration,
	   r.R_Location,
	   loc.D_Title LocationTitle,
	   ts.PaidPrice,
	   (CASE WHEN r.R_Cost IS NULL OR r.R_Cost=0 THEN 0
		ELSE r.R_Cost-ISNULL(ts.PaidPrice,0) end
	   ) ModPrice
FROM dbo.Vi_Request r
INNER JOIN dbo.Vi_Family f
ON f.F_Id=r.R_FamilyId
LEFT JOIN dbo.Vi_Personnel p
ON p.P_Id=r.R_TurnerId
LEFT JOIN dbo.Vi_Personnel c
ON c.P_Id=r.R_CauserId
LEFT JOIN dbo.Vi_Data dt
ON dt.D_ID=r.R_Type
LEFT JOIN dbo.Vi_Data loc
ON loc.D_ID=r.R_Location
LEFT JOIN [dbo].[Vi_TurnSummery] ts
ON ts.TurnId=r.R_Id
WHERE r.R_TurnDateMiladi=CONVERT(DATE,@Date) AND
	  r.R_Status=1

GO

