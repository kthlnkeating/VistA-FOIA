SDMDAL1 ;RGI/CBR - APPOINTMENT API; 5/13/13
 ;;5.3;scheduling;**260003**;08/13/93;
GETCLN(RETURN,CLN,INT,EXT,REZ) ; Get clinic detail
 N FILE,SFILES,FLDS
 S FILE=44
 S FLDS("*")=""
 S SFILES("2501")="",SFILES("2501","N")="PRIVILEGED USER",SFILES("2501","F")="44.04"
 S SFILES("1910")="",SFILES("1910","N")="SI",SFILES("1910","F")="44.03"
 D GETREC^SDMDAL(.RETURN,CLN,FILE,.FLDS,.SFILES,$G(INT),$G(EXT),$G(REZ))
 Q
 ;
GETCLNX(RETURN,SC) ; Get clinic detailx
 N IND
 F IND=0:0 S IND=$O(RETURN(IND)) Q:IND=""  D
 . S RETURN(IND)=$$GET1^DIQ(44,SC_",",IND,"I")
 S RETURN=1
 Q
 ;
LSTCLNS(RETURN,SEARCH,START,NUMBER) ; Return clinics filtered by name.
 N FILE,FIELDS,RET,SCR,S
 S FILE="44",FIELDS="@;.01;1"
 S:$D(START)=0 START="" S:$D(SEARCH)=0 SEARCH=""
 S S=SEARCH
 S SCR="I $P(^(0),U,3)=""C"",'$G(^(""OOS""))"
 S:S'="" SCR=SCR_",$E($P(^(0),U),1,$L(S))=S!($E($P(^(0),U,2),1,$L(S))=S)"
 S:S'="" SCR=SCR_"!($E($P(^(0),U,2),1,$L(S))=$$UP^XLFSTR(S))"
 D LIST^DIC(FILE,"",FIELDS,"",$G(NUMBER),.START,,"B",.SCR,"","RETURN")
 Q
 ;
GETCSC(FLDS,CSC) ; Get Clinic Stop Code
 N FLD,C
 D GETS^DIQ(40.7,CSC,"*","I","C")
 S FLD=""
 F  S FLD=$O(C(40.7,""_CSC_",",FLD)) Q:FLD=""  D
 . S FLDS(FLD)=C(40.7,""_CSC_",",FLD,"I")
 Q
 ;
CLNURGHT(CLN,USR,DATA) ; Return user right
 S DATA=$G(^SC(CLN,"SDPRIV",USR,0))
 Q
 ;
LSTTMPL(RETURN,CLN) ; List defined day template
 N FILE,SFILES,FLDS
 S FILE=44
 S SFILES("1922")="",SFILES("1922","N")="SUNDAY TEMPLATE",SFILES("1922","F")="44.06"
 S SFILES("1923")="",SFILES("1923","N")="MONDAY TEMPLATE",SFILES("1923","F")="44.07"
 S SFILES("1924")="",SFILES("1924","N")="TUESDAY TEMPLATE",SFILES("1924","F")="44.08"
 S SFILES("1925")="",SFILES("1925","N")="WEDNESDAY TEMPLATE",SFILES("1925","F")="44.09"
 S SFILES("1926")="",SFILES("1926","N")="THURSDAY TEMPLATE",SFILES("1926","F")="44.08"
 S SFILES("1927")="",SFILES("1927","N")="FRIDAY TEMPLATE",SFILES("1927","F")="44.09"
 S SFILES("1928")="",SFILES("1928","N")="SATURDAY TEMPLATE",SFILES("1928","F")="44.0001"
 D GETREC^SDMDAL(.RETURN,CLN,FILE,.FLDS,.SFILES)
 Q
 ;
NXTAV(CLN,SD) ; Get next available day.
 Q $O(^SC(CLN,"ST",SD))
 ;
GETHOL(RETURN,SDATE) ; Get holiday.
 S:$D(^HOLIDAY(SDATE)) RETURN(SDATE)=$G(^HOLIDAY(SDATE,0))
 Q
 ;
