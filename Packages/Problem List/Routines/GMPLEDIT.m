GMPLEDIT ; SLC/MKB/KER -- VALM Utilities for Edit sub-list ;03/13/13
 ;;2.0;Problem List;**26,35,260002**;Aug 25, 1994
 ;
 ; External References
 ;   DBIA 10060  ^VA(200
 ;   DBIA 10076  ^XUSEC("GMPL ICD CODE"
 ;   DBIA 10009  YN^DICN
 ;   DBIA 10116  $$SETSTR^VALM1
 ;   DBIA 10117  CLEAN^VALM10
 ;   DBIA 10117  CNTRL^VALM10
 ;   DBIA 10103  $$FMTE^XLFDT
 ;   DBIA 10104  $$REPEAT^XLFSTR
 ;                    
EN ; Init Variables, list array
 ;   Expects GMPIFN   IEN of file 900011 (required)
 ;           GMPLNUM  Sequence # of Problem Edit (optional)
 N I,MSG
 D BLD^DIALOG(1250000.195,,,"MSG")
 D EN^DDIOL(.MSG)
 D EN^DDIOL($S($G(GMPLNUM):"#"_GMPLNUM_" ",1:"")_"...",,"?0")
 D EN^DDIOL("",,"!") K GMPFLD,GMPORIG
 ;   Set GMPFLD() and GMPORIG() Arrays
 ;D GETFLDS^GMPLEDT3(GMPIFN)
 S %=$$DETAIL^GMPLAPI2(.GMPORIG,GMPIFN,$S('$D(GMPLMGR):+GMPROV,1:""))
 I '$D(GMPORIG) D  G KILL
 . K MSG
 . D BLD^DIALOG(1250000.194,,,"MSG")
 . D EN^DDIOL(MSG)
 . S VALMBCK="Q"
 M GMPFLD=GMPORIG
INIT ;   Build list from GMPFLD()
 N LCNT,TEXT,I,SP,LINE,STR,NUM,NOTE,ICD
 S LCNT=1,ICD=$$KCHK^XUSRB("GMPL ICD CODE")
 S SP="" F I=1.11,1.12,1.13,1.15,1.16,1.17,1.18 S:GMPFLD(I) SP=SP_$P(GMPFLD(I),U,2)_U
 S:$L(SP) SP=$E(SP,1,$L(SP)-1)
 K GMPSAVED,GMPREBLD D CLEAN^VALM10
 D WRAP^GMPLX($P(GMPFLD(.05),U,2),65,.TEXT)
 ;   Line 1
 S LINE=$$EZBLD^DIALOG(1250000.196,TEXT(1))
 S ^TMP("GMPLEDIT",$J,LCNT,0)=LINE D HI(LCNT,1)
 I +$G(GMPLUSER),GMPARAM("VER"),$P(GMPFLD(1.02),U)="T" S LINE=$E(LINE,1,12)_"$"_$E(LINE,14,79),^TMP("GMPLEDIT",$J,LCNT,0)=LINE D HI(LCNT,13)
 I TEXT>1 F I=2:1:TEXT S LCNT=LCNT+1,^TMP("GMPLEDIT",$J,LCNT,0)="              "_TEXT(I)
 S LCNT=LCNT+1,^TMP("GMPLEDIT",$J,LCNT,0)="   "
IN1 ;   Line 2
 S LINE=$$EZBLD^DIALOG(1250000.197),STR=$P(GMPFLD(.13),U,2)
 S LINE=LINE_$S(STR="":$$EZBLD^DIALOG(1250000.198),1:STR),LCNT=LCNT+1
 I GMPVA S STR=$S(ICD:7,1:6)_"  "_$$EZBLD^DIALOG(1250000.153,$S(GMPFLD(1.1)="":$$EZBLD^DIALOG(1250000.198),1:$P(GMPFLD(1.1),U,2))),LINE=$$SETSTR^VALM1(STR,LINE,45,34)
 S ^TMP("GMPLEDIT",$J,LCNT,0)=LINE F I=1,45 D HI(LCNT,I)
IN2 ;   Line 3
 S LINE=$$EZBLD^DIALOG(1250000.199,$P(GMPFLD(.12),U,2)),LCNT=LCNT+1
 I $E(GMPFLD(.12))="A",$L(GMPFLD(1.14)) S LINE=LINE_"/"_$P(GMPFLD(1.14),U,2)
 I $E(GMPFLD(.12))="I",GMPFLD(1.07) S LINE=LINE_$$EZBLD^DIALOG(1250000.155,$P(GMPFLD(1.07),U,2))
 I GMPVA S STR=$S(ICD:8,1:7)_$$EZBLD^DIALOG(1250000.622,$S('$L(SP):$$EZBLD^DIALOG(1250000.170),1:$P(SP,U))),LINE=$$SETSTR^VALM1(STR,LINE,45,34)
 S ^TMP("GMPLEDIT",$J,LCNT,0)=LINE F I=1,45 D HI(LCNT,I)
IN3 ;   Line 4
 S LINE=$$EZBLD^DIALOG(1250000.200,$P(GMPFLD(1.05),U,2)),LCNT=LCNT+1
 I GMPVA,$L(SP,U)>1 S STR=$P(SP,U,2),LINE=$$SETSTR^VALM1(STR,LINE,60,20)
 S ^TMP("GMPLEDIT",$J,LCNT,0)=LINE D HI(LCNT,1)
 ;   Line 5
 I $E(GMPLVIEW("VIEW"))="S" S LINE=$$EZBLD^DIALOG(1250000.201,$P(GMPFLD(1.06),U,2))
 E  S LINE=$$EZBLD^DIALOG(1250000.202,$P(GMPFLD(1.08),U,2))
 I GMPVA,$L(SP,U)>2 S STR=$P(SP,U,3),LINE=$$SETSTR^VALM1(STR,LINE,60,20)
 S LCNT=LCNT+1,^TMP("GMPLEDIT",$J,LCNT,0)=LINE D HI(LCNT,1) G:'ICD IN4
 ;   Line 6
 S LINE=$$EZBLD^DIALOG(1250000.203,$P(GMPFLD(.01),U,2)),LCNT=LCNT+1
 S ^TMP("GMPLEDIT",$J,LCNT,0)=LINE D HI(LCNT,1)
IN4 ;   Line 7/8
 S LCNT=LCNT+1,^TMP("GMPLEDIT",$J,LCNT,0)="   "
 S LCNT=LCNT+1,^TMP("GMPLEDIT",$J,LCNT,0)=$$EZBLD^DIALOG(1250000.169)
 D CNTRL^VALM10(LCNT,1,8,IOUON,IOUOFF)
 S NUM=$S(GMPVA:7,1:5) S:ICD NUM=NUM+1
 I GMPFLD(10,0) F I=1:1:GMPFLD(10,0) D
 . S NUM=NUM+1,NOTE=GMPFLD(10,I)
 . S LINE=NUM_$E("   ",1,3-$L(NUM))_$J($$EXTDT^GMPLX($P(NOTE,U,5)),8)
 . I $P(GMPFLD(10,I),U,3)="",$P(GMPORIG(10,I),U,3)'="" S $P(NOTE,U,3)=$$EZBLD^DIALOG(1250000.204)
 . S LCNT=LCNT+1,^TMP("GMPLEDIT",$J,LCNT,0)=LINE_": "_$P(NOTE,U,3)
 . D HI(LCNT,1) Q:'$D(GMPLMGR)
 . S LINE="             "_$$PROVNAME^GMPLEXT(+$P(NOTE,U,6))
 . S LCNT=LCNT+1,^TMP("GMPLEDIT",$J,LCNT,0)=LINE
IN5 ;   Last Line
 I $D(GMPFLD(10,"NEW"))>9 S NUM=NUM+1 D
 . S LINE=NUM_$E("   ",1,3-$L(NUM))_$J($$EXTDT^GMPLX(DT),8)_": "
 . S I=$O(GMPFLD(10,"NEW",0)),LINE=LINE_GMPFLD(10,"NEW",I)
 . S LCNT=LCNT+1,^TMP("GMPLEDIT",$J,LCNT,0)=LINE D HI(LCNT,1)
 . F  S I=$O(GMPFLD(10,"NEW",I)) Q:I'>0  D
 . . S LINE="             "_GMPFLD(10,"NEW",I)
 . . S LCNT=LCNT+1,^TMP("GMPLEDIT",$J,LCNT,0)=LINE
 S VALMCNT=LCNT,^TMP("GMPLEDIT",$J,0)=NUM_U_LCNT,VALMSG=$$MSG^GMPLEDT3
 Q
 ;          
HI(LINE,COL) ; Hi-lite #
 D CNTRL^VALM10(LINE,COL,3,IOINHI,IOINORM)
 Q
 ;          
HDR ; Header code
 N LASTMOD,PAT S PAT=$P(GMPDFN,U,2)_"  ("_$P(GMPDFN,U,3)_")"
 S %=$$LASTMOD^GMPLAPI4(.LASTMOD,GMPIFN)
 S LASTMOD=$$EZBLD^DIALOG(1250000.190,$$FMTE^XLFDT(LASTMOD))
 S VALMHDR(1)=PAT_$$REPEAT^XLFSTR(" ",(79-$L(PAT)-$L(LASTMOD)))_LASTMOD
 Q
 ;
HELP ; Help code
 N DIR,MSG,DLG,CNT
 S DIR(0)="EA"
 S DLG=$S(VALMCNT>11:1250000.405,1:1250000.205)
 D BLD^DIALOG(DLG,CNT,,"DIR(""A"")")
 D ^DIR
 S CNT=+$G(^TMP("GMPLEDIT",$J,0))
 S VALMSG=$$MSG^GMPLEDT3,VALMBCK=$S(VALMCC:"",1:"R")
 Q
 ;          
EXIT ; Exit code
 N DIFFRENT,%,MSG G:$D(GMPSAVED) KILL
 S DIFFRENT=$$EDITED^GMPLEDT2 I 'DIFFRENT G KILL
 D BLD^DIALOG(1250000.206,,,"MSG")
 D EN^DDIOL($C(7))
 D EN^DDIOL(.MSG)
EX1 ;   Ask to Save Changes on Exit
 K MSG
 D BLD^DIALOG(1250000.207,,,"MSG")
 D EN^DDIOL(.MSG)
 S %=1 D YN^DICN G:(%<0)!(%=2) KILL I %=0 D  G EX1
 . K MSG
 . D BLD^DIALOG(1250000.208,,,"MSG")
 . D EN^DDIOL(.MSG)
 D EN^DDIOL($$EZBLD^DIALOG(1250000.94,,"!!"))
 N RETURN
 I '$$UPDATE^GMPLAPI2(.RETURN,GMPIFN,.GMPORIG,.GMPFLD,.GMPLUSER,+GMPROV) D  G EX1
 . W !,$$ERRTXT^GMPLAPIE(.RETURN)
 D EN^DDIOL($$EZBLD^DIALOG(1250000.95))
KILL ;   Clean-up
 S CNT=+$G(^TMP("GMPLEDIT",$J,0))
 F I=1:1:CNT K XQORM("KEY",I)
 D CLEAN^VALM10 K XQORM("KEY","$")
 K GMPFLD,GMPORIG,GMPQUIT,DUOUT,DTOUT,I,CNT
 Q
