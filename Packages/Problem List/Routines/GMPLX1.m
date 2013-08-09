GMPLX1 ; SLC/MKB/KER -- Problem List Person Utilities ;3/12/13
 ;;2.0;Problem List;**3,26,35,260002**;Aug 25, 1994
 ;
 ; External References
 ;   DBIA   348  ^DPT(
 ;   DBIA  3106  ^DIC(49
 ;   DBIA   872  ^ORD(101
 ;   DBIA 10060  ^VA(200
 ;   DBIA 10062  7^VADPT
 ;   DBIA 10062  DEM^VADPT
 ;   DBIA  2716  $$GETSTAT^DGMSTAPI
 ;   DBIA  3457  $$GETCUR^DGNTAPI
 ;   DBIA 10104  $$REPEAT^XLFSTR
 ;   DBIA 10006  ^DIC
 ;   DBIA 10018  ^DIE
 ;   DBIA 10026  ^DIR
 ;
PAT() ; Select patient -- returns DFN^NAME^BID
 N DIC,X,Y,DFN,VADM,VA,PAT
P1 S DIC="^AUPNPAT(",DIC(0)="AEQM" D ^DIC I +Y<1 Q -1
 I $P(Y,U,2)'=$$PATNAME^GMPLEXT(+Y) D  G P1
 . D EN^DDIOL($C(7))
 . D EN^DDIOL($$EZBLD^DIALOG(1250000.498))
 S DFN=+Y,PAT=Y D DEM^VADPT
 S PAT=PAT_U_$E($P(PAT,U,2))_VA("BID"),AUPNSEX=$P(VADM(5),U)
 I VADM(6) S PAT=PAT_U_+VADM(6) ; date of death
 Q PAT
 ;          
VADPT(DFN) ; Get Service/Elig Flags
 ;          
 ; Returns = 1/0/"" if Y/N/unknown
 ;   GMPSC     Service Connected
 ;   GMPAGTOR  Agent Orange Exposure
 ;   GMPION    Ionizing Radiation Exposure
 ;   GMPGULF   Persian Gulf Exposure
 ;   GMPMST    Military Sexual Trauma
 ;   GMPHNC    Head and/or Neck Cancer
 ;   GMPCV     Combat Veteran
 ;   GMPSHD    Shipboard Hazard and Defense
 ;          
 N VAEL,VASV,VAERR,HNC,X,PD,% D 7^VADPT S GMPSC=VAEL(3),GMPAGTOR=VASV(2)
 S GMPION=VASV(3)
 S %=$$PATDET^GMPLEXT(.PD,DFN)
 S X=$P($G(PD("PGSVC")),U),GMPGULF=$S(X="Y":1,X="N":0,1:"")
 S GMPCV=0 I +$G(VASV(10)) S:DT'>$P($G(VASV(10,1)),U) GMPCV=1  ;CV
 S GMPSHD=+$G(VASV(14,1))  ;SHAD
 S X=$P($$GETSTAT^DGMSTAPI(DFN),"^",2),GMPMST=$S(X="Y":1,X="N":0,1:"")
 S X=$$GETCUR^DGNTAPI(DFN,"HNC"),X=+($G(HNC("STAT"))),GMPHNC=$S(X=4:1,X=5:1,X=1:0,X=6:0,1:"")
 Q
SCS(PROB,SC) ; Get Exposure/Conditions Strings
 ;                 
 ;   Input     PROB  Pointer to Problem #9000011
 ;               
 ;   Returns   SC Array passed by reference
 ;             SC(1)="AO/IR/EC/HNC/MST/CV/SHD"
 ;             SC(2)="A/I/E/H/M/C/S"
 ;             SC(3)="AIEHMCS"
 ;                     
 ;   NOTE:  Military Sexual Trauma (MST) is suppressed
 ;          if the current device is a printer.
 ;                     
 N DA,FL,AO,IR,EC,HNC,MST,PTR,%,PRB,CV,SHD
 S DA=+($G(PROB)) Q:+DA=0
 S %=$$DETAIL^GMPLAPI2(.PRB,DA)
 S AO=+($P(PRB(1.11),U)),IR=+($P(PRB(1.12),U))
 S EC=+($P(PRB(1.13),U)),HNC=+($P(PRB(1.15),U)),MST=+($P(PRB(1.16),U))
 S CV=+($P(PRB(1.17),U)),SHD=+($P(PRB(1.18),U))
 S PTR=$$PTR^GMPLUTL4
 I +AO>0 D
 . S:$G(SC(1))'["AO" SC(1)=$G(SC(1))_"/AO" S:$G(SC(2))'["A" SC(2)=$G(SC(2))_"/A" S:$G(SC(3))'["A" SC(3)=$G(SC(3))_"A"
 I +IR>0 D
 . S:$G(SC(1))'["IR" SC(1)=$G(SC(1))_"/IR" S:$G(SC(2))'["I" SC(2)=$G(SC(2))_"/I" S:$G(SC(3))'["I" SC(3)=$G(SC(3))_"I"
 I +EC>0 D
 . S:$G(SC(1))'["EC" SC(1)=$G(SC(1))_"/EC" S:$G(SC(2))'["E" SC(2)=$G(SC(2))_"/E" S:$G(SC(3))'["E" SC(3)=$G(SC(3))_"E"
 I +HNC>0 D
 . S:$G(SC(1))'["HNC" SC(1)=$G(SC(1))_"/HNC" S:$G(SC(2))'["H" SC(2)=$G(SC(2))_"/H" S:$G(SC(3))'["H" SC(3)=$G(SC(3))_"H"
 I +MST>0 D
 . S:$G(SC(1))'["MST" SC(1)=$G(SC(1))_"/MST" S:$G(SC(2))'["M" SC(2)=$G(SC(2))_"/M" S:$G(SC(3))'["M" SC(3)=$G(SC(3))_"M"
 I +CV>0 D
 . S:$G(SC(1))'["CV" SC(1)=$G(SC(1))_"/CV" S:$G(SC(2))'["C" SC(2)=$G(SC(2))_"/C" S:$G(SC(3))'["C" SC(3)=$G(SC(3))_"C"
 I +PTR'>0 D
 . I +SHD>0 S:$G(SC(1))'["SHD" SC(1)=$G(SC(1))_"/SHD" S:$G(SC(2))'["D" SC(2)=$G(SC(2))_"/S" S:$G(SC(3))'["S" SC(3)=$G(SC(3))_"S"
 S:$D(SC(1)) SC(1)=$$RS(SC(1)) S:$D(SC(2)) SC(2)=$$RS(SC(2))
 Q
SCCOND(DFN,SC) ; Get Service/Elig Flags (array)
 ; Returns local array .SC passed by value
 N HNC,VAEL,VASV,VAERR,X,PD,% D 7^VADPT
 S SC("DFN")=$G(DFN),SC("SC")=$P(VAEL(3),"^",1)
 S SC("AO")=$P(VASV(2),"^",1)
 S SC("IR")=$P(VASV(3),"^",1)
 S %=$$PATDET^GMPLEXT(.PD,DFN)
 S X=$P($G(PD("PGSVC")),U),SC("PG")=$S(X="Y":1,X="N":0,1:"")
 S SC("CV")=0 I +$G(VASV(10)) S:DT'>$P($G(VASV(10,1)),U) SC("CV")=1  ;CV
 S SC("SHD")=+$G(VASV(14,1))  ;SHAD
 S X=$P($$GETSTAT^DGMSTAPI(DFN),"^",2),SC("MST")=$S(X="Y":1,X="N":0,1:"")
 S X=$$GETCUR^DGNTAPI(DFN,"HNC"),X=+($G(HNC("STAT"))),SC("HNC")=$S(X=4:1,X=5:1,X=1:0,X=6:0,1:"")
 Q
 ;
CKDEAD(DATE) ; Dead patient ... continue?  Returns 1 if YES, 0 otherwise
 N DIR,X,Y S DIR(0)="YA",DIR("B")="NO"
 D BLD^DIALOG(1250000.489,,,"DIR(""A"")")
 D BLD^DIALOG(1250000.499,,,"DIR(""?"")")
 D EN^DDIOL($C(7))
 D EN^DDIOL($$EZBLD^DIALOG(1250000.500,$$EXTDT^GMPLX(DATE)))
 D ^DIR
 Q +Y
 ;
REQPROV() ; Returns requesting provider
 N DIR,X,Y
 I +$G(GMPLUSER) S Y=DUZ_U_$$PROVNAME^GMPLEXT(DUZ) Q Y
 D BLD^DIALOG(1250000.501,,,"DIR(""?"")")
 S DIR(0)="PA^200:AEQM",DIR("A")=$$EZBLD^DIALOG(1250000.508)
 S:$G(GMPROV) DIR("B")=$P(GMPROV,U,2) W ! D ^DIR
 I $D(DUOUT)!($D(DTOUT))!(+Y'>0) Q -1
 Q Y
 ;
NAME(USER) ; Formats user name into "Lastname,F"
 N NAME,LAST,FIRST
 S NAME=$$PROVNAME^GMPLEXT(+USER) I '$L(NAME) Q ""
 S LAST=$P(NAME,","),FIRST=$P(NAME,",",2)
 S:$E(FIRST)=" " FIRST=$E(FIRST,2,99)
 Q $E(LAST,1,15)_","_$E(FIRST)
 ;
SERV(X) ; Return service name abbreviation
 N NAME,ABBREV
 S NAME=$$SVCNAME^GMPLEXT(+X)
 I NAME="" Q ""
 S ABBREV=$$SVCABBV^GMPLEXT(+X)
 I ABBREV="" S ABBREV=$E($P(NAME,U),1,4)
 Q ABBREV_"/"
 ;
CLINIC(LAST) ; Returns clinic from file #44
 N X,Y,DIC,DIR S Y="" G:$E(GMPLVIEW("VIEW"))="S" CLINQ
 S DIR(0)="FAO^1:30",DIR("A")=$$EZBLD^DIALOG(1250000.502) S:$L(LAST) DIR("B")=$P(LAST,U,2)
 D BLD^DIALOG(1250000.503,,,"DIR(""?"")")
 S DIR("??")="^D LISTCLIN^GMPLMGR1 W !,DIR(""?"")_""."""
CLIN1 ; Ask Clinic
 D ^DIR S:$D(DUOUT)!($D(DTOUT)) Y="^" S:Y="@" Y="" G:("^"[Y) CLINQ
 S DIC="^SC(",DIC(0)="EMQ",DIC("S")="I $P(^(0),U,3)=""C"""
 D ^DIC I Y'>0 D  G CLIN1
 . D EN^DDIOL($$EZBLD^DIALOG(1250000.504),,"!?5")
 . D EN^DDIOL("",,"!")
CLINQ ; Quit Asking
 Q Y
 ;
VOCAB() ; Select search vocabulary
 N DIR,X,Y S DIR(0)="SAOM^N:NURSING;I:IMMUNOLOGIC;D:DENTAL;S:SOCIAL WORK;P:GENERAL PROBLEM"
 S DIR("A")=$$EZBLD^DIALOG(1250000.505),DIR("B")="GENERAL PROBLEM"
 D BLD^DIALOG(1250000.506,,,"DIR(""?"")")
 D ^DIR S X=$S(Y="N":"NUR",Y="I":"IMM",Y="D":"DEN",Y="S":"SOC",Y="P":"PL1",1:"^")
 Q X
 ;
PARAMS ; Edit pkg parameters in file #125.99
 N OLDVERFY,VERFY,BLANK,MN,NAME,OLD,NEW
 S BLANK="       "
 S %=$$GETPAR^GMPLSITE(.OLD),OLDVERFY=OLD("VER")
 S DIE="^GMPL(125.99,",DA=1,DR="1:6" D ^DIE
 S %=$$GETPAR^GMPLSITE(.NEW)
 Q:OLDVERFY=NEW("VER")
 S DA(1)=$$PROTKEY^GMPLEXT("GMPL PROBLEM LIST") Q:'DA(1)
 S VERFY=$$PROTKEY^GMPLEXT("GMPL VERIFY") W "."
 S MN=$S(OLDVERFY:"@",1:"$")
 S NAME=$S(OLDVERFY:BLANK,1:"@")
 W "."
 D UPDITEM^GMPLEXT(DA(1),VERFY,MN,NAME)
 W "."
 Q
 ;
RS(X) ; Remove Slashes
 S X=$G(X) F  Q:$E(X,1)'="/"  S X=$E(X,2,$L(X))
 F  Q:$E(X,$L(X))'="/"  S X=$E(X,1,($L(X)-1))
 Q X
 ;
FMTNAME(NAME) ; Formats name into "Lastname,F"
 N LAST,FIRST
 Q:$G(NAME)="" ""
 S LAST=$P(NAME,","),FIRST=$P(NAME,",",2)
 S:$E(FIRST)=" " FIRST=$E(FIRST,2,99)
 Q $E(LAST,1,15)_","_$E(FIRST)
