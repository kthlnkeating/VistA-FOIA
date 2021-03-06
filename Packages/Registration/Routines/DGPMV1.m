DGPMV1 ;ALB/MRL/MIR/JAN - PATIENT MOVEMENT, CONT.; 8/30/13
 ;;5.3;Registration;**59,358,260005**;Aug 13, 1993
 K VAIP S VAIP("D")="L",VAIP("L")=""
 G:'$D(DFN)#2 Q
 S X=PAT("MEANST") W:'X !!,"Means Test not required based on available information" I X D
 .D DOM^DGMTR D:'$G(DGDOM) DIS^DGMTU(DFN) K DGDOM
 D CS^DGPMV10
 ;
NEXT S Z="^CONTINUE^EDIT^MORE^QUIT^" D EN^DDIOL(" ")
 S DIR("A")=$$EZBLD^DIALOG(4070000.072)
 S DIR(0)="FOA" D ^DIR I X']"" S X="C" W X
 I X["^" S X="Q" W " ",X
 D IN^DGHELP
 I X]"","^C^M^Q^"[("^"_X_"^") D:X'="Q" @X G Q
 W !!,"CHOOSE FROM:" F I=1:1 S J=$P($T(HELP+I),";;",2,999) Q:J="QUIT"  W !?5,J
 W ! G NEXT
 ;
C S DGPM2X=0 ;were DGPMVI variables set 2 times?
 N %,LMVT,LST
 S %=$$GETLASTM^DGPMAPI8(.LMVT,DFN)
 I DGPMT=1,+$G(LMVT("TYPE"))=4,'$D(^DGPM("APTT1",DFN)) W !!,*7,"THIS PATIENT IS A LODGER AND HAS NO ADMISSIONS ON FILE.",!,"YOU MUST CHECK HIM OUT PRIOR TO CONTINUING" Q
 I DGPMT=4,"^1^2^6^7^"[("^"_+$G(LMVT("TYPE"))_"^"),'$D(^DGPM("APTT4",DFN)) W !!,*7,"THIS PATIENT IS AN INPATIENT AND HAS NO LODGER MOVEMENTS ON FILE.",!,"YOU MUST DISCHARGE HIM PRIOR TO CONTINUING" Q
 I "^1^2^6"[("^"_+$G(LMVT("TYPE"))_"^")&("^4^5^"[("^"_DGPMT_"^"))!(+$G(LMVT("TYPE"))=3&(DGPMT=5)) D
 . S %=$$LSTPLDGI^DGPMAPI7(.LST,DFN) S DGPM2X=1
 I +$G(LMVT("TYPE"))=4&("^1^2^3^6^"[("^"_DGPMT_"^"))!(+$G(LMVT("TYPE"))=5&(DGPMT=3)) K VAIP S VAIP("D")="L" D
 . S %=$$LSTPADMS^DGPMAPI7(.LST,DFN) S DGPM2X=1
 I DGPM2X D
 . S %=$$GETLASTM^DGPMAPI8(.LMVT,DFN,+$G(LST(1,"DATE")))
 ;lock added to block 2 ppl from moving same patient at same time; abr
LOCK ;
 S %=$$LOCKMVT^DGPMAPI9(.RE,DFN) I 'RE D  Q
 . N TXT D BLD^DIALOG(4070000.027,,,"TXT")
 . S TXT(1,"F")="!!" D EN^DDIOL(.TXT),EN^DDIOL(" ")
 D EN^DGPMV2(.LMVT) D ULOCKMVT^DGPMAPI9(DFN) Q  ;continue with movement entry
Q D KVAR^VADPT K DGPM2X,DGPMIFN,DGPMDCD,DGPMVI,DGPMY,DIE,DR,I,J,X,X1,Z Q
M D 10^VADPT S X=$O(^UTILITY("VAEN",$J,0)) D EN S X=$O(^UTILITY("VASD",$J,0)) D AP K I,X W ! D C Q  ;display enrollments,appointments --> continue
 ;
L D ENED^DGRP G C
 ;
EN W !!?2,"Active clinic enrollments:" I 'X W !?5,"PATIENT IS NOT ACTIVELY ENROLLED IN ANY CLINICS" Q
 W !?5,$P(^UTILITY("VAEN",$J,X,"E"),"^",1) F I=X:0 S I=$O(^UTILITY("VAEN",$J,I)) Q:'I  S X=$P(^(I,"E"),"^",1) W:($X+$L(X))>70 ",",!?5 W:$X>5 ", " W X
 Q
AP W !!?2,"Future Clinic Appointments:" I 'X W !?5,"Patient has no future appointments scheduled" Q
 W !?5,$P(^UTILITY("VASD",$J,X,"E"),"^",2)_"( "_$P(^("E"),"^",1)_")" F I=X:0 S I=$O(^UTILITY("VASD",$J,I)) Q:'I  S X=^(I,"E"),X=$P(X,"^",2)_"( "_$P(X,"^",1)_")" W:$X+$L(X)>78 ",",!?5 W:$X>5 ", " W X
 Q
HELP ;
 ;;<C> = CONTINUE processing without editing or further displays.
 ;;<M> = Display pending appointments and clinic enrollments.
 ;;<Q> = QUIT without further displays or editing.
 ;;QUIT
