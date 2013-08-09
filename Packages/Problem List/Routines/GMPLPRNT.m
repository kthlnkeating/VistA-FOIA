GMPLPRNT ; SLC/MKB,KER -- Problem List prints/displays; 03/25/13
 ;;2.0;Problem List;**1,13,26,41,260002**;Aug 25, 1994
 ;
 ; External References
 ;   DBIA 10090  ^DIC(4
 ;   DBIA 10082  ^ICD9(
 ;   DBIA 10086  ^%ZIS
 ;   DBIA 10086  HOME^%ZIS
 ;   DBIA 10089  ^%ZISC
 ;   DBIA 10063  ^%ZTLOAD
 ;   DBIA 10026  ^DIR
 ;   DBIA 10061  OERR^VADPT
 ;   DBIA 10116  CLEAR^VALM1
 ;   DBIA 10103  $$FMTE^XLFDT
 ;   DBIA 10103  $$NOW^XLFDT
 ;   DBIA 10104  $$REPEAT^XLFSTR
 ;   DBIA 10112  $$SITE^VASITE
 ;                   
EN ; Print/Display (Main)
 N DIR,X,Y S VALMBCK=$S(VALMCC:"",1:"R") W !
 I '(($L(GMPLVIEW("ACT")))!(GMPLVIEW("PROV"))!($L(GMPLVIEW("VIEW"),"/")>2)) S Y="A" G EN1
 S DIR(0)="SAOM^C:CURRENT VIEW;A:ALL PROBLEMS;"
 D BLD^DIALOG(1250000.407,,,"DIR(""A"")")
 D BLD^DIALOG(1250000.408,,,"DIR(""?"")")
 D ^DIR G:$D(DTOUT)!($D(DUOUT))!(Y="") ENQ
EN1 ;   Print View
 W ! D @$S(Y="C":"LIST",1:"VAF")
 I GMPRT'>0 D  G ENQ
 . D EN^DDIOL($$EZBLD^DIALOG(1250000.409),,"!!")
 . D EN^DDIOL($C(7))
 . H 1
 D DEVICE G:$D(GMPQUIT) ENQ
 D CLEAR^VALM1,PRT S VALMBCK="R"
ENQ ;   Quit Print/Display
 D KILL^GMPLX S VALMSG=$$MSG^GMPLX Q
 ;             
VAF ; Build Chart Copy
 N TOTAL,VIEW,HASPRB,%
 K GMPLCURR
 S (TOTAL,GMPRT)=0
 S (TOTAL,GMPRT)=0
 S %=$$HASPRBS^GMPLAPI4(.HASPRB,+GMPDFN)
 S (VIEW("ACT"),VIEW("VIEW"))="",VIEW("PROV")=0
 D GETPLIST^GMPLMGR1(.GMPRT,.TOTAL,.VIEW)
 S GMPRT=TOTAL
 Q
 ;
LIST ; Build Current View
 S GMPLCURR=1,GMPRT=0 Q:+$G(GMPCOUNT)'>0  N I,IFN
 D EN^DDIOL($$EZBLD^DIALOG(1250000.410))
 F I=0:0 S I=$O(^TMP("GMPLIDX",$J,I)) Q:I'>0  D
 . S IFN=$P($G(^TMP("GMPLIDX",$J,I)),U,2) Q:IFN'>0
 . S GMPRT=GMPRT+1,GMPRT(I)=IFN W "."
 Q
 ;
DEVICE ; Get Device
 S %ZIS="Q",%ZIS("B")="" D ^%ZIS I POP S GMPQUIT=1 G DQ
 I '$D(GMPLCURR) K GMPRINT
 I $D(IO("Q")) D
 . S ZTRTN="PRT^GMPLPRNT",ZTDESC="PROBLEM LIST OF "_$P(GMPDFN,U,2)
 . S (ZTSAVE("GMPRT"),ZTSAVE("GMPRT("),ZTSAVE("GMPDFN"),ZTSAVE("GMPVAMC"))=""
 . S:$D(GMPLCURR) ZTSAVE("GMPLCURR")="" S ZTDTH=$H
 . D ^%ZTLOAD,HOME^%ZIS S:$D(ZTSK) GMPQUIT=1
DQ ;   Quit Device
 K IO("Q"),POP,%ZIS,ZTRTN,ZTDESC,ZTSAVE,ZTSK
 Q
 ;
HDR ; Header Code
 N PAGE,MSG S PAGE=$$EZBLD^DIALOG(1250000.509,GMPLPAGE),GMPLPAGE=GMPLPAGE+1
 D EN^DDIOL($$REPEAT^XLFSTR("-",79))
 I IOST?1"P".E D
 . S MSG=$S($D(GMPLCURR):1250000.411,1:1250000.412)
 . D EN^DDIOL($$EZBLD^DIALOG(MSG))
 I IOST'?1"P".E D EN^DDIOL($P(GMPDFN,U,2)_"  ("_$P(GMPDFN,U,3)_")")
 S MSG=$S($D(GMPLCURR):1250000.413,1:1250000.414)
 D EN^DDIOL($$EZBLD^DIALOG(MSG),,"?41")
 D EN^DDIOL(PAGE,,"?"_(79-$L(PAGE)))
 D EN^DDIOL($$REPEAT^XLFSTR("-",79))
 K MSG
 D BLD^DIALOG(1250000.415,,,"MSG")
 D EN^DDIOL(.MSG)
 D EN^DDIOL($$REPEAT^XLFSTR("-",79))
 Q
 ;
FTR ; Footer Code
 N I,SITE,DFN,VA,VADM,LOC,DATE,FORM,PARAM,MSG
 F I=1:1:(IOSL-$Y-6) D EN^DDIOL("",,"!")
 S SITE=$$SITE^VASITE,SITE=$P(SITE,"^",2)
 S:SITE'["VAMC" SITE=SITE_" VAMC"
 S DFN=+GMPDFN D OERR^VADPT
 S PARAM=$S(VAIN(4)]"":$P(VAIN(4),U,2)_"  "_VAIN(5),1:$$EZBLD^DIALOG(1250000.418))
 S LOC=$$EZBLD^DIALOG(1250000.417,PARAM) K VAIN
 I $L(LOC)>51 S LOC=$E(LOC,1,51),FORM="VAF10-141"
 E  S FORM="VA FORM 10-1415"
 S MSG=$S($D(GMPLFLAG):$$EZBLD^DIALOG(1250000.419),1:"")
 D EN^DDIOL(MSG)
 D EN^DDIOL($$REPEAT^XLFSTR("-",79))
 D EN^DDIOL($P(GMPDFN,U,2))
 D EN^DDIOL(SITE,,"?"_(79-$L(SITE)\2))
 S DATE=$$FMTE^XLFDT($E(($$NOW^XLFDT),1,12),2)
 S DATE=$$EZBLD^DIALOG(1250000.420,$P(DATE,"@")_" "_$P(DATE,"@",2))
 D EN^DDIOL(DATE,,"?"_(79-$L(DATE)))
 D EN^DDIOL(VA("PID"))
 D EN^DDIOL(LOC,,"?"_(79-$L(LOC)))
 D EN^DDIOL(FORM,,"?"_(79-$L(FORM)))
 D EN^DDIOL($$REPEAT^XLFSTR("-",79))
 W @IOF
 Q
 ;
RETURN() ; End of page
 N X,Y,DIR,I F I=1:1:(IOSL-$Y-3) D EN^DDIOL("",,"!")
 S DIR(0)="E" D ^DIR
 Q +Y
 ;
PRT ; Body of Problem List
 U IO N I,IFN,GMPLPAGE,GMPLFLAG S GMPLPAGE=1 D HDR
 F I=0:0 S I=$O(GMPRT(I)) Q:I'>0  D  Q:$D(GMPQUIT)
 . S IFN=GMPRT(I) Q:IFN'>0
 . D PROB(IFN,I)
 D FTR:IOST?1"P".E I '$D(GMPQUIT),IOST?1"C".E S I=$$RETURN
 I $D(ZTQUEUED) S ZTREQ="@" K GMPDFN,GMPLCURR,GMPQUIT,GMPRT
 D ^%ZISC
 Q
 ;
PROB(DA,NUM) ; Get Problem Text Line
 N GMPL,ONSET,DATE,TEXT,NOTES,J,RESOLVED,X,LINES,PROB,SCS,SP
 Q:'$$DETAILX^GMPLAPI2(.GMPL,DA,0)
 S ONSET=GMPL("ONSET")
 S DATE=$P(GMPL("RECORDED"),U)
 S RESOLVED=GMPL("RESOLVED")
 D SCS^GMPLX1(+DA,.SCS) S SP=$G(SCS(3))
 I 'DATE S DATE=$P(GMPL("ENTERED"),U)
 S PROB=GMPL("NARRATIVE")
 S PROB=PROB_" ("_GMPL("DIAGNOSIS")_")"
 I $E(GMPL("PRIORITY"))="A" S PROB="*"_PROB
 E  S PROB=" "_PROB
 D WRAP^GMPLX(PROB,50,.TEXT)
 D NOTES(.GMPL,.NOTES) S LINES=TEXT+NOTES+1
 I ($Y+LINES)>(IOSL-7) D  Q:$D(GMPQUIT)
 . I IOST?1"P".E D FTR,HDR Q
 . I $$RETURN W @IOF D HDR Q
 . S GMPQUIT=1
PR1 ; Write Problem Text Line
 W !!,$E("   ",1,3-$L(NUM))_NUM_". "_$J(DATE,8)
 D GET^GMPLSITE(.GMPARAM)
 I $E(GMPL("CONDITION"))="T",GMPARAM("VER") W ?14,"$" S GMPLFLAG=1
 W ?15,TEXT(1),?62,$J(ONSET,8)
 I $E(GMPL("STATUS"))="I" W ?71,$S(RESOLVED:$J(RESOLVED,8),1:"unknown")
 I TEXT>1 F J=2:1:TEXT W !?15,TEXT(J)
 Q:'NOTES
 F J=1:1:NOTES D
 . S X=$S(DATE'=$P(NOTES(J),U):$P(NOTES(J),U),1:"")
 . W !?5,$J(X,8),?17,$P(NOTES(J),U,2)
 . S DATE=$P(NOTES(J),U)
 Q
NOTES(GMPL,NOTES) ; Place Comments in NOTES array
 N I
 S NOTES=GMPL("COMMENT")
 F I=1:1:NOTES D
 . S NOTES(I)=$P(GMPL("COMMENT",I),U)_U_$P(GMPL("COMMENT",I),U,3)
 Q
