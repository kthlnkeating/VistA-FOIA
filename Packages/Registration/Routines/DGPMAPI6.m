DGPMAPI6 ;RGI/VSL - FACILITY TRATING SPECIALTY API; 4/2/13
 ;;5.3;Registration;**260005**;
CHKDT(RETURN,PARAM) ; Check transfer date
 K RETURN
 S %=$$CHKDT^DGPMAPI2(.RETURN,.PARAM) Q:'RETURN 0
 S RETURN=1
 Q 1
CHKADD(RETURN,PARAM) ; 
 N % K RETURN S RETURN=1
 ; facility treating specialty
 S:'$G(PARAM("DGPMPC")) %=$$CHKFTS^DGPMAPI6(.RETURN,$G(PARAM("FTSPEC")),PARAM("DATE")) Q:'RETURN 0
 ;attender
 S %=$$CHKPROV^DGPMAPI6(.RETURN,$G(PARAM("ATNDPHY")),PARAM("DATE"),"PARAM('ATNDPHY')") Q:'RETURN 0
 ; primary physician
 I $G(PARAM("PRYMPHY"))'=""&($G(PARAM("PRYMPHY"))'="^") D  Q:'RETURN 0
 . S %=$$CHKPROV^DGPMAPI6(.RETURN,$G(PARAM("PRYMPHY")),PARAM("DATE"))
 Q 1
 ;
CHKUPD(RETURN,PARAM,MFN,NEW,OLD) ; 
 N %,I,OLD
 K RETURN S RETURN=1
 D GETMVT^DGPMAPI8(.OLD,MFN)
 S PARAM("PATIENT")=OLD("PATIENT")
 ; facility treating specialty
 I $G(PARAM("FTSPEC"))'="",+OLD("FTSPEC")'=+PARAM("FTSPEC") D  Q:'RETURN 0
 . S %=$$CHKFTS^DGPMAPI6(.RETURN,$G(PARAM("FTSPEC")),PARAM("DATE")) Q
 . S NEW("FTSPEC")=PARAM("FTSPEC")
 ;attender
 I $G(PARAM("ATNDPHY"))'="",+OLD("ATNDPHY")'=+PARAM("ATNDPHY") D  Q:'RETURN 0
 . S %=$$CHKPROV^DGPMAPI6(.RETURN,$G(PARAM("ATNDPHY")),PARAM("DATE"),"PARAM('ATNDPHY')") Q
 . S NEW("ATNDPHY")=PARAM("ATNDPHY")
 ; primary physician
 I $G(PARAM("PRYMPHY"))'="",+OLD("PRYMPHY")'=+PARAM("PRYMPHY") D  Q:'RETURN 0
 . S %=$$CHKPROV^DGPMAPI6(.RETURN,$G(PARAM("PRYMPHY")),PARAM("DATE"))
 . S NEW("PRYMPHY")=PARAM("PRYMPHY")
 ; diagosis
 I $D(PARAM("DIAG")) D
 . N CH S CH=0
 . F I=0:0 S I=$O(PARAM("DIAG",I)) Q:'I  S:PARAM("DIAG",I)'=$G(OLD("DIAG",I)) CH=1 S NEW("DIAG",I)=PARAM("DIAG",I)
 . K:'CH NEW("DIAG")
 S RETURN=($D(NEW)>0)
 Q 1
 ;
CHKFTS(RETURN,FTS,DATE) ; Check FTS
 N TMP,TXT K RETURN S RETURN=0
 I $G(FTS)="" S TXT(1)="PARAM('FTSPEC')" D ERRX^DGPMAPIE(.RETURN,"INVPARM",.TXT) Q 0
 D GETFTS^DGPMDAL2(.TMP,+FTS,".01;100*") I TMP=0 D ERRX^DGPMAPIE(.RETURN,"FTSNFND") Q 0
 I $D(TMP("E")),'$$ISFTSACT^DGPMAPI7(.TMP,+DATE) D ERRX^DGPMAPIE(.RETURN,"FTSINAC") Q 0
 S RETURN=1
 Q 1
 ;
