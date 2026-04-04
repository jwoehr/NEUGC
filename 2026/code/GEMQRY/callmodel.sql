-- callmodel.sql
-- examples of calling models via IBM i DB2 SQL

-- For the record, a paradigmatic example of using the older SYSTOOLS.HTTPPOSTCLOB
-- Has nothing to do with generative AI

-- VALUES
    -- SYSTOOLS.HTTPPOSTCLOB(
        -- URL => 'https://httpbin.org/post?parm1=value1',
        -- HTTPHEADER => '<httpHeader><header name="Accept" value="application/json" /></httpHeader>',
        -- REQUESTMSG => '{"form1":"test1"}');


-- Equivalent of the above example using instead modern QSYS2.HTTP_POST

-- VALUES
    -- QSYS2.HTTP_POST('https://httpbin.org/post?parm1=value1', '{"form1":"test1"}', '{"headers": {"Accept": "application/json"}}');


-- Example using QSYS2.HTTP_POST to query Google Gemini
-- Replace YOUR_API_KEY with your actual Gemini API key
-- The Gemini API expects a JSON request with contents array containing parts with text
VALUES
    QSYS2.HTTP_POST(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=YOUR_API_KEY',
        '{"contents":[{"parts":[{"text":"Explain quantum computing in simple terms"}]}]}',
        '{"headers": {"Content-Type": "application/json"}}');


-- Function to query Google Gemini API with parameterized inputs
-- Returns the HTTP response as a scalar
CREATE OR REPLACE FUNCTION GEMINI_QUERY (
            MODEL VARCHAR(100) DEFAULT 'gemini-2.5-pro',
            KEY VARCHAR(100),
            CONTENT CLOB(1M) DEFAULT '{"contents":[]}'
        )
    RETURNS CLOB(10M)
    LANGUAGE SQL
    SPECIFIC GEMINI_QUERY
    NOT DETERMINISTIC
    MODIFIES SQL DATA
    RETURN
        QSYS2.HTTP_POST(
            'https://generativelanguage.googleapis.com/v1beta/models/' || TRIM(MODEL) || ':generateContent?key=' || TRIM(KEY),
            CONTENT, '{"headers": {"Content-Type": "application/json"}}');

-- Example usage of the GEMINI_QUERY function:
-- VALUES GEMINI_QUERY(
--     MODEL => 'gemini-2.5-pro',
--     KEY => 'YOUR_API_KEY',
--     CONTENT => '{"contents":[{"parts":[{"text":"What is AI?"}]}]}'
-- );

-- DROP FUNCTION GEMINI_QUERY;
