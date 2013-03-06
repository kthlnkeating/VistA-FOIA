DGPMAPI5 ;RGI/VSL - CHECK-OUT PATIENT API; 3/4/2013
 ;;5.3;Registration;**260005**;
CHKDT(RETURN,PARAM,TYPE,MAS,ADM) ; Check lodger check-out date
 N %,TXT,TT,DIS
 K RETURN S RETURN=0 ; patient
 D GETMVT^DGPMDAL1(.ADM,+$G(PARAM("ADMIFN")),".02;.03;")
 D GETMVTT^DGPMDAL2(.TT,+$G(PARAM("TYPE")))
 S TYPE=$G(TT(.03,"I"))
 D GETMASMT^DGPMDAL2(.MAS,TYPE)
 I $G(PARAM("ADMIFN"))="" S TXT(1)="PARAM('ADMIFN')" D ERRX^DGPMAPIE(.RETURN,"INVPARM",.TXT) Q 0
 D GETMVT^DGPMDAL1(.ADM,+$G(PARAM("ADMIFN")))
 I ADM=0 S TXT(1)="PARAM('ADMIFN')" D ERRX^DGPMAPIE(.RETURN,"ADMNFND",.TXT) Q 0
 I ADM(.17,"I")>0 D  Q 0
 . D GETMVT^DGPMDAL1(.DIS,+ADM(.17,"I"))
 . S TXT(1)=DIS(.01,"E")
 . D ERRX^DGPMAPIE(.RETURN,"DCHPADON",.TXT)
 I $G(PARAM("DATE"))=""!(+$G(PARAM("DATE"))<1800000) D  Q 0
 . S TXT(1)="PARAM('DATE')",RETURN=0 D ERRX^DGPMAPIE(.RETURN,"INVPARM",.TXT)
 I $$TIMEUSD^DGPMDAL2(+ADM(.03,"I"),+PARAM("DATE")) D ERRX^DGPMAPIE(.RETURN,"TIMEUSD") Q 0
 I +PARAM("DATE")<ADM(.01,"I") D ERRX^DGPMAPIE(.RETURN,"TRANBADM",.TXT) Q 0
 S %=$$GETLASTM^DGPMAPI8(.LMVT,+ADM(.03,"I"))
 I +PARAM("DATE")<LMVT("DATE") D ERRX^DGPMAPIE(.RETURN,"DCHNBLM",.TXT) Q 0
 S RETURN=1
 Q 1
CHKCO(RETURN,PARAM,TYPE,MAS,ADM) ; Check discharge patient
 N %,TXT,TT,ADM,DIS
 K RETURN S RETURN=0 ; patient
 S %=$$CHKDT(.RETURN,.PARAM,.TYPE,.MAS,.ADM)
 ; type of movement
 S PARAM("PATIENT")=+ADM(.03,"I")
 S %=$$CHKCOTYP(.RETURN,$G(PARAM("TYPE")),+ADM(.03,"I"),+PARAM("DATE")) Q:'RETURN 0
 D GETMVT^DGPMDAL1(.ADM,+$G(PARAM("ADMIFN")),".02;.03;")
 D GETMVTT^DGPMDAL2(.TT,+$G(PARAM("TYPE")))
 S TYPE=$G(TT(.03,"I"))
 I +TYPE=46 I $$GETAMT^DGPMDAL3(45)="" S TXT(1)=MAS(.01,"E") D ERRX^DGPMAPIE(.RETURN,"DSCNMVTD",.TXT) Q 0
 S RETURN=1
 Q 1
CHKCOTYP(RETURN,TYPE,DFN,DATE) ; Check lodger check-out type
 N %,TMP,TXT,ADTYP,ERR K RETURN S RETURN=0
 S %=$$CHKTYPE^DGPMAPI8(.RETURN,.TYPE,+DFN,+DATE,.TMP) Q:'RETURN 0
 S RETURN=0
 S %=$$LSTCOTYP^DGPMAPI7(.ADTYP,+TYPE,,,+DFN,+DATE)
 S TXT(1)=TMP(.01,"E")
 I $G(TMP(.04,"I"))'=1 D ERRX^DGPMAPIE(.RETURN,"MVTTINAC",.TXT) Q 0
 I +$G(ADTYP(0))=0 D ERRX^DGPMAPIE(.RETURN,"DISINVAT",.TXT) Q 0
 S RETURN=1
 Q 1
 ;