GETPATT(RETURN,SC,SD) ; Get date pattern
 S RETURN=0
 S:$D(^SC(SC,"ST",$P(SD,"."),1)) RETURN(0)=^SC(SC,"ST",$P(SD,"."),1)
 S:$D(^SC(SC,"ST",$P(SD,"."),"CAN")) RETURN(1)=^SC(SC,"ST",$P(SD,"."),"CAN")
 S RETURN=1
 Q
 ;
GETSCAP(RETURN,SC,DFN,SD) ; Get clinic appointment
 N ZL,NOD0,CO
 I $D(^SC(SC,"S",SD))  D
 . S ZL=0
 . F  S ZL=$O(^SC(SC,"S",SD,1,ZL)) Q:'ZL  D
 . . I '$D(^SC(SC,"S",SD,1,ZL,0)) Q
 . . I +^SC(SC,"S",SD,1,ZL,0)=DFN  D
 . . . M RETURN=^SC(SC,"S",SD,1,ZL)
 . . . S RETURN=ZL
 . Q
 Q
 ;
GETCAPT(RETURN,SC,SD,IFN,FLAG) ; Get clinic appointment by IFN
 N CAPT,DIC,DIQ,DA,DR
 S DIQ="CAPT(",DIC="^SC(SC,""S"",SD,1,",DIQ(0)=$G(FLAG)
 S DA=IFN,DR=".01;1;3;7;8;9;10;30;309;302;303;304;306;688"
 D EN^DIQ1
 M RETURN=CAPT(44.003,IFN)
 S RETURN(222)=SC
 S RETURN(333)=IFN
 Q
 ;
LOCKST(SC,SD) ; Lock availability node
 L +^SC(SC,"ST",$P(SD,"."),1):5 Q:'$T 0
 Q 1
 ;
UNLCKST(SC,SD) ; Lock availability node
 L -^SC(SC,"ST",$P(SD,"."),1)
 Q
 ;
LOCKS(SC,SD) ; Lock clinic date node
 L +^SC(SC,"S",$P(SD,"."),1):5 Q:'$T 0
 Q 1
 ;
UNLCKS(SC,SD) ; Unlock clinic date node
 L -^SC(SC,"S",$P(SD,"."),1)
 Q
 ;
SETST(SC,SD,S) ; Set availability
 S ^SC(SC,"ST",$P(SD,".",1),1)=S
 Q
 ;
MAKE(SC,SD,DFN,LEN,SM,USR,OTHR,RQXRAY) ; Make clinic appointment
 N ERR,FDA,IENS,SCRQ
 S IENS="+2,"_SC_","
 S IENS(2)=+SD
 S FDA(44.001,IENS,.01)=+SD
 D UPDATE^DIE("","FDA","IENS","ERR")
 K FDA,IENS,ERR
 S IENS="+1,"_+SD_","_SC_","
 S FDA(44.003,IENS,.01)=DFN
 S FDA(44.003,IENS,1)=LEN
 S FDA(44.003,IENS,3)=$G(OTHR)
 S FDA(44.003,IENS,7)=USR
 S FDA(44.003,IENS,8)=$P($$NOW^XLFDT,".")
 S:$G(SM) FDA(44.003,IENS,9)="O"
 S SCRQ=$$GET1^DIQ(44,SC_",",2000,"I")
 I $G(SCRQ)>0!($G(SCRQ)="Y")!+$G(RQXRAY) S ^SC("ARAD",SC,SD,DFN)=""
 D UPDATE^DIE("","FDA","IENS","ERR")
 Q
 ;
