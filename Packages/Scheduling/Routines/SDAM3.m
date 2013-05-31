SDAM3 ;MJK/ALB - Appt Mgt (Clinic) ; 1/14/2013
 ;;5.3;Scheduling;**63,189,380,478,492,260003**;Aug 13, 1993;Build 1
 ;
INIT ; -- get init clinic appt data
 ;  input:        SDCLN := ifn of pat
 ; output:  ^TMP("SDAM" := appt array
 S X=$P($G(^DG(43,1,"SCLR")),U,12),SDPRD=$S(X:X,1:2)
 S X1=DT,X2=-SDPRD D C^%DTC S VALMB=X D RANGE^VALM11
 I '$D(VALMBEG) S VALMQUIT="" G INITQ
 S SDBEG=VALMBEG,SDEND=VALMEND
 D CHGCAP^VALM("NAME","Patient")
 S X="NO ACTION TAKEN" D LIST^SDAM
INITQ K VALMB,VALMBEG,VALMEND Q
 ;
BLD ; -- scan apts
 N RETURN,STAT
 D INIT^SDAM10
 S STAT=+$O(^SD(409.62,"B",$P(SDAMLIST,U),0))
 S %=$$LSTCAPTS^SDMAPI1(.RETURN,SDCLN,SDBEG,SDEND,STAT)
 D BLD1^SDAM1(.RETURN)
 D NUL^SDAM10,LARGE^SDAM10:$D(SDLARGE)
 S $P(^TMP("SDAM",$J,0),U,4)=VALMCNT
 Q
 ;
HDR ; -- list screen header
 ;   input:      SDCLN := ifn of pat
 ;  output:  VALMHDR() := hdr array
 ;
 S VALMHDR(1)=$E($P("Clinic: "_$G(^SC(SDCLN,0)),"^",1),1,45)  ;for proper display of clinic name for SD*5.3*189
 Q
 ;
CLN ; -- change clinic
 I $G(SDAMLIST)["CANCELLED" S VALMBCK="" W !!,*7,"You must be viewing a patient to list cancelled appointments." D PAUSE^VALM1 G CLNQ
 D FULL^VALM1 S VALMBCK="R" W !
 S X="" I $D(XQORNOD(0)) S X=$P($P(XQORNOD(0),U,4),"=",2)
 S PAR("PRMPT")=$$EZBLD^DIALOG(480000.031)
 S Y=$$SELCLN^SDMUI(.PAR)
 I Y<0!(+Y=0) D  G CLNQ
 .I SDAMTYP="C" S VALMSG=$C(7)_"Clinic has not been changed."
 .I SDAMTYP="P" S VALMSG=$C(7)_"View of patient remains in affect."
 I SDAMTYP'="C" D CHGCAP^VALM("NAME","Patient") S SDAMTYP="C"
 N SDRES I SDAMTYP="C" S SDRES=$$CLNCK^SDUTL2(+Y,1) I 'SDRES D  G CLNQ
 .W !,?5,"Clinic MUST be corrected before continuing." D PAUSE^VALM1
 S SDCLN=+Y K SDFN D BLD
CLNQ Q
 ;
