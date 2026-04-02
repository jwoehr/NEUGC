# rpgollama

Early experiment in using [DbToo](https://github.com/IBM/AI-SDK-Db2-IBMi/tree/main/src/ollama) to query LLM.

- Uses localhost port 11434
- Was implemented using ssh port redirection to a remote server running Ollama
- Compiling
    - Code4i does
        - `CRTSQLRPGI OBJ(JWOEHR/rpgollama) SRCSTMF('/home/JWOEHR/work/AI/COMMONSweden25Q4/code/rpgollama/rpgollama.sqlrpgle') CLOSQLCSR(*ENDMOD) OPTION(*EVENTF) DBGVIEW(*SOURCE) TGTRLS(*CURRENT) CVTCCSID(*JOB)`
