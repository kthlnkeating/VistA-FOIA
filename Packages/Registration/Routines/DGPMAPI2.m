DGPMAPI2 ;RGI/VSL - TRANSFER PATIENT API; 8/26/13
 ;;5.3;Registration;**260005**;
CHKDT(RETURN,PARAM) ; Check transfer date
 N %,TXT,ADM,DSH K RETURN S RETURN=1
 ; transfer date
 S %=$$CHKDT^DGPMAPI9(.RETURN,$G(PARAM("DATE"))) Q:'RETURN 0
 I '$G(PARAM("ADMIFN")) S RETURN=0,TXT(1)="PARAM(""ADMIFN"")" D ERRX^DGPMAPIE(.RETURN,"INVPARM",.TXT) Q 0
 D GETMVT^DGPMDAL1(.ADM,+$G(PARAM("ADMIFN")))
 I ADM=0 S TXT(1)="PARAM(""ADMIFN"")" D ERRX^DGPMAPIE(.RETURN,"MVTNFND",.TXT) Q 0
 S PARAM("PATIENT")=ADM(.03,"I")
 I $$TIMEUSD^DGPMDAL2(+PARAM("PATIENT"),+PARAM("DATE")) D  Q 0
 . S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"TIMEUSD")
 ;not before admission
 K TXT S TXT(1)=$$LOW^XLFSTR($$EZBLD^DIALOG(4070000.011))
 I +PARAM("DATE")<+ADM(.01,"I") S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"TRANBADM",.TXT) Q 0
 I ADM(.17,"I")>0 D  Q:'RETURN 0
 . D GETMVT^DGPMDAL1(.DSH,+ADM(.17,"I"),".01")
 . I +PARAM("DATE")>+DSH(.01,"I") S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"TRANADIS") Q
 S RETURN=1
 Q 1
 ;
