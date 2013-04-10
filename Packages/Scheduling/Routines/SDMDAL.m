SDMDAL ;RGI/VSL - FILE ACCESS DAL; 4/10/13
 ;;5.3;scheduling;**260003**;08/13/93
GETREC(RETURN,IFN,FILE,FLDS,SFILES,INT,EXT,REZ) ; Get one record and specified subfiles from a file
 N STRF,FLD,FLAG,C,SFILE,IFLD,REC,SFLDN
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
 . I $E(FLD)="*" Q
 . S:FLAG=""!(FLAG="R") RETURN(FLD)=REC(FILE,""_IFN_",",FLD)
 . S:FLAG["I" RETURN(FLD)=REC(FILE,""_IFN_",",FLD,"I")
 . I FLAG["E" D
 . . I RETURN(FLD)=REC(FILE,""_IFN_",",FLD,"E") Q
 . . S RETURN(FLD)=$S($L($G(RETURN(FLD)))>0:RETURN(FLD)_U,1:"")_REC(FILE,""_IFN_",",FLD,"E")
 S SFILE=""
 F  S SFILE=$O(SFILES(SFILE)) Q:SFILE=""  D
 . S SFLDN=$S(FLAG["R":SFILES(SFILE,"N"),1:SFILE)
 . D GETSREC(.RETURN,.REC,SFILES(SFILE,"F"),SFLDN,FLAG)
 Q
 ;
GETSREC(RETURN,REC,SFILE,SFLD,FLAG) ; Get record subfile data
 N IDX,ID,FLD
 S FLD="",IDX=""
 F  S IDX=$O(REC(SFILE,IDX)) Q:IDX=""  D
 . F  S FLD=$O(REC(SFILE,IDX,FLD)) Q:FLD=""  D
 . . S ID=$P(IDX,",",1)
 . . S:FLAG=""!(FLAG="R") RETURN(SFLD,ID,FLD)=REC(SFILE,IDX,FLD)
 . . S:FLAG["I" RETURN(SFLD,ID,FLD)=REC(SFILE,IDX,FLD,"I")
 . . S:FLAG["E" RETURN(SFLD,ID,FLD)=$S($L($G(RETURN(SFLD,ID,FLD)))>0:RETURN(SFLD,ID,FLD)_U,1:"")_REC(SFILE,IDX,FLD,"E")
 . . N SI S SI=0
 . . F  S SI=$O(REC(SFILE,IDX,FLD,SI)) Q:SI=""!(SI="I")!(SI="E")  D
 . . . S RETURN(SFLD,ID,FLD,SI)=REC(SFILE,IDX,FLD,SI),RETURN(SFLD,ID,FLD)=""
 Q
 ;
LSTSCOD(FILE,FIELD,LIST) ;List codes in SET OF CODE fields
 ;FILE = file number
 ;FIELD = field number
 ;LIST = output array:
 ;   LIST(#)=code^display_name
 N SET,NODE,CODE,NAME,I,COUNT
 S SET=$$GET1^DID(FILE,FIELD,,"POINTER")
 S COUNT=1
 F I=1:1:$L(SET,";") D
 . S NODE=$P(SET,";",I)
 . S CODE=$P(NODE,":")
 . Q:CODE=""
 . S NAME=$P(NODE,":",2)
 . S LIST(COUNT)=CODE_"^"_NAME
 . S COUNT=COUNT+1
 S LIST(0)=COUNT-1
 Q
 ;
