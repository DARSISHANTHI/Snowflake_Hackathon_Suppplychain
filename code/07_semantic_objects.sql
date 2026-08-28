-- Semantic schema objects (knowledge base table + Cortex Search service)
-- Co-authored with CoCo

USE DATABASE AEROSPACE_SUPPLY_CHAIN_AI;
USE SCHEMA SEMANTIC;

-- ============================================================
-- KNOWLEDGE_BASE
-- ============================================================
CREATE OR REPLACE TABLE KNOWLEDGE_BASE (
    KB_SK NUMBER(38,0) NOT NULL AUTOINCREMENT START 1 INCREMENT 1 NOORDER,
    TERM_ID VARCHAR(30) NOT NULL,
    CATEGORY VARCHAR(50),
    OWNER VARCHAR(100),
    SOURCE_TABLE VARCHAR(200),
    CONTENT VARCHAR(5000),
    CREATED_TIMESTAMP TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (KB_SK)
);

-- ============================================================
-- CORTEX SEARCH SERVICE (for RAG-based conversational analytics)
-- ============================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE SUPPLY_CHAIN_KNOWLEDGE_SEARCH
  ON CONTENT
  ATTRIBUTES TERM_ID, CATEGORY, OWNER, SOURCE_TABLE
  WAREHOUSE = 'COMPUTE_WH'
  TARGET_LAG = '1 hour'
  REFRESH_MODE = INCREMENTAL
  AS (
    SELECT
      TERM_ID AS term_id,
      CATEGORY AS category,
      OWNER AS owner,
      SOURCE_TABLE AS source_table,
      CONTENT AS content
    FROM AEROSPACE_SUPPLY_CHAIN_AI.SEMANTIC.KNOWLEDGE_BASE
  );