CANCEL(SC,SD,DFN,CIFN) ; Kill clinic appointment
 N X
 S X=$P(^SC(SC,"S",SD,1,0),U,3),X=$S(X-1=0:"",1:X-1),$P(^SC(SC,"S",SD,1,0),U,3)=X
 S X=$P(^SC(SC,"S",SD,1,0),U,4),X=$S(X-1=0:"",1:X-1),$P(^SC(SC,"S",SD,1,0),U,4)=X
 N HSI,SB,SDDIF,SI,SL,SS,ST,STARTDAY,STR,I,S,X,Y,TLNK
 S ^SC("ARAD",SC,SD,DFN)="N"
 S TLNK=$P($G(^SC(SC,"S",SD,1,CIFN,"CONS")),U)
 K ^SC(SC,"S",SD,1,CIFN)
 K:$O(^SC(SC,"S",SD,0))'>0 ^SC(SC,"S",SD,0)
 K:TLNK'="" ^SC("AWAS1",TLNK),TLNK
 Q:'$D(^SC(SC,"ST",SD\1,1))
 S SL=^SC(SC,"SL"),X=$P(SL,U,3),STARTDAY=$S($L(X):X,1:8),SB=STARTDAY-1/100,X=$P(SL,U,6),HSI=$S(X:X,1:4),SI=$S(X="":4,X<3:4,X:X,1:4),STR="#@!$* XXWVUTSRQPONMLKJIHGFEDCBA0123456789jklmnopqrstuvwxyz",SDDIF=$S(HSI<3:8/HSI,1:2) K Y
 S S=^SC(SC,"ST",SD\1,1),Y=SD#1-SB*100,ST=Y#1*SI\.6+(Y\1*SI),SS=SL*HSI/60
 I Y'<1 F I=ST+ST:SDDIF S Y=$E(STR,$F(STR,$E(S,I+1))) Q:Y=""  S S=$E(S,1,I)_Y_$E(S,I+2,999),SS=SS-1 Q:SS'>0
 S ^SC(SC,"ST",SD\1,1)=S
 Q
 ;
COVERB(SC,SD,IFN) ; Kill first overbook appointment
 I $D(^SC(SC,"S",SD,1,IFN,"OB")) Q 0
 N X,OIFN
 S X=IFN,OIFN=0
 F  S X=$O(^SC(SC,"S",SD,1,X)) Q:X=""!(OIFN>0)  D
 . I $D(^SC(SC,"S",SD,1,X,"OB")) K ^SC(SC,"S",SD,1,X,"OB") S OIFN=X
 Q OIFN
 ;
GETFSTA(SC) ; Get first available day.
 N I
 S I=0
 Q $O(^SC(SC,"T",I))
 ;
GETDAYA(RETURN,SC,SD) ; Get all day appointments
 N IND,I,D,%
 S I=$P(SD,".",1)
 F D=I-.01:0 S D=$O(^SC(SC,"S",D)) Q:$P(D,".",1)-I  D
 . S %=0
 . F  S %=$O(^SC(SC,"S",D,1,%)) Q:%'>0  D
 . . Q:'$D(^SC(SC,"S",D,1,%,0))
 . . S RETURN(%,"STATUS")=$P(^SC(SC,"S",D,1,%,0),U,9)
 . . S RETURN(%,"OB")=$D(^SC(SC,"S",D,1,%,"OB"))
 Q
 ;
LSTCAPTS(RETURN,SC,SDBEG,SDEND) ; 
 N SDT,SDDA,CNT,APT,SDATA,CNSTLNK,SDT
 S CNT=0
 F SDT=SDBEG:0 S SDT=$O(^SC(SC,"S",SDT)) Q:'SDT!($P(SDT,".",1)>SDEND)  D
 . F SDDA=0:0 S SDDA=$O(^SC(SC,"S",SDT,1,SDDA)) Q:'SDDA  D
 . . S CNSTLNK=$P($G(^SC(SC,"S",SDT,1,SDDA,"CONS")),U)
 . . Q:'$D(^SC(SC,"S",SDT,1,SDDA,0))
 . . S APT=^SC(SC,"S",SDT,1,SDDA,0)
 . . S CNT=CNT+1
 . . S SDATA=^DPT(+APT,"S",SDT,0)
 . . S RETURN(CNT,"CONS")=$G(CNSTLNK)
 . . S RETURN(CNT,"SD")=SDT
 . . S RETURN(CNT,"SC")=+SDATA
 . . S RETURN(CNT,"DFN")=+APT
 . . S RETURN(CNT,"SDDA")=SDDA
 . . S RETURN(CNT,"SDATA")=SDATA
 . . S RETURN(CNT,"CDATA")=APT
 Q
 ;
