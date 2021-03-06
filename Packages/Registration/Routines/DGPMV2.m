DGPMV2 ;ALB/MRL/MIR - PATIENT MOVEMENT PROCESSOR; 8/30/2013
 ;;5.3;Registration;**40,260005**;Aug 13, 1993
EN(LMVT) ;
 N OLD,ADM,PMVT,NMVT
 I '$D(LMVT) W !!,*7,"INPATIENT ARRAY NOT DEFINED...MODULE ENTERED INCORRECTLY" Q
 K DGPME S DGPMMD="",DEF="NOW",DGPM1X=0 D S I "^1^4^5^"'[("^"_DGPMT_"^") D PTF^DGPMV21 I $D(DGPME) G Q
 ;S DGPMDCD=LMVT("DISDT")
 I DGPMT=3!(DGPMT=5) K DGPME G OLD:DGPMDCD S DGPML="",DGPM1X=1 G NEW
 D @("S"_DGPMT)
 S DGPML=$S($D(MVTS(1)):+MVTS(1,"DATE"),1:"") K C,D,I,J,N
 D NOW^%DTC
 S:$S('DGPMDCD:1,DGPMDCD>%:1,DGPM2X:1,1:0)&$S(DGPMT=1:1,DGPMT=4:1,1:0) DGPMMD=DGPML I $S('DGPMDCD:0,DGPMT=3:1,DGPMT=5:1,DGPMDCD'>%:1,1:0)&$S(DGPMT=1:0,DGPMT=4:0,1:1) S DGPMMD=DGPML,DEF=""
 I $S(DGPMT=2:1,DGPMT=6:1,1:0),DGPMDCD,(DGPMDCD<%) S DEF=""
SEL I $D(DGPME),(DGPME="***") D Q Q  ;if no PTF, quit all the way out, don't reprompt
 K DGPME I DGPMMD S Y=DGPMMD X ^DD("DD") S DEF=Y
NEW S DGX=$S(DGPMT=5:7,DGPMT=6:20,1:0) I DGX S DGONE=1 I $O(^DG(405.1,"AM",DGX,+$O(^DG(405.1,"AM",DGX,0)))) S DGONE=0
 I 'DGX S DGONE=0
 I DGPML D ^DGPMV20
 I $D(^UTILITY("DGPMVN",$J,7)) W !?22,"Enter '?' to see more choices"
SEL2 S DGPMN=0 W !! W:'DGPM1X "Select " W DGPMUC," DATE:  ",DEF W $S(DEF]"":"// ",1:"") R X:DTIME G Q:'$T!(X["^") I X["?" D SHOW G SEL2
 D UP^DGHELP I $S($E(X,1,3)="NOV":0,$E(X)="N":1,X=""&(DEF="NOW"):1,1:0) D NOW^%DTC S DGPMN=1,(DGZ,Y)=% X ^DD("DD") W "  (",Y,")" S Y=DGZ G CONT:(DEF="NOW")!(DGPMT=2)!(DGPMT=6) D E G SEL
 I X="",DGPMMD]"" S Y=DGPMMD G CONT
 ;I X=" ",$D(^DISV(DUZ,"DGPMADM",DFN)) S DGX=^(DFN) I $D(^UTILITY("DGPMVD",$J,+DGX)) S (Y,DGY)=^(DGX) X ^DD("DD") W "  (",Y,")" K DGX,DGY G CONT
 I X?1N.N,$D(^UTILITY("DGPMVN",$J,+X)) S (Y,DGZ)=$P(^UTILITY("DGPMVN",$J,+X,"DATE"),"^") X ^DD("DD") W "  (",Y,")" S Y=DGZ G CONT
 I X=+X,(X<10000),'$D(^UTILITY("DGPMVN",$J,+X)) D E G SEL
 S %DT="SEXT",%DT(0)="-NOW" D ^%DT I $S('Y:1,$D(^UTILITY("DGPMVD",$J,+Y)):0,Y'?7N1".".N:1,1:0) D E G SEL
 I '$D(^UTILITY("DGPMVD",$J,+Y)) S DGPMN=1 I $S(DGPMMD']"":0,DGPMT=2:0,DGPMT=6:0,1:1)!($P(Y,".",2)']"") D E G SEL
CONT S DGPMY=+Y,DGPMDA=$S($D(^UTILITY("DGPMVD",$J,+Y)):+^UTILITY("DGPMVD",$J,+Y),1:"") I DGPMT=1!(DGPMT=4) S DGPMCA=+DGPMDA
 K %DT D ^DGPMV21,SCHDADM^DGPMV22:DGPMT=1&DGPMN,^DGPMV3:DGPMY I $D(DGPME) W:DGPME'="***" !,DGPME G SEL
Q K %,D,DEF,DGPM1X,DGPMAN,DGPMCA,DGPME,DGPML,DGPMMD,DGPMN,DGONE,DGPMSA,I,J,I1,N,PTF,X,Y,^UTILITY("DGPMVD",$J),^UTILITY("DGPMVN",$J) Q
E W !?8,*7,"NOT A VALID SELECTION...CHOOSE BY DATE/TIME OR NUMBER." W:DGPMN !?8,"NEW MOVEMENT ENTRIES MUST INCLUDE A DATE AND TIME." Q
 ;
SHOW W !,"CHOOSE FROM" S %DT="RSE" W ! F I=0:0 S I=$O(^UTILITY("DGPMVN",$J,I)) Q:'I  D WR^DGPMV20
 W ! D HELP^%DTC K I,I1,N,D,C,%DT Q
 ;
S S %=$$GETADM^DGPMAPI8(.ADM,$G(LMVT("ADMIFN")))
 S DGPMAN=$S(ADM:^DGPM(+LMVT("ADMIFN"),0),1:0)
 S DGPMCA=$S(ADM:LMVT("ADMIFN"),1:"") Q
S1 S %=$$LSTPADMS^DGPMAPI7(.MVTS,DFN)
 D SETU(.MVTS)
 Q
S2 S %=$$LSTPTRAN^DGPMAPI7(.MVTS,DFN,DGPMCA)
 D SETU(.MVTS)
 Q
S4 S %=$$LSTPLDGI^DGPMAPI7(.MVTS,DFN)
 D SETU(.MVTS)
 Q
S6 S %=$$LSTPFTS^DGPMAPI7(.MVTS,DFN,DGPMCA)
 D SETU(.MVTS)
 Q
SETU(MVTS) ;
 N I
 F I=0:0 S I=$O(MVTS(I)) Q:'I  D
 . M ^UTILITY("DGPMVN",$J,I)=MVTS(I)
 . S ^UTILITY("DGPMVD",$J,+MVTS(I,"DATE"))=+MVTS(I,"ID")
 . S ^UTILITY("DGPMVDA",$J,+MVTS(I,"ID"))=I
 Q
OLD ;for previous entries (discharges and check-outs) skip select
 S DGPMY=+DGPMDCD,DGPMDA=+LMVT("DISIFN"),DGPMN=0 K %DT D ^DGPMV21 I $D(DGPME) W:DGPME'="***" !,DGPME D Q Q
 I DGPMY D ^DGPMV3 I $D(DGPME) W !,DGPME G OLD
 D Q Q
