SDMAPI2 ;RGI/VSL - APPOINTMENT API; 5/13/13
 ;;5.3;scheduling;**260003**;08/13/93
CHKAPP(RETURN,SC,DFN,SD,LEN,LVL) ; Check make appointment
 N PAT,CLN,VAL,PATT,HOL,TXT,X,X1,X2,APT,CAPT,FRSTA,SDEDT,SDSOH,%
 K RETURN S RETURN=1
 S:'$G(LVL) LVL=7
 I '+$G(SD)!'($G(SD)#1) D  Q 0
 . S TXT(1)="SD",RETURN=0
 . D ERRX^SDAPIE(.RETURN,"INVPARAM",.TXT)
 S %=$$CHKPAT^SDMAPI3(.RETURN,.DFN) Q:'% 0
 S %=$$CHKCLN^SDMAPI3(.RETURN,.SC) Q:'% 0
 I '$G(LEN) S RETURN=0,TXT(1)="LEN" D ERRX^SDAPIE(.RETURN,"INVPARAM",.TXT) Q 0
 D GETPAT^SDMDAL3(.PAT,+DFN,1) ; get patient data
 D GETCLN^SDMDAL1(.CLN,+SC,1) ; get clinic data
 ;check patient, stop code and inactive
 S %=$$CHKAPTU(.RETURN,+SC,+DFN,+SD,.CLN,.PAT) Q:RETURN=0 0
 ;check user permissions
 S VAL=$$CLNRGHT^SDMAPI1(.RETURN,+SC) Q:VAL=0 VAL
 S %=$$SETST^SDMAPI5(.RETURN,+SC,+SD) Q:RETURN=0 0
 ;verify that day hasn't been canceled via "SET UP A CLINIC"
 D GETPATT^SDMDAL1(.PATT,+SC,+SD) I $G(PATT(0))'["[" S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTCLUV") Q 0
 ;check if schedule on holiday is permited
 D GETHOL^SDMDAL1(.HOL,$P(SD,"."))
 S SDSOH=$S('$D(CLN(1918.5)):0,CLN(1918.5)']"":0,1:1)
 I $D(HOL($P(SD,"."))),'SDSOH S TXT(1)=$P(HOL($P(SD,".")),U,2) S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTSHOL",.TXT) Q 0
 ;check if exceed max days for future appointment
 S X1=DT,SDEDT=$G(CLN(2002))
 S:SDEDT'>0 SDEDT=365
 S X2=SDEDT D C^%DTC S SDEDT=X
 I $P(SD,".")'<SDEDT S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTEXCD") Q 0
 ;check if patient has an active appointment on the same time
 D GETAPTS^SDMDAL2(.APT,+DFN,+SD)
 I $D(APT),APT("APT",+SD,"STATUS")'["C"  D
 . N CO
 . S CO=$$CODT^SDCOU(+DFN,+SD,+APT("APT",+SD,"CLINIC"))
 . S %=$$GETSCAP^SDMAPI1(.CAPT,+APT("APT",+SD,"CLINIC"),+DFN,+SD) Q:'$D(CAPT)
 . S TXT(1)="("_CAPT("LENGTH")_" MINUTES)"
 . S:+SC'=+APT("APT",+SD,"CLINIC") TXT(2)=" "_$$EZBLD^DIALOG(480000.09)_" "_$P(APT("APT",+SD,"CLINIC"),U,2)
 . S RETURN=0 D ERRX^SDAPIE(.RETURN,$S(CO:"APTPAHCO",1:"APTPAHA"),.TXT,$S(CO:1,1:2))
 I RETURN=0 S RETURN=$S(+LVL>1:0,1:1) Q:+LVL>1 RETURN
 ;check if patient has an active appointment on the same day
 I +LVL>2 D
 . K APT N IDX S IDX=""
 . D GETDAPTS^SDMDAL2(.APT,+DFN,$P(SD,"."))
 . F  S IDX=$O(APT(IDX)) Q:IDX=""  I APT(IDX,2)'["C"  D  Q
 . . K TXT S TXT(1)="(AT "_$E(IDX_0,9,10)_":"_$E(IDX_"000",11,12)_")"
 . . S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTPHSD",.TXT,3)
 Q:RETURN=0 0
 ;check if patient has an canceled appointment on the same time
 I +LVL'<2 D
 . K APT
 . D GETAPTS^SDMDAL2(.APT,+DFN,+SD)
 . I $D(APT),APT("APT",+SD,"STATUS")["P" D 
 . . S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTPPCP",,2)
 Q:RETURN=0 0
 ;check if date is prior to patient birth date
 I $P(SD,".",1)<$P($G(PAT(.03)),U,1) S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTPPAB") Q RETURN
 ;check if date is prior to clinic availability
 S FRSTA=$$GETFSTA^SDMDAL1(+SC) I FRSTA,$P(SD,".",1)<FRSTA S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTPCLA") Q 0
 ;check overbook
 S %=$$CHKOVB^SDMAPI3(.RETURN,.CLN,+SC,+SD,+LEN,+LVL) Q:RETURN=0 RETURN
 S RETURN=1
 Q RETURN
 ;
CHKAPTU(RETURN,SC,DFN,SD,CLN,PAT,UNS) ; Check make unscheduled appointment
 N PAPT,TXT,VAL,%
 K RETURN S RETURN=0
 S %=$$CHKPAT^SDMAPI3(.RETURN,.DFN) Q:'% 0
 S %=$$CHKCLN^SDMAPI3(.RETURN,.SC) Q:'% 0
 D:'$D(PAT) GETPAT^SDMDAL3(.PAT,+DFN,1) ; get patient data
 D:'$D(CLN) GETCLN^SDMDAL1(.CLN,+SC,1) ; get clinic data
 ;check if patient already has appointment
 S PAPT(.01)="" D GETPAPT^SDMDAL2(.PAPT,+DFN,+SD)
 S TXT(1)=$$FTIME^VALM1(+SD)
 I PAPT(.01)>0,$D(UNS) S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTPAHU",.TXT) Q RETURN
 ;check if patient is dead
 I +$G(PAT(.351))>0 S RETURN=0 D ERRX^SDAPIE(.RETURN,"PATDIED") Q RETURN
 ;check if clinic is valid (stop code)
 S VAL=$$CLNCK^SDMAPI1(.RETURN,+SC) Q:VAL=0 VAL
 ;check inactive clinic period
 I CLN(2505),$P(SD,".")'<CLN(2505),$S('CLN(2506):1,CLN(2506)>$P(SD,".")!('CLN(2506)):1,1:0) D  Q 0
 . S TXT(1)=$$DTS^SDMAPI(CLN(2505))
 . S:CLN(2506) TXT(2)=$$EZBLD^DIALOG(480000.072)_$$DTS^SDMAPI(CLN(2506))
 . S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTCINV",.TXT)
 S RETURN=1
 Q 1
 ;
MAKEUS(RETURN,DFN,SC,SD,TYP,STYP,CIO) ; Make unscheduled appointment
 N SCAP,STAT,%,TYPE,S,CLN,SM,TXT
 K RETURN S RETURN=0
 S:$D(TYP) TYPE=+TYP S:$G(SD)="" SD=$$NOW^XLFDT()
 I +$G(SD)=0!'($G(SD)#1) S RETURN=0,TXT(1)="SD" D ERRX^SDAPIE(.RETURN,"INVPARAM",.TXT) Q 0
 S %=$$CHKAPTU(.RETURN,.SC,.DFN,.SD,,,1) Q:RETURN=0 0
 S %=$$CHKTYPE^SDMAPI5(.RETURN,+DFN,.TYP) Q:'% 0
 S %=$$CHKSTYP^SDMAPI5(.RETURN,$G(TYP),.STYP) Q:'% 0
 I +SD>$$FMADD^XLFDT(DT,1) S RETURN=0 D ERRX^SDAPIE(.RETURN,"INVPARAM","SD") Q 0
 S SD=+$E(SD,1,12)
 S STAT=$$INP^SDAM2(+DFN,+SD)
 D GETCLN^SDMDAL1(.CLN,+SC,1)
 D MAKE^SDMDAL3(+DFN,+SD,+SC,+TYPE,+$G(STYP),STAT,4,DUZ,DT,"W",0)
 D MAKE^SDMDAL1(+SC,+SD,+DFN,CLN(1912),,DUZ)
 S %=$$LOCKST^SDMDAL1(+SC,+SD) I '% S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTLOCK") Q 0
 S SM=$$DECAVA^SDMAPI3(.CLN,+SC,+SD,CLN(1912),.S)
 D SETST^SDMDAL1(+SC,+SD,S)
 D UNLCKST^SDMDAL1(+SC,+SD)
 S %=$$GETSCAP^SDMAPI1(.SCAP,+SC,+DFN,+SD)
 S %=$$CIO(.RETURN,+DFN,+SD,+SC,.CIO)
 D MAKE^SDAMEVT(+DFN,+SD,+SC,SCAP("IFN"),2)
 S RETURN(1)=+SD
 S RETURN=1
 Q 1
 ;
MAKE(RETURN,DFN,SC,SD,TYPE,STYP,LEN,SRT,OTHR,CIO,LAB,XRAY,EKG,RQXRAY,CONS,LVL) ; Make appointment
 N CLN,%,TYP,APT,I,STAT,TXT
 S:'$G(LVL) LVL=7
 K RETURN S RETURN=1
 S %=$$CHKAPP(.RETURN,.SC,.DFN,.SD,.LEN,+LVL) Q:RETURN=0 0
 S %=$$CHKTYPE^SDMAPI5(.RETURN,+DFN,.TYPE) Q:'RETURN 0
 S %=$$CHKSTYP^SDMAPI5(.RETURN,$G(TYPE),.STYP) Q:'RETURN 0
 S %=$$CHKSRT^SDMAPI5(.RETURN,.SRT) Q:'RETURN 0
 S %=$$CHKCONS^SDMAPI5(.RETURN,.CONS) Q:'RETURN 0
 D GETCLN^SDMDAL1(.CLN,+SC,1)
 F I="LAB","XRAY","EKG" S:$G(@I)]"" %=$$CHKLABS^SDMAPI5(.RETURN,SD,.CLN,I,DFN) Q:'RETURN
 Q:'RETURN 0
 I +$G(LEN)>0,$G(CLN(1913))'="V",$G(CLN(1912))'=+LEN S RETURN=0,TXT(1)="LEN" D ERRX^SDAPIE(.RETURN,"INVPARAM",.TXT) Q 0
 S:$D(TYPE) TYP=+TYPE
 I RETURN=0,$P(RETURN(0),U,3)'>+LVL Q RETURN
 I LVL=1 D
 . D GETAPTS^SDMDAL2(.APT,+DFN,+SD)
 . Q:+$G(APT("APT",+SD,"CANCELLATION REASON"))=13&(+$G(APT("APT",+SD,"CANCELLATION REMARKS"))=13)
 . I $G(APT("APT",+SD,"CLINIC")) D
 . . S %=$$CANCEL(.RETURN,+DFN,+APT("APT",+SD,"CLINIC"),+SD,"C",13,"13",+APT("APT",+SD,"CLINIC"))
 . K RETURN(0)
 E  Q:'$G(RETURN)&('$G(LVL)) 0
 N S,SM,SDY,SCAP,SRT0
 S %=$$LOCKST^SDMDAL1(+SC,+SD) I '% S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTLOCK") Q 0
 S %=$$LOCKS^SDMDAL1(+SC,+SD) I '% S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTLOCK") Q 0
 S SM=$$DECAVA^SDMAPI3(.CLN,+SC,+SD,+LEN,.S)
 D SETST^SDMDAL1(+SC,+SD,S)
 D MAKE^SDMDAL1(+SC,+SD,+DFN,+LEN,SM,DUZ,$G(OTHR),.RQXRAY)
 D UNLCKS^SDMDAL1(+SC,+SD)
 D UNLCKST^SDMDAL1(+SC,+SD)
 S STAT=$$INP^SDAM2(+DFN,+SD)
 S SRT0=$$NAVA^SDMANA(+SC,+SD,.SRT)
 D MAKE^SDMDAL3(+DFN,+SD,+SC,+TYP,+$G(STYP),STAT,3,DUZ,DT,.SRT,SRT0,.LAB,.XRAY,.EKG)
 N DATA S DATA(27)=$S($G(SRT)="O":$P(SD,"."),1:DT),DATA(28)=$$PTFU^SDMAPI1(,+DFN,+SC)
 D UPDPAPT^SDMDAL4(.DATA,+DFN,+SD)
 S %=$$GETSCAP^SDMAPI1(.SCAP,+SC,+DFN,+SD)
 I $G(CONS)>0 S DATA(688)=CONS
 D UPDCAPT^SDMDAL4(.DATA,+SC,+SD,$G(SCAP("IFN")))
 S:$G(CONS)>0 %=$$EDITCS^SDCAPI1(.RETURN,CONS,+SD,.OTHR,$G(CLN("NAME"))) ;SD/478
 S %=$$CIO(.RETURN,+DFN,+SD,+SC,.CIO)
 D MAKE^SDAMEVT(+DFN,+SD,+SC,$G(SCAP("IFN")),2)
 S RETURN=1
 Q 1
 ;
