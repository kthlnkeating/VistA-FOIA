SDAMEP3 ;ALB/CAW - Extended Display (Appt. Event Log) ; 5/31/13
 ;;5.3;Scheduling;**20,241,260003**;Aug 13, 1993
 ;
APLOG ;
 D SET^SDAMEP1("                       *** Appointment Event Log ***")
 D CNTRL^VALM10(SDLN,24,29,IOINHI,IOINORM)
 D SET^SDAMEP1($$EVENT("Event","Date","User"))
 D SET^SDAMEP1($$EVENT("-----","----","----"))
 D SET^SDAMEP1($$EVENT("Appt Made",$S(+$G(APT("MADEDT"))]"":$P(APT("MADEDT"),U,2),1:$P(APT("MADEDT"),U,2)),$S($G(APT("ENTRY"))]"":$P(APT("ENTRY"),U,2),1:$P(APT("ENTRY"),U,2))))
 D SET^SDAMEP1($$EVENT("Check In",$P(APT("CIDT"),U,2),$P(APT("CIUSER"),U,2)))
 D SET^SDAMEP1($$EVENT("Check Out",$P(APT("CODT"),U,2),$P(APT("COUSER"),U,2)))
 D SET^SDAMEP1($$EVENT("Check Out Entered",$P(APT("COENTER"),U,2),""))
 D SET^SDAMEP1($$EVENT("No-Show/Cancel",$P(APT("NOSHOWDT"),U,2),$P(APT("NOSHOWBY"),U,2))),SET^SDAMEP1("")
 ;
 S X=""
 S X=$$SETSTR^VALM1("  Checked Out:",X,7,SDWIDTH)
 S X=$$SETSTR^VALM1($S($G(SDOE(.07))]"":"YES",1:""),X,SDFSTCOL+5,30)
 D SET^SDAMEP1(X)
 ;
 S X=""
 S X=$$SETSTR^VALM1("  Cancel Reason:",X,5,SDWIDTH)
 S X=$$SETSTR^VALM1($P(APT("CREASON"),U,2),X,SDFSTCOL+5,30)
 D SET^SDAMEP1(X)
 ;
 S X=""
 S X=$$SETSTR^VALM1("  Cancel Remark:",X,5,SDWIDTH)
 S X=$$SETSTR^VALM1(APT("CREMARKS"),X,SDFSTCOL+5,50)
 D SET^SDAMEP1(X)
 ;
 S X=""
 S X=$$SETSTR^VALM1("  Rebooked Date:",X,5,SDWIDTH)
 S X=$$SETSTR^VALM1($P(APT("ARBK"),U,2),X,SDFSTCOL+5,20)
 D SET^SDAMEP1(X)
CWT ;Clinic Wait Time Information
 N SDCWT,SDCWT1,SDCWT2
 ;Get internal data values
 ;F SDCWT=3,20,25:1:28 S SDCWT(SDCWT)=SDPTI(2.98,SDT,SDCWT,"I")
 ;Wait time data applicable?
 S SDCWT=1 S:$E(APT("STATUS"))="C" SDCWT=0
 S SDCWT1=+APT("MADEDT"),SDCWT2=+APT("DDATE")
 ;Calculate Wait Time1
 S SDCWT1=$S(SDCWT1<1:"",SDT<SDCWT1:0,1:$$FMDIFF^XLFDT(SDT,SDCWT1,1))
 ;Calculate Wait Time2
 S:'$$CWT3^SCRPW75(SDT,+APT("NEXTA"),+APT("DDATE"),+APT("FVISIT"),.SDCWT2) SDCWT2=""
 S:+SDCWT1=SDCWT1 SDCWT1=SDCWT1_" day"_$S(SDCWT1=1:"",1:"s")
 S:+SDCWT2=SDCWT2 SDCWT2=SDCWT2_" day"_$S(SDCWT2=1:"",1:"s")
 D SET^SDAMEP1("                      *** Clinic Wait Time Information ***")
 D CNTRL^VALM10(SDLN,20,40,IOINHI,IOINORM)
 D SET^SDAMEP1("")
 ;
 S X=""
 S X=$$SETSTR^VALM1("       Request type:",X,7,SDWIDTH+6)
 S X=$$SETSTR^VALM1($S('SDCWT:"N/A",$G(APT("RTYPE"))]"":$P(APT("RTYPE"),U,2),1:"Unknown"),X,SDFSTCOL+10,50)
 D SET^SDAMEP1(X)
 ;
 S X=""
 S X=$$SETSTR^VALM1("'Next Available' Type:",X,5,SDWIDTH+6)
 S X=$$SETSTR^VALM1($S('SDCWT:"N/A",1:$P(APT("NEXTA"),U,2)),X,SDFSTCOL+10,50)
 D SET^SDAMEP1(X)
 ;
 S X=""
 S X=$$SETSTR^VALM1("         Desired date:",X,5,SDWIDTH+6)
 S X=$$SETSTR^VALM1($S('SDCWT:"N/A",1:$P(APT("DDATE"),U,2)),X,SDFSTCOL+10,50)
 D SET^SDAMEP1(X)
 ;
 S X=""
 S X=$$SETSTR^VALM1("      Follow-up visit:",X,5,SDWIDTH+6)
 S X=$$SETSTR^VALM1($S('SDCWT:"N/A",1:$P(APT("FVISIT"),U,2)_$S($L($P(APT("FVISIT"),U,2)):"  (computed)",1:"")),X,SDFSTCOL+10,50)
 D SET^SDAMEP1(X)
 ;
 S X=""
 S X=$$SETSTR^VALM1("    Clinic Wait Time1:",X,5,SDWIDTH+6)
 S X=$$SETSTR^VALM1($S('SDCWT:"N/A",1:SDCWT1),X,SDFSTCOL+10,50)
 D SET^SDAMEP1(X)
 ;
 S X=""
 S X=$$SETSTR^VALM1("    Clinic Wait Time2:",X,5,SDWIDTH+6)
 S X=$$SETSTR^VALM1($S('SDCWT:"N/A",1:SDCWT2),X,SDFSTCOL+10,50)
 D SET^SDAMEP1(X)
 D SET^SDAMEP1("")
 I SDCWT D  Q
 .D SET^SDAMEP1("NOTE: Clinic Wait Time1 represents the difference between the date the")
 .D SET^SDAMEP1("      appointment was entered and the date it was performed.  Clinic Wait")
 .D SET^SDAMEP1("      Time2 represents the difference between the 'desired date' and the")
 .D SET^SDAMEP1("      date the appointment was performed.")
 .Q
 D SET^SDAMEP1("")
 D SET^SDAMEP1("NOTE: Clinic Wait Time data is not applicable for appointments that have a")
 D SET^SDAMEP1("      status of 'cancelled by clinic'.")
 D SET^SDAMEP1("")
 Q
 ;
EVENT(TYPE,TIME,USER) ;
 Q $$SETSTR^VALM1(TYPE,$$SETSTR^VALM1(TIME,$$SETSTR^VALM1(USER,"",50,30),25,21),2,20)
 ;
