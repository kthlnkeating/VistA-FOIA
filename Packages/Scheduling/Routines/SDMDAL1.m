SDMDAL1 ;MAKE APPOINTMENT API; 05/28/2012  11:46 AM
 ;;;Scheduling;;05/28/2012;
GETCLN(RETURN,CLN,INT,EXT,REZ) ; Get clinic detail
 N FILE,SFILES,FLDS
 S FILE=44
 S FLDS("*")=""
 S SFILES("2501")="",SFILES("2501","N")="PRIVILEGED USER",SFILES("2501","F")="44.04"
 D GETREC^SDMDAL(.RETURN,CLN,FILE,.FLDS,.SFILES,$G(INT),$G(EXT),$G(REZ))
 Q
 ;
LSTCLNS(RETURN,SEARCH,START,NUMBER) ; Return clinics filtered by name.
 N FILE,FIELDS,RET,SCR
 S FILE="44",FIELDS="@;.01"
 S:$D(START)=0 START="" S:$D(SEARCH)=0 SEARCH=""
 S SCR="I $P(^(0),U,3)=""C"",'$G(^(""OOS""))"
 D LIST^DIC(FILE,"",FIELDS,"",$G(NUMBER),.START,SEARCH,"B",.SCR,"","RETURN")
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
 Q $N(^SC(CLN,"ST",SD))
 ;
GETHOL(RETURN,SDATE) ; Get holiday.
 S RETURN=0
 S:$D(^HOLIDAY(SDATE)) RETURN(0)=$G(^HOLIDAY(SDATE,0))
 S RETURN=1
 Q
 ;
GETPATT(RETURN,SC,SD) ; Get date pattern
 S RETURN=0
 S:$D(^SC(SC,"ST",$P(SD,"."),1)) RETURN(0)=^SC(SC,"ST",$P(SD,"."),1)
 S RETURN=1
 Q
 ;
GETSCAP(RETURN,SC,DFN,SD) ; Get clinic appointment
 N ZL
 I $D(^SC(SC,"S",SD))  D
 . S ZL=0
 . F  S ZL=$O(^SC(SC,"S",SD,1,ZL)) Q:'ZL  D
 . . I '$D(^SC(SC,"S",SD,1,ZL,0)) D FLEN1 Q
 . . I +^SC(SC,"S",SD,1,ZL,0)=DFN  D
 . . . S RETURN("IFN")=ZL
 . . . S RETURN("USER")=$P(^(0),U,6)
 . . . S RETURN("DATE")=$P(^(0),U,7)
 . . . S RETURN("LENGTH")=$P(^(0),U,2)
 . . . S RETURN("CONSULT")=$P($G(^SC(SC,"S",SD,1,ZL,"CONS")),U)
 . Q
 Q
 ;
FLEN1 Q:'$D(^SC(SC,"S",SD,1,ZL,"C"))
 S DA(2)=SC,DA(1)=NDT,DA=ZL,DIK="^SC("_DA(2)_",""S"","_DA(1)_",1," D ^DIK
 Q
 ;
LOCKST(SC,SD) ; Lock availability node
 L +^SC(SC,"ST",$P(SD,"."),1):$S($G(DILOCKTM)>0:DILOCKTM,1:5) Q:'$T 0
 Q 1
 ;
UNLCKST(SC,SD) ; Lock availability node
 L -^SC(SC,"ST",$P(SD,"."),1)
 Q 1
 ;
LOCKS(SC,SD) ; Lock clinic date node
 L +^SC(SC,"S",$P(SD,"."),1):$S($G(DILOCKTM)>0:DILOCKTM,1:5) Q:'$T 0
 Q 1
 ;
UNLCKS(SC,SD) ; Unlock clinic date node
 L -^SC(SC,"S",$P(SD,"."),1)
 Q 1
 ;
SETST(SC,SD,S) ; Set availability
 S ^SC(SC,"ST",$P(SD,".",1),1)=S
 Q
 ;
MAKE(SC,SD,DFN,LEN,SM,USR) ; Make clinic appointment
 S ^SC(SC,"S",SD,0)=SD
 S:'$D(^SC(SC,"S",0)) ^(0)="^44.001DA^^"
 F SDY=1:1 I '$D(^SC(SC,"S",SD,1,SDY))  D  Q
 . S:'$D(^(0)) ^(0)="^44.003PA^^"
 . S IENS="?+1,"_SD_","_SC_","
 . S FDA(44.003,IENS,.01)=DFN
 . S FDA(44.003,IENS,1)=LEN
 . S FDA(44.003,IENS,7)=USR
 . S FDA(44.003,IENS,8)=$P($$NOW^XLFDT,".")
 . S:SM FDA(44.003,IENS,9)="O"
 . D UPDATE^DIE("","FDA","","ERR") Q
 Q SDY
 ;
CANCEL(SC,SD,DFN,IFN) ; Kill clinic appointment
 ;S SDNODE=^SC(SC,"S",SD,1,CIFN,0)
 S ^SC("ARAD",SC,SD,DFN)="N"
 S TLNK=$P($G(^SC(SC,"S",SD,1,CIFN,"CONS")),U)
 K ^SC(SC,"S",SD,1,CIFN)
 K:$O(^SC(SC,"S",SD,0))'>0 ^SC(SC,"S",SD,0)
 K:TLNK'="" ^SC("AWAS1",TLNK),TLNK
 Q:'$D(^SC(SC,"ST",SD\1,1))
 S SL=^SC(SC,"SL"),X=$P(SL,U,3),STARTDAY=$S($L(X):X,1:8),SB=STARTDAY-1/100,X=$P(SL,U,6),HSI=$S(X:X,1:4),SI=$S(X="":4,X<3:4,X:X,1:4),STR="#@!$* XXWVUTSRQPONMLKJIHGFEDCBA0123456789jklmnopqrstuvwxyz",SDDIF=$S(HSI<3:8/HSI,1:2) K Y
 S S=^SC(SC,"ST",SD\1,1),Y=SD#1-SB*100,ST=Y#1*SI\.6+(Y\1*SI),SS=SL*HSI/60
 I Y'<1 F I=ST+ST:SDDIF S Y=$E(STR,$F(STR,$E(S,I+1))) Q:Y=""  S S=$E(S,1,I)_Y_$E(S,I+2,999),SS=SS-1 Q:SS'>0
 S ^(1)=S
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
CHECKIN(IEN,SC,SD,USR,DT) ; Check in appointment
 N IENS S IENS=IEN_","_SD_","_SC_","
 N FDA
 S FDA(44.003,IENS,309)=DT
 S FDA(44.003,IENS,302)=USR
 N ERR
 D UPDATE^DIE("","FDA","ERR") Q
 ;
GETFSTA(SC) ; Get first available day.
 N I
 S I=0
 Q $N(^SC(SC,"T",I))
 ;