CIO(RETURN,DFN,SD,SC,CIO) ; Check in/check out
 N %
 I $D(CIO),CIO="CI",+SD'>$$NOW^XLFDT(),+SD>DT D
 . S %=$$CHECKIN^SDMAPI2(.RETURN,+DFN,+SD,+SC,+SD)
 I $D(CIO),CIO="CO",+SD<$$NOW^XLFDT() D
 . S %=$$CHECKO^SDMAPI4(.RETURN,+DFN,+SD,+SC,+$G(CIO("DT")))
 Q 1
CHKRSN(RETURN,RSN,TYPE) ; Check cancellation reason
 N CRSN K RETURN S RETURN=0
 I '+$G(RSN) D ERRX^SDAPIE(.RETURN,"INVPARAM","RSN") Q 0
 I '$$RSNEXST^SDMDAL3(+RSN) D ERRX^SDAPIE(.RETURN,"RSNNFND") Q 0
 D GETCRSN^SDMDAL4(.CRSN,RSN)
 I $E(TYPE,1)'=$G(CRSN(2,"I")),$G(CRSN(2,"I"))'="B" D ERRX^SDAPIE(.RETURN,"INVPARAM","RSN") Q 0
 S RETURN=1
 Q 1
CANCEL(RETURN,DFN,SC,SD,TYP,RSN,RMK,APC) ; Cancel appointment
 N CDATE,CDT,ERR,ODT,OIFN,OUSR,%,CAPT,CIFN
 K RETURN S RETURN=0
 I $G(TYP)=0!($G(TYP)'["C") D ERRX^SDAPIE(.RETURN,"INVPARAM","TYP") Q 0
 I +$G(SD)=0 D ERRX^SDAPIE(.RETURN,"INVPARAM","SD") Q 0
 S %=$$CHKPAT^SDMAPI3(.RETURN,+$G(DFN)) Q:'% 0
 S %=$$CHKCLN^SDMAPI3(.RETURN,+$G(SC)) Q:'% 0
 S %=$$CHKRSN^SDMAPI2(.RETURN,+$G(RSN),$G(TYP)) Q:'% 0
 S %=$$CHKCAN^SDMAPI3(.RETURN,+DFN,+SC,.SD) Q:RETURN=0 0
 S CDATE=$$NOW^XLFDT
 S %=$$GETSCAP^SDMAPI1(.CAPT,+SC,+DFN,+SD)
 S CIFN=CAPT("IFN")
 S OUSR=CAPT("USER"),ODT=CAPT("DATE")
 N SDATA,SDCPHDL
 S SDCPHDL=$$HANDLE^SDAMEVT(1)
 D BEFORE^SDAMEVT(.SDATA,+DFN,+SD,+SC,CIFN,SDCPHDL)
 S CDT=$J($$NOW^XLFDT(),4,2)
 D CANCEL^SDMDAL3(.ERR,+DFN,+SD,TYP,+RSN,$G(RMK),CDT,DUZ,OUSR,ODT,.APC)
 S OIFN=$$COVERB^SDMDAL1(+SC,+SD,CIFN)
 S %=$$CANCEL^SDCAPI1(RETURN,CAPT("CONSULT"),+SC,+SD,CIFN,$G(RMK),TYP)
 D CANCEL^SDMDAL1(+SC,+SD,+DFN,CIFN)
 D CANCEL^SDAMEVT(.SDATA,+DFN,+SD,+SC,CIFN,0,SDCPHDL)
 S RETURN=1
 Q RETURN
 ;
CHECKIN(RETURN,DFN,SD,SC,CIDT) ; Check in appointment
 N CAPT,CI,%,CIFN,CD,APT0
 K RETURN S RETURN=0 S CI=DT
 S %=$$CHKPAT^SDMAPI3(.RETURN,.DFN) Q:'% 0
 S %=$$CHKCLN^SDMAPI3(.RETURN,.SC) Q:'% 0
 I $G(CIDT)]"",'+$G(CIDT) S RETURN=0 D ERRX^SDAPIE(.RETURN,"INVPARAM","CIDT") Q 0
 S CI=+$S(+$G(CIDT):$J(CIDT,2,4),1:$J($$NOW^XLFDT(),2,4))
 I +$G(SD)=0 S RETURN=0 D ERRX^SDAPIE(.RETURN,"INVPARAM","SD") Q 0
 S APT0=$$GETAPT0^SDMDAL2(+DFN,+SD)
 I APT0="" S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTNFND") Q 0
 S %=$$GETSCAP^SDMAPI1(.CAPT,+SC,+DFN,+SD)
 S CIFN=$G(CAPT("IFN"))
 I 'CIFN S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTCIPE") Q 0
 N SDATA,SDCIHDL,X
 S SDATA=CIFN_U_DFN_U_SD_U_SC,SDCIHDL=$$HANDLE^SDAMEVT(1)
 D BEFORE^SDAMEVT(.SDATA,+DFN,+SD,+SC,CIFN,SDCIHDL)
 S %=$$CHKCIN^SDMAPI3(.RETURN,+DFN,+SD,+SDATA("BEFORE","STATUS")) Q:'% 0
 S CD(302)=DUZ,CD(309)=CI
 D UPDCAPT^SDMDAL4(.CD,+SC,+SD,CAPT("IFN"))
 D AFTER^SDAMEVT(.SDATA,+DFN,+SD,+SC,CIFN,SDCIHDL)
 M RETURN=SDATA
 I SDATA("BEFORE","STATUS")'=SDATA("AFTER","STATUS") D
 . D EVT^SDAMEVT(.SDATA,4,0,SDCIHDL) ; 4 := ci evt , 0 := interactive mode
 S %=$$GETSCAP^SDMAPI1(.CAPT,+SC,+DFN,+SD)
 S RETURN("CI")=$G(CAPT("CHECKIN"))
 S RETURN=1
 Q 1
 ;