LDGOUT(RETURN,PARAM) ; Lodger check-out
 N %,PM,APM,DFN,IFN,ADM,WARD,ADMIFN,DATE,PAT,DGDT,IFNP,MAS,PTF,RPTF
 N TFCTY,TT,TXT
 S %=$$CHKCO(.RETURN,.PARAM,.TYPE,.MAS,.ADM)
 I %=0 Q 0
 S DFN=+PARAM("PATIENT")
 S %=$$LOCKMVT^DGPMDAL1(DFN)
 I %=0 S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"FILELOCK") Q 0
 D INITEVT^DGPMDAL1
 D SETCIEVT^DGPMDAL1(+PARAM("ADMIFN"),"P")
 S IFN=$$ADDCO(.RETURN,.PARAM,DFN,TYPE)
 D SETCOEVT^DGPMDAL1(IFN,"A")
 D SETCIEVT^DGPMDAL1(+PARAM("ADMIFN"),"A")
 D MVTEVT^DGPMAPI7(DFN,3,IFN)
 D ULOCKMVT^DGPMDAL1(DFN)
 Q 1
 ;
ADDCO(RETURN,PARAM,DFN,TYPE) ;
 N MVT,ADMIFN,DGDT,PM
 D GETMVT^DGPMDAL1(.MVT,+PARAM("ADMIFN"),".01;.03;.06;.16")
 S ADMIFN=+PARAM("ADMIFN")
 S DGDT=+PARAM("DATE")
 S PM(.01)=DGDT ; discharge date
 D ADDMVMTX^DGPMDAL1(.RETURN,.PM)
 S IFN=+RETURN
 K PM
 S PM(.14)=ADMIFN
 S PM(.02)=5  ; transaction
 S PM(.03)=DFN  ; patient
 S PM(.04)=+PARAM("TYPE")  ; type of movement
 S PM(30.03)=$P($G(PARAM("LDGDISP")),U)  ; disposition
 S PM(100)=DUZ,PM(101)=$$NOW^XLFDT()
 S PM(102)=DUZ,PM(103)=$$NOW^XLFDT()
 D UPDMVT^DGPMDAL1(.RETURN,.PM,IFN)
 S %=$$UPDPAT^DGPMAPI7(,.PAT,+DFN)
 Q IFN
 ;
CHKUDT(RETURN,COFN,DGDT) ; Check lodger date update
 N %,TXT,MTYPE,WARD,DATE,NMVT K RETURN S RETURN=1
 ; check-out date
 D GETMVT^DGPMDAL1(.OLD,+$G(COFN))
 D GETMVT^DGPMDAL1(.ADM,+$G(OLD(.14,"I")),".01;.02;.03;")
 I OLD=0 S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"DCHNFND") Q 0
 I $G(DGDT)'="",+$G(OLD(.01,"I"))'=+$G(DGDT) D  Q:'RETURN 0
 . I +DGDT<ADM(.01,"I") S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"TRANBADM",.TXT) Q
 . ;not before last movement
 . I $D(NMVT),NMVT("ID")'=+COFN S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"DCHNBLM") Q
 . I $$TIMEUSD^DGPMDAL2(+OLD(.03,"I"),+DGDT) D  Q
 . . S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"TIMEUSD")
 . S NEW("DATE")=+DGDT
 S DATE=$S($D(NEW("DATE")):+NEW("DATE"),1:+OLD(.01,"I"))
 S RETURN=1
 Q 1
 ;