CHKADD(RETURN,PARAM,TYPE,MAS,LMVT) ; Check transfer parameters
 N %,TT K RETURN S RETURN=1
 ; transfer date
 S %=$$CHKDT(.RETURN,.PARAM) Q:'RETURN 0
 S %=$$GETLASTM^DGPMAPI8(.LMVT,+PARAM("PATIENT"),+PARAM("DATE"))
 ; type of movement
 S %=$$CHKTTYP^DGPMAPI6(.RETURN,$G(PARAM("TYPE")),+PARAM("PATIENT"),+PARAM("DATE")) Q:'RETURN 0
 D GETMVTT^DGPMDAL2(.TT,+PARAM("TYPE"))
 S TYPE=TT(.03,"I")
 D GETMASMT^DGPMDAL2(.MAS,TYPE)
 I "^1^2^3^23^25^26^"[(U_TYPE_U) S RETURN=1 Q 1
 I 1 D  Q:'RETURN 0
 . I TYPE=13 S %=$$CHKASH^DGPMAPI6(.RETURN,.PARAM) Q
 . I TYPE=43 S %=$$CHKFCTY^DGPMAPI6(.RETURN,$G(PARAM("FCTY"))) Q
 . S %=$$CHKREG^DGPMAPI9(.RETURN,.PARAM,+PARAM("PATIENT"),.MAS)
 S RETURN=1
 Q 1
TRANSF1(RETURN,PARAM,TYPE,MAS,LMVT) ; Transfer patient
 ;Input:
 ;  .RETURN [Required,Numeric] Set to the new transfer IEN, 0 otherwise.
 ;                             Set to Error description if the call fails
 ;  .PARAM [Required,Array] Array passed by reference that holds the new data.
 ;      PARAM("WARD") [Required,Numeric] Ward location IEN (pointer to the Ward Location file #42)
 ;      PARAM("ROOMBED") [Optional,Numeric] Room-bed IEN (pointer to the Room-bed file #405.4)
 ;      PARAM("FTSPEC") [Optional,Numeric] Facility treating specialty IEN (pointer to the Facility Treating Specialty file #45.7)
 ;                                         Required if PARAM("ATNDPHY") is set
 ;      PARAM("ATNDPHY") [Optional,Numeric] Attending physician IEN (pointer to the New Person file #200)
 ;                                         Required if PARAM("FTSPEC") is set
 ;      PARAM("PRYMPHY") [Optional,Numeric] Primary physician IEN (pointer to the New Person file #200)
 ;      PARAM("DIAG") [Optional,Array] Array of detailed diagnosis description.
 ;         PARAM("DIAG",n) [Optional,String] Detailed diagnosis description.
 ;Output:
 ;  1=Success,0=Failure
 N %,TFN,MVT6
 I TYPE=25!(TYPE=26) S PARAM("WARD")=+LMVT("WARD")
 S TFN=$$ADDTRA(.RETURN,.PARAM)
 I MAS(.05,"I"),$D(PARAM("FTSPEC")),$D(PARAM("ATNDPHY")) D
 . S PARAM("RELIFN")=TFN
 . S %=$$ADD^DGPMAPI6(.MVT6,.PARAM)
 D SETTEVT^DGPMDAL1(TFN,+$G(MVT6),"A")
 S RETURN=TFN
 Q 1
 ;
ADDTRA(RETURN,PARAM) ; Add patient transfer
 N %,IFN1,IFN2,DT2,PM2,MVT2,TYPE
 S IFN1=+PARAM("ADMIFN"),DT2=+PARAM("DATE"),TYPE=+PARAM("TYPE")
 S PM2(.01)=DT2 ; transfer date
 S PM2(.02)=2  ; transaction
 S PM2(.03)=+PARAM("PATIENT")  ; patient
 S PM2(.04)=+TYPE  ; type of movement
 S PM2(.14)=IFN1
 D ADDMVMTX^DGPMDAL1(.MVT2,.PM2)
 S IFN2=+MVT2 K PM2
 S:$G(PARAM("FCTY")) PM2(.05)=+PARAM("FCTY")  ; patient
 S:$D(PARAM("ASHSEQ")) PM2(.22)=+PARAM("ASHSEQ")  ; ASIH sequence
 S PM2(100)=DUZ,PM2(101)=$$NOW^XLFDT()
 S PM2(102)=DUZ,PM2(103)=$$NOW^XLFDT()
 S:$D(PARAM("RABSDT")) PM2(.13)=+PARAM("RABSDT")
 S:$D(PARAM("WARD")) PM2(.06)=+PARAM("WARD")  ; ward
 S:$D(PARAM("ROOMBED")) PM2(.07)=+$G(PARAM("ROOMBED"))  ; roombed
 D UPDMVT^DGPMDAL1(.MVT2,.PM2,IFN2)
 Q IFN2
 ;
TRANSF(RETURN,PARAM) ; Transfer patient
 ;Input:
 ;  .RETURN [Required,Numeric] Set to the new transfer IEN, 0 otherwise.
 ;                             Set to Error description if the call fails
 ;  .PARAM [Required,Array] Array passed by reference that holds the new data.
 ;      PARAM("ADMIFN") [Required,Numeric] Admission associated IEN (pointer to the Patient Movement file #405)
 ;      PARAM("DATE") [Required,DateTime] Transfer date
 ;      PARAM("TYPE") [Required,Numeric] Transfer type IEN (pointer to the Facility Movement Type file #405.1)
 ;        If MAS movement type of the transfer type is:
 ;          - INTERWARD TRANSFER see TRANSF1^DGPMAPI2,
 ;          - TO ASIH see ASIH^DGPMAPI6,
 ;          - TO ASIH (OTHER FACILITY) or CHANGE ASIH LOCATION (OTHER FACILITY) see ASIHOF^DGPMAPI9,
 ;          - AUTHORIZED ABSENCE, UNAUTHORIZED ABSENCE, AUTH ABSENCE 96 HOURS OR LESS, FROM UNAUTHORIZED ABSENCE
 ;            FROM AUTHORIZED ABSENCE or FROM AUTH. ABSENCE OF 96 HOURS OR LESS see ABS^DGPMAPI9,
 ;        for a detailed parameters description.
 ;Output:
 ;  1=Success,0=Failure
 N %,MAS,TYPE,DFN,LMVT,DGIDX
 K RETURN S RETURN=0
 S %=$$CHKADD(.RETURN,.PARAM,.TYPE,.MAS,.LMVT) Q:'RETURN 0
 S DFN=+PARAM("PATIENT")
 S %=$$LOCKMVT^DGPMAPI9(.RETURN,DFN) Q:'RETURN 0
 S %=$$ADD(.RETURN,.PARAM,.TYPE,.MAS,.LMVT,1)
 S %=$$UPDPAT^DGPMAPI9(,.PARAM,DFN,,1)
 D EVT(DFN,+RETURN,1)
 D ULOCKMVT^DGPMAPI9(DFN)
 Q 1
 ;
ADD(RETURN,PARAM,TYPE,MAS,LMVT,QUIET) ;
 N TT,%,DGQUIET
 S:$G(QUIET) DGQUIET=1
 D INITEVT^DGPMDAL1
 S:'$D(LMVT) %=$$GETLASTM^DGPMAPI8(.LMVT,+PARAM("PATIENT"),+PARAM("DATE"))
 I '$D(TYPE) D GETMVTT^DGPMDAL2(.TT,+PARAM("TYPE")) S TYPE=TT(.03,"I")
 D:'$D(MAS) GETMASMT^DGPMDAL2(.MAS,TYPE)
 I 1 D
 . I "^13^44^"[(U_+TYPE_U) S %=$$ASIH^DGPMAPI6(.RETURN,.PARAM) Q
 . I "^43^45^"[(U_+TYPE_U) S %=$$ASIHOF^DGPMAPI9(.RETURN,.PARAM) Q
 . I "^1^2^3^"[(U_+TYPE_U) S %=$$ABS^DGPMAPI9(.RETURN,.PARAM,.LMVT) Q
 . I TYPE=14,LMVT("DISIFN")>0 D DELMVT^DGPMDAL1(LMVT("DISIFN"))
 . S %=$$TRANSF1(.RETURN,.PARAM,TYPE,.MAS,.LMVT) Q
 Q RETURN
 ;
EVT(DFN,TFN,MODE,QUE) ; Transfer event
 D MVTEVT^DGPMAPI9(+DFN,2,TFN,.MODE,.QUE)
 Q
CHKUDT(RETURN,TFN,DGDT,OLD,NEW) ; Check transfer date
 N %,LMVT,TXT
 ; transfer date
 S:'$D(OLD) %=$$GETTRA^DGPMAPI8(.OLD,+$G(TFN))
 I OLD=0 S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"TRANFND") Q 0
 I $G(DGDT)'="",+$G(OLD("DATE"))'=+$G(DGDT) D  Q:'RETURN 0
 . S %=$$CHKDT^DGPMAPI9(.RETURN,+DGDT) Q:'RETURN
 . S %=$$GETLASTM^DGPMAPI8(.LMVT,+OLD("PATIENT"),+DGDT)
 . ;not before admission
 . K TXT S TXT(1)=$$LOW^XLFSTR($$EZBLD^DIALOG(4070000.011))
 . I +DGDT<+LMVT("ADMDT") S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"TRANBADM",.TXT) Q
 . I LMVT("TYPE")=3,+DGDT>+LMVT("DATE") S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"TRANADIS") Q
 . I $$TIMEUSD^DGPMDAL2(+OLD("PATIENT"),+DGDT) D  Q
 . . S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"TIMEUSD")
 . S NEW("DATE")=+DGDT
 Q 1
CHKUPD(RETURN,PARAM,TFN,OLD,NEW,MAS) ; Check transfer parameters
 N %,TXT,MTYPE,WARD,DATE,TT,TYPE,RPHY K RETURN,OLD,NEW,MAS S RETURN=1
 S %=$$GETTRA^DGPMAPI8(.OLD,+$G(TFN))
 I OLD=0 S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"TRANFND") Q 0
 D GETMVTT^DGPMDAL2(.TT,+OLD("TYPE"))
 I "^13^44^"[(U_$G(TT(.03,"I"))_U) S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"TRACEAT") Q 0
 S %=$$CHKUDT(.RETURN,TFN,$G(PARAM("DATE")),.OLD,.NEW) Q:'RETURN 0
 S DATE=$S($D(NEW("DATE")):+NEW("DATE"),1:+OLD("DATE"))
 ; type of movement
 I $G(PARAM("TYPE"))'="",+$G(OLD("TYPE"))'=+$G(PARAM("TYPE")) D  Q:'RETURN 0
 . S %=$$CHKTTYP^DGPMAPI6(.RETURN,+$G(PARAM("TYPE")),+OLD("PATIENT"),DATE) Q:'%
 . S NEW("TYPE")=+PARAM("TYPE")
 S TYPE=$S($D(NEW("TYPE")):+NEW("TYPE"),1:+OLD("TYPE"))
 D GETMVTT^DGPMDAL2(.TT,+TYPE)
 S MTYPE=$G(TT(.03,"I"))
 D GETMASMT^DGPMDAL2(.MAS,MTYPE)
 I MTYPE=23!(MTYPE=25)!(MTYPE=26) S RETURN=1 Q 1
 ; ward 
 I $G(PARAM("WARD"))'="",+$G(OLD("WARD"))'=+$G(PARAM("WARD")) D  Q:'RETURN 0
 . S %=$$CHKWARD^DGPMAPI9(.RETURN,$G(PARAM("WARD")),+DATE) Q:'%
 . S NEW("WARD")=+PARAM("WARD")
 S WARD=$S($D(NEW("WARD")):+NEW("WARD"),1:+OLD("WARD"))
 ; roombed
 I $G(PARAM("ROOMBED"))'="",+$G(OLD("ROOMBED"))'=+$G(PARAM("ROOMBED")) D  Q:'RETURN 0
 . S %=$$CHKBED^DGPMAPI9(.RETURN,+PARAM("ROOMBED"),WARD,+OLD("PATIENT"),DATE) Q:'%
 . S NEW("ROOMBED")=+PARAM("ROOMBED")
 ; related physical movement
 I MAS(.05,"I") D  Q:'% 0
 . S RPHY=$$GETRPHY^DGPMDAL1(TFN)
 . S:RPHY>0 %=$$CHKUPD^DGPMAPI6(.RETURN,.PARAM,+RPHY,.NEW) Q:'%
 . I 'RPHY,$D(PARAM("FCTY")),PARAM("ATNDPHY") S %=$$CHKADD^DGPMAPI6(.RETURN,.PARAM) Q:'%
 I TYPE=13!(TYPE=44) D  Q:'RETURN 0
 . N ASH S ASH=1
 . S NEW("DATE")=DATE
 . S NEW("PATIENT")=+OLD("PATIENT")
 . S NEW("ADMIFN")=+OLD("ADMIFN")
 . S NEW("WARD")=$G(PARAM("WARD"))
 . S NEW("FDEXC")=$G(PARAM("FDEXC"))
 . S NEW("ADMREG")=$G(PARAM("ADMREG"))
 . S NEW("SHDIAG")=$G(PARAM("SHDIAG"))
 . S NEW("FTSPEC")=$G(PARAM("FTSPEC"))
 . S NEW("ATNDPHY")=$G(PARAM("ATNDPHY"))
 . S NEW("PRYMPHY")=$G(PARAM("PRYMPHY"))
 . S NEW("ADMSCC")=$G(PARAM("ADMSCC"))
 . S NEW("ADMSRC")=$G(PARAM("ADMSRC"))
 . S:+OLD("DATE")=+DATE ASH=2
 . S %=$$CHKASH^DGPMAPI6(.RETURN,.NEW,,,.ASH) Q:'%
 S RETURN=($D(NEW)>0)
 Q 1
 ;
UPDTRA(RETURN,PARAM,TFN) ; Update transfer
 ;Input:
 ;  .RETURN [Required,Numeric] Set to the new transfer IEN, 0 otherwise.
 ;                             Set to Error description if the call fails
 ;  .PARAM [Required,Array] Array passed by reference that holds the new data.
 ;      PARAM("DATE") [Optional,DateTime] Transfer date
 ;      PARAM("TYPE") [Optional,Numeric] Transfer type IEN (pointer to the Facility Movement Type file #405.1)
 ;        If MAS movement type of the transfer type is:
 ;          - INTERWARD TRANSFER see TRANSF1^DGPMAPI2,
 ;          - TO ASIH see ASIH^DGPMAPI6,
 ;          - TO ASIH (OTHER FACILITY) or CHANGE ASIH LOCATION (OTHER FACILITY) see ASIHOF^DGPMAPI9,
 ;          - AUTHORIZED ABSENCE, UNAUTHORIZED ABSENCE, AUTH ABSENCE 96 HOURS OR LESS, FROM UNAUTHORIZED ABSENCE
 ;            FROM AUTHORIZED ABSENCE or FROM AUTH. ABSENCE OF 96 HOURS OR LESS see ABS^DGPMAPI9,
 ;        for a detailed description of the parameters **.
 ;        ** If PARAM("TYPE") has the same value with the transfer type of the old transfer all the parameters are optional.
 ;   TFN [Required,Numeric] Transfer IEN to update (pointer to the Patient Movement file #405)
 ;Output:
 ;  1=Success,0=Failure
 N %,OLD,NEW,DFN,MAS
 K RETURN S RETURN=0
 S %=$$CHKUPD(.RETURN,.PARAM,.TFN,.OLD,.NEW,.MAS)
 I RETURN=0 S:'$D(RETURN(0)) RETURN=1 Q $S('$D(RETURN(0)):1,1:0)
 S DFN=$P(OLD("PATIENT"),U)
 S %=$$LOCKMVT^DGPMAPI9(.RETURN,DFN) Q:'RETURN 0
 S %=$$UPD(.RETURN,.PARAM,TFN,.OLD,.NEW,.MAS,1)
 S %=$$UPDPAT^DGPMAPI9(,.PARAM,DFN,,1)
 D EVT(DFN,+TFN,1)
 D ULOCKMVT^DGPMAPI9(DFN)
 Q 1
 ;
UPD(RETURN,PARAM,TFN,OLD,NEW,MAS,QUIET) ; Update transfer
 N %,MVT,RPHY,MVT6,TT,TYPE,DGQUIET
 S:$G(QUIET) DGQUIET=1 K RETURN S RETURN=0
 S RPHY=$$GETRPHY^DGPMDAL1(TFN)
 D INITEVT^DGPMDAL1
 D SETTEVT^DGPMDAL1(TFN,RPHY,"P")
 S:$D(NEW("DATE")) MVT(.01)=+NEW("DATE")
 S:$D(NEW("TYPE")) MVT(.04)=+NEW("TYPE")
 S:$D(NEW("RABSDT")) MVT(.13)=+NEW("RABSDT")
 S:$D(NEW("WARD")) MVT(.06)=+NEW("WARD")
 S:$D(NEW("ROOMBED")) MVT(.07)=+NEW("ROOMBED")
 D UPDMVT^DGPMDAL1(.RETURN,.MVT,TFN)
 S:+RPHY>0 %=$$UPD^DGPMAPI6(.RETURN,.PARAM,RPHY)
 I '$D(MAS) D
 . S TYPE=$S($D(NEW("TYPE")):+NEW("TYPE"),1:+OLD("TYPE"))
 . D GETMVTT^DGPMDAL2(.TT,+TYPE)
 . D GETMASMT^DGPMDAL2(.MAS,$G(TT(.03,"I")))
 I 'RPHY,MAS(.05,"I"),$D(PARAM("FTSPEC")),$D(PARAM("ATNDPHY")) D
 . S PARAM("RELIFN")=TFN,PARAM("ADMIFN")=TFN
 . S %=$$ADD^DGPMAPI6(.MVT6,.PARAM)
 I "^13^44^"[(U_+$G(MAS(.001,"I"))_U) S %=$$ASIH^DGPMAPI6(.RETURN,.NEW,TFN)
 D SETTEVT^DGPMDAL1(TFN,RPHY,"A")
 S RETURN=1
 Q 1
 ;
CANDEL(RETURN,TFN,TRA,PMVT,NMVT) ; Can delete transfer?
 N FLDS,ADM,ASIH,TXT,MVTT,PTFCO
 S RETURN=0,FLDS=".01;.02;.03;.04;.14;.15;.16;.17;.18;.21"
 D GETMVT^DGPMDAL1(.TRA,TFN,FLDS)
 I TRA=0 S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"TRANFND") Q 0
 D GETMVT^DGPMDAL1(.ADM,TRA(.14,"I"),FLDS)
 D GETPMVT^DGPMDAL3(.PMVT,TRA(.03,"I"),TRA(.14,"I"),,TFN,FLDS)
 D GETNMVT^DGPMDAL3(.NMVT,TRA(.03,"I"),TRA(.14,"I"),,TFN,FLDS)
 I $G(PMVT(.18,"I"))=43,$G(NMVT(.18,"I"))=42 S RETURN=1 Q 1
 I $D(NMVT(.04,"I")),NMVT(.18,"I")'=42,'$$CANFOL^DGPMDAL3(NMVT(.04,"I"),PMVT(.04,"I")) D ERRX^DGPMAPIE(.RETURN,"DELTITP") Q 0
 I "^13^44^"[("^"_TRA(.18,"I")_"^") D ERRX^DGPMAPIE(.RETURN,"DELTMDTA") Q 0
 I TRA(.18,"I")=14,$G(ADM(.17,"I"))>0 D ERRX^DGPMAPIE(.RETURN,"DELTCDWD") Q 0
 D GETMVT^DGPMDAL1(.ASIH,TRA(.15,"I"),FLDS)
 I ASIH D  Q:PTFCO=1 0
 . D GETPTFCO^DGPTDAL1(.PTFCO,ASIH(.16,"I"))
 . I PTFCO=1  D ERRX^DGPMAPIE(.RETURN,"DELTCDPC") Q
 I "^14^43^45^"[("^"_TRA(.18,"I")_"^"),("^13^14^43^44^45^"[("^"_$G(NMVT(.18,"I"))_"^")) D  Q 0
 . D GETMVTT^DGPMDAL2(.MVTT,NMVT(.04,"I"))
 . S TXT(1)=MVTT(.01,"E")
 . D ERRX^DGPMAPIE(.RETURN,"DELTMMRF",.TXT) Q
 S RETURN=1
 Q 1
 ;
DELTRA(RETURN,TFN) ; Delete transfer
 ;Input:
 ;  .RETURN [Required,Numeric] Set to 1 if the operation succeeds
 ;                             Set to Error description if the call fails
 ;   TFN [Required,Numeric] Transfer IEN to delete (pointer to the Patient Movement file #405)
 ;Output:
 ;  1=Success,0=Failure
 N TRA,PMVT,NMVT,DFN,%
 K RETURN S RETURN=0
 S %=$$CANDEL(.RETURN,+TFN,.TRA,.PMVT,.NMVT) Q:'RETURN 0
 S DFN=TRA(.03,"I")
 S %=$$LOCKMVT^DGPMAPI9(.RETURN,DFN) Q:'RETURN 0
 S %=$$DEL(.RETURN,+TFN,.TRA,.PMVT,.NMVT,1)
 S %=$$UPDPAT^DGPMAPI9(,,DFN,,1)
 D EVT(DFN,+TFN,1,1)
 D ULOCKMVT^DGPMAPI9(DFN)
 Q 1
DEL(RETURN,TFN,TRA,PMVT,NMVT,QUIET) ; Delete transfer
 N %,RPHY,PAR,LMVT,ASH,DIS,FLDS,DGQUIET
 S:$G(QUIET) DGQUIET=1
 S FLDS=".01;.02;.03;.04;.14;.15;.16;.17;.18;.21"
 K RETURN S RETURN=0
 D:'$D(PMVT) GETPMVT^DGPMDAL3(.PMVT,TRA(.03,"I"),TRA(.14,"I"),,TFN,FLDS)
 D:'$D(NMVT) GETNMVT^DGPMDAL3(.NMVT,TRA(.03,"I"),TRA(.14,"I"),,TFN,FLDS)
 D INITEVT^DGPMDAL1
 S RPHY=$$GETRPHY^DGPMDAL1(+TFN)
 D SETTEVT^DGPMDAL1(+TFN,RPHY,"P")
 D:+$G(RPHY)>0 DELMVT^DGPMDAL1(RPHY)
 D DELMVT^DGPMDAL1(+TFN)
 I TRA(.18,"I")=43,NMVT(.18,"I")=42 D DELMVT^DGPMDAL1(NMVT("ID"))
 I TRA(.18,"I")=14,(PMVT(.18,"I")=44)!(PMVT(.18,"I")=13) D
 . D GETMVT^DGPMDAL1(.ASH,PMVT(.15,"I"))
 . D DELMVT^DGPMDAL1(ASH(.17,"I"))
 . S DIS("TYPE")=34,DIS("ADMIFN")=PMVT(.14,"I")
 . S DIS("DATE")=$$FMADD^XLFDT(PMVT(.01,"I"),30)
 . S %=$$ADDDIS^DGPMAPI3(.RETURN,.DIS,ASH(.03,"I"))
 I TRA(.18,"I")=14,PMVT(.18,"I")=43 D
 . S %=$$GETLASTM^DGPMAPI8(.LMVT,PMVT(.03,"I"),PMVT(.01,"I"))
 . S PAR("PATIENT")=PMVT(.03,"I")
 . S PAR("DATE")=PMVT(.01,"I"),PAR("ADMIFN")=LMVT("ADMIFN")
 . S %=$$ASHODIS^DGPMAPI9(.RETURN,.PAR)
 I TRA(.18,"I")=45 D
 . N ADH
 . S ADH=$$GETAPTT3^DGPMDAL3(+TRA(.03,"I"),+TRA(.01,"I"))
 . D DEL^DGPMAPI3(,ADH,,1)
 D SETTEVT^DGPMDAL1(+TFN,RPHY,"A")
 S RETURN=1
 Q 1
 ;
DELASH(RETURN,TFN) ; Delete ASIH transfer
 N TRA,ADM,FLDS
 K RETURN S RETURN=0
 S FLDS=".01;.02;.03;.04;.14;.15;.16;.17;.18;.21"
 D GETMVT^DGPMDAL1(.TRA,TFN,FLDS)
 D GETMVT^DGPMDAL1(.ADM,TRA(.14,"I"),FLDS)
 D DELMVT^DGPMDAL1(+ADM(.17,"I"))
 D DELMVT^DGPMDAL1(+TFN)
 D SETDEVT^DGPMDAL1(+ADM(.17,"I"),"A")
 D SETTEVT^DGPMDAL1(+TFN,,"A")
 S RETURN=1
 Q 1
 ;
