**FREE
// Jack Woehr jack@seidengroup.com 2025-09-26
// New RPG program to interact with an Ollama-compatible LLM API
// QSYS/CRTSQLRPGI OBJ(NEWLLM) SRCSTMF('/home/jwoehr/work/AI/COMMONSweden25Q4/code/rpgollama/NEWLLM.SQLRPGLE') TEXT('Roo-authored take on RPGOLLAMA') CVTCCSID(*JOB)
Ctl-Opt DftActGrp(*No) Option(*Srcstmt : *NodebugIO) main(qNewLLM);

dcl-s MyAnswer SQLTYPE(clob:16000000);
dcl-s DspStr varchar(52);
dcl-s PromptText varchar(200) inz('{ "role": "user", "content": "Tell me a short story about a brave knight."}');

dcl-proc qNewLLM;

  // Configure Ollama server settings
  exec sql call dbsdk_v1.ollama_setserverforjob(hostname => 'localhost');
  exec sql call dbsdk_v1.ollama_setportforjob(port => '11434');
  exec sql call dbsdk_v1.ollama_setprotocolforjob(protocol => 'http');
  exec sql call dbsdk_v1.ollama_setmodelforjob(model => 'llama3.2:3b'); // Using llama3.2:3b as per user's available model

  // Generate response from LLM
  exec sql select dbsdk_v1.ollama_generate(prompt => :PromptText) into :MyAnswer from SYSIBM.SYSDUMMY1;
  if SQLSTATE = '00000';
    DspStr = MyAnswer_DATA;
    dsply DspStr;
    snd-msg *INFO DspStr %target(*CALLER);
  else;
    DspStr = 'SQL Error: ' + SQLSTATE;
    dsply DspStr;
    snd-msg *INFO DspStr %target(*CALLER);
  endif;

  *inlr=*on;
end-Proc;