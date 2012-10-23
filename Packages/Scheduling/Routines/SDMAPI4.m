SDMAPI4 ;RGI/CBR - APPOINTMENT API; 10/23/2012
 ;;5.3;scheduling;**260003**;08/13/93;
CHECKO(RETURN,DFN,SD,SC) ; Check out
 N CAPT,OE,APT0,CD
 D GETSCAP^SDMAPI1(.CAPT,SC,DFN,SD)
 I '$D(CAPT) D ERRX^SDAPIE(.RETURN,"APTCOCN") Q 0
 S APT0=$$GETAPT0^SDMDAL2(DFN,SD)
 S STATUS=$$STATUS^SDAM1(DFN,SD,+$G(APT0),$G(APT0))
 K % S %=$$CHKCO(.RETURN,DFN,SD,+STATUS)
 Q:'RETURN 0
 I '$$NEW^SDPCE(SD) D ERRX^SDAPIE(.RETURN,"APTCONW",,2)
 S CD(304)=DUZ,CD(303)=$$NOW^XLFDT()
 ;D UPDCAPT^SDMDAL4(.CD,SC,SD,CAPT("IFN"))
 S RETURN("SDOE")=$$GETAPT(DFN,SD,SC)
 S RETURN("COD")=CAPT("CHECKOUT")
 S OE(.04)="",OE(.05)=""
 D GETOE^SDMDAL4(.OE,RETURN("SDOE"))
 S RETURN("LOCATION")=OE(.04)
 S RETURN("VISIT")=OE(.05)
 S RETURN("COVISIT")=$P(APT0,U,11)
 I "^2^8^12^"[("^"_+STATUS_"^"),$P(STATUS,";",3)["CHECKED OUT" D
 . S RETURN("CO")=1
 . D ERRX^SDAPIE(.RETURN,"APTCOAC",,2)
 Q 1
 ;
GETAPT(DFN,SDT,SDCL,SDVIEN) ;Look-up Outpatient Encounter IEN for Appt
 ; Input  -- DFN      Patient file IEN
 ;           SDT      Appointment Date/Time
 ;           SDCL     Hospital Location file IEN for Appt
 ;           SDVIEN   Visit file pointer [optional]
 ; Output -- Outpatient Encounter file IEN
 N PAPT
 S PAPT(21)=""
 D GETPAPT^SDMDAL2(.PAPT,DFN,SD)
 I 'PAPT(21) D APPT^SDVSIT(DFN,SDT,SDCL,$G(SDVIEN)) D GETPAPT^SDMDAL2(.PAPT,DFN,SD)
 I PAPT(21) D VIEN^SDVSIT2(PAPT(21),$G(SDVIEN))
 Q +$G(PAPT(21))
 ;
CHKCO(RETURN,DFN,SD,STATUS) ; Check in check out
 S RETURN=0
 I '$D(STATUS) D
 . S APT0=$$GETAPT0^SDMDAL2(DFN,SD)
 . S STATUS=$$STATUS^SDAM1(DFN,SD,+$G(APT0),$G(APT0))
 S %=$$CHKSPCO(.RETURN,DFN,SD,+STATUS) Q:'% 0
 S DT=$$NOW^XLFDT
 I $P(SD,".")>DT D ERRX^SDAPIE(.RETURN,"APTCOTS") Q 0
 Q 1
 ;
CHKSPCO(RETURN,DFN,SD,STATUS) ; Check if status permit check in
 N IND,STAT,STATS
 S RETURN=0
 D LSTCOST1^SDMDAL2(.STAT)
 D BLDLST^SDMAPI(.STATS,.STAT)
 S IND=0
 F  S IND=$O(STATS(IND)) Q:IND=""!(RETURN=1)  D
 . I STATS(IND,"ID")=STATUS S RETURN=1 Q
 I 'RETURN D ERRX^SDAPIE(.RETURN,"APTCOCE")
 Q RETURN
 ;
CHKDCO(RETURN,DFN,SD) ; Check delete check out
 N PAPT,CAPT,OE,SDATA,SDELHDL,X
 S PAPT(21)="",PAPT(.01)=""
 S OE(.01)="",OE(.04)="",OE(.05)="",OE(.08)="",OE(.09)="",OE(.06)=""
 D GETPAPT^SDMDAL2(.PAPT,DFN,SD)
 D GETSCAP^SDMAPI1(.CAPT,PAPT(.01),DFN,SD)
 D GETOE^SDMDAL4(.OE,PAPT(21))
 S RETURN=0
 I 'PAPT(21)!('CAPT("CHECKOUT")) D ERRX^SDAPIE(.RETURN,"APTDCOD") Q 0
 I '$$NEW^SDPCE(OE(.01)) D ERRX^SDAPIE(.RETURN,"APTDCOO") Q 0
 S RETURN=1
 Q 1
 ;
DELCOPC(RETURN,SDOE,SDELHDL,SDELSRC) ; Delete check out (PCE)
 N SC,OE,SDDA,SDEVTF,X
 D SETCO(.SDOE,.DFN,.SD,.OE,.SC,.SDDA)
 I $G(SDELSRC)'="PCE" S X=$$DELVFILE^PXAPI("ALL",OE(.05),"","","")
 I '$$NEW^SDPCE(SD) D ERRX^SDAPIE(.RETURN,"APTDCOO") Q 0
 I '$G(SDELHDL) N SDATA,SDELHDL S SDEVTF=1 D EVT^SDCOU1(SDOE,"BEFORE",.SDELHDL,.SDATA)
 S %=$$DELCOL(.RETURN,DFN,SD,SC,SDDA,SDOE,.OE)
 I $G(SDEVTF) D EVT^SDCOU1(SDOE,"AFTER",.SDELHDL,.SDATA)
 Q 1
 ;
DELCOSD(RETURN,DFN,SD,ECHO) ; Delete check out (SD)
 S %=$$CHKDCO(.RETURN,DFN,SD)
 I RETURN=0 Q 0
 N SDOE,SC,OE,SDDA,X
 D SETCO(.SDOE,.DFN,.SD,.OE,.SC,.SDDA)
 I '$$NEW^SDPCE(SD) D ERRX^SDAPIE(.RETURN,"APTDCOO") Q 0
 S SDELHDL=$$HANDLE^SDAMEVT(1)
 S X=$$DELVFILE^PXAPI("ALL",OE(.05),"","","",.ECHO)
 S %=$$DELCOL(.RETURN,DFN,SD,SC,SDDA,SDOE,.OE)
 S SDOE=$$GETAPT(DFN,SD,SC)
 Q 1
 ;
SETCO(SDOE,DFN,SD,OE,SC,SDDA) ; Set Check out params
 N PAPT,CAPT
 I '$D(SDOE) D
 . S PAPT(21)="",PAPT(.01)=""
 . D GETPAPT^SDMDAL2(.PAPT,DFN,SD)
 . S SDOE=PAPT(21),SC=PAPT(.01)
 S OE(.01)="",OE(.02)="",OE(.04)="",OE(.05)="",OE(.08)="",OE(.09)="",OE(.06)=""
 D GETOE^SDMDAL4(.OE,SDOE)
 S DFN=OE(.02),SD=OE(.01),SC=OE(.04)
 D GETSCAP^SDMAPI1(.CAPT,SC,DFN,SD)
 S SDDA=CAPT("IFN")
 Q
 ;
DELCOL(RETURN,DFN,SD,SC,SDDA,SDOE,OE) ; Delete check out
 N SDATA,SDELHDL,SDORG,VSIT
 S SDORG=OE(.08),VSIT=OE(.05)
 I "^1^2^3^"[("^"_SDORG_"^") D DELCHLD(SDOE)
 N PDATA
 I SDORG=1 D
 . S PDATA(21)="@"
 . N CDATA S CDATA(303)="@"
 . D UPDCAPT^SDMDAL4(.CDATA,SC,SD,SDDA)
 I SDORG=3 D
 . S PDATA(18)="@"
 D UPDPAPT^SDMDAL4(.PDATA,DFN,SD)
 D DELCLS^SDMDAL4(SDOE)
 D DELOE(SDOE,.OE)
 ; -- call pce to make sure its data is gone
 D DEAD^PXUTLSTP(VSIT)
 Q 1
 ;
DELOE(SDOE,OE) ; Delete Outpatient Encounter
 I '$D(OE) D
 . S OE(.05)="",OE(.01)="",OE(.08)=""
 . D GETOE^SDMDAL4(.OE,SDOE)
 I '$$NEW^SDPCE(OE(.01)) Q
 D DELOE^SDMDAL4(SDOE)
 S X=$$KILL^VSITKIL(OE(.05))
 Q
 ;
DELCHLD(SDOEP) ;Delete Children
 N SDOEC,CHLD
 S SDOEC=0
 D GETCHLD^SDMDAL4(.CHLD,SDOEP)
 F  S SDOEC=$O(CHLD(SDOEC)) Q:'SDOEC  D
 . D DELOE(SDOEC)
 Q
 ;
LSTDAYAP(RETURN,DFN) ; List all day active appointment
 N DAP,PAP,CAP,PFLDS,CFLDS,AP,FLD,NM,PNMS,CNMS,TXT
 I '$D(DT) S DT=$P($$NOW^XLFDT(),".")
 I '$D(DFN)!(+$G(DFN)'>0) S RETURN=0,TXT(1)="DFN" D ERRX^SDAPIE(.RETURN,"INVPARAM",.TXT)
 S PFLDS=".01;3",CFLDS=".01;222;333"
 S PNMS="CLINIC;STATUS",CNMS="PATIENT;CIFN;IFN"
 D GETDAPTS^SDMDAL2(.DAP,+DFN,$P(DT,"."))
 F AP=0:0 S AP=$O(DAP(AP)) Q:AP=""  D
 . I DAP(AP,2)["C"!(DAP(AP,2)["N")!(DAP(AP,2)="NT") Q
 . D GETPAPT^SDMDAL4(.PAP,+DFN,AP,PFLDS)
 . F FLD=0:0 S FLD=$O(PAP(FLD)) Q:'FLD  D
 . . S NM=$$FLDNAME^SDMUTL(PFLDS,PNMS,FLD)
 . . S RETURN(AP,NM)=PAP(FLD,"I")_U_PAP(FLD,"E")
 . D GETCAPT^SDMDAL4(.CAP,+DFN,AP,CFLDS)
 . F FLD=0:0 S FLD=$O(CAP(FLD)) Q:'FLD  D
 . . S NM=$$FLDNAME^SDMUTL(CFLDS,CNMS,FLD)
 . . S RETURN(AP,"C",NM)=CAP(FLD)
 Q 1
 ;
GETPAPT(RETURN,DFN,SD) ; Get patient appointment
 N IND,NAME,FLDS,NAMES,APT
 S FLDS=".01;3;5;6;7;9;12;13;14;15;16;9.5;17;19;20;21;25;26;27;28"
 S NAMES="CLINIC;STATUS;LABDT;XRAYDT;EKGDT;PURPOSE;ARBK;CVISIT;NOSHOWBY;NOSHOWDT;"
 S NAMES=NAMES_"CREASON;TYPE;CREMARKS;ENTRY;MADEDT;OE;RTYPE;NEXTA;DDATE;FVISIT"
 D GETPAPT^SDMDAL4(.APT,DFN,SD)
 F IND=0:0 S IND=$O(APT(IND)) Q:IND=""  D
 . S NAME=$$FLDNAME^SDMUTL(FLDS,NAMES,IND)
 . S RETURN(NAME)=APT(IND,"E")
 . S RETURN(NAME,"I")=APT(IND,"I")
 Q 1
 ;
GETCAPT(RETURN,DFN,SD) ; Get clinic appointment
 N IND,NAME,FLDS,NAMES,CAPT
 S FLDS=".01;1;3;7;8;9;30;309;302;303;304;306;222;333"
 S NAMES="PATIENT;LENGTH;OTHER;ENTRY;MADEDT;OVERBOOK;EVISIT;CIDT;"
 S NAMES=NAMES_"CIUSER;CODT;COUSER;COENTER;222;333"
 D GETCAPT^SDMDAL4(.CAPT,DFN,SD)
 F IND=0:0 S IND=$O(CAPT(IND)) Q:IND=""  D
 . S NAME=$$FLDNAME^SDMUTL(FLDS,NAMES,IND) Q:NAME=""
 . S RETURN(NAME)=CAPT(IND)
 S RETURN("STATUS")=$$STATUS^SDAM1(DFN,SD,CAPT(222),CAPT(333))
 Q 1
 ;
GETOE(RETURN,SDOE) ; Get outpatient encounter
 K RETURN
 S RETURN(.07)="",RETURN(.08)="",RETURN(.01)="",RETURN(.02)=""
 S RETURN(.03)="",RETURN(.04)="",RETURN(.05)=""
 D GETOE^SDMDAL4(.RETURN,SDOE)
 Q:'$D(RETURN) 0
 S RETURN("DATE")=RETURN(.01)
 S RETURN("PATIENT")=RETURN(.02)
 S RETURN("SCODE")=RETURN(.03)
 S RETURN("CLINIC")=RETURN(.04)
 S RETURN("VISIT")=RETURN(.05)
 Q 1
 ;
GETPAT(RETURN,DFN) ; Get patient
 N IND,NAME,FLDS,NAMES,PAT
 S FLDS=".01;.02;.03;.05;.08;.361;.323;.131;.111;.134;.112;.135;.1173;.1112;"
 S FLDS=FLDS_".114;.115;.1172;.1171;.133;.32103;.525;.32102;.3213;.32115;.322013"
 S NAMES="PATIENT;SEX;BIRTH;MSTATUS;RELIG;PELIG;PSERV;PHONE;ADD1;"
 S NAMES=NAMES_"CELL;ADD2;PAGER;COUNTRY;ZIP;CITY;STATE;PCODE;PROVINCE;"
 S NAMES=NAMES_"EMAIL;EXPOI;POWSTAT;AGENTO;AGENTOL;PROJ;SASIA"
 D GETPAT^SDMDAL4(.PAT,DFN)
 F IND=0:0 S IND=$O(PAT(IND)) Q:IND=""  D
 . S NAME=$$FLDNAME^SDMUTL(FLDS,NAMES,IND) Q:NAME=""
 . S RETURN(NAME)=PAT(IND,"E")
 . S RETURN(NAME,"I")=PAT(IND,"I")
 Q 1
 ;
GETCHLD(RETURN,SDOE) ; Get children encounters
 D GETCHLD^SDMDAL4(.RETURN,SDOE)
 Q 1
 ; 
DOW(SD) ;
 N Y
 S %=$E(SD,1,3),Y=$E(SD,4,5),Y=Y>2&'(%#4)+$E("144025036146",Y)
 F %=%:-1:281 S Y=%#4=1+1+Y
 S Y=$E(SD,6,7)+Y#7
 Q Y
 ;
SETST(RETURN,SC,SD) ;
 N SDD,ST,PATT,CLN,DATA,SI
 S SDD=$P(SD,".",1)
 S ST=$$GETDST^SDMDAL1(SC,SDD)
 S RETURN=0
 I $G(ST)']"" D  Q:RETURN=0 0
 . S DOW=$$DOW(SD)
 . D GETDPATT^SDMDAL1(.PATT,SC,SDD,DOW)
 . I PATT("IEN")'>0!($G(PATT("PAT"))="") D ERRX^SDAPIE(.RETURN,"APTWHEN") Q
 . S ST=PATT("PAT")
 . S CLN(1917)=""
 . D GETCLNX^SDMDAL1(.CLN,SC)
 . S SI=CLN(1917),SI=$S(SI="":4,SI<3:4,SI:SI,1:4)
 . S ST=$E($P($T(DAY),U,DOW+2),1,2)_" "_$E(SD,6,7)_$J("",SI+SI-6)_ST
 . S DATA(.01)=SDD,DATA(1)=ST
 . D ADDPATT^SDMDAL1(.DATA,SC,SDD)
 . S RETURN=1
 S RETURN=1
 Q 1
DAY ;;^SUN^MON^TUES^WEDNES^THURS^FRI^SATUR
 ;
CANDELCO(RETURN) ; Check if user can delete check out data
 N KEYS,SUP K RETURN
 S KEYS("SD SUPERVISOR")=""
 D GETXUS^SDMDAL3(.SUP,.KEYS,DUZ)
 I '$D(SUP("SD SUPERVISOR")) S RETURN=0 D ERRX^SDAPIE(.RETURN,"APTCOSU") Q 0
 S RETURN=1
 Q 1
 ;
DELCODT(RETURN,SDOE) ;Delete Check Out Process Completion Date
 D DELCODT^SDMDAL4(.RETURN,SDOE)
 S RETURN=1
 Q 1
 ;
ADDTSTS(RETURN,DFN,SD,LAB,XRAY,EKG) ; Append tests to pending appointment
 N DATA,ERR
 K RETURN
 S %=$$ISOECO^SDMAPI4(.ERR,DFN,SD,"add")
 I ERR=1 M RETURN=ERR S RETURN=0 Q 0
 S:$D(LAB) DATA(5)=LAB
 S:$D(XRAY) DATA(6)=XRAY
 S:$D(EKG) DATA(7)=EKG
 D UPDPAPT^SDMDAL4(.DATA,DFN,SD)
 S RETURN=1
 Q 1
 ;
DELTSTS(RETURN,DFN,SD,LAB,XRAY,EKG) ; Delete tests from pending appointment
 N DATA,ERR
 K RETURN
 S %=$$ISOECO^SDMAPI4(.ERR,DFN,SD,"delete")
 I ERR=1 M RETURN=ERR S RETURN=0 Q 0
 S:$D(LAB) DATA(5)="@"
 S:$D(XRAY) DATA(6)="@"
 S:$D(EKG) DATA(7)="@"
 D UPDPAPT^SDMDAL4(.DATA,DFN,SD)
 S RETURN=1
 Q 1
 ;
ISOECO(RETURN,DFN,SD,OP) ; Is outpatient encounter checked out?
 N OE,APT,FLDS,PARAM
 S RETURN=0,DFN=+DFN,PARAM(1)=OP
 S OE(.12)="",FLDS="21"
 D GETPAPT^SDMDAL4(.APT,+DFN,+SD,.FLDS)
 I $G(APT(21,"I"))="" Q 1
 D GETOE^SDMDAL4(.OE,APT(21,"I"))
 I OE(.12)=2 D BLD^DIALOG(480000.03,.OP,,"RETURN","FS") S RETURN=1
 Q 1
 ;