NOSHOW(RETURN,DFN,SC,SD,LVL) ; No-show appointment
 N APT0,STATUS,APTSTAT,AUTO,CNSTLNK,NSDA,NSDIE,%,CAPT,CIFN
 K RETURN S RETURN=0
 S:'$D(LVL) LVL=7
 S %=$$CHKNS^SDMAPI3(.RETURN,.DFN,.SC,.SD,.LVL,.STATUS,.APTSTAT)
 I RETURN=0,$P(RETURN(0),U,3)'>+LVL Q RETURN
 N FDA,CIFN,CAPT
 S %=$$GETSCAP^SDMAPI1(.CAPT,+SC,+DFN,+SD)
 S CIFN=CAPT("IFN")
 S CNSTLNK=$G(CAPT("CONSULT"))
 S RETURN("BEFORE")=STATUS
 N SDNSHDL S SDNSHDL=$$HANDLE^SDAMEVT(1)
 N SDATA
 D BEFORE^SDAMEVT(.SDATA,+DFN,+SD,+SC,CIFN,SDNSHDL)
 I APTSTAT=""!(APTSTAT="NT") D
 . S FDA(3)="N",FDA(14)=DUZ,FDA(15)=$$NOW^XLFDT()
 E  D
 . S FDA(3)="@",FDA(14)="@",FDA(15)="@"
 D UPDPAPT^SDMDAL4(.FDA,+DFN,+SD)
 D NOSHOW^SDAMEVT(.SDATA,+DFN,+SD,+SC,CIFN,2,SDNSHDL)
 S:+$G(CNSTLNK) %=$$NOSHOW^SDCAPI1(.RETURN,+SC,+SD,+DFN,CNSTLNK,CIFN)
 S APT0=$$GETAPT0^SDMDAL2(+DFN,+SD)
 S APTSTAT=$P(APT0,U,2)
 S STATUS=$$STATUS^SDAM1(+DFN,+SD,+$G(APT0),$G(APT0))
 S RETURN("AFTER")=STATUS
 S RETURN=1
 Q 1
 ;
