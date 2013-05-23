DGPMDAL2 ;RGI/VSL - PATIENT MOVEMENT DAL; 4/19/13
 ;;5.3;Registration;**260005**;
GETFCTY(DATA,IFN,FLDS) ; Get transfer facility
 N TMP,ERR
 I '$D(FLDS) S FLDS=".01;.02;.05;101"
 D GETS^DIQ(4,IFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(4,IFN_",")
 Q
 ;
GETAREG(DATA,IFN,FLDS) ; Get admission regulation
 N TMP,ERR
 I '$D(FLDS) S FLDS=".001;.01;4"
 D GETS^DIQ(43.4,IFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(43.4,IFN_",")
 Q
 ;
GETRSN(DATA,IFN,FLDS) ; Get reason for lodging
 N TMP,ERR
 I '$D(FLDS) S FLDS=".01;"
 D GETS^DIQ(406.41,IFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(406.41,IFN_",")
 Q
 ;
GETADMS(DATA,IFN,FLDS) ; Get source of admission
 N TMP,ERR
 I '$D(FLDS) S FLDS=".01;2;3"
 D GETS^DIQ(45.1,IFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(45.1,IFN_",")
 Q
 ;
GETMVTT(DATA,IFN,FLDS) ; Get movement type
 N TMP,ERR
 I '$D(FLDS) S FLDS=".01;.02;.03;.04"
 D GETS^DIQ(405.1,IFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(405.1,IFN_",")
 Q
 ;
GETPSRV(DATA,IFN,FLDS) ; Get period of service
 N TMP,ERR
 I '$D(FLDS) S FLDS=".01;.02;.03;.04"
 D GETS^DIQ(21,IFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(21,IFN_",")
 Q
 ;
GETMASMT(DATA,IFN,FLDS) ; Get mas movement type
 N TMP,ERR
 I '$D(FLDS) S FLDS=".001;.01;.02;.05;.06;50.01;50.02;50.03;"
 D GETS^DIQ(405.2,IFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(405.2,IFN_",")
 Q
 ;
GETPAT(DATA,IFN,FLDS) ; Get patient
 N TMP,ERR
 I '$D(FLDS) S FLDS=".01;.02"
 D GETS^DIQ(2,IFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(2,IFN_",")
 Q
 ;
GETPROV(DATA,IFN,FLDS) ; Get provider
 N TMP,ERR
 I '$D(FLDS) S FLDS=".01;1;"
 D GETS^DIQ(200,IFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(200,IFN_",")
 Q
 ;
GETWARD(DATA,IFN,FLDS) ; Get ward
 N TMP,ERR,I
 I '$D(FLDS) S FLDS=".01;.02"
 D GETS^DIQ(42,IFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(42,IFN_",")
 S I=""
 I FLDS["200*" F  S I=$O(TMP(42.08,I)) Q:'I  M DATA("OOS",$P(I,","))=TMP(42.08,I)
 Q
 ;
GETBED(DATA,IFN,FLDS) ; Get roombed
 N TMP,ERR,I
 I '$D(FLDS) S FLDS=".01;.02"
 D GETS^DIQ(405.4,IFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(405.4,IFN_",")
 S I=""
 I FLDS["100*" F  S I=$O(TMP(405.41,I)) Q:'I  M DATA("W",$P(I,","))=TMP(405.41,I)
 I FLDS["200*" F  S I=$O(TMP(405.42,I)) Q:'I  M DATA("OOS",$P(I,","))=TMP(405.42,I)
 Q
 ;
LSTOCBED(RETURN,SEARCH,START,NUMBER) ; Return occupied beds.
 N FILE,FIELDS,RET,SCR
 S FILE="405",FIELDS="@;.01;.03;.06;.07"
 S:$D(START)=0 START="" S:$D(SEARCH)=0 SEARCH=""
 D LIST^DIC(FILE,"",FIELDS,"I",$G(NUMBER),.START,SEARCH,"ARM",.SCR,"","RETURN")
 Q
 ;
GETFTS(DATA,IFN,FLDS) ; Get facility treating specialty
 N TMP,ERR,I
 I '$D(FLDS) S FLDS=".01;1;2"
 D GETS^DIQ(45.7,IFN,FLDS,"IE","TMP","ERR")
 I $D(ERR) S DATA=0 M DATA=ERR Q
 S DATA=1 M DATA=TMP(45.7,IFN_",")
 S I=""
 I FLDS["100*" F  S I=$O(TMP(45.702,I)) Q:'I  M DATA("E",$P(I,","))=TMP(45.702,I)
 Q
 ;
LSTPMVT(RETURN,DFN,TYPE,FLDS,AFN) ; Return patient movements.
 N SCR,E
 S:'$D(FLDS) FLDS="@;.01;.03IE;.06;.07;.17I"
 S SCR="I $P(^(0),U,3)=DFN,$P(^(0),U,2)=TYPE"_$S($D(AFN):",$P(^(0),U,14)=AFN",1:"")
 D LIST^DIC(405,"",FLDS,"",,,,"B",.SCR,"","RETURN","E")
 Q
 ;
LSTDIAG(RETURN) ; Return movements diagnosis.
 N ID,I,D S I=0
 F  S I=$O(RETURN(I)) Q:I=""  D
 . N DIAG
 . S ID=RETURN(I,"ID")
 . D GETDIAG(.DIAG,ID)
 . M RETURN(I)=DIAG
 Q
 ;
GETDIAG(RETURN,MFN) ; Return movement diagnosis.
 N D
 F D=0:0 S D=$O(^DGPM(MFN,"DX",D)) Q:D=""  D
 . S RETURN(99,D)=^DGPM(MFN,"DX",D,0)
 Q
 ;
LSTWARD(RETURN,SEARCH,START,NUMBER,FLDS) ; Return wards.
 N SCR,TMP,E
 S:'$D(FLDS) FLDS=".01;.017IE;.03IE;"
 S FLDS="@;"_FLDS,SCR="I $S($D(^(""ORDER"")):^(""ORDER""),1:0)"
 D LIST^DIC(42,"",FLDS,"",.NUMBER,.START,.SEARCH,"B",.SCR,"","RETURN","E")
 I $D(E) M RETURN=E
 Q
 ;
LSTWBED(RETURN,SEARCH,START,NUMBER,FLDS,WARD) ; Return ward beds.
 N SCR,TMP,E
 S:'$D(FLDS) FLDS=".01;.02;.2;"
 S FLDS="@;"_FLDS
 S SCR="I $D(^DG(405.4,""W"",+WARD,+Y))"
 D LIST^DIC(405.4,"",FLDS,"",.NUMBER,.START,.SEARCH,"B",.SCR,"","RETURN","E")
 I $D(E) M RETURN=E
 Q
 ;
LSTPROV(RETURN,SEARCH,START,NUMBER,FLDS,DGDT) ; Return providers.
 N SCR,TMP,E
 S:'$D(FLDS) FLDS=".01;8;"
 S FLDS="@;"_FLDS
 S SCR="I $$SCREEN^DGPMDD(Y,,.DGDT)"
 D LIST^DIC(200,"",FLDS,"",.NUMBER,.START,.SEARCH,"AK.PROVIDER",.SCR,"","RETURN","E")
 I $D(E) M RETURN=E
 Q
 ;
LSTADREG(RETURN,SEARCH,START,NUMBER,FLDS) ; Return admitting regulation.
 N SCR,TMP,E
 S:'$D(FLDS) FLDS=".01;2;"
 S FLDS="@;"_FLDS
 I +$G(SEARCH)>0 S TMP=+SEARCH K SEARCH
 S SCR="I '$P(^(0),U,4)"
 S:$D(TMP) SCR=SCR_",$D(TMP),+Y=TMP"
 D LIST^DIC(43.4,"",FLDS,"",.NUMBER,.START,.SEARCH,"B",.SCR,"","RETURN","E")
 I $D(E) M RETURN=E
 Q
 ;
LSTADSRC(RETURN,SEARCH,START,NUMBER,FLDS,DGDT) ; Return facility treating specialties
 N SCR,TMP,S,L,E
 S:'$D(FLDS) FLDS=".01;2;11"
 S FLDS="@;"_FLDS S S=$S('$D(SEARCH):"",1:SEARCH),L=$L(S)
 I +$E(S,1)>0 S SCR="I $E($P(^(0),U),1,L)=S"
 E  S SCR="I $E($P(^(0),U,2),1,L)=S"
 D LIST^DIC(45.1,"",FLDS,"",.NUMBER,.START,,"B",.SCR,"","RETURN","E")
 I $D(E) M RETURN=E
 Q
 ;
LSTFTS(RETURN,SEARCH,START,NUMBER,FLDS,DGDT) ; Return facility treating specialties
 N SCR,TMP,E
 S:'$D(FLDS) FLDS=".01;1;"
 S FLDS="@;"_FLDS
 S SCR="I $$ACTIVE^DGACT(45.7,Y,DGDT)"
 D LIST^DIC(45.7,"",FLDS,"",.NUMBER,.START,.SEARCH,"B",.SCR,"","RETURN","E")
 I $D(E) M RETURN=E
 Q
 ;
LSTFCTY(RETURN,SEARCH,START,NUMBER,FLDS) ; Return transfer facilities
 N SCR,TMP,E
 S:'$D(FLDS) FLDS=".01;"
 S FLDS="@;"_FLDS
 D LIST^DIC(4,"",FLDS,"",.NUMBER,.START,.SEARCH,"B",.SCR,"","RETURN","E")
 I $D(E) M RETURN=E
 Q
 ;
LSTLRSN(RETURN,SEARCH,START,NUMBER,FLDS) ; Return reasons for lodging
 N SCR,TMP,E
 S:'$D(FLDS) FLDS=".01;"
 S FLDS="@;"_FLDS
 D LIST^DIC(406.41,"",FLDS,"",.NUMBER,.START,.SEARCH,"B",.SCR,"","RETURN","E")
 I $D(E) M RETURN=E
 Q
 ;
LSTMVTT(RETURN,SEARCH,START,NUMBER,FLDS,TYPE,DFN,DGDT) ; Return movement types.
 N SCR,TMP,ADM,MVT,DGPM0,DGPM2,DGPMABL,DGPMAN,DGPMCA,DGPMP,X1,DA,DGX,E,X,MFN,DGPMDA
 N %,LMVT,MAS,NMVT,PAR,PMVT
 S:'$D(FLDS) FLDS=".01;.02IE;.04IE"
 S FLDS="@;"_FLDS
 S (DGPM0,DGPM2)="",DGPMDA=0,SEARCH=$E($G(SEARCH),1,29)
 D GETLASTM^DGPMDAL1(.LMVT,+DFN,+DGDT)
 S:+DGDT=+LMVT(3) MFN=LMVT(1),DGPMDA=MFN
 S PAR("DATE")=+DGDT
 S %=$$GETMVT^DGPMAPI8(.ADM,LMVT(13))
 S %=$$GETPMVT^DGPMAPI8(.PMVT,LMVT(13),DGDT,.MFN)
 S %=$$GETNMVT^DGPMAPI8(.NMVT,LMVT(13),DGDT,.MFN)
 S DGPMABL=0 I NMVT S %=$$GETMASMT^DGPMAPI8(.MAS,NMVT("MASTYPE")) S DGPMABL=+MAS("ABS")
 S SCR="I $D(TYPE),($P(^(0),U,2)=TYPE),$P(^(0),U,4) S DGER=0,DGPMTYP=$P(^(0),U,3)"
 S SCR=SCR_" D:TYPE'=4 @(""DICS^DGPMV3""_TYPE) I 'DGER"
 ;S:$D(TMP) SCR=SCR_",$D(TMP),+Y=TMP"
 D LIST^DIC(405.1,"",FLDS,"",.NUMBER,.START,.SEARCH,"B",.SCR,"","RETURN","E")
 I $D(E) M RETURN=E
 Q
 ;
LSTPATS(RETURN,SEARCH,START,NUMBER,TYPE) ; Get patients
 N FILE,FIELDS,RET,SCR,INDX
 S FILE="2",FIELDS="@;.01;.03;.09;391;1901",INDX="B"
 S:$D(START)=0 START="" S:$D(SEARCH)=0 SEARCH=""
 I $D(SEARCH),SEARCH?4N S INDX="BS"
 I $L(SEARCH)>1,SEARCH?.N S INDX="SSN"
 I $L(SEARCH)>0,SEARCH?1A4N S INDX="BS5"
 I $G(TYPE) S SCR="I $D(^DGPM(""APTT""_TYPE,+Y))"
 D LIST^DIC(FILE,"",FIELDS,"",$G(NUMBER),.START,SEARCH,INDX,.SCR,"","RETURN")
 Q
 ;
TIMEUSD(DFN,DGDT) ; Is time used
 N Y
 S Y=+DGDT
 I $D(^DGPM("APRD",DFN,Y))!$D(^DGPM("APTT6",DFN,Y))!$D(^DGPM("APTT4",DFN,Y))!$D(^DGPM("APTT5",DFN,Y)) Q 1
 Q 0
