SROACL1 ;BIR/MAM - CARDIAC PREOP CLINICAL DATA ;08/11/2011
 ;;3.0;Surgery;**38,71,95,125,153,160,174,176**;24 Jun 93;Build 8
 ;
 ; Reference to EN1^GMRVUT0 supported by DBIA #1446
 ;
 D TUT^SROAUTL3 F I=0,200,202,205,206,206.1,208,209,200.1 S SRA(I)=$G(^SRF(SRTN,I))
HT N SRSD,SRED S SRED=$P(SRA(0),"^",9)
 I $P(SRA(206),"^")="" S SRSD=$$FMADD^XLFDT(SRED,-365),NYUK=$$HW(SRSD,SRED,"HT") D
 .I NYUK'="" S NYUK=NYUK+.5\1,$P(^SRF(SRTN,206),"^")=NYUK,SRA(206)=$G(^SRF(SRTN,206))
 S NYUK=$P(SRA(206),"^") S:NYUK'="" NYUK=$S(NYUK["C"!(NYUK["c"):+NYUK_" cm",+NYUK=NYUK:+NYUK_" in",NYUK="NS":" NS",1:NYUK) S SRAO(1)=NYUK_"^236"
WT I $P(SRA(206),"^",2)="" S SRSD=$$FMADD^XLFDT(SRED,-30),NYUK=$$HW(SRSD,SRED,"WT") D
 .I NYUK'="" S NYUK=NYUK+.5\1,$P(^SRF(SRTN,206),"^",2)=NYUK,SRA(206)=$G(^SRF(SRTN,206))
 S NYUK=$P(SRA(206),"^",2) S:NYUK'="" NYUK=$S(NYUK["K"!(NYUK["k"):+NYUK_" kg",+NYUK=NYUK:+NYUK_" lb",NYUK="NS":" NS",1:NYUK) S SRAO(2)=NYUK_"^237"
 S Y=$P(SRA(200.1),"^",11),C=$P(^DD(130,519,0),"^",2) D:Y'="" Y^DIQ S SRAO(3)=Y_"^519"
 S Y=$P(SRA(200.1),"^",12),C=$P(^DD(130,520,0),"^",2) D:Y'="" Y^DIQ S SRAO(4)=Y_"^520"
 K SRA(0) S NYUK=$P(SRA(200),"^",11) D YN S SRAO(5)=SHEMP_"^203"
 S SRAO(6)=$P(SRA(206),"^",5)_"^347",NYUK=$P(SRA(206),"^",6) D YN S SRAO(7)=SHEMP_"^209",NYUK=$P(SRA(206),"^",7) D YN S SRAO(8)=SHEMP_"^348"
 S Y=$P(SRA(200.1),"^",9),C=$P(^DD(130,517,0),"^",2) D:Y'="" Y^DIQ S SRAO(9)=Y_"^517"
 S Y=$P(SRA(200.1),"^",10),C=$P(^DD(130,518,0),"^",2) D:Y'="" Y^DIQ S SRAO(10)=Y_"^518"
 S NYUK=$P(SRA(200),"^",55) D YN S SRAO(11)=SHEMP_"^618",NYUK=$P(SRA(206),"^",10) D YN S SRAO(12)=SHEMP_"^349"
 S NYUK=$P(SRA(206),"^",11) D YN S SRAO(13)=SHEMP_"^350",NYUK=$P(SRA(200),"^",8),SRAO(14)=$S(NYUK=1:"INDEPENDENT",NYUK=2:"PARTIAL DEPENDENT",NYUK=3:"TOTALLY DEPENDENT",NYUK="NS":"NO STUDY",1:"")_"^240"
 S NYUK=$P(SRA(206),"^",13),SRAO(15)=$S(NYUK=0:"NONE",NYUK=1:"NONE RECENT",NYUK=2:"12-72 HRS",NYUK=3:"<12 hrs",NYUK=12:"12 - 72 hrs",NYUK=72:">72 hrs - 7 days",NYUK=7:">7 days",NYUK="NS":"NO STUDY",1:"")_"^351"
 S NYUK=$P(SRA(206),"^",14),SRAO(16)=$S(NYUK=0:"NONE",NYUK=1:"< OR = 7 DAYS",NYUK=2:"> 7 DAYS",1:"")_"^205"
 S NYUK=$P(SRA(206),"^",15) S SRAO(17)=$S(NYUK=0:"NONE",NYUK=">":">3",NYUK="Y":"YES",NYUK="N":"NO",1:NYUK)_"^352"
 S SRAO(18)=$P(SRA(206),"^",42)_"^485"
 S NYUK=$P(SRA(206),"^",16) D YN S SRAO(19)=SHEMP_"^265"
 S NYUK=$P(SRA(200.1),"^",13),SRAO(20)=$S(NYUK=1:"YES/NO SURG",NYUK=2:"YES/PRIOR SURG",NYUK=0:"NO CVD",1:"")_"^521"
 S NYUK=$P(SRA(200.1),"^",14),SRAO(21)=$S(NYUK=1:"HIST OF TIA'S",NYUK=2:"CVA W/O NEURO DEF",NYUK=3:"CVA W/ NEURO DEF",NYUK=0:"NO CVD",1:"")_"^522"
 S SRAO(22)=$P(SRA(206),"^",18)_"^267",SRAO(23)=$P(SRA(206),"^",19)_"^207",NYUK=$P(SRA(206),"^",20) D YN S SRAO(24)=SHEMP_"^353",NYUK=$P(SRA(206),"^",21) D YN S SRAO(25)=SHEMP_"^354"
 S NYUK=$P(SRA(206),"^",22) D YN S SRAO(26)=SHEMP_"^355"
 S NYUK=$P(SRA(209),"^",2),SRAO(27)=$S(NYUK="N":"NONE",NYUK="I":"IABP",NYUK="V":"VAD",NYUK="A":"ARTI",NYUK="O":"OTHER",1:"")_"^474"
 S NYUK=$P(SRA(206),"^",38) D YN S SRAO(28)=SHEMP_"^463"
 S NYUK=$P(SRA(208),"^",19) D YN S SRAO(29)=SHEMP_"^509"
