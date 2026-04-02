-- set up and test Rochester team's DbToo https://ibm.github.io/AI-SDK-Db2-IBMi/
-- drop schema dbsdk_v1;

-- Set globally
set
    dbsdk_v1.ollama_protocol = 'http';
set
    dbsdk_v1.ollama_server = 'localhost';
set
    dbsdk_v1.ollama_port = 11434;
set
    -- dbsdk_v1.ollama_model = 'llama3.2:3b';
    dbsdk_v1.ollama_model = 'granite-code:8b';


-- Set up for job only
call dbsdk_v1.ollama_setprotocolforjob('http');
call dbsdk_v1.ollama_setserverforjob('localhost');
call dbsdk_v1.ollama_setportforjob(11434);
call dbsdk_v1.ollama_setmodelforjob('granite-code:8b');

select
    dbsdk_v1.ollama_getmodel ()
from
    SYSIBM.SYSDUMMY1;


values
    dbsdk_v1.ollama_protocol;


values
    dbsdk_v1.ollama_server;


values
    dbsdk_v1.ollama_port;


values
    dbsdk_v1.ollama_model;


select
    dbsdk_v1.ollama_getmodel ()
from
    SYSIBM.SYSDUMMY1;


select
    dbsdk_v1.ollama_generate (
        prompt => '{ "role": "user", "content": "why do dogs bark?"}'
    ) as myanswer
from
    SYSIBM.SYSDUMMY1;


/* select
dbsdk_v1.ollama_generate (
prompt => '{ "role": "user", "content": "Yes, please elaborate."}'
) as myanswer
from
SYSIBM.SYSDUMMY1; */
set
    dbsdk_v1.ollama_model = 'granite-code:8b';


select
    dbsdk_v1.ollama_generate (
        prompt => '{ "role": "user", "content": "why do dogs bark?"}'
    ) as myanswer
from
    SYSIBM.SYSDUMMY1;


create or replace variable dbsdk_v1.ollama_stream varchar(5) ccsid 1208 default 'false';


values
    dbsdk_v1.ollama_stream;


set
    dbsdk_v1.ollama_stream = false;


values
    dbsdk_v1.ollama_getstream ();