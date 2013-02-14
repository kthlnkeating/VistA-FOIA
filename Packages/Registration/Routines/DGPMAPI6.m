DGPMAPI6 ;RGI/VSL - FACILITY TRATING SPECIALTY API; 2/11/2013
 ;;5.3;Registration;**260005**;
CHKRPM(RETURN,PARAM) ; 
 K RETURN S RETURN=1
 N %
 ; facility treating specialty
 S %=$$CHKFTS^DGPMAPI6(.RETURN,$G(PARAM("FTSPEC")),PARAM("DATE")) Q:'RETURN 0
 ;attender
 S %=$$CHKPROV^DGPMAPI6(.RETURN,$G(PARAM("ATNDPHY")),PARAM("DATE"),"PARAM('ATNDPHY')") Q:'RETURN 0
 ; primary physician
 I $G(PARAM("PRYMPHY"))'="" D  Q:'RETURN 0
 . S %=$$CHKPROV^DGPMAPI6(.RETURN,$G(PARAM("PRYMPHY")),PARAM("DATE"))
 Q 1
 ;
CHKUPD(RETURN,PARAM,MFN,NEW) ; 
 N %,OLD,FLDS
 K RETURN S RETURN=1
 S FLDS=".08;.09;.19"
 D GETMVT^DGPMDAL1(.OLD,MFN,FLDS)
 ; facility treating specialty
 I $G(PARAM("FTSPEC"))'="",OLD(.09,"I")'=PARAM("FTSPEC") D  Q:'RETURN 0
 . S %=$$CHKFTS^DGPMAPI6(.RETURN,$G(PARAM("FTSPEC")),PARAM("DATE")) Q
 . S NEW("FTSPEC")=PARAM("FTSPEC")
 ;attender
 I $G(PARAM("ATNDPHY"))'="",OLD(.09,"I")'=PARAM("ATNDPHY") D  Q:'RETURN 0
 . S %=$$CHKPROV^DGPMAPI6(.RETURN,$G(PARAM("ATNDPHY")),PARAM("DATE"),"PARAM('ATNDPHY')") Q
 . S NEW("ATNDPHY")=PARAM("ATNDPHY")
 ; primary physician
 I $G(PARAM("PRYMPHY"))'="",OLD(.09,"I")'=PARAM("PRYMPHY") D  Q:'RETURN 0
 . S %=$$CHKPROV^DGPMAPI6(.RETURN,$G(PARAM("PRYMPHY")),PARAM("DATE"))
 . S NEW("PRYMPHY")=PARAM("PRYMPHY")
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
UPDFTS(RETURN,PARAM,MFN) ; Update facility treating specialty
 N %,MVT,DIAG
 K RETURN S RETURN=0
 S %=$$CHKUPD^DGPMAPI6(.RETURN,.PARAM,MFN) Q:'% 0
 I RETURN=0 S:'$D(RETURN(0)) RETURN=1 Q $S('$D(RETURN(0)):1,1:0)
 S MVT(.08)=PARAM("PRYMPHY")  ; primary physician
 S MVT(.09)=PARAM("FTSPEC")   ; facility treating specialty
 S MVT(.19)=PARAM("ATNDPHY")  ; attending physician
 D UPDMVT^DGPMDAL1(.RETURN,.MVT,MFN)
 M DIAG=PARAM("DIAG")
 D UPDDIAG^DGPMDAL1(.RETURN,.DIAG,MFN)
 Q 1
 ;
ADDFTS(RETURN,PARAM) ; Add ralated physical movement
 N %,PM6,IFN6,DIAG
 S %=$$CHKRPM(.RETURN,.PARAM)
 I %=0 Q 0
 S PM6(.01)=+PARAM("DATE") ; admission date
 D ADDMVMTX^DGPMDAL1(.RETURN,.PM6)
 S IFN6=+RETURN
 S PM6(.02)=6  ; transaction
 D UPDMVT^DGPMDAL1(.RETURN,.PM6,IFN6)
 S PM6(.03)=+PARAM("PATIENT")  ; patient
 S PM6(.14)=+PARAM("ADMIFN")  ; admission checkin movement
 S PM6(.24)=+PARAM("RELIFN")  ; related physical movement
 S PM6(100)=DUZ,PM6(101)=$$NOW^XLFDT()
 S PM6(102)=DUZ,PM6(103)=$$NOW^XLFDT()
 D UPDMVT^DGPMDAL1(.RETURN,.PM6,IFN6)
 K PM6
 S PM6(.04)=42
 S:$D(PARAM("PRYMPHY")) PM6(.08)=+PARAM("PRYMPHY")  ; primary physician
 S PM6(.09)=+PARAM("FTSPEC")  ; facility treating specialty
 S PM6(.19)=+PARAM("ATNDPHY")  ; attending physician
 D UPDMVT^DGPMDAL1(.RETURN,.PM6,IFN6)
 S:'$D(PARAM("DIAG")) DIAG(1)=$G(PARAM("SHDIAG"))
 M:$D(PARAM("DIAG")) DIAG=PARAM("DIAG")
 D UPDDIAG^DGPMDAL1(.RETURN,.DIAG,IFN6)
 S RETURN=IFN6
 Q 1
 ;