DISP ; display fields
 S SRPAGE="PAGE: 1" D HDR^SROAUTL
 W !," 1. Height:",?29,$P(SRAO(1),"^"),?42,"16. Prior MI: ",$J($P(SRAO(16),"^"),23)
 W !," 2. Weight:",?29,$P(SRAO(2),"^"),?42,"17. Num Prior Heart Surgeries: ",?75,$P(SRAO(17),"^")
 W !," 3. Diabetes - Long Term:",?30,$P(SRAO(3),"^"),?42,"18. Prior Heart Surgeries:" D H485
 W !," 4. Diabetes - 2 Wks Preop:",?30,$P(SRAO(4),"^"),?42,"19. Peripheral Vascular Disease:",?75,$P(SRAO(19),"^")
 W !," 5. COPD:",?30,$P(SRAO(5),"^"),?42,"20. CVD Repair/Obstruct: ",?(79-$L($P(SRAO(20),"^"))),$E($P(SRAO(20),"^"),1,12)
 W !," 6. FEV1:",?($S($P(SRAO(6),"^")="NS":30,1:27)),$P(SRAO(6),"^")_$S($P(SRAO(6),"^")="":"",$P(SRAO(6),"^")="NS":"",1:" liters"),?42,"21. History of CVD:",?(79-$L($P(SRAO(21),"^"))),$P(SRAO(21),"^")
 W !," 7. Cardiomegaly (X-ray):",?30,$P(SRAO(7),"^"),?42,"22. Angina (use CCS Class):",?75,$P(SRAO(22),"^")
 W !," 8. Pulmonary Rales:",?30,$P(SRAO(8),"^"),?42,"23. CHF (use NYHA Class):",?75,$P(SRAO(23),"^")
 W !," 9. Tobacco Use:",$J($P(SRAO(9),"^"),24),?42,"24. Current Diuretic Use:",?75,$P(SRAO(24),"^")
 W !,"10. Tobacco Use Timeframe: ",$P(SRAO(10),"^"),?42,"25. Current Digoxin Use:",?75,$P(SRAO(25),"^")
 W !,"11. Positive Drug Screening: ",?30,$P(SRAO(11),"^"),?42,"26. IV NTG within 48 Hours:",?75,$P(SRAO(26),"^")
 W !,"12. Active Endocarditis:",?30,$P(SRAO(12),"^"),?42,"27. Preop Circulatory Device:",?75,$P(SRAO(27),"^")
 W !,"13. Resting ST Depression:",?30,$P(SRAO(13),"^"),?42,"28. Hypertension (Y/N):",?75,$P(SRAO(28),"^")
 W !,"14. Functional Status: ",$J($P(SRAO(14),"^"),17),?42,"29. Preop Atrial Fibrillation:",?75,$P(SRAO(29),"^")
 W !,"15. PCI: ",?((18-$L($P(SRAO(15),"^"))\2)+22),$P(SRAO(15),"^")
 W ! F MOE=1:1:80 W "-"
 Q
