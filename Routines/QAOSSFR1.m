QAOSSFR1 ;HISC/DAD-OCCURRENCE SCREEN / MONITORING SYSTEM AUTO ENROLL SPECIAL FUNCTIONS ROUTINE ;11/8/93  09:54
 ;;3.0;Occurrence Screen;**4**;09/14/1993
 ;
PRINT ; QUEUE PRINTING OF REPORTS
 S QAOSDFLT=$P(QAOS740,"^",5)
 I $P(QAOS740,"^",9) D
 . F QAOSDIVN=0:0 S QAOSDIVN=$O(^QA(740,1,"OS2",QAOSDIVN)) Q:QAOSDIVN'>0  D
 .. S ZTIO=$P(^QA(740,1,"OS2",QAOSDIVN,0),"^",2)
 .. S ZTIO=$S(ZTIO]"":ZTIO,1:QAOSDFLT)
 .. D QPRINT(ZTIO,QAOSDIVN)
 .. K ^TMP("QAO",$J,"RPT",QAOSDIVN)
 .. K ^TMP("QAO",$J,"WKS",QAOSDIVN)
 .. Q
 . I $D(^TMP("QAO",$J,"WKS"))!$D(^TMP("QAO",$J,"WKS")) D
 .. D QPRINT(QAOSDFLT,"*")
 .. Q
 . Q
 E  D QPRINT(QAOSDFLT,"*")
 Q
 ;
QPRINT(ZTIO,DIVISION) ; OUTPUT DEVICE , DIVISION (* = ALL)
 Q:ZTIO=""  S ZTRTN="ENTSK^QAOSSFR1",ZTDTH=$H
 S (ZTSAVE("QAMTODAY"),ZTSAVE("QAOSSCRN"))="",ZTSAVE("QAOSDIVN")=DIVISION
 I DIVISION="*" D
 . S ZTSAVE("^TMP(""QAO"",$J,""RPT"",")=""
 . S ZTSAVE("^TMP(""QAO"",$J,""WKS"",")=""
 . Q
 E  D
 . S ZTSAVE("^TMP(""QAO"",$J,""RPT"","_DIVISION_",")=""
 . S ZTSAVE("^TMP(""QAO"",$J,""WKS"","_DIVISION_",")=""
 . Q
 S ZTDESC="Occurrence Screen auto enroll output"
 D ^%ZTLOAD
 Q
 ;
ENTSK ; TASKED ENTRY POINT FOR PRINT
 U IO
 K QAOSUNDL S $P(QAOSUNDL,"-",81)="",QAOSPAGE=1,QAOCOUNT=0
 S %DT="",X="T" D ^%DT X ^DD("DD") S QAOTODAY=$P(Y,"@",1)
 S QAOSSCRN(0)=$P($G(^QA(741.1,QAOSSCRN,0)),"^",2)
 S Y=QAMTODAY\1 X ^DD("DD") S QAOSOCDT=Y
 I $O(^TMP("QAO",$J,"RPT",""))="" D  G DONE
 . D HEAD
 . W !,"No patients found meeting this screen."
 . Q
 S QAOSDVN=""
 F  S QAOSDVN=$O(^TMP("QAO",$J,"RPT",QAOSDVN)) Q:QAOSDVN=""  D
 . S QAOSDVN(0)=$P($G(^DG(40.8,+QAOSDVN,0)),"^")
 . D HEAD S QAOSPAT=""
 . F  S QAOSPAT=$O(^TMP("QAO",$J,"RPT",QAOSDVN,QAOSPAT)) Q:QAOSPAT=""  D
 .. F QAOSD0=0:0 S QAOSD0=$O(^TMP("QAO",$J,"RPT",QAOSDVN,QAOSPAT,QAOSD0)) Q:QAOSD0'>0  D
 ... D:$Y>(IOSL-6) HEAD S X=^TMP("QAO",$J,"RPT",QAOSDVN,QAOSPAT,QAOSD0)
 ... W !!,QAOSPAT,?34,$P(X,"^")
 ... W ?49,$S($D(^SC(+$P(X,"^",2),0))#2:$P(^(0),"^"),1:$P(X,"^",2))
 ... W !?3,$P(X,"^",3) S Y=$P(X,"^",4) X ^DD("DD") W ?37,Y
 ... S QAOCOUNT=QAOCOUNT+1
 ... Q
 .. Q
 . Q
DONE ;
 W !!,"Number of occurrences: ",QAOCOUNT,!,@IOF
 I $O(^TMP("QAO",$J,"WKS",""))]"",$P($G(^QA(740,1,"OS")),"^",4) D
 . S QAOSDVN="",(QAOSDATA,QAOSHOW)=1,QAOSQUIT=0
 . F  S QAOSDVN=$O(^TMP("QAO",$J,"WKS",QAOSDVN)) Q:QAOSDVN=""  D
 .. S QAOSPAT=""
 .. F  S QAOSPAT=$O(^TMP("QAO",$J,"WKS",QAOSDVN,QAOSPAT)) Q:QAOSPAT=""  D
 ... F QAOSD0=0:0 S QAOSD0=$O(^TMP("QAO",$J,"WKS",QAOSDVN,QAOSPAT,QAOSD0)) Q:QAOSD0'>0  D ^QAOSPCL0,^QAOSPCL1
 ... Q
 .. Q
 . Q
 S IONOFF=1 D ^%ZISC
 K %DT,IONOFF,QAMTODAY,QAOCOUNT,QAOSD0,QAOSDATA,QAOSOCDT,QAOSPAGE,QAOSPAT
 K QAOSQUIT,QAOSSCRN,QAOSUNDL,QAOTODAY,X,Y,ZTDTH,ZTIO,ZTRTN,ZTSAVE,ZTSK
 K ^TMP("QAO",$J)
 S:$D(ZTQUEUED) ZTREQ="@"
 Q
HEAD ;
 W:(QAOSPAGE>1)!($E(IOST)="C") @IOF
 W !!?20,"AUTO ENROLLED OCCURRENCE SCREEN PATIENTS",?65,QAOTODAY,!?26,"OCCURRENCE DATE: ",QAOSOCDT,?65,"PAGE: ",QAOSPAGE
 S X=$S($G(QAOSDVN(0))]"":QAOSDVN(0),"*"'[$G(QAOSDIVN):$P($G(^DG(40.8,+$G(QAOSDIVN),0)),"^"),1:"")
 I X]"" S X="DIVISION: "_X W !?80-$L(X)/2,X
 S QAOSPAGE=QAOSPAGE+1 D EN6^QAQAUTL
 W !,"   (* Denotes that this occurrence has already been entered into the system)"
 W !!,"Patient Name",?34,"SSN",?49,"Ward/Clinic",!?3,"Admitting Diagnosis",?37,"Previous Movement",!,QAOSUNDL
 W !!?5,"Screen: ",QAOSSCRN,"   ",QAOSSCRN(0),!
 Q