CHKPROV(RETURN,PROV,DATE,TXT) ; Check provider
 K RETURN S RETURN=0
 I $G(PROV)="" S TXT(1)=TXT D ERRX^DGPMAPIE(.RETURN,"INVPARM",.TXT) Q 0
 D GETPROV^DGPMDAL2(.TMP,+PROV)
 I TMP=0 D ERRX^DGPMAPIE(.RETURN,"PROVNFND") Q 0
 I '$$SCREEN^DGPMDD(+PROV,,+DATE) D  Q 0
 . S TXT(1)=$G(TMP(.01,"E")) D ERRX^DGPMAPIE(.RETURN,"PROVINAC",.TXT)
 S RETURN=1
 Q 1
 ;
UPDFTSE(RETURN,PARAM,MFN) ; Update facility treating specialty
 N %,OLD,NEW,DFN
 K RETURN S RETURN=0
 S %=$$CHKUPD(.RETURN,.PARAM,.AFN,.OLD,.NEW)
 I RETURN=0 S:'$D(RETURN(0)) RETURN=1 Q $S('$D(RETURN(0)):1,1:0)
 S DFN=$P(OLD("PATIENT"),U)
 S %=$$LOCKMVT^DGPMAPI9(.RETURN,DFN) Q:'RETURN 0
 S %=$$UPD(.RETURN,.PARAM,AFN,.OLD,.NEW)
 S %=$$UPDPAT^DGPMAPI7(,.PARAM,DFN)
 D EVT(DFN,+AFN,1)
 D ULOCKMVT^DGPMAPI9(DFN)
 Q 1
UPD(RETURN,PARAM,MFN,OLD,NEW) ; Update facility treating specialty
 N %,MVT,DIAG
 K RETURN S RETURN=0
 D SETREVT^DGPMDAL1(MFN,"P")
 S:+$G(NEW("PRYMPHY")) MVT(.08)=+NEW("PRYMPHY")  ; primary physician
 S:$D(NEW("FTSPEC")) MVT(.09)=+NEW("FTSPEC")   ; facility treating specialty
 S:$D(NEW("ATNDPHY")) MVT(.19)=+NEW("ATNDPHY")  ; attending physician
 D UPDMVT^DGPMDAL1(.RETURN,.MVT,MFN)
 M DIAG=PARAM("DIAG")
 D UPDDIAG^DGPMDAL1(.RETURN,.DIAG,MFN)
 D SETREVT^DGPMDAL1(MFN,"A")
 Q 1
 ;
FTS(RETURN,PARAM) ; Add facility treating movement/provider change
 N %,DFN
 K RETURN S RETURN=0
 S %=$$CHKADD(.RETURN,.PARAM) Q:'RETURN 0
 S DFN=+PARAM("PATIENT")
 S %=$$LOCKMVT^DGPMAPI9(.RETURN,DFN) Q:'RETURN 0
 S %=$$ADD(.RETURN,.PARAM)
 S %=$$UPDPAT^DGPMAPI7(,.PARAM,DFN)
 D EVT(DFN,+RETURN,1)
 D ULOCKMVT^DGPMAPI9(DFN)
 Q 1
EVT(DFN,IFN,MODE) ; Event
 D MVTEVT^DGPMAPI7(DFN,6,IFN,.MODE)
 Q
 ;
ADD(RETURN,PARAM) ; Add ralated physical movement
 N %,PM6,MFN,DIAG,PTS
 S PM6(.01)=+PARAM("DATE") ; admission date
 D ADDMVMTX^DGPMDAL1(.RETURN,.PM6)
 S MFN=+RETURN
 S PM6(.02)=6  ; transaction
 D UPDMVT^DGPMDAL1(.RETURN,.PM6,MFN)
 S PM6(.03)=+PARAM("PATIENT")  ; patient
 S PM6(.14)=+PARAM("ADMIFN")  ; admission checkin movement
 S:$D(PARAM("RELIFN")) PM6(.24)=+PARAM("RELIFN")  ; related physical movement
 S PM6(100)=DUZ,PM6(101)=$$NOW^XLFDT()
 S PM6(102)=DUZ,PM6(103)=$$NOW^XLFDT()
 D UPDMVT^DGPMDAL1(.RETURN,.PM6,MFN)
 K PM6
 S PM6(.04)=42
 S:+$G(PARAM("PRYMPHY")) PM6(.08)=+PARAM("PRYMPHY")  ; primary physician
 I $G(PARAM("DGPMPC")) D
 . S PTS=$$GETPVTS^DGPMDAL1(+PARAM("PATIENT"),+PARAM("ADMIFN"),+PARAM("DATE"))
 . D GETMVT^DGPMDAL1(.PTS,PTS)
 . S PARAM("FTSPEC")=PTS(.09,"I")
 S PM6(.09)=+PARAM("FTSPEC")  ; facility treating specialty
 S PM6(.19)=+PARAM("ATNDPHY")  ; attending physician
 D UPDMVT^DGPMDAL1(.RETURN,.PM6,MFN)
 S:'$D(PARAM("DIAG"))&($G(PARAM("SHDIAG"))]"") DIAG(1)=$G(PARAM("SHDIAG"))
 M:$D(PARAM("DIAG")) DIAG=PARAM("DIAG")
 D UPDDIAG^DGPMDAL1(.RETURN,.DIAG,MFN)
 D SETREVT^DGPMDAL1(MFN,"A")
 S RETURN=MFN
 Q 1
 ;
