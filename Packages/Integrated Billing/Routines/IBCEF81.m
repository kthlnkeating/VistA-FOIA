IBCEF81 ;ALB/BI - PROVIDER ADJUSTMENTS ;11-OCT-2010
 ;;2.0;INTEGRATED BILLING;**432,473**;21-MAR-94;Build 29
 ;;Per VHA Directive 2004-038, this routine should not be modified.
 ;
 Q
 ;
EN(INPUT)  ; FIRST ENTRY POINT
 N INSLEVEL,PRTYPE,OUTPUT,IBIEN,CMODE,CPRNUM,STATUS
 S STATUS=1
 I $D(INPUT)=0 S STATUS=0 Q STATUS
 I (($G(IBXFORM)=2)!($G(IBXFORM)=3)) D EN^IBCEF82(.INPUT) Q STATUS    ; PERFORM LOCAL PRINT BUSINESS RULES
 K OUTPUT M OUTPUT=INPUT
 D CINIT1 Q:IBIEN="" STATUS
 F INSLEVEL="P","S","T" D    ; P=PRIMARY, S=SECONDARY, T=TERTIARY
 . D CINIT2
 . F PRTYPE=1,2,3,5,9 D    ; 1=REFERRING, 2=OPERATING, 3=RENDERING, 5=SUPERVISING, 9=OTHER OPERATING
 .. D START(INSLEVEL,PRTYPE,.OUTPUT)
 K INPUT M INPUT=OUTPUT
 Q STATUS
START(INSLEVEL,PRTYPE,OUTPUT)  ; START PROCESSING
 N INTERM,PROVINFO,MAXAINFO,FIRSTINF
 S INTERM="A"
 S INTERM=INTERM_$$TEST1  ; Does Claim Level Provider Exist, 0=NO, 1=YES
 S INTERM=INTERM_$$TEST2  ; All procedures have a line level provider, 0=NO, 1=YES
 S INTERM=INTERM_$$TEST3  ; One Line Level provider is most significant, 0=NO, 1=YES
 S INTERM=INTERM_$$TEST4  ; At least one line level provider matches the claim level provider, 0=NO, 1=YES
 S INTERM=INTERM_$$TEST5  ; There is only one procedure without a line level provider, 0=NO, 1=YES
 D @INTERM
 Q 
 ;
TEST1()  ; Does Claim Level Provider Exist, 0=NO, 1=YES
 N PROVX,PROVY
 I $D(CMODE(INSLEVEL))#10=0 Q 0
 I $D(CPRNUM(INSLEVEL))#10=0 Q 0
 S (PROVX,PROVY)=$G(INPUT("PROVINF",IBIEN,CMODE(INSLEVEL),CPRNUM(INSLEVEL),PRTYPE)) Q:PROVX="" 0
 S PROVX="^"_$P(PROVX,";",2)_$P(PROVX,";",1)_")"
 I $D(@PROVX) D  Q 1    ;CLAIM PROVIDER EXISTS, RETURN TRUE.
 . ; LOAD CLAIM LEVEL PROVIDER INFORMATION
 . S PROVINFO=PROVY
 . S PROVINFO("PROVINF",IBIEN)=IBIEN
 . S PROVINFO("PROVINF",IBIEN,CMODE(INSLEVEL))=""
 . S PROVINFO("PROVINF",IBIEN,CMODE(INSLEVEL),CPRNUM(INSLEVEL))=INSLEVEL
 . M PROVINFO("PROVINF",IBIEN,CMODE(INSLEVEL),CPRNUM(INSLEVEL),PRTYPE)=INPUT("PROVINF",IBIEN,CMODE(INSLEVEL),CPRNUM(INSLEVEL),PRTYPE)
 Q 0
 ;
