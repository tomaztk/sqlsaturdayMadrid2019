/*

####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
####
####  Joking
####  SQL Sat Madrid 209
####  Tomaz Kastrun
####  Predicting and ploting
####
####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*/

-- ##############################
-- ##### 1. Predict
-- ##############################


USE WideWorldImportersDW;
GO


DECLARE @input AS NVARCHAR(MAX)
SET @input = N'SELECT                                
       SUM(fs.[Profit]) AS Profit
       ,c.[Sales Territory] AS SalesTerritory
       ,CASE
                     WHEN c.[Sales Territory] = ''Rocky Mountain'' THEN 1
                     WHEN c.[Sales Territory] = ''Mideast'' THEN 2
                     WHEN c.[Sales Territory] = ''New England'' THEN 3
                     WHEN c.[Sales Territory] = ''Plains'' THEN 4
                     WHEN c.[Sales Territory] = ''Southeast'' THEN 5
                     WHEN c.[Sales Territory] = ''Great Lakes'' THEN 6
                     WHEN c.[Sales Territory] = ''Southwest'' THEN 7
                     WHEN c.[Sales Territory] = ''Far West'' THEN 8
						END AS SalesTerritoryID
					   ,fs.[Customer Key] AS CustomerKey   
					   ,SUM(fs.[Quantity]) AS Quantity

				FROM [Fact].[Sale] AS  fs
					   JOIN dimension.city AS c
					   ON c.[City Key] = fs.[City Key]
					   WHERE
							  fs.[customer key] <> 0
					   AND c.[Sales Territory] NOT IN (''External'')
				GROUP BY
					   c.[Sales Territory]
					   ,fs.[Customer Key]
					   ,CASE
                     WHEN c.[Sales Territory] = ''Rocky Mountain'' THEN 1
                     WHEN c.[Sales Territory] = ''Mideast'' THEN 2
                     WHEN c.[Sales Territory] = ''New England'' THEN 3
                     WHEN c.[Sales Territory] = ''Plains'' THEN 4
                     WHEN c.[Sales Territory] = ''Southeast'' THEN 5
                     WHEN c.[Sales Territory] = ''Great Lakes'' THEN 6
                     WHEN c.[Sales Territory] = ''Southwest'' THEN 7
                     WHEN c.[Sales Territory] = ''Far West'' THEN 8
        END ;' ;

DECLARE @RCode AS NVARCHAR(MAX);
SET @RCode = N'library(RevoScaleR)
		some_model <- rxLinMod(Profit ~ Quantity + SalesTerritoryID, data = blabla);
		prtm <- rxPredict(modelObject = some_model, data = blabla, outData = NULL,   
							predVarNames = "ProfitPredict", type = "response", 
							checkFactorLevels=FALSE, extraVarsToWrite = c("CustomerKey"),
							writeModelVars = TRUE, overwrite = TRUE);
		OutputDataSet <- prtm';

EXEC sys.sp_execute_external_script
	 @language = N'R'
	,@script = @RCode
	,@input_data_1 = @input
	,@input_data_1_name = N'blabla'
WITH RESULT SETS ((
			  ProfitPredict FLOAT
			 ,CustomerKey INT
			 ,Profit INT
			 ,SalesTerritoryID INT
			 ,QUANTITY INT
));  


 USE WideWorldImportersDW;
 GO

-- ##############################
-- ##### 2. Association Rules
-- ##### using a standard library
-- ##############################


-- Getting Association Rules into T-SQL
DECLARE @TSQL AS NVARCHAR(MAX)
SET @TSQL = N'WITH PRODUCT
                        AS
                      (
                      SELECT
                      [Stock Item Key]
                      ,[WWI Stock Item ID]
                      ,[Stock Item] 
                      ,LEFT([Stock Item], 8) AS L8DESC 
                      ,ROW_NUMBER() OVER (PARTITION BY LEFT([Stock Item], 8) ORDER BY ([Stock Item])) AS RN_ID_PR
                      ,DENSE_RANK() OVER (ORDER BY (LEFT([Stock Item], 8))) AS PRODUCT_GROUP
                      FROM [Dimension].[Stock Item]
                      )
                      
                      SELECT
                      O.[WWI Order ID] AS OrderID
                      -- ,O.[Order Key]   AS OrderLineID
                      -- ,O.[Stock Item Key] AS ProductID
                      ,P.PRODUCT_GROUP AS ProductGroup
                      -- ,O.[Description] AS ProductDescription
                      ,LEFT([Stock Item],8) AS ProductDescription
                      
                      FROM [Fact].[Order] AS O
                      JOIN PRODUCT AS P
                      ON P.[Stock Item Key] = O.[Stock Item Key]
                      GROUP BY
                       O.[WWI Order ID]
                      ,P.PRODUCT_GROUP 
                      ,LEFT([Stock Item],8) 
                      ORDER BY 
                      O.[WWI Order ID]'

