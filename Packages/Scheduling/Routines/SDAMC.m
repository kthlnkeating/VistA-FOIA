SDAMC ;ALB/MJK - Cancel Appt Action ; 2/21/2013  ; Compiled January 8, 2009 15:41:48
 ;;5.3;Scheduling;**20,28,32,46,263,414,444,478,538,554,260003**;Aug 13, 1993;Build 5
 ;
EN ; -- protocol SDAM APPT CANCEL entry pt
 ; input:  VALMY := array entries
 ;
 N SDI,SDAT,VALMY,SDAMCIDT,CNT,L,SDWH,SDCP,SDREM,SDSCR,SDMSG,SCLHOLD
 K ^UTILITY($J)
 ;
 ;
 I '$D(DFN),$G(SDFN),($G(SDAMTYP)="P") S DFN=SDFN
 ;
 S VALMBCK=""
 D SEL^VALM2,CHK G ENQ:'$O(VALMY(0))
 D FULL^VALM1 S VALMBCK="R"
 S SDWH=$$WHO,SDCP=$S(SDWH="C":0,1:1) G ENQ:SDWH=-1
 S SDSCR=$$RSN(SDWH) G ENQ:SDSCR=-1
 S (TMPD,SDREM)=$$REM G ENQ:SDREM=-1 ;SD/478
 S (SDI,CNT,L)=0
 F  S SDI=$O(VALMY(SDI)) Q:'SDI  I $D(^TMP("SDAMIDX",$J,SDI)) K SDAT S SDAT=^(SDI) W !,^TMP("SDAM",$J,+SDAT,0) D CAN($P(SDAT,U,2),$P(SDAT,U,3),.CNT,.L,SDWH,SDCP,SDSCR,SDREM)
 I SDAMTYP="P" D BLD^SDAM1
 I SDAMTYP="C" D BLD^SDAM3
ENQ Q
 ;
CAN(DFN,SDT,CNT,L,SDWH,SDCP,SDSCR,SDREM) ;
 N A1,NDT S NDT=SDT
 S %=$$GETAPTS^SDMAPI1(.APTS,DFN,.SDT)
 S:'$G(L) L=0 ; If there is no data in L set L to 0 - PATCH SD*5.3*554
 S:'$G(SDAMTYP) SDAMTYP="P" ; If there is no data in SDAMTYP set SDAMTYP to 0" - PATCH SD*5.3*554
 I APTS("APT",SDT,"STATUS")["C" W !!,"Appointment already cancelled" H 2 D CANQ(DFN,SDCLN,SDAMTYP) Q  ; SD*5.3*554
 I $D(APTS),APTS("APT",SDT,"STATUS")'["C"  D
 . S SC=+APTS("APT",SDT,"CLINIC"),L=L\1+1,APL=""
 . D FLEN^SDCNP1A(.APTS)
 . S ^UTILITY($J,"SDCNP",L)=NDT_"^"_SC_"^"_COV_"^"_APL_"^^"_APL_"^^^^^^"_SDSP
 . D CHKSO^SDCNP0(.APTS)
 ;SD*5.3*414 next line added to set hold variable SCLHOLD for clinic ptr
 S APP=1,A1=L\1 S SCLHOLD=$P(^UTILITY($J,"SDCNP",A1),U,2) D BEGD^SDCNP0
 S SDFN=DFN ; Sets SDFN - PATCH SD*5.3*554
 D MES,NOPE W ! S (CNT,L)=0 K ^UTILITY($J,"SDCNP")
 Q
CANQ(SDFN,SDCLN,SDAMTYP) ; SD*5.3*554 - Passes in SDFN, SDCLN, and SDAMTYP
 ;Wait List Message
 ;
 Q:(SDFN=""!SDCLN="")  ; Checks to make sure that SDFN and SDCLN are set to a non null value - PATCH SD*5.3*554
 I $G(SCLHOLD)'="" S:'$D(SDCLN) SDCLN=SCLHOLD  ; SD*5.3*414
 N SDOMES S SDOMES="" I $G(SDCLN)'="",$D(^SDWL(409.3,"SC",SDCLN)) D
 .N SDWL S SDWL="" F  S SDWL=$O(^SDWL(409.3,"SC",SDCLN,SDWL)) Q:SDWL=""  D  Q:SDOMES
 ..I $P(^SDWL(409.3,SDWL,0),U,17)="O" I $P(^SDWL(409.3,SDWL,0),U)=$G(SDFN) D  S SDOMES=1
 ...W !,?1,"There are Wait List entries waiting for an Appointment for this patient in ",!?1,$P(^SC(SDCLN,0),U,1)," Clinic.",!
 S DIR(0)="E" D ^DIR W !
 K:$G(SDAMTYP)="P" SDCLN ; - PATCH SD*5.3*554
 K SCLHOLD,SC,COV,APP
 Q
MES ; -- set error message
 S SDMSG="W !,""Enter appt. numbers separated by commas and/or a range separated"",!,""by dashes (ie 2,4,6-9)"" H 2"
 Q
 ;
WHO() ;
 W ! S DIR(0)="SOA^PC:PATIENT;C:CLINIC",DIR("A")="Appointments cancelled by (P)atient or (C)linic: ",DIR("B")="Patient"
 D ^DIR K DIR
 Q $S(Y=""!(Y="^"):-1,1:Y)
 ;
RSN(SDWH) ;
RSN1 ;
 W !
 S SDSCRPC=$S(SDWH["P":"P",1:"C")
 S SDSCR=$$SELCRSN^SDMUI(,SDSCRPC)
 I X["^" S SDSCR=-1 G RSNQ
 I SDSCR=-1 W *7 G RSN1
RSNQ Q +SDSCR
 ;
REM() ;
 W ! S DIR(0)="2.98,17" D ^DIR K DIR
 I $E(X)="^" S Y=-1
 Q Y
 ;
NOPE ;
 N SDEND,SDPAUSE
 S:'CNT SDPAUSE=1
 D NOPE^SDCNP1
 D:$G(SDPAUSE) PAUSE^VALM1
 Q
 ;
CHK ; -- check if status of appt permits cancelling
 N SDI S SDI=0
 F  S SDI=$O(VALMY(SDI)) Q:'SDI  I $D(^TMP("SDAMIDX",$J,SDI)) K SDAT S SDAT=^(SDI) I '$$CHKSPC^SDMAPI3(,$P(SDAT,U,2),$P(SDAT,U,3)) D
 .W !,^TMP("SDAM",$J,+SDAT,0),!!,*7,"You cannot cancel this appointment."
 .K VALMY(SDI) D PAUSE^VALM1
 Q
