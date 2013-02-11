PRSNRDN0 ;WOIFO/KJS - GROUP SUMMARY ACTIVITY DIRECT AND NON DIRECT I REPORT;8/4/2011
 ;;4.0;PAID;**126**;Sep 21, 1995;Build 59
 ;;Per VHA Directive 2004-038, this routine should not be modified
 ;
 ;
DAP ; Entry point for Data Approval Personnel
 N GROUP
 D ACCESS^PRSNUT02(.GROUP,"A",DT,1)
 ; quit if any error during group selection
 I $P($G(GROUP(0)),U,2)="E" D  Q
 .W !,$P(GROUP(0),U,3)
 D MAIN
 Q
 ;
COORD ;Entry point for VANOD Coordinator
 ; Coordinator has no access limits so let them pick any group
 N GROUP
 D PIKGROUP^PRSNUT04(.GROUP,"",1)
 I $P($G(GROUP(0)),U,2)="E" D  Q
 .W !,$P(GROUP(0),U,3)
 D MAIN
 ;
 Q
 ;
MAIN ;
 N RANGE,BEG,END,EXTBEG,EXTEND,STOP,TYPE,BEG,END
 S STOP=0
 D DATE
 Q:STOP
 D QUE
 Q
 ;
REPORT ;for group of location or t&l
 ;
 N X,PRSIEN,PRSNGLB,PRSNG,GRP,SORT,PRSNGA,PRSNGB,SKILMIX,PICK,PG
 U IO
 S SORT=$P(GROUP(0),U,2),PG=0,TODAY=$E(DT,4,5)_"/"_$E(DT,6,7)_"/"_$E(DT,2,3)
 D HDR^PRSNRDN1(EXTBEG,EXTEND)
 S (PICK,STOP)=0
 F  S PICK=$O(GROUP(PICK)) Q:PICK=""  D
 .S PRSNG=GROUP(0)_"^"_PICK_"^"_GROUP(PICK)
 .S PRSNGLB=$S($P(PRSNG,U,2)="N":$NA(^NURSF(211.8,"D",$P(PRSNG,U,7))),1:$NA(^PRSPC("ATL"_$P(PRSNG,U,3))))
 .S GRP=$P(PRSNG,U,3)  ;External form of primary location
 .S PRSNGA=""
 .F  S PRSNGA=$O(@PRSNGLB@(PRSNGA)) QUIT:PRSNGA=""  D
 ..S PRSNGB=0
 ..F  S PRSNGB=$O(@PRSNGLB@(PRSNGA,PRSNGB)) QUIT:'PRSNGB  D
 ...I $P(PRSNG,U,2)="N",+$P(PRSNG,U,4)'=+$$PRIMLOC^PRSNUT03(PRSNGB) Q
 ...S PRSIEN=$S($P(PRSNG,U,2)="N":+$G(^VA(200,PRSNGB,450)),1:PRSNGB)
 ...S X=$$ISNURSE^PRSNUT01(PRSIEN)
 ...I +X D
 ....D GATHER^PRSNRDN1(.SKILMIX,GRP,PRSIEN,BEG,END)
 D PRTLP^PRSNRDN1(EXTBEG,EXTEND)
 W !!,"End of Report"
 D ^%ZISC
 Q
 ;
DATE ; User is prompted for a date range 
 ;
 S RANGE=$$POCRANGE^PRSNUT01()
 ; QUIT HERE IF RANGE=0 
 I +$G(RANGE)'>0 S STOP=1 Q
 ;
 S BEG=$P(RANGE,U)
 S END=$P(RANGE,U,2)
 S EXTBEG=$P(RANGE,U,3)
 S EXTEND=$P(RANGE,U,4)
 ;
 Q
 ;
QUE ;call to generate and display report for individual activity
 N %ZIS,POP,IOP
 S %ZIS="MQ"
 D ^%ZIS
 Q:POP
 I $D(IO("Q")) D
 . K IO("Q")
 . N ZTSK,ZTDESC,ZTDTH,ZTIO,ZTRTN,ZTSAVE,ZTUCI,ZTCPU,ZTPRI,ZTKIL,ZTSYNC
 . S ZTDESC="GROUP SUMMARY ACTIVITY DIRECT AND NON DIRECT"
 . S ZTRTN="REPORT^PRSNRDN0"
 . S ZTSAVE("GROUP")=""
 . S ZTSAVE("GROUP(")=""
 . S ZTSAVE("TYPE")=""
 . S ZTSAVE("BEG")=""
 . S ZTSAVE("END")=""
 . S ZTSAVE("EXTBEG")=""
 . S ZTSAVE("EXTEND")=""
 . D ^%ZTLOAD
 . I $D(ZTSK) S ZTREQ="@" W !,"Request "_ZTSK_" Queued."
 E  D
 . D REPORT
 Q