ASIH(RETURN,PARAM) ; ASIH transfer
 N %,TFN,AFN,NADM,TRA,DIS,FTS,FTSFN,DFN,DMFN
 D SETAEVT^DGPMDAL1(+PARAM("ADMIFN"),,"P")
 S TFN=$$ADDTRA^DGPMAPI2(.RETURN,.PARAM)
 M NADM=PARAM S DFN=+PARAM("PATIENT")
 S NADM("TYPE")=10 ; mvmt type
 S %=$$ADDADM^DGPMAPI1(,.NADM)
 S AFN=+%,TRA(.15)=AFN,TRA(.22)=1
 D UPDMVT^DGPMDAL1(,.TRA,TFN)
 M DIS=PARAM
 S DIS("TYPE")=34,DIS("DATE")=$$FMADD^XLFDT(+PARAM("DATE"),30)
 S %=$$ADDDIS^DGPMAPI3(.RETURN,.DIS,DFN)
 S DMFN=+RETURN
 K NADM
 ;S NADM(.17)=DMFN ; asih transfer
 S NADM(.21)=TFN ; asih transfer
 S NADM(.22)=2 ; asih sequence
 D UPDMVT^DGPMDAL1(,.NADM,AFN)
 M FTS=PARAM
 S FTS("ADMIFN")=AFN,FTS("RELIFN")=AFN
 S %=$$ADD^DGPMAPI6(.RETURN,.FTS)
 S FTSFN=+RETURN
 D SETTEVT^DGPMDAL1(TFN,,"A")
 D SETDEVT^DGPMDAL1(DMFN,"A")
 D SETAEVT^DGPMDAL1(+PARAM("ADMIFN"),,"A")
 D SETAEVT^DGPMDAL1(AFN,FTSFN,"A")
 S RETURN=TFN
 Q 1
 ;
CANDEL(RETURN,MFN,MVT) ; facility treating movement
 N % K RETURN S RETURN=0
 S %=$$GETMVT^DGPMAPI8(.MVT,+MFN)
 I MVT=0 D ERRX^DGPMAPIE(.RETURN,"RPMNFND") Q 0
 I +MVT("ADMIFN")=+MVT("RPM") D ERRX^DGPMAPIE(.RETURN,"CANDRPM") Q 0
 S RETURN=1
 Q 1
 ;
DELFTS(RETURN,MFN) ; Delete facility treating movement
 N %,MVT,DFN
 K RETURN S RETURN=0
 S %=$$CANDEL(.RETURN,+MFN,.MVT) Q:'RETURN 0
 S DFN=MVT("PATIENT")
 S %=$$LOCKMVT^DGPMAPI9(.RETURN,DFN) Q:'RETURN 0
 S %=$$DEL(.RETURN,+MFN,.MVT)
 D EVT(DFN,+MFN,1)
 D ULOCKMVT^DGPMAPI9(DFN)
 Q 1
DEL(RETURN,MFN,MVT) ; Delete facility treating movement
 D INITEVT^DGPMDAL1
 D SETREVT^DGPMDAL1(+MFN,"P")
 D DELMVT^DGPMDAL1(+MFN)
 D SETREVT^DGPMDAL1(+MFN,"A","")
 Q 1
