DGPMV3 ;ALB/MIR - ENTER TRANSACTION INFORMATION; 4/8/13
 ;;5.3;Registration;**34,54,62,95,692,715,260005**;Aug 13, 1993
 N PAR
 D NOW^%DTC S DGNOW=%,DGPMHY=DGPMY,DGPMOUT=0 G:'DGPMN DT S X=DGPMY
 ;-- provider change
 I DGPMT=6,$D(DGPMPC) S PAR("DGPMPC")=1
 D VAR G DR
DT D VAR G:DGPM1X DR S (DGPMY,Y)=DGPMHY X ^DD("DD") W !,DGPMUC," DATE: ",Y,"// " R X:DTIME G Q:'$T!(X["^") I X="" G DR
 S %DT="SRXE",%DT(0)="-NOW" I X["?"!(Y<0) D HELP^%DTC G DT
 I X="@" G OKD
 D ^%DT I Y<0 D HELP^%DTC G DT
 S OLDDATE=DGPMY
 K %DT S DGPMY=Y,PAR("DATE")=Y D CHK^DGPMV30:(X]"")&(DGPMY'=+OLDDATE) I $D(DGPME) S DGPMY=DGPMHY W !,DGPME K DGPME G DT
DR ;select input template for transaction type
 S DIE="^DGPM(" I "^1^4^6^"[("^"_DGPMT_"^"),DGPMN S DIE("NO^")=""
 ;S DGODSPT=$S('$D(^DGPM(DGPMCA,"ODS")):0,^("ODS"):1,1:0)
 S %=DGPMT,API=$S(%=1:"GETADM",%=2:"GETTRA",%=4:"GETADM",1:"GETMVT")
 S DGDA=$S($G(DGPMDA):DGPMDA,1:$G(MVTSD(DGPMY)))
 I 'DGPMN S RTN="S %=$$"_API_"^DGPMAPI8(.OLD,DGDA)" X RTN M PAR=OLD
 S PAR("DATE")=DGPMY,OLD("DATE")=DGPMY,PAR("PATIENT")=DFN
 S DA=$S(DGPMN=1:0,1:DGPMDA),DGX=DGPMY,PAR("ADMIFN")=$G(DGPMCA)
 K %DT(0)
 D @("^DGPMX"_DGPMT)
 ;Modified in patch dg*5.3*692 to include privacy indicator node "DIR"
 K DGZ,DGQUIT
 I $D(Y)#2 S DGPMOUT=1
 D:DGPMT'=4 @("^DGPMV3"_DGPMT) G:$G(DGQUIT) EVENTS
 N RE,RTN,NEW,OLD
 I DGPMN D  Q:RE=0
 . S RTN="S %=$$CHKADD^DGPMAPI"_DGPMT_"(.RE,.PAR)" X RTN
 . I RE=0 W !,$P(RE(0),U,2) Q
 . S RTN="S %=$$ADD^DGPMAPI"_DGPMT_"(.RE,.PAR)" X RTN
 I 'DGPMN D  Q:RE=0
 . S RTN="S %=$$CHKUPD^DGPMAPI"_DGPMT_"(.RE,.PAR,DGDA,.OLD,.NEW)" X RTN
 . G:RE=0&'$D(RE(0)) EVENTS
 . I RE=0 W !,$P(RE(0),U,2) Q
 . S RTN="S %=$$UPD^DGPMAPI"_DGPMT_"(.RE,.PAR,DGDA,.OLD,.NEW)" X RTN S RE=DGDA
 I RE,DGPMT<4 D
 . K TXT
 . S TXT(1)=$$EZBLD^DIALOG(4070000.008)
 . S TXT(2)=$$EZBLD^DIALOG("4070000.0"_$S(DGPMN:2,1:1)_DGPMT)
 . S:'DGPMN TXT(3)=$$EZBLD^DIALOG(4070000.018)
 . D EN^DDIOL($$EZBLD^DIALOG("4070000.01",.TXT)),EN^DDIOL(" "):DGPMT=1
EVENTS ;
 I DGPMT'=4&(DGPMT'=5) S %=$$UPDPAT^DGPMAPI7(,.PAR,DFN) I (DGPMT'=6) D SI^DGPMV33
 X:RE>0&'$G(DGQUIT) "D EVT^DGPMAPI"_DGPMT_"(DFN,+RE)"
Q S:$D(DGPMBYP) DGPMBYP=DGPMDA
 K DGIDX,DGOWD,DGOTY ;variables set in DGPMGLC - G&L corrections
 K DGODS,DGODSPT ;ods variables
 K %DT,DA,DGER,DGNOW,DGOK,DGPM0,DGPM0ND,DGPM2,DGPMA,DGPMAB,DGPMABL,DGPMDA,DGPMER,DGPMHY,DGPMNI,DGPMOC,DGPMOS,DGPMOUT,DGPMP,DGPMPHY,DGPMPHY0,DGPMPTF,DGPMSP,DGPMTYP,DGPMTN,DGPMWD,DGT,DGSV,DGX,DGX1
 K DIC,DIE,DIK,DR,I,I1,J,K,X,X1,X2,Y,^UTILITY("DGPM",$J) Q
 ;
OKD ;
 K %DT D:DGPMT=6 PRIOR^DGPMV36
 N OLD
 S RTN="S %=$$CANDEL^DGPMAPI"_DGPMT_"(.RE,DGPMDA,.OLD)" X RTN
 I RE=0 D EN^DDIOL($P(RE(0),U,2),,"!!") G Q
 D EN^DDIOL($$EZBLD^DIALOG(4070000.032),,"!!") S %=2 D YN^DICN G Q:%<0,DT:%=2 I '% D EN^DDIOL($$EZBLD^DIALOG(4070000.033,$$EZBLD^DIALOG(4070000.001)),,"!?5") G OKD
 S RTN="S %=$$DEL^DGPMAPI"_DGPMT_"(.RE,DGPMDA,.OLD)" X RTN
 I RE=0 W !,$P(RE(0),U,2)
 I RE,DGPMT<4 D
 . K TXT
 . S TXT(1)=$$EZBLD^DIALOG(4070000.008)
 . S TXT(2)=$$EZBLD^DIALOG("4070000.01"_DGPMT)
 . S TXT(3)=$$EZBLD^DIALOG(4070000.009)
 . D EN^DDIOL($$EZBLD^DIALOG("4070000.01",.TXT))
 G EVENTS
VAR ;Set up variables
 ;Modified in patch dg*5.3*692 to include privacy indicator node "DIR"
 S DA=DGPMDA ;DGPMP=Before edit
 ;I DGPMT=6 S Y=DGPMDA D PRIOR^DGPMV36
 S %=$$GETPMVT^DGPMAPI8(.PMVT,.DGPMCA,.DGPMY,.DGPMDA)
 S %=$$GETNMVT^DGPMAPI8(.NMVT,.DGPMCA,.DGPMY,.DGPMDA)
 S DGPMABL=0 I NMVT S %=$$GETMASMT^DGPMAPI8(.MAS,NMVT("MASTYPE")) S DGPMABL=+MAS("ABS") ;is the next movement an absence?
 ;I DGPMT=6 S Y=DGPMDA D PRIOR^DGPMV36
 Q
NEW ;Entry point to add a new entry to ^DGPM
 D NEW^DGPMV301 ; continuation of routine DGPMV3 in DGPMV301
 Q
 ;
PRODAT(NODE) ;-- This function will add the ward and other data from the
 ; previous TS movement to the provider TS movement.
 ;
 N X,Y
 S Y=NODE,X=$O(^DGPM("ATS",DFN,DGPMCA,9999999.9999999-$P(NODE,U))) I X S X=$O(^(X,0)) I X S X=$O(^(X,0)) I X S X=^DGPM(X,0)
 S $P(Y,U,4)=$P(X,U,4),$P(Y,U,9)=$P(X,U,9)
 Q Y
 ;