CHKUPD(RETURN,PARAM,COFN,OLD,NEW) ; Check lodger update
 N %,TXT,MTYPE,WARD,DATE,NMVT K RETURN S RETURN=1
 ; transfer date
 S %=$$CHKUDT(.RETURN,COFN,+PARAM("DATE")) Q:'RETURN 0
 ; type of movement
 I $G(PARAM("TYPE"))'="",+$G(OLD(.04,"I"))'=+$G(PARAM("TYPE")) D  Q:'RETURN 0
 . S %=$$CHKCOTYP(.RETURN,+$G(PARAM("TYPE")),+OLD(.03,"I"),DATE) Q:'%
 . S NEW("TYPE")=+PARAM("TYPE")
 S TYPE=$S($D(NEW("TYPE")):+NEW("TYPE"),1:+OLD(.04,"I"))
 ; disposition
 I $G(PARAM("LDGDISP"))'="",$G(OLD(30.03,"I"))'=$P($G(PARAM("LDGDISP")),U) D  Q:'RETURN 0
 . ;S %=$$CHKCOTYP(.RETURN,+$G(PARAM("TYPE")),+OLD(.03,"I"),DATE) Q:'%
 . S NEW("LDGDISP")=$P(PARAM("LDGDISP"),U)
 S RETURN=($D(NEW)>0)
 Q 1
 ;
UPDLDGOU(RETURN,PARAM,COFN) ; Update lodger check-out
 N OLD,NEW
 K RETURN S RETURN=0
 S %=$$CHKUPD(.RETURN,.PARAM,.COFN,.OLD,.NEW)
 Q:%=0 0
 I RETURN=0 S:'$D(RETURN(0)) RETURN=1 Q $S('$D(RETURN(0)):1,1:0)
 D SETCOEVT^DGPMDAL1(+COFN,"P")
 S:$D(NEW("DATE")) DIS(.01)=+NEW("DATE")
 S:$D(NEW("TYPE")) DIS(.04)=+NEW("TYPE")
 S:$D(NEW("LDGDISP")) DIS(30.03)=NEW("LDGDISP")
 D UPDMVT^DGPMDAL1(,.DIS,+COFN)
 D SETCOEVT^DGPMDAL1(+COFN,"A")
 D MVTEVT^DGPMAPI7(+PARAM("PATIENT"),3,+COFN)
 S RETURN=1
 Q 1
 ;
CANDEL(RETURN,COFN) ; Can delete lodger check-out
 N LMVT,PMVT,ASHADM,DCH,FLDS,ADM
 K RETURN S RETURN=0,FLDS=".01;.02;.03;.04;.14;.15;.16;.17;.18;.21"
 D GETMVT^DGPMDAL1(.DCH,COFN,FLDS)
 I DCH=0 S RETURN=0 D ERRX^DGPMAPIE(.RETURN,"DCHNFND") Q 0
 S %=$$GETLASTM^DGPMAPI8(.LMVT,+DCH(.03,"I"))
 I $G(LMVT("MFN"))'=+COFN D ERRX^DGPMAPIE(.RETURN,$S(LMVT("TYPE")<4:"DCHCDOLA",1:"DCHDODLM")) Q 0
 S RETURN=1
 Q 1
 ;
DELLDGOU(RETURN,COFN) ; Delete lodger check-out
 N %,DIS,DA
 K RETURN S RETURN=0,DA=+COFN
 S %=$$CANDEL^DGPMAPI3(.RETURN,+COFN) Q:'RETURN 0
 D INITEVT^DGPMDAL1
 D GETMVT^DGPMDAL1(.DIS,+COFN,".03;.14;.16;.17;.21")
 D SETCIEVT^DGPMDAL1(DIS(.14,"I"),"P")
 D SETCOEVT^DGPMDAL1(+COFN,"P")
 D DELMVT^DGPMDAL1(+COFN)
 D SETCIEVT^DGPMDAL1(DIS(.14,"I"),"A")
 D SETCOEVT^DGPMDAL1(+COFN,"A")
 S %=$$UPDPAT^DGPMAPI7(,.PARAM,+DIS(.03,"I"))
 D MVTEVT^DGPMAPI7(DIS(.03,"I"),3,+COFN)
 S RETURN=1
 Q 1
 ;
