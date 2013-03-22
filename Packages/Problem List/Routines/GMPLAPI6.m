GMPLAPI6 ; Problem Selection Lists ; 3/21/13
 ;;2.0;Problem List;**260002**;Aug 25, 1994
GETULST(RETURN,USER) ; Get user assigned problem selection list
 ; RETURN - Passed by reference, List IFN^List name
 ; USER - User IFN
 S RETURN=0
 I '$$PROVIEN^GMPLCHK(.RETURN,.USER,"USER") Q 0
 S RETURN=$$GETULST^GMPLEXT1(USER)
 Q 1
 ;
GETCLST(RETURN,GMPCLIN) ; Get first list assigned to the clinic
 ; RETURN - Passed by reference, List IFN^List name
 ; GMPCLIN - Location IFN
 S RETURN=0
 I '$$SCIEN^GMPLCHK(.RETURN,.GMPCLIN,"GMPCLIN") Q 0
 S RETURN=$$GETCLST^GMPLDAL1(GMPCLIN)
 Q 1
 ;
VALGRP(RETURN,GMPLGRP) ; check all problems in the category for inactive codes
 ; RETURN  - Passed by reference
 ;    1    = category has no problems with inactive codes
 ;    0    = category has one or more problems with inactive codes
 ; GMPLCAT = ien from file 125.11
 N RET,PIFN,GMPLVALC
 S RETURN=0,PIFN=0,GMPLVALC=1
 I '$$CTGIEN^GMPLCHK(.RETURN,.GMPLGRP) Q 0
 S %=$$GETGRPP^GMPLDAL1(.RET,GMPLGRP)
 F  S PIFN=$O(RET(PIFN)) Q:'PIFN!('GMPLVALC)  D
 . I '$$STATCHK^ICDAPIU(RET(PIFN),DT) S GMPLVALC=0
 S RETURN=GMPLVALC
 Q RETURN
 ;
VALLIST(RETURN,GMPLLST) ;check all categories in list for probs w/ inactive codes
 ; RETURN - Passed by reference
 ;    1 = list has no problems with inactive codes
 ;    0 = list has one or more problems with inactive codes
 ; GMPLLST = ien from file 125
 N RET,CIFN,GMPLVALC
 S CIFN=0
 S RETURN=0,GMPLVALC=1
 I '$$LSTIEN^GMPLCHK(.RETURN,.GMPLLST) Q 0
 S %=$$GETLSTC^GMPLDAL1(.RET,GMPLLST)
 F  S CIFN=$O(RET(CIFN)) Q:CIFN=""!('GMPLVALC)  D
 . I '$$VALGRP(.RETURN,RET(CIFN)) S GMPLVALC=0
 S RETURN=GMPLVALC
 Q RETURN
 ;
GETFINC(RETURN) ; check probs on lists for future inactivation dates
 ; returns:
 ;   ^TMP("GMPLSL",$J,"F",category,problem)
 ;   ^TMP("GMPLSL",$J,"F",category,"L",list)
 K RETURN
 N PROB,CAT,LIST,RET,PROBCAT,PROBNTX
 S PROB=0,PROBCAT=0
 D ALLPROB^GMPLDAL1(.RET)
 F  S PROBCAT=$O(RET(PROBCAT)) Q:'PROBCAT  D
 . S PROB=0
 . F  S PROB=$O(RET(PROBCAT,PROB)) Q:'PROB  D
 . . N PROB0,PROBTX,APIDATA,ACTDT,CODE
 . . S CODE=RET(PROBCAT,PROB,"CODE")
 . . I $L(CODE)'>0 Q
 . . I '$$STATCHK^ICDAPIU(CODE,DT) Q  ;already inactive
 . . S APIDATA=$$HIST^ICDAPIU(CODE,.APIDATA)
 . . S ACTDT=+$O(APIDATA(DT))
 . . Q:'ACTDT  ; no future activity
 . . I $G(APIDATA(ACTDT)) Q  ; no future inactivation = OK
 . . S PROBTX=RET(PROBCAT,PROB,"TXT")
 . . S PROBNTX=RET(PROBCAT,PROB,"NEWTXT")
 . . S RETURN(PROBCAT,PROB)=PROBTX_U_PROBNTX_U_CODE_U_$$FMTE^XLFDT(ACTDT)
 . Q
 ;
 ; find lists that contain the categories
 S CAT=0
 F  S CAT=$O(RETURN(CAT)) Q:'CAT  D
 . M RETURN(CAT,"L")=RET(CAT,"L")
 . Q
 Q
 ;
ASSUSR(RETURN,GMPLLST,GMPLUSER) ; Assign Problem Selection List to users
 ; Input
 ;  GMPLLST   List IEN
 ;  GMPLUSER  List of users (^UserIEN^...)
 S RETURN=0
 S RETURN=$$USERLST(.RETURN,.GMPLLST,.GMPLUSER,"ADD")
 Q RETURN
 ;
REMUSR(RETURN,GMPLLST,GMPLUSER) ; Remove Problem Selection List from users
 ; Input
 ;  GMPLLST   List IEN
 ;  GMPLUSER  List of users (^UserIEN^...)
 S RETURN=0
 S RETURN=$$USERLST(.RETURN,.GMPLLST,.GMPLUSER,"REM")
 Q RETURN
 ;
USERLST(RETURN,GMPLLST,GMPLUSER,ACTION) ; Add/Remove Problem Selection List from users
 I '$$LSTIEN^GMPLCHK(.RETURN,.GMPLLST) Q 0
 N EXISTS,GMPLI,UE,RET,USR,CNT
 S UE=0,RET=0
 I '$$VALLIST^GMPLAPI6(.RET,+GMPLLST) D ERRX^GMPLAPIE(.RETURN,"INACTICD") Q 0
 I $G(GMPLUSER)="" D ERRX^GMPLAPIE(.RETURN,"INVPARAM","GMPLUSER") Q 0
 S CNT=$L(GMPLUSER,U)
 F GMPLI=1:1:CNT S USR=$P(GMPLUSER,U,GMPLI) D
 . I '$$PROVIEN^GMPLCHK(.RETURN,USR,"GMPLUSER") S UE=1 Q
 Q:UE>0 0
 F GMPLI=1:1:$L(GMPLUSER,U) S USR=$P(GMPLUSER,U,GMPLI) I USR D
 . I ACTION="ADD" S %=$$ASSUSR^GMPLEXT1(.RETURN,GMPLLST,USR) Q
 . I ACTION="REM" S %=$$REMUSR^GMPLEXT1(.RETURN,GMPLLST,USR) Q
 Q 1
 ;
