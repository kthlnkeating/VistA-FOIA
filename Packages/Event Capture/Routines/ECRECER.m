ECRECER ;ALB/DAN-Event Capture Encounter Report ;12/13/11  10:23
 ;;2.0;EVENT CAPTURE;**112**;8 May 96;Build 18
 ;
STRPT ;
 K ^TMP("ECRECER",$J),^TMP($J,"ECRPT")
 D GETREC
 I ECPTYP="E" D EXPORT Q
 U IO
 D PRINT
 Q
 ;
GETREC ;Find records to put on report
 N ECLI,ECDFN,ECD,ECDT,ECIEN,ECPROV,ECPATN,ECSSN,ECVOL,UNI,ECARR,ECIO
 S ECLI=0 F  S ECLI=$O(ECLOC1(ECLI)) Q:'+ECLI  D
 .S ECDFN=0 K UNI
 .F  S ECDFN=+$O(^ECH("ADT",ECLI,ECDFN)) Q:'ECDFN  D
 ..S ECD=0
 ..F  S ECD=$O(ECDSSU(ECD)) Q:'ECD  D
 ...S ECDT=ECSD-.1
 ...F  S ECDT=+$O(^ECH("ADT",ECLI,ECDFN,ECD,ECDT)) Q:'ECDT!(ECDT>(ECED_.24))  D
 ....S ECIEN=0
 ....F  S ECIEN=+$O(^ECH("ADT",ECLI,ECDFN,ECD,ECDT,ECIEN)) Q:'ECIEN  D
 .....S ECPROV=$$GETPROV^ECRDSSA(ECIEN)
 .....Q:$D(UNI(ECDFN,ECDT,ECD))  S UNI(ECDFN,ECDT,ECD)="" ;don't count if already counted
 .....K ECARR D GETS^DIQ(721,ECIEN,"1;9;29","IE","ECARR","ECERROR")
 .....S ECPATN=ECARR(721,ECIEN_",",1,"E")_"~"_ECDFN
 .....S ECSSN=$$GETSSN^ECRDSSA(ECIEN)
 .....S ECVOL=ECARR(721,ECIEN_",",9,"E"),ECIO=ECARR(721,ECIEN_",",29,"I")
 .....I $G(ECSORT)="P" D
 ......S ^TMP("ECRECER",$J,ECLOC1(ECLI),ECPATN,ECPROV,ECIEN)=ECIO_U_ECDT_U_ECD_U_ECVOL_U_ECSSN
 .....I $G(ECSORT)="D" D
 ......S ^TMP("ECRECER",$J,ECLOC1(ECLI),ECPROV,ECPATN,ECIEN)=ECIO_U_ECDT_U_ECD_U_ECVOL_U_ECSSN
 Q
 ;
EXPORT ;Put in delimited format for exporting
 N CNT,LOC,PATN,PROV,IEN,DATA
 Q:'$D(^TMP("ECRECER",$J))
 S CNT=1,^TMP($J,"ECRPT",CNT)="LOCATION^PATIENT^SSN^I/O^DATE/TIME^PROVIDER #1^DSS UNIT^VOLUME"
 I ECSORT="P" D
 .S LOC="" F  S LOC=$O(^TMP("ECRECER",$J,LOC)) Q:LOC=""  D
 ..S PATN="" F  S PATN=$O(^TMP("ECRECER",$J,LOC,PATN)) Q:PATN=""  D
 ...S PROV="" F  S PROV=$O(^TMP("ECRECER",$J,LOC,PATN,PROV)) Q:PROV=""  D
 ....S IEN=0 F  S IEN=$O(^TMP("ECRECER",$J,LOC,PATN,PROV,IEN)) Q:'+IEN  D
 .....S DATA=^(IEN) ;Naked reference to above line
 .....S CNT=CNT+1,^TMP($J,"ECRPT",CNT)=LOC_U_$P(PATN,"~")_U_$P(DATA,U,5)_U_$P(DATA,U,1)_U_$$FMTE^XLFDT($P(DATA,U,2),2)_U_PROV_U_ECDSSU($P(DATA,U,3))_U_$P(DATA,U,4)
 I ECSORT="D" D
 .S LOC="" F  S LOC=$O(^TMP("ECRECER",$J,LOC)) Q:LOC=""  D
 ..S PROV="" F  S PROV=$O(^TMP("ECRECER",$J,LOC,PROV)) Q:PROV=""  D
 ...S PATN="" F  S PATN=$O(^TMP("ECRECER",$J,LOC,PROV,PATN)) Q:PATN=""  D
 ....S IEN=0 F  S IEN=$O(^TMP("ECRECER",$J,LOC,PROV,PATN,IEN)) Q:'+IEN  D
 .....S DATA=^(IEN) ;Naked reference to above line
 .....S CNT=CNT+1,^TMP($J,"ECRPT",CNT)=LOC_U_$P(PATN,"~")_U_$P(DATA,U,5)_U_$P(DATA,U,1)_U_$$FMTE^XLFDT($P(DATA,U,2),2)_U_PROV_U_ECDSSU($P(DATA,U,3))_U_$P(DATA,U,4)
 Q
 ;
