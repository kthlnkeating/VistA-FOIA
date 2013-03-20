SDMAPI5 ;RGI/VSL - APPOINTMENT API; 3/20/13
 ;;5.3;scheduling;**260003**;08/13/93;
CHKTYPE(RETURN,DFN,TYPE) ; Check appointment type
 N PAT,ERR,ELIG,ATYP
 K RETURN S RETURN=0
 I '+$G(TYPE) D ERRX^SDAPIE(.RETURN,"INVPARAM","TYPE") Q 0
 I '$$TYPEXST^SDMDAL3(+TYPE) D ERRX^SDAPIE(.RETURN,"TYPNFND") Q 0
 D GETPAT^SDMDAL3(.PAT,+DFN,1) S ERR=0
 I PAT(.301)=""!('+PAT(.361)),+TYPE=11 S ERR=1
 I PAT(.301)="N",(+PAT(.302)>0)!(PAT(.361)=1)!(PAT(.361)=3),+TYPE=11 S ERR=1
 I PAT(.301)="Y",+PAT(.302)<50,PAT(.361)'=3,+TYPE=11 S ERR=1
 I PAT(.301)="Y",+PAT(.302)>49,PAT(.361)'=1,+TYPE=11 S ERR=1
 I ERR D ERRX^SDAPIE(.RETURN,"TYPINVSC") Q 0
 D GETELIG^SDMDAL2(.ELIG,PAT(.361),1)
 D GETAPPT^SDMDAL2(.ATYP,+TYPE,1)
 I '$G(ATYP(3)),$S($G(ELIG(4))["Y":1,1:$G(ATYP(5))),$S('$G(ATYP(6)):1,$D(PAT(361,+ATYP(6))):1,+PAT(.361)=ATYP(6):1,1:0) S RETURN=1
 I RETURN=0 D ERRX^SDAPIE(.RETURN,"TYPINVD") Q 0
 S RETURN=1
 Q 1
 ;
CHKSTYP(RETURN,TYPE,STYP) ; Check appointment subtype
 N LST,I,DL
 S DL="DILIST"
 K RETURN S RETURN=0
 I $G(STYP)="" S RETURN=1 Q 1
 I $G(STYP)]"",'+$G(STYP) D ERRX^SDAPIE(.RETURN,"INVPARAM","STYP") Q 0
 D LSTASTYP^SDMDAL2(.LST,,,,+$G(TYPE))
 F I=0:0 S I=$O(LST(DL,2,I)) Q:I=""  D
 . I LST(DL,2,I)=+STYP,LST(DL,"ID",I,.03)="YES" S RETURN=1
 I 'RETURN D ERRX^SDAPIE(.RETURN,"STYPNFND") Q 0
 Q 1
 ;
CHKSRT(RETURN,SRT) ; Check scheduling request type
 N LST,I,DL
 K RETURN S RETURN=0
 I $G(SRT)="" D ERRX^SDAPIE(.RETURN,"INVPARAM","SRT") Q 0
 S %=$$LSTSRT^SDMAPI1(.LST)
 F I=0:0 S I=$O(LST(I)) Q:I=""!RETURN  D
 . I $P(LST(I),U)=$P(SRT,U) S RETURN=1
 I 'RETURN D ERRX^SDAPIE(.RETURN,"SRTNFND") Q 0
 Q 1
 ;
CHKLABS(RETURN,SD,CLN,TEST,DFN) ; Check tests date
 N APT,SD1
 K RETURN S RETURN=0
 I $G(@TEST)="" S RETURN=1 Q 1
 I +$G(@TEST)'>0 D ERRX^SDAPIE(.RETURN,"INVPARAM",$G(TEST)) Q 0
 S SD1=+$G(@TEST)
 I SD1=SD D ERRX^SDAPIE(.RETURN,"TSTAHAPT",CLN(.01)) Q 0
 S %=$$GETAPTS^SDMAPI1(.APT,DFN,SD1)
 I $D(APT("APT",SD1)),("I"[$P($G(APT("APT",SD1,"STATUS")),U,1)) D  Q 0
 . D ERRX^SDAPIE(.RETURN,"TSTAHAPT",$P(APT("APT",SD1,"CLINIC"),U,2))
 S RETURN=1
 Q 1
 ;
CHKCONS(RETURN,CONS) ; Check request/consultation
 N REQ
 K RETURN S RETURN=0
 I $G(CONS)="" S RETURN=1 Q 1
 I +$G(CONS)'>0 D ERRX^SDAPIE(.RETURN,"INVPARAM",$G(TEST)) Q 0
 I '$$CNSEXST^SDMEXT(+CONS) D ERRX^SDAPIE(.RETURN,"CNSNFND") Q 0
 S RETURN=1
 Q 1
 ;
LSTASTYP(RETURN,SEARCH,START,NUMBER,TYPE) ; List appointment subtypes
 N LST,FLDS
 M LST=RETURN
 D LSTASTYP^SDMDAL2(.LST,$$UP^XLFSTR($G(SEARCH)),.START,$G(NUMBER),+$G(TYPE))
 K RETURN
 S FLDS(.02)="NAME",FLDS(.03)="STATUS"
 D BLDLST^SDMAPI(.RETURN,.LST,.FLDS)
 S RETURN=1
 Q RETURN
 ;
DOW(SD) ;
 N Y,%
 S %=$E(SD,1,3),Y=$E(SD,4,5),Y=Y>2&'(%#4)+$E("144025036146",Y)
 F %=%:-1:281 S Y=%#4=1+1+Y
 S Y=$E(SD,6,7)+Y#7
 Q Y
 ;
SETST(RETURN,SC,SD) ;
 N SDD,ST,PATT,CLN,DATA,SI,DOW
 K RETURN S RETURN=0
 S SDD=$P(+SD,".",1)
 S ST=$$GETDST^SDMDAL1(+SC,SDD)
 I $G(ST)']"" D  Q:RETURN=0 0
 . S DOW=$$DOW(+SD)
 . D GETDPATT^SDMDAL1(.PATT,+SC,SDD,DOW)
 . I PATT("IEN")'>0!($G(PATT("PAT"))="") D ERRX^SDAPIE(.RETURN,"APTWHEN") Q
 . S ST=PATT("PAT")
 . S CLN(1917)=""
 . D GETCLNX^SDMDAL1(.CLN,+SC)
 . S SI=CLN(1917),SI=$S(SI="":4,SI<3:4,SI:SI,1:4)
 . S ST=$E($P($T(DAY),U,DOW+2),1,2)_" "_$E(+SD,6,7)_$J("",SI+SI-6)_ST
 . S DATA(.01)=SDD,DATA(1)=ST
 . D ADDPATT^SDMDAL1(.DATA,+SC,SDD)
 . S RETURN=1
 S RETURN=1
 Q 1
DAY ;;^SUN^MON^TUES^WEDNES^THURS^FRI^SATUR
 ;