TEST2()  ; All procedures have a line level provider, 0=NO, 1=YES
 N SLC,RESULT,LMODE,LPRNUM,PROVX,LINECNT
 S SLC=0,RESULT=1,LINECNT=0
 F  S SLC=$$LINIT1(SLC) Q:+SLC=0  D
 . S LINECNT=LINECNT+1
 . D LINIT2
 . I $D(LMODE(INSLEVEL))#10=0 S RESULT=0 Q
 . I $D(LPRNUM(INSLEVEL))#10=0 S RESULT=0 Q
 . S PROVX=$G(INPUT("L-PROV",IBIEN,SLC,LMODE(INSLEVEL),LPRNUM(INSLEVEL),PRTYPE))
 . I PROVX="" D  Q
 .. S RESULT=RESULT*0
 . S PROVX="^"_$P(PROVX,";",2)_$P(PROVX,";",1)_")"
 . S RESULT=RESULT*($D(@PROVX)'=0)
 I +$G(INPUT("SLC"))'=0,INPUT("SLC")>LINECNT S RESULT=0
 Q RESULT
 ;
TEST3()  ; One Line Level provider is most significant, 0=NO, 1=YES
 N SLC,RESULT,LMODE,LPRNUM,PCOUNT,PCOUNTF,PCOUNTL,PROVX,TEMPNODE
 S SLC=0,RESULT=0
 F  S SLC=$$LINIT1(SLC) Q:+SLC=0  D
 . D LINIT2
 . I $D(LMODE(INSLEVEL))#10=0 Q
 . I $D(LPRNUM(INSLEVEL))#10=0 Q
 . S PROVX=$G(INPUT("L-PROV",IBIEN,SLC,LMODE(INSLEVEL),LPRNUM(INSLEVEL),PRTYPE)) Q:PROVX=""
 . I $D(FIRSTINF)=0 D
 .. ; LOAD FIRST AVAILABLE PROVIDER INFORMATION
 .. S FIRSTINF=$G(INPUT("L-PROV",IBIEN,SLC,LMODE(INSLEVEL),LPRNUM(INSLEVEL),PRTYPE))
 .. S FIRSTINF("L-PROV",IBIEN)=IBIEN
 .. S FIRSTINF("L-PROV",IBIEN,LMODE(INSLEVEL),LPRNUM(INSLEVEL))=INSLEVEL
 .. M FIRSTINF("L-PROV",IBIEN,LMODE(INSLEVEL),LPRNUM(INSLEVEL),PRTYPE)=INPUT("L-PROV",IBIEN,SLC,LMODE(INSLEVEL),LPRNUM(INSLEVEL),PRTYPE)
 . S PCOUNT(PROVX)=$P($G(PCOUNT(PROVX)),"^",1)+1_"^"_SLC_"^"_LMODE(INSLEVEL)_"^"_LPRNUM(INSLEVEL)_"^"_PRTYPE
 S PROVX="" F  S PROVX=$O(PCOUNT(PROVX)) Q:PROVX=""  D
 . S PCOUNTF($P(PCOUNT(PROVX),"^",1),PROVX)=$P(PCOUNT(PROVX),"^",2,5)
 S PCOUNTL(1)=$O(PCOUNTF(""),-1) Q:PCOUNTL(1)="" RESULT
 S PCOUNTL(2,1)=$O(PCOUNTF(PCOUNTL(1),""),-1) Q:PCOUNTL(2,1)="" RESULT
 S PCOUNTL(2,2)=$O(PCOUNTF(PCOUNTL(1),PCOUNTL(2,1)),-1)
 I PCOUNTL(2,2)="" D
 . S RESULT=1
 . ; LOAD MOST SIGNIFICANT LINE LEVEL PROVIDER INFORMATION
 . S MAXAINFO=PCOUNTL(2,1)
 . S TEMPNODE=PCOUNTF(PCOUNTL(1),PCOUNTL(2,1))
 . S MAXAINFO("L-PROV",IBIEN)=IBIEN
 . S MAXAINFO("L-PROV",IBIEN,$P(TEMPNODE,"^",2),$P(TEMPNODE,"^",3))=INSLEVEL
 . M MAXAINFO("L-PROV",IBIEN,$P(TEMPNODE,"^",2),$P(TEMPNODE,"^",3),$P(TEMPNODE,"^",4))=INPUT("L-PROV",IBIEN,$P(TEMPNODE,"^",1),$P(TEMPNODE,"^",2),$P(TEMPNODE,"^",3),$P(TEMPNODE,"^",4))
 Q RESULT
 ;
TEST4()  ; At least one line level provider matches the claim level provider, 0=NO, 1=YES
 N CPROV,RESULT,LMODE,LPRNUM,LPROV,SLC
 I $D(CMODE(INSLEVEL))#10=0 Q 0
 I $D(CPRNUM(INSLEVEL))#10=0 Q 0
 S CPROV=$G(INPUT("PROVINF",IBIEN,CMODE(INSLEVEL),CPRNUM(INSLEVEL),PRTYPE)) Q:CPROV="" 0
 S SLC=0,RESULT=0
 F  S SLC=$$LINIT1(SLC) Q:+SLC=0  D
 . D LINIT2
 . I $D(LMODE(INSLEVEL))#10=0 Q
 . I $D(LPRNUM(INSLEVEL))#10=0 Q
 . S LPROV=$G(INPUT("L-PROV",IBIEN,SLC,LMODE(INSLEVEL),LPRNUM(INSLEVEL),PRTYPE))  Q:LPROV=""
 . I LPROV=CPROV S RESULT=1
 Q RESULT
 ;
TEST5()  ; There is only one procedure without a line level provider, 0=NO, 1=YES
 N SLC,LMODE,LPRNUM,PROVCNT,RESULT
 S SLC=0,PROVCNT=0,RESULT=0
 F  S SLC=$$LINIT1(SLC) Q:+SLC=0  D
 . D LINIT2
 . I $D(LMODE(INSLEVEL))#10=0 Q
 . I $D(LPRNUM(INSLEVEL))#10=0 Q
 . S PROVX=$G(INPUT("L-PROV",IBIEN,SLC,LMODE(INSLEVEL),LPRNUM(INSLEVEL),PRTYPE))
 . S:PROVX'="" PROVCNT=PROVCNT+1
 I +$G(INPUT("SLC"))'=0,INPUT("SLC")=(PROVCNT+1) S RESULT=1
 Q RESULT
 ;
A00000  ;  Case 1
 ; TESTS: Does Claim Level Provider Exist: 0=NO
 ;        All procedures have a line level provider: 0=NO
 ;        One Line Level provider is most significant: 0=NO
 ; At least one line level provider matches the claim level provider: 0=NO
 ;        There is only one procedure without a line level provider: 0=NO
 ;
 ; Move the first available line level provider to the claim level.
 I $G(FIRSTINF)="" Q
 M OUTPUT("PROVINF",IBIEN)=FIRSTINF("L-PROV",IBIEN)
 ;
 ; Remove the claim lines associated with the primary provider.
 S PROVINFO=FIRSTINF
 D REMOVELN
 Q
 ;
A00001  ;  Case 2
 ; TESTS: Does Claim Level Provider Exist: 0=NO
 ;        All procedures have a line level provider: 0=NO
 ;        One Line Level provider is most significant: 0=NO
 ; At least one line level provider matches the claim level provider: 0=NO
 ;        There is only one procedure without a line level provider: 1=YES
 ;
 ; Move the first available line level provider to the claim level.
 I $G(FIRSTINF)="" Q
 M OUTPUT("PROVINF",IBIEN)=FIRSTINF("L-PROV",IBIEN)
 ;
 ; Remove the claim lines associated with the primary provider.
 S PROVINFO=FIRSTINF
 D REMOVELN
 Q
 ;
A00010  ;  Case 3 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
A00011  ;  Case 4 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
A00100  ;  Case 5
 ; TESTS: Does Claim Level Provider Exist: 0=NO
 ;        All procedures have a line level provider: 0=NO
 ;        One Line Level provider is most significant: 1=YES
 ; At least one line level provider matches the claim level provider: 0=NO
 ;        There is only one procedure without a line level provider: 0=NO
 ;
 ; Set the claim level provider equal to the most significant line level provider.
 I $G(MAXAINFO)="" Q
 M OUTPUT("PROVINF",IBIEN)=MAXAINFO("L-PROV",IBIEN)
 ;
 ; Remove the claim lines associated with the primary provider.
 S PROVINFO=MAXAINFO
 D REMOVELN
 ;
 Q
 ;
A00101  ;  Case 6
 ; TESTS: Does Claim Level Provider Exist: 0=NO
 ;        All procedures have a line level provider: 0=NO
 ;        One Line Level provider is most significant: 1=YES
 ; At least one line level provider matches the claim level provider: 0=NO
 ;        There is only one procedure without a line level provider: 1=YES
 ;
 ; Set the claim level provider equal to the most significant line level provider.
 I $G(MAXAINFO)="" Q
 M OUTPUT("PROVINF",IBIEN)=MAXAINFO("L-PROV",IBIEN)
 ;
 ; Remove the claim lines associated with the primary provider.
 S PROVINFO=MAXAINFO
 D REMOVELN
 ;
 Q
 ;
A00110  ;  Case 7 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
A00111  ;  Case 8 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
A01000  ;  Case 9
 ; TESTS: Does Claim Level Provider Exist: 0=NO
 ;        All procedures have a line level provider: 1=YES
 ;        One Line Level provider is most significant: 0=NO
 ; At least one line level provider matches the claim level provider: 0=NO
 ;        There is only one procedure without a line level provider: 0=NO
 ;
 ; Move the first available line level provider to the claim level.
 ; Set the claim level provider equal to the most significant line level provider.
 I $G(FIRSTINF)="" Q
 M OUTPUT("PROVINF",IBIEN)=FIRSTINF("L-PROV",IBIEN)
 ;
 ; Remove the claim lines associated with the primary provider.
 S PROVINFO=FIRSTINF
 D REMOVELN
 Q
 ;
A01001  ; Case 10 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
A01010  ; Case 11 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
A01011  ; Case 12 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
A01100  ; Case 13
 ; TESTS: Does Claim Level Provider Exist: 0=NO
 ;        All procedures have a line level provider: 1=YES
 ;        One Line Level provider is most significant: 1=YES
 ; At least one line level provider matches the claim level provider: 0=NO
 ;        There is only one procedure without a line level provider: 0=NO
 ;
 ; Set the claim level provider equal to the most significant line level provider.
 I $G(MAXAINFO)="" Q
 M OUTPUT("PROVINF",IBIEN)=MAXAINFO("L-PROV",IBIEN)
 ;
 ; Remove the claim lines associated with the primary provider.
 S PROVINFO=MAXAINFO
 D REMOVELN
 ;
 Q
 ;
A01101  ; Case 14 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
A01110  ; Case 15 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
A01111  ; Case 16 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
A10000  ; Case 17
 ; TESTS: Does Claim Level Provider Exist: 1=YES
 ;        All procedures have a line level provider: 0=NO
 ;        One Line Level provider is most significant: 0=NO
 ; At least one line level provider matches the claim level provider: 0=NO
 ;        There is only one procedure without a line level provider: 0=NO
 ;
 ; ACTIONS: Transmit as is.
 ;
 Q
 ;
A10001   ; Case 18
 ; TESTS: Does Claim Level Provider Exist: 1=YES
 ;        All procedures have a line level provider: 0=NO
 ;        One Line Level provider is most significant: 0=NO
 ; At least one line level provider matches the claim level provider: 0=NO
 ;        There is only one procedure without a line level provider: 1=YES
 ;
 ; ACTIONS: Transmit as is.
 ;
 Q
 ;
A10010   ; Case 19
 ; TESTS: Does Claim Level Provider Exist: 1=YES
 ;        All procedures have a line level provider: 0=NO
 ;        One Line Level provider is most significant: 0=NO
 ; At least one line level provider matches the claim level provider: 1=YES
 ;        There is only one procedure without a line level provider: 0=NO
 ;
 ; Remove the claim lines associated with the claim level provider.
 D REMOVELN
 ;
 Q
 ;
A10011   ; Case 20
 ; TESTS: Does Claim Level Provider Exist: 1=YES
 ;        All procedures have a line level provider: 0=NO
 ;        One Line Level provider is most significant: 0=NO
 ; At least one line level provider matches the claim level provider: 1=YES
 ;        There is only one procedure without a line level provider: 1=YES
 ;
 ; Remove the claim lines associated with the claim level provider.
 D REMOVELN
 ;
 Q
 ;
A10100   ; Case 21
 ; TESTS: Does Claim Level Provider Exist: 1=YES
 ;        All procedures have a line level provider: 0=NO
 ;        One Line Level provider is most significant: 1=YES
 ; At least one line level provider matches the claim level provider: 0=NO
 ;        There is only one procedure without a line level provider: 0=NO
 ;
 ; ACTIONS: Transmit as is.
 ;
 Q
 ;
A10101   ; Case 22
 ; TESTS: Does Claim Level Provider Exist: 1=YES
 ;        All procedures have a line level provider: 0=NO
 ;        One Line Level provider is most significant: 1=YES
 ; At least one line level provider matches the claim level provider: 0=NO
 ;        There is only one procedure without a line level provider: 1=YES
 ;
 ; ACTIONS: Transmit as is.
 ;
 Q
 ;
A10110   ; Case 23
 ; TESTS: Does Claim Level Provider Exist: 1=YES
 ;        All procedures have a line level provider: 0=NO
 ;        One Line Level provider is most significant: 1=YES
 ; At least one line level provider matches the claim level provider: 1=YES
 ;        There is only one procedure without a line level provider: 0=NO
 ;
 ; Remove the claim lines associated with the claim level provider.
 D REMOVELN
 ;
 Q
 ;
A10111   ; Case 24
 ; TESTS: Does Claim Level Provider Exist: 1=YES
 ;        All procedures have a line level provider: 0=NO
 ;        One Line Level provider is most significant: 1=YES
 ; At least one line level provider matches the claim level provider: 1=YES
 ;        There is only one procedure without a line level provider: 1=YES
 ;
 ; Remove the claim lines associated with the claim level provider.
 D REMOVELN
 ;
 Q
 ;
A11000   ; Case 25
 ; TESTS: Does Claim Level Provider Exist: 1=YES
 ;        All procedures have a line level provider: 1=YES
 ;        One Line Level provider is most significant: 0=NO
 ; At least one line level provider matches the claim level provider: 0=NO
 ;        There is only one procedure without a line level provider: 0=NO
 ;
 S STATUS="0^CASE 25 ERROR"
 ;
 Q
 ;
A11001   ; Case 26 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
A11010   ; Case 27
 ; TESTS: Does Claim Level Provider Exist: 1=YES
 ;        All procedures have a line level provider: 1=YES
 ;        One Line Level provider is most significant: 0=NO
 ; At least one line level provider matches the claim level provider: 1=YES
 ;        There is only one procedure without a line level provider: 0=NO
 ;
 ; Remove the claim lines associated with the claim level provider.
 D REMOVELN
 ;
 Q
 ;
A11011   ; Case 28 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
A11100   ; Case 29
 ; TESTS: Does Claim Level Provider Exist: 1=YES
 ;        All procedures have a line level provider: 1=YES
 ;        One Line Level provider is most significant: 1=YES
 ; At least one line level provider matches the claim level provider: 0=NO
 ;        There is only one procedure without a line level provider: 0=NO
 ;
 S STATUS="0^CASE 29 ERROR"
 ;
 Q
 ;
A11101   ; Case 30 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
A11110   ; Case 31
 ; TESTS: Does Claim Level Provider Exist: 1=YES
 ;        All procedures have a line level provider: 1=YES
 ;        One Line Level provider is most significant: 1=YES
 ; At least one line level provider matches the claim level provider: 1=YES
 ;        There is only one procedure without a line level provider: 0=NO
 ;
 ; Remove the claim lines associated with the claim level provider.
 D REMOVELN
 ;
 Q
 ;
A11111   ; Case 32 - This case can never happen!
 ; ACTIONS: N/A - Transmit as is.
 Q
 ;
CINIT1    ; Claim level initiation
 S IBIEN=$O(INPUT("L-PROV",0))
 I IBIEN="" S IBIEN=$O(INPUT("PROVINF",0))
 I IBIEN="" S IBIEN=$O(INPUT("LAB/FAC",0))
 Q
 ;
CINIT2    ; Claim level initiation
 N MODEX,PRNUMX,PROVX
 F MODEX="C","O" D
 . S PRNUMX=0 F  S PRNUMX=$O(INPUT("PROVINF",IBIEN,MODEX,PRNUMX)) Q:+PRNUMX=0  D
 .. I $G(INPUT("PROVINF",IBIEN,MODEX,PRNUMX))="" Q
 .. I INPUT("PROVINF",IBIEN,MODEX,PRNUMX)=INSLEVEL S CMODE(INSLEVEL)=MODEX,CPRNUM(INSLEVEL)=PRNUMX
 Q
 ;
LINIT1(SLC)    ; Line level initiation
 Q $O(INPUT("L-PROV",IBIEN,SLC))
 ;
LINIT2    ; Line level initiation
 N MODEX,PRNUMX,PROVX
 F MODEX="C","O" D
 . S PRNUMX=0 F  S PRNUMX=$O(INPUT("L-PROV",IBIEN,SLC,MODEX,PRNUMX)) Q:+PRNUMX=0  D
 .. I INPUT("L-PROV",IBIEN,SLC,MODEX,PRNUMX)=INSLEVEL S LMODE(INSLEVEL)=MODEX,LPRNUM(INSLEVEL)=PRNUMX
 Q
 ;
REMOVELN    ; Remove the claim lines associated with the claim level provider.
 N MODEX,PRNUMX,PROVX
 S SLC=0 F  S SLC=$O(OUTPUT("L-PROV",IBIEN,SLC)) Q:+SLC=0  D
 . F MODEX="C","O" D
 .. S PRNUMX=0 F  S PRNUMX=$O(OUTPUT("L-PROV",IBIEN,SLC,MODEX,PRNUMX)) Q:+PRNUMX=0  D
 ... Q:$G(PROVINFO)=""
 ... I $G(OUTPUT("L-PROV",IBIEN,SLC,MODEX,PRNUMX,PRTYPE))=PROVINFO D
 .... K OUTPUT("L-PROV",IBIEN,SLC,MODEX,PRNUMX,PRTYPE)
 .... I $D(OUTPUT("L-PROV",IBIEN,SLC,MODEX,PRNUMX))=1 K OUTPUT("L-PROV",IBIEN,SLC,MODEX,PRNUMX)
 .... I $D(OUTPUT("L-PROV",IBIEN,SLC,MODEX))=1 K OUTPUT("L-PROV",IBIEN,SLC,MODEX)
 .... I $D(OUTPUT("L-PROV",IBIEN,SLC))=1 K OUTPUT("L-PROV",IBIEN,SLC)
 Q