LSTPAPTS(RETURN,DFN,SDBEG,SDEND) ; Get patient appointments
 N SDT,CNT,SDDA,SC,CN,CNPAT,SDATA,CNSTLNK
 S CNT=0
 F SDT=SDBEG:0 S SDT=$O(^DPT(DFN,"S",SDT)) Q:'SDT!($P(SDT,".",1)>SDEND)  D
 . Q:'$D(^DPT(+DFN,"S",SDT,0))
 . S CNT=CNT+1
 . S SDATA=^DPT(+DFN,"S",SDT,0)
 . S SC=+SDATA
 . S RETURN(CNT,"SD")=SDT
 . S RETURN(CNT,"SC")=SC
 . S RETURN(CNT,"DFN")=DFN
 . S SDDA="",CN=0
 . F  S CN=$O(^SC(SC,"S",SDT,1,CN)) Q:'+CN!(SDDA>0)  D
 . . S CNPAT=$P($G(^SC(SC,"S",SDT,1,CN,0)),U)
 . . Q:CNPAT'=DFN
 . . S SDDA=CN
 . S RETURN(CNT,"SDDA")=SDDA
 . S RETURN(CNT,"SDATA")=SDATA
 . S:SDDA>0 RETURN(CNT,"CDATA")=$G(^SC(SC,"S",SDT,1,SDDA,0))
 . S:SDDA>0 CNSTLNK=$P($G(^SC(SC,"S",SDT,1,SDDA,"CONS")),U)
 . S RETURN(CNT,"CONS")=$G(CNSTLNK)
 Q
 ;
GETDST(SC,SD) ; Get day slot
 Q $G(^SC(SC,"ST",SD,1))
 ;
GETDPATT(RETURN,SC,SD,DAY) ;
 S RETURN("IEN")=$O(^SC(SC,"T"_DAY,SD))
 S:RETURN("IEN")'="" RETURN("PAT")=$G(^SC(SC,"T"_DAY,RETURN("IEN"),1))
 Q
 ;
UPDPATT(DATA,SC,SD) ; Update day pattern
 N IENS,I
 S IENS=SD_","_SC_","
 N FDA
 F I=0:0 S I=$O(DATA(I)) Q:I=""  D
 . S FDA(44.005,IENS,I)=DATA(I)
 N ERR
 D UPDATE^DIE("","FDA",,"ERR")
 Q
 ;
ADDPATT(DATA,SC,SD) ; Add day pattern
 N IENS,I,FDA,ERR
 S IENS="+1,"_SC_","
 S IENS(1)=SD
 F I=0:0 S I=$O(DATA(I)) Q:I=""  D
 . S FDA(44.005,IENS,I)=DATA(I)
 D UPDATE^DIE("","FDA","IENS","ERR")
 Q
 ;
LSTAENC(RETURN,SEARCH,START,NUMBER) ; Returns active encounters.
 N FILE,FIELDS,RET,SCR
 S FILE="409.68",FIELDS="@;.01I;.04I;.06"
 S:$D(START)=0 START="" S:$D(SEARCH)=0 SEARCH=""
 S SCR="I $P(^(0),""^"",2)="_SEARCH_"&($D(^SCE(""ADFN"","_SEARCH_",$P(^(0),""^"",1))))"
 K SEARCH
 D LIST^DIC(FILE,"",.FIELDS,"",$G(NUMBER),.START,.SEARCH,"B",.SCR,"","RETURN","ERR")
 Q
 ;
