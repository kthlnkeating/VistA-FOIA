GMPLBLD ; SLC/MKB -- Build Problem Selection Lists ;03/14/13
 ;;2.0;Problem List;**3,28,33,260002**;Aug 25, 1994
 ;
 ;This routine invokes IA #3991
 ;
EN ; -- main entry point
 D EN^VALM("GMPL SELECTION LIST BUILD")
 Q
 ;
HDR ; -- header code
 N NAME,NUM,DATE
 S NUM=+^TMP("GMPLST",$J,0)_$S(+^TMP("GMPLST",$J,0)'=1:$$EZBLD^DIALOG(1250000.036),1:$$EZBLD^DIALOG(1250000.037))
 S DATE=$$EZBLD^DIALOG(1250000.038)_^TMP("GMPLIST",$J,"LST","MODIFIED")
 S VALMHDR(1)=DATE_$J(NUM,79-$L(DATE))
 S NAME=^TMP("GMPLIST",$J,"LST","NAME"),VALMHDR(2)=$J(NAME,$L(NAME)\2+41)
 Q
 ;
INIT ; -- init variables and list array
 N RETURN,MSG
 S GMPLSLST=$$LIST^GMPLBLD2("L") I GMPLSLST="^" S VALMQUIT=1 Q
 I '$$LOCKLST^GMPLAPI1(.RETURN,GMPLSLST) D  G INIT
 . S MSG(1)=$C(7)
 . S MSG(2)=$$EZBLD^DIALOG(1250000.039)
 . S MSG(2,"F")="!!"
 . S MSG(3)=""
 . D EN^DDIOL(.MSG)
 S GMPLMODE="E",VALMSG=$$MSG^GMPLX
 D GETLIST,BUILD("^TMP(""GMPLIST"",$J)",GMPLMODE)
 D LENGTH
 Q
 ;
GETLIST ; Build ^TMP("GMPLIST",$J,#)
 N RETURN K ^TMP("GMPLIST",$J)
 D EN^DDIOL($$EZBLD^DIALOG(1250000.040))
 S %=$$GETLIST^GMPLAPI1(.RETURN,GMPLSLST,50)
 M ^TMP("GMPLIST",$J)=RETURN
 Q
 ;
BUILD(LIST,MODE) ; Build ^TMP("GMPLST",$J,)
 N SEQ,LCNT,NUM,HDR,GROUP,IFN,ITEM,PSEQ,FLAG D CLEAN^VALM10
 S:'$D(^TMP("GMPLIST",$J,0)) ^TMP("GMPLIST",$J,0)=0
 I $P($G(^TMP("GMPLIST",$J,0)),U,1)'>0 S ^TMP("GMPLST",$J,1,0)="   ",^TMP("GMPLST",$J,2,0)=$$EZBLD^DIALOG(1250000.041),^TMP("GMPLST",$J,0)="0^2",VALMCNT=2 Q
 S (LCNT,NUM,SEQ)=0
 F  S SEQ=$O(^TMP("GMPLIST",$J,"SEQ",SEQ)) Q:SEQ'>0  D
 . S IFN=^TMP("GMPLIST",$J,"SEQ",SEQ),LCNT=LCNT+1,NUM=NUM+1
 . S GROUP=$P(^TMP("GMPLIST",$J,IFN),U,2),HDR=$P(^TMP("GMPLIST",$J,IFN),U,3)
 . S:'$L(HDR) HDR=$$EZBLD^DIALOG(1250000.042)
 . I LCNT>1,+$P(^TMP("GMPLIST",$J,IFN),U,4),^TMP("GMPLST",$J,LCNT-1,0)'="   " S LCNT=LCNT+1,^TMP("GMPLST",$J,LCNT,0)="   "
 . S ^TMP("GMPLST",$J,LCNT,0)=$S(MODE="I":$J("<"_SEQ_">",8),1:"        ")_$J(NUM,4)_" "_HDR,^TMP("GMPLST",$J,"B",NUM)=IFN
 . D CNTRL^VALM10(LCNT,9,5,IOINHI,IOINORM)
 . Q:'+$P(^TMP("GMPLIST",$J,IFN),U,4)
 . D CNTRL^VALM10(LCNT,14,$L(HDR),IOUON,IOUOFF)
 . F PSEQ=0:0 S PSEQ=$O(^TMP("GMPLIST",$J,"GRP",+GROUP,PSEQ)) Q:PSEQ'>0  D
 . . S LCNT=LCNT+1
 . . S ITEM=^TMP("GMPLIST",$J,"GRP",+GROUP,PSEQ)
 . . S ^TMP("GMPLST",$J,LCNT,0)="             "_$P(ITEM,U,1)
 . . I $L($P(ITEM,U,2)) D
 ... S ^TMP("GMPLST",$J,LCNT,0)=^TMP("GMPLST",$J,LCNT,0)_" ("_$P(ITEM,U,2)_")"
 ... S FLAG=$P(ITEM,U,3)
 ... Q:$G(FLAG)="0"  ; code is active
 ... S ^TMP("GMPLST",$J,LCNT,0)=^TMP("GMPLST",$J,LCNT,0)_$$EZBLD^DIALOG(1250000.043)
 . S LCNT=LCNT+1,^TMP("GMPLST",$J,LCNT,0)="   "
 S ^TMP("GMPLST",$J,0)=NUM_U_LCNT,VALMCNT=LCNT
 Q
 ;
HELP ; -- help code
 N X,DIR
 D BLD^DIALOG(1250000.044,,,"DIR(""A"")")
 S DIR(0)="FAO"
 D ^DIR
 S VALMSG=$$MSG^GMPLX,VALMBCK=$S(VALMCC:"",1:"R")
 Q
 ;
EXIT ; -- exit code
 I $D(GMPLSAVE),$$CKSAVE^GMPLBLD2 D
 . D SAVE^GMPLBLD2
 D UNLKLST^GMPLAPI1(+GMPLSLST)
 K GMPLIST,GMPLST,GMPLMODE,GMPLSLST,GMPLSAVE,GMPREBLD,GMPQUIT,RT,TMPLST
 K ^TMP("GMPLIST",$J),^TMP("GMPLST",$J)
 Q
 ;
ADD ; Add group(s)
 N SEQ,GROUP,HDR,IFN,GMPQUIT,GMPREBLD,ERR,RETURN,RET,MSG D FULL^VALM1
 F  D  Q:$D(GMPQUIT)  D EN^DDIOL(" ")
 . S GROUP=$$GROUP^GMPLBLD2("") I GROUP="^" S GMPQUIT=1 Q
 . I $D(^TMP("GMPLIST",$J,"GRP",+GROUP)) D EN^DDIOL($$EZBLD^DIALOG(1250000.045),"","!?4") Q
 . I '$$VALGRP^GMPLAPI6(.RET,+GROUP) D  Q
 .. D FULL^VALM1
 .. D EN^DDIOL($C(7))
 .. D BLD^DIALOG(1250000.046,,,"MSG")
 .. D EN^DDIOL(.MSG)
 .. N DIR,DTOUT,DIRUT,DUOUT,X,Y
 .. S DIR(0)="E" D ^DIR
 .. S VALMBCK="R"
 . S HDR=$$HDR^GMPLBLD1($P(GROUP,U,2)) I HDR="^" S GMPQUIT=1 Q
 . S RT="^TMP(""GMPLIST"",$J,""SEQ"",",SEQ=+$$LAST^GMPLBLD2(RT)+1
 . S SEQ=$$SEQ^GMPLBLD1(SEQ) I SEQ="^" S GMPQUIT=1 Q
 . S IFN=$$TMPIFN^GMPLBLD1,^TMP("GMPLIST",$J,IFN)=SEQ_U_+GROUP_U_HDR_"^1"
 . S (^TMP("GMPLIST",$J,"GRP",+GROUP),^TMP("GMPLIST",$J,"SEQ",SEQ))=IFN,^TMP("GMPLIST",$J,0)=^TMP("GMPLIST",$J,0)+1,GMPREBLD=1
 . S %=$$GETCATD^GMPLAPI5(.RETURN,+GROUP,50)
 . M ^TMP("GMPLIST",$J)=RETURN
 I $D(GMPREBLD) S VALMBCK="R",GMPLSAVE=1 D BUILD("^TMP(""GMPLIST"",$J)",GMPLMODE),HDR
 S VALMBCK="R",VALMSG=$$MSG^GMPLX
 Q
 ;
EDIT ; Edit category contents
 N GMPLIST,GMPLST,GMPLMODE,GMPLGRP,GMPLSAVE
 D EN^VALM("GMPL SELECTION GROUP BUILD")
 S GMPLMODE="E"
 D GETLIST,BUILD("TMP(""GMPLIST"",$J)",GMPLMODE)
 S VALMBCK="R",VALMSG=$$MSG^GMPLX
 Q
 ;
REMOVE ; Remove group
 N NUM,IFN,SEQ,GRP,DIR,X,Y S VALMBCK=""
 S NUM=$$SEL1^GMPLBLD1 G:NUM="^" RMQ
 S IFN=$G(^TMP("GMPLST",$J,"B",NUM)) G:+IFN'>0 RMQ
 I "@"[$G(^TMP("GMPLIST",$J,IFN)) D  H 2 G RMQ
 . D EN^DDIOL($C(7))
 . D EN^DDIOL($$EZBLD^DIALOG(1250000.047,"","!!"))
 S DIR("A")=$$EZBLD^DIALOG(1250000.048,$P(^TMP("GMPLIST",$J,IFN),U,3))
 S DIR("?")=$$EZBLD^DIALOG(1250000.049)
 S DIR(0)="YA",DIR("B")="NO" D ^DIR
 I 'Y D EN^DDIOL($$EZBLD^DIALOG(1250000.132)) H 1 G RMQ
 D DELETE^GMPLBLD1(IFN) S VALMBCK="R",GMPLSAVE=1
 D BUILD("^TMP(""GMPLIST"",$J)",GMPLMODE),HDR
RMQ S:'VALMCC VALMBCK="R" S VALMSG=$$MSG^GMPLX
 Q
 ;
LENGTH ;SHORTEN THE ICD9'S DESCRIPTION TO FIT SCREEN
 S LLCNT=0
 F  S LLCNT=$O(^TMP("GMPLST",$J,LLCNT)) Q:LLCNT=""  Q:LLCNT'?1N.N  D
 .; I '$D(^TMP("GMPLST",$J,LLCNT,O)) Q
 . S ICD9VAR=^TMP("GMPLST",$J,LLCNT,0) I $L(ICD9VAR)>50 D
 .. S ICD9VAR=$P(ICD9VAR,"(",1)
 .. S ICD9VAR=$E(ICD9VAR,1,50)_" ("_$P(^TMP("GMPLST",$J,LLCNT,0),"(",2)
 .. S ^TMP("GMPLST",$J,LLCNT,0)=ICD9VAR
 Q