DECLARE @RScript AS NVARCHAR(MAX)
SET @RScript = N'
                library(arules)
                cust.data <- InputDataSet
                cd_f <- data.frame(OrderID=as.factor(cust.data$OrderID),
				ProductGroup=as.factor(cust.data$ProductGroup))
                cd_f2_tran  <- as(split(cd_f[,"ProductGroup"], cd_f[,"OrderID"]), "transactions")
                rules <- apriori(cd_f2_tran, parameter=list(support=0.01, confidence=0.1))
                OutputDataSet <- data.frame(inspect(rules))'

EXEC sys.sp_execute_external_script
           @language = N'R'
          ,@script = @RScript
          ,@input_data_1 = @TSQL
          
WITH RESULT SETS ((
     lhs NVARCHAR(500)
    ,[Var.2] NVARCHAR(10)
    ,rhs NVARCHAR(500)
    ,support DECIMAL(18,3)
    ,confidence DECIMAL(18,3)
    ,lift DECIMAL(18,3)
                 ));

-- ##############################
-- ##### 3. Visualization
-- ##### using a standard library
-- ##############################

DECLARE @SQLStat NVARCHAR(4000)
SET @SQLStat = 'SELECT                                
       SUM(fs.[Profit]) AS Profit
       ,c.[Sales Territory] AS SalesTerritory
       ,CASE
                     WHEN c.[Sales Territory] = ''Rocky Mountain'' THEN 1
                     WHEN c.[Sales Territory] = ''Mideast'' THEN 2
                     WHEN c.[Sales Territory] = ''New England'' THEN 3
                     WHEN c.[Sales Territory] = ''Plains'' THEN 4
                     WHEN c.[Sales Territory] = ''Southeast'' THEN 5
                     WHEN c.[Sales Territory] = ''Great Lakes'' THEN 6
                     WHEN c.[Sales Territory] = ''Southwest'' THEN 7
                     WHEN c.[Sales Territory] = ''Far West'' THEN 8
						END AS SalesTerritoryID
					   ,fs.[Customer Key] AS CustomerKey   
					   ,SUM(fs.[Quantity]) AS Quantity

				FROM [Fact].[Sale] AS  fs
					   JOIN dimension.city AS c
					   ON c.[City Key] = fs.[City Key]
					   WHERE
							  fs.[customer key] <> 0
					   AND c.[Sales Territory] NOT IN (''External'')
				GROUP BY
					   c.[Sales Territory]
					   ,fs.[Customer Key]
					   ,CASE
                     WHEN c.[Sales Territory] = ''Rocky Mountain'' THEN 1
                     WHEN c.[Sales Territory] = ''Mideast'' THEN 2
                     WHEN c.[Sales Territory] = ''New England'' THEN 3
                     WHEN c.[Sales Territory] = ''Plains'' THEN 4
                     WHEN c.[Sales Territory] = ''Southeast'' THEN 5
                     WHEN c.[Sales Territory] = ''Great Lakes'' THEN 6
                     WHEN c.[Sales Territory] = ''Southwest'' THEN 7
                     WHEN c.[Sales Territory] = ''Far West'' THEN 8
        END ;'
DECLARE @RStat NVARCHAR(4000)
SET @RStat = 'library(ggplot2)
              image_file <- tempfile()
                       jpeg(filename = image_file, width = 400, height = 400)
                       clusters <- hclust(dist(Sales[,c(1,3,5)]), method = ''average'')
                       clusterCut <- cutree(clusters, 3)
                       ggplot(Sales, aes(Total, Quantity, color = Sales$SalesTerritory)) +
                       geom_point(alpha = 0.4, size = 2.5) + geom_point(col = clusterCut) +
                       scale_color_manual(values = c(''black'', ''red'', ''green'',''yellow'',''blue'',''lightblue'',''magenta'',''brown''))
                       dev.off()
                    OutputDataSet <- data.frame(data=readBin(file(image_file, "rb"), what=raw(), n=1e6))'

EXECUTE sp_execute_external_script
        @language = N'Python'
       ,@script = @RStat
       ,@input_data_1 = @SQLStat
       ,@input_data_1_name = N'Sales'
WITH RESULT SETS ((plot varbinary(max)))



-- ##############################
-- ##### 4. PYthon
-- ##### using a standard library
-- ##############################

-- Change the server
EXECUTE sp_execute_external_script  
	 @language = N'Python'  
	,@script = N'
import pandas
OutputDataSet = InputDataSet
#print (OutputDataSet)
print (OutputDataSet.mean())'
	,@input_data_1 = N'SELECT sal FROM dbo.employee_test;'
GO



--Find mean for the salary for all three observations
-- and output the results
-- #OutputDataSet = pd.DataFrame(OutputDataSet.mean())

