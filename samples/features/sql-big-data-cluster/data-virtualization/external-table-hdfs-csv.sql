USE sales
GO

-- Create file format for CSV file with appropriate properties.
--
CREATE EXTERNAL FILE FORMAT csv_file
WITH (
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS(
        FIELD_TERMINATOR = ',',
        STRING_DELIMITER = '"',
        FIRST_ROW = 2,
        USE_TYPE_DEFAULT = TRUE)
);

-- Create external table over HDFS data source (SqlStoragePool) in
-- SQL Server 2019 big data cluster. The SqlStoragePool data source
-- is a special data source that is available in any new database in
-- SQL Master instance.
--
CREATE EXTERNAL TABLE [web_clickstreams_hdfs_csv]
("wcs_click_date_sk" BIGINT , "wcs_click_time_sk" BIGINT , "wcs_sales_sk" BIGINT , "wcs_item_sk" BIGINT , "wcs_web_page_sk" BIGINT , "wcs_user_sk" BIGINT)
WITH
(
    DATA_SOURCE = SqlStoragePool,
	LOCATION = '/clickstream_data',
    FILE_FORMAT = csv_file
);
GO

-- Join external table with local tables
-- 
SELECT  
    wcs_user_sk,
    SUM( CASE WHEN i_category = 'Books' THEN 1 ELSE 0 END) AS book_category_clicks,
    SUM( CASE WHEN i_category_id = 1 THEN 1 ELSE 0 END) AS [Home & Kitchen],
    SUM( CASE WHEN i_category_id = 2 THEN 1 ELSE 0 END) AS [Music],
    SUM( CASE WHEN i_category_id = 3 THEN 1 ELSE 0 END) AS [Books],
    SUM( CASE WHEN i_category_id = 4 THEN 1 ELSE 0 END) AS [Clothing & Accessories],
    SUM( CASE WHEN i_category_id = 5 THEN 1 ELSE 0 END) AS [Electronics],
    SUM( CASE WHEN i_category_id = 6 THEN 1 ELSE 0 END) AS [Tools & Home Improvement],
    SUM( CASE WHEN i_category_id = 7 THEN 1 ELSE 0 END) AS [Toys & Games],
    SUM( CASE WHEN i_category_id = 8 THEN 1 ELSE 0 END) AS [Movies & TV],
    SUM( CASE WHEN i_category_id = 9 THEN 1 ELSE 0 END) AS [Sports & Outdoors]
  FROM [dbo].[web_clickstreams_hdfs_csv]
  INNER JOIN item it ON (wcs_item_sk = i_item_sk
                        AND wcs_user_sk IS NOT NULL)
GROUP BY  wcs_user_sk;
GO

DROP EXTERNAL TABLE [dbo].[web_clickstreams_hdfs_csv];
GO