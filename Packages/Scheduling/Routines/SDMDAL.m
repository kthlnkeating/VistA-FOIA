SDMDAL ;FILE ACCESS DAL; 05/28/2012  11:46 AM
 ;;;Scheduling;;05/28/2012;
GETREC(RETURN,IFN,FILE,FLDS,SFILES,INT,EXT,REZ) ; Get one record and specified subfiles from a file
 N STRF,FLD,FLAG,C,SFILE,IFLD,REC
 S STRF=""
 S IFLD=""
 F  S IFLD=$O(FLDS(IFLD)) Q:IFLD=""  S STRF=STRF_$S(STRF="":"",1:";")_IFLD
 S SFILE=""
 F  S SFILE=$O(SFILES(SFILE)) Q:SFILE=""  S STRF=STRF_$S(STRF="":"",1:";")_SFILE_"*"
 S FLD="",FLAG=""
 S:$G(INT) FLAG=FLAG_"I" ;Returns Internal values
 S:$G(EXT) FLAG=FLAG_"E" ;Returns External values
 S:$G(REZ) FLAG=FLAG_"R" ;Resolves field numbers to field names
 D GETS^DIQ(FILE,IFN,STRF,FLAG,"REC")
 F  S FLD=$O(REC(FILE,""_IFN_",",FLD)) Q:FLD=""  D
 . S:FLAG=""!(FLAG="R") RETURN(FLD)=REC(FILE,""_IFN_",",FLD)
 . S:FLAG["I" RETURN(FLD)=REC(FILE,""_IFN_",",FLD,"I")
 . S:FLAG["E" RETURN(FLD)=$S($L($G(RETURN(FLD)))>0:RETURN(FLD)_U,1:"")_REC(FILE,""_IFN_",",FLD,"E")
 S SFILE=""
 F  S SFILE=$O(SFILES(SFILE)) Q:SFILE=""  D
 . S SFLDN=$S(FLAG["R":SFILES(SFILE,"N"),1:SFILE)
 . D GETSREC(.RETURN,.REC,SFILES(SFILE,"F"),SFLDN,FLAG)
 Q 1
 ;
GETSREC(RETURN,REC,SFILE,SFLD,FLAG) ; Get record subfile data
 N IDX,ID S FLD="",IDX=""
 F  S IDX=$O(REC(SFILE,IDX)) Q:IDX=""  D
 . F  S FLD=$O(REC(SFILE,IDX,FLD)) Q:FLD=""  D
 . . S ID=$P(IDX,",",1)
 . . S:FLAG=""!(FLAG="R") RETURN(SFLD,ID,FLD)=REC(SFILE,IDX,FLD)
 . . S:FLAG["I" RETURN(SFLD,ID,FLD)=REC(SFILE,IDX,FLD,"I")
 . . S:FLAG["E" RETURN(SFLD,ID,FLD)=$S($L($G(RETURN(SFLD,ID,FLD)))>0:RETURN(SFLD,ID,FLD)_U,1:"")_REC(SFILE,IDX,FLD,"E")
 Q 1
 ;