EXECUTE sp_execute_external_script  
	 @language = N'Python'  
	,@script = N'
import pandas as pd
OutputDataSet = InputDataSet
print(OutputDataSet.mean())
OutputDataSet = pd.DataFrame(OutputDataSet.mean())'
	,@input_data_1 = N'SELECT sal FROM dbo.employee_test;'
WITH RESULT SETS
((
	[mean_sal :-)] FLOAT
))
GO



EXECUTE sp_execute_external_script  
	 @language = N'Python'  
	,@script = N'
import pandas as pd
from scipy import optimize
import matplotlib.pyplot as plt
import revoscalepy
import pickle
from sklearn.linear_model import LogisticRegression

class Parameter:
    def __init__(self, value):
            self.value = value

    def set(self, value):
            self.value = value

    def __call__(self):
            return self.value
OutputDataSet = pd.DataFrame(InputDataSet);'
	,@input_data_1 = N'SELECT sal FROM dbo.employee_test;'
WITH RESULT SETS  
((
	[mean_sal :-)] FLOAT
))
GO


-- ##############################################################
-- ##### 5. Doing Predictions with sp_execute_external_script
-- #####   with reading the model from the sql server table
-- #############################################################



USE [ISACL16]
GO


-- Serialize; unserialize!
-- two separate steps
-- CREATE THE MODEL
CREATE OR ALTER PROCEDURE BBModel_CREATE
AS
BEGIN
DECLARE @input AS NVARCHAR(MAX)
SET @input = N'
SELECT CustomerKey, MaritalStatus, Gender,
TotalChildren, NumberChildrenAtHome,
Education, Occupation,
HouseOwnerFlag, NumberCarsOwned, CommuteDistance,
Region, BikeBuyer
FROM dbo.TargetMail;'

DECLARE @RKoda NVARCHAR(MAX)
SET @RKoda = N'library(RevoScaleR)
					bbLogR <- rxLogit(BikeBuyer ~
                    MaritalStatus + Gender + TotalChildren +
                    NumberChildrenAtHome + Education + Occupation +
                    HouseOwnerFlag + NumberCarsOwned + CommuteDistance + Region,data = sqlTM);
				   BBModel <- data.frame(as.raw(serialize(bbLogR, connection=NULL)));'

EXEC sys.sp_execute_external_script
 @language = N'R', 
 @script = @RKoda, 
  @input_data_1 = @input,
  @input_data_1_name = N'sqlTM',
  @output_data_1_name = N'BBModel'
with result sets ((model varbinary(max)))
END;


SELECT * FROM RModels

--INSERT
DECLARE @@temp table (Model VARBINARY(MAX))
INSERT @@temp
EXEC BBModel_CREATE;


INSERT INTO RModels (ModelName, Model)
SELECT 'bbLogR', Model 
FROM
	 @@temp




--MAKE PREDICTIONS!

DECLARE @input AS NVARCHAR(MAX)
SET @input = N'
SELECT CustomerKey, MaritalStatus, Gender,
TotalChildren, NumberChildrenAtHome,
Education, Occupation,
HouseOwnerFlag, NumberCarsOwned, CommuteDistance,
Region, BikeBuyer
FROM dbo.TargetMail;'
DECLARE @mod VARBINARY(max) =
 (SELECT Model
  FROM dbo.RModels
  WHERE ModelName = N'bbLogR'); 

  DECLARE @Rkoda NVARCHAR(MAX)
SET @Rkoda =  'blabla <- unserialize(as.raw(model));
				prtm <- rxPredict(modelObject = blabla, data = sqlTM, outData = NULL,
                  predVarNames = "BikeBuyerPredict", type = "response",
                  checkFactorLevels = FALSE, extraVarsToWrite = c("CustomerKey"),
                  writeModelVars = TRUE, overwrite = TRUE);
			OutputDataSet <- prtm[which(prtm$CustomerKey=="11000"),]';

EXEC sys.sp_execute_external_script
 @language = N'R', 
 @script = @RKoda, 
 @input_data_1 = @input, 
 @input_data_1_name = N'sqlTM',
 @params = N'@model VARBINARY(MAX)',
 @model = @mod 
WITH RESULT SETS ((BikeBuyerPredict FLOAT,CustomerKey INT,BikeBuyer INT,
 MaritalStatus NCHAR(1),Gender NCHAR(1),TotalChildren INT,NumberChildrenAtHome INT,Education NVARCHAR(40),
 Occupation NVARCHAR(100),HouseOwnerFlag NCHAR(1),NumberCarsOwned INT,CommuteDistance NVARCHAR(15),Region NVARCHAR(50) 
 )); 
GO


-- Results
-- BikeBuyersPredict	CustomerKey
-- 0,797310057618298	11000