PRINT ;Display results
 N LOC,PATN,PROV,IEN,DATA,PAGE,PTOT,PROTOT
 I '$D(^TMP("ECRECER",$J)) S LOC="NONE" D HDR W !,"No data found"
 S PAGE=0
 I ECSORT="P" D
 .S LOC="" F  S LOC=$O(^TMP("ECRECER",$J,LOC)) Q:LOC=""  D HDR D
 ..S PATN="" F  S PATN=$O(^TMP("ECRECER",$J,LOC,PATN)) Q:PATN=""  K PTOT,PROTOT D  D SUB
 ...S PROV="" F  S PROV=$O(^TMP("ECRECER",$J,LOC,PATN,PROV)) Q:PROV=""  D
 ....S IEN=0 F  S IEN=$O(^TMP("ECRECER",$J,LOC,PATN,PROV,IEN)) Q:'+IEN  D
 .....S DATA=^(IEN) ;Naked reference to above line
 .....W !,$P(PATN,"~"),?32,$P(DATA,U,5),?38,$P(DATA,U,1),?43,$$FMTE^XLFDT($P(DATA,U,2),2),?59,PROV,?91,ECDSSU($P(DATA,U,3)),?123,$P(DATA,U,4)
 .....S PTOT=+$G(PTOT)+1,PROTOT(PROV)=+$G(PROTOT(PROV))+1
 I ECSORT="D" D
 .S LOC="" F  S LOC=$O(^TMP("ECRECER",$J,LOC)) Q:LOC=""  D HDR D
 ..S PROV="" F  S PROV=$O(^TMP("ECRECER",$J,LOC,PROV)) Q:PROV=""  K PROTOT,PTOT D  D SUB
 ...S PATN="" F  S PATN=$O(^TMP("ECRECER",$J,LOC,PROV,PATN)) Q:PATN=""  D
 ....S IEN=0 F  S IEN=$O(^TMP("ECRECER",$J,LOC,PROV,PATN,IEN)) Q:'+IEN  D
 .....S DATA=^(IEN) ;Naked reference to above line
 .....W !,$P(PATN,"~"),?32,$P(DATA,U,5),?38,$P(DATA,U,1),?43,$$FMTE^XLFDT($P(DATA,U,2),2),?59,PROV,?91,ECDSSU($P(DATA,U,3)),?123,$P(DATA,U,4)
 .....S PTOT(PATN)=+$G(PTOT(PATN))+1,PROTOT=+$G(PROTOT)+1
 Q
HDR ;Print Header
 N SORT
 W @IOF
 S PAGE=+$G(PAGE)+1
 W ?51,"Event Capture Encounters Report",?123,"Page: ",PAGE
 W !,?(132-(12+$L(LOC))\2),"For Location ",LOC
 W !,?47,"From ",$$FMTE^XLFDT(ECSD)," through ",$$FMTE^XLFDT(ECED)
 S SORT=$S(ECSORT="P":"Patient Name",1:"Provider")
 W !,?(132-(9+$L(SORT))\2),"Sorted by ",SORT,!
 W !,"Patient",?32,"SSN",?38,"I/O",?43,"Date/Time",?59,"Provider #1",?91,"DSS Unit",?123,"Vol"
 W !,$$REPEAT^XLFSTR("-",132)
 Q
SUB ;Print totals
 N ARR,DISP
 I ECSORT="P" D
 .W !
 .S ARR="" F  S ARR=$O(PROTOT(ARR)) Q:ARR=""  S DISP="Subtotal for provider "_ARR W !,$J(DISP,128),$J(PROTOT(ARR),4)
 .W !,?128,"===="
 .S DISP="Total for patient "_$P(PATN,"~") W !,$J(DISP,128),$J(PTOT,4),!
 I ECSORT="D" D
 .W !
 .S ARR="" F  S ARR=$O(PTOT(ARR)) Q:ARR=""  S DISP="Subtotal for patient "_$P(ARR,"~") W !,$J(DISP,128),$J(PTOT(ARR),4)
 .W !,?128,"===="
 .S DISP="Total for provider "_PROV W !,$J(DISP,128),$J(PROTOT,4),!
 Q