YN ; store answer
 S SHEMP=$S(NYUK="NS":"NS",NYUK="N":"NO",NYUK="Y":"YES",NYUK="NA":"N/A",1:"")
 Q
H485 S SHEMP="",X=$P(SRAO(18),"^") F I=1:1:$L(X,",") D
 .S C=$P(X,",",I) S:I>1 SHEMP=SHEMP_", " S SHEMP=SHEMP_$S(C=0:"NONE",C=1:"CABG-ONLY",C=2:"VALVE-ONLY",C=3:"CABG/VALVE",C=4:"OTHER",C=5:"CABG/OTHER",1:"")
 ;
 S X=SHEMP I $L(X)<12 W ?68,$J(X,11) Q
 W ?68,$J($P(X,",")_",",11) I $L($P(X,", ",2,9))<36 W !,?44,$P(X,", ",2,9) Q
 W !,?44,$P(X,", ",2,4)_",",!,?44,$P(X,", ",5,9)
 Q
HW(SRSD,SRED,SVTYPE) ; get weight & height from Vitals
 N GMRVSTR,SRTYPE,SRBCNT,SRBRDT,SRBIEN,SRBDATA,RESULTS
 K ^UTILITY($J,"GMRVD"),RESULTS S GMRVSTR=SVTYPE,GMRVSTR(0)=SRSD_"^"_SRED_"^^"
 D EN1^GMRVUT0 Q:'$D(^UTILITY($J,"GMRVD")) ""
 S SRTYPE="",SRBCNT=1 F  S SRTYPE=$O(^UTILITY($J,"GMRVD",SRTYPE)) Q:SRTYPE=""  D
 .S SRBRDT=0 F  S SRBRDT=$O(^UTILITY($J,"GMRVD",SRTYPE,SRBRDT)) Q:'SRBRDT  D
 ..S SRBIEN=0 F  S SRBIEN=$O(^UTILITY($J,"GMRVD",SRTYPE,SRBRDT,SRBIEN)) Q:'SRBIEN  D
 ...S SRBDATA=$G(^UTILITY($J,"GMRVD",SRTYPE,SRBRDT,SRBIEN))
 ...S RESULTS(SRTYPE,SRBRDT)=$P(SRBDATA,"^",1,2)_"^"_$P(SRBDATA,"^",8),SRBCNT=SRBCNT+1
 I $D(RESULTS(SVTYPE)) S SRI=$O(RESULTS(SVTYPE,0)) Q $P(RESULTS(SVTYPE,SRI),"^",3)
 Q ""
