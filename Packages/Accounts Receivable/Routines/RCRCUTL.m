RCRCUTL ;ALB/CMS - RC REFERRAL UTILITY PROGRAM ; 16-JUN-00
V ;;4.5;Accounts Receivable;**63,159**;Mar 20, 1995
 ;;Per VHA Directive 10-93-142, this routine should not be modified.
 Q
 ;
BN ;User Select an AR Bill No.
 ;Returns PRCABN if exists
 N DIC,DA,X,Y,%Y
BNA S DIC="^PRCA(430,",DIC(0)="AEQMZ"
 S DIC("S")="I $P(^(0),U,8)=16,$P($G(^PRCA(430.2,+$P(^(0),U,2),0)),U,6)=""T"""
 D ^DIC S PRCABN=+Y
 I $G(PRCABN)<0 K PRCABN
BNQ Q
 ;
BNVAR(PRCABN) ;Set PRCA( array with bill information
 ;Returns PRCA(
 N PRCABN0
 I '$G(PRCABN) G BNVARQ
 S PRCABN0=$G(^PRCA(430,PRCABN,0))
 S PRCA("BNAME")=$P(PRCABN0,U,1)
 S PRCA("CAT")=$P(PRCABN0,U,2)_"^"_$P($G(^PRCA(430.2,+$P(PRCABN0,U,2),0)),U,1,2)
 S PRCA("STATUS")=$P(PRCABN0,U,8)_"^"_$P($G(^PRCA(430.3,+$P(PRCABN0,U,8),0)),U,1,2)
BNVARQ Q
 ;
DEBT(PRCABN) ;Get Debtor Name and Address
 ;Send Bill Number
 ;Return PRCA( array nodes: DEBTNM, DEBTOR, DEBTCT, DEBTZIP, DEBTST,
 ;                          DEBTAD1, DEBTAD2, DEBTADD
 N PRCACT,PRCAKP,PRCAST,PRCAST1,PRCAST2,X,Y,%Y
 K PRCA("DEBTNM"),PRCA("DEBTOR"),PRCA("DEBTCT"),PRCA("DEBTZIP")
 K PRCA("DEBTST"),PRCA("DEBTAD1"),PRCA("DEBTAD2"),PRCA("DEBTADD")
 I '$G(PRCABN) G DEBTQ
 D DEBTOR^PRCAUTL
 I $G(PRCA("DEBTNM"))="" G DEBTQ
 S PRCA("DEBTCT")=$G(PRCACT,"UNK")
 S PRCA("DEBTZIP")=$G(PRCAKP,"UNK")
 S PRCA("DEBTST")=$G(PRCAST,"UNK")
 S PRCA("DEBTAD1")=$G(PRCAST1)
 S PRCA("DEBTAD2")=$G(PRCAST2)
 S PRCA("DEBTADD")=$G(X)
DEBTQ Q
 ;
PT(DFN) ;Get Patient information
 ;Return values in arrays: VA(, VADM(, VAPD(
 K VA,VADM,VAPD
 I '$D(^DPT(+$G(DFN),0)) G PTQ
 D DEM^VADPT,ADD^VADPT
PTQ Q
 ;
RCDOM() ;Get supporting RC Domain
 ;Returns Domain Name
 N X
 ;S X=$O(RCDIV(0))
 ;I +X S X=$P($G(RCDIV(+X)),U,6)
 ;I X]"" G RCDOMQ
 S X=$O(^RCT(349.1,"B","RC",0))
 S X=$P($G(^RCT(349.1,+X,3)),U,4)
RCDOMQ Q X
 ;
RCCAT(ARRAY) ;Get array of valid AR/RC Bill Categories
 ;Send back ARRAY(IEN)=x^AR Category Name
 ; x = 1 = Reconciliation, Referral and Follow-up
 ; x = 2 = Reconciliation Only
 S ARRAY(6)="2^"_$P(^PRCA(430.2,6,0),U,1)
 S ARRAY(7)="2^"_$P(^PRCA(430.2,7,0),U,1)
 S ARRAY(9)="1^"_$P(^PRCA(430.2,9,0),U,1)
 S ARRAY(10)="2^"_$P(^PRCA(430.2,10,0),U,1)
RCCATQ Q
 ;
REFST(PRCABN) ;Referral Status
 ;Return: If Referred date^code^amount
 ;        If not Referred 0
 N X S X=0
 I $P($G(^PRCA(430,PRCABN,0)),U,8)'=16 G REFSTQ
 S X=$P($G(^PRCA(430,PRCABN,6)),U,4,6)
 I 'X S X=0
REFSTQ Q X
 ;
RETN(PRCABN) ;Returned from RC/DOJ
 ;Return: If Return Date send Date
 ;        If not send 0
 N X S X=+$P($G(^PRCA(430,PRCABN,6)),U,11)
 Q X
 ;
ACTDT(PRCABN) ;Date account activated
 ;Return: Date account activated
 N X S X=0
 I '$G(PRCABN) G ACTDTQ
 S X=+$P($G(^PRCA(430,PRCABN,6)),"^",21) I X G ACTDTQ
 S X=+$P($G(^PRCA(430,PRCABN,9)),"^",3) I X G ACTDTQ
 S X=+$P($G(^PRCA(430,PRCABN,0)),"^",10)
ACTDTQ Q X
 ;
AEOB ;File 433 Cross-Ref on Transaction Type
 ;     -used to alert pending EOB processing when Payment in Part
 ;      transaction is created
 N PRCABN,RCAT
 I (X'=2)!(+$G(DA)<1) G AEOBQ
 S PRCABN=+$P($G(^PRCA(433,DA,0)),U,2) I 'PRCABN G AEOBQ
 I +$P($G(^PRCA(430,PRCABN,0)),U,2)'=9 G AEOBQ
 I $$REFST(PRCABN)=0 G AEOBQ
 S ^PRCA(433,"AEOB",PRCABN,DA)=""
AEOBQ Q
 ;
ECHK ;Check to see if pending EOB Code Processing exists
 I $O(^PRCA(433,"AEOB",0)) W !!,*7,"*** You have Referred TP Bills pending EOB Code processing ***"
ECHKQ Q
 ;
ADDR ;Regional Counsel Addresses and Death Notification addresses.
 ;;OGCBOSRI@MAIL.DOMAIN.EXT^OGCRegion1DeathNotification@mail.DOMAIN.EXT
 ;;OGCNYNRI@MAIL.DOMAIN.EXT^OGCRegion2DeathNotification@mail.DOMAIN.EXT
 ;;OGCBALRI@MAIL.DOMAIN.EXT^OGCRegion3DeathNotification@mail.DOMAIN.EXT
 ;;OGCPHIRI@MAIL.DOMAIN.EXT^OGCRegion4DeathNotification@mail.DOMAIN.EXT
 ;;OGCATLRI@MAIL.DOMAIN.EXT^OGCRegion5DeathNotification@mail.DOMAIN.EXT
 ;;OGCBAYRI@MAIL.DOMAIN.EXT^OGCRegion6DeathNotification@mail.DOMAIN.EXT
 ;;OGCCLERI@MAIL.DOMAIN.EXT^OGCRegion7DeathNotification@mail.DOMAIN.EXT
 ;;OGCNASRI@MAIL.DOMAIN.EXT^OGCRegion8DeathNotification@mail.DOMAIN.EXT
 ;;OGCJACRI@MAIL.DOMAIN.EXT^OGCRegion9DeathNotification@mail.DOMAIN.EXT
 ;;OGCCHIRI@MAIL.DOMAIN.EXT^OGCRegion10DeathNotification@mail.DOMAIN.EXT
 ;;OGCDETRI@MAIL.DOMAIN.EXT^OGCRegion11DeathNotification@mail.DOMAIN.EXT
 ;;OGCSTLRI@MAIL.DOMAIN.EXT^OGCRegion12DeathNotification@mail.DOMAIN.EXT
 ;;OGCWACRI@MAIL.DOMAIN.EXT^OGCRegion13DeathNotification@mail.DOMAIN.EXT
 ;;OGCHOURI@MAIL.DOMAIN.EXT^OGCRegion14DeathNotification@mail.DOMAIN.EXT
 ;;OGCMINRI@MAIL.DOMAIN.EXT^OGCRegion15DeathNotification@mail.DOMAIN.EXT
 ;;OGCDENRI@MAIL.DOMAIN.EXT^OGCRegion16DeathNotification@mail.DOMAIN.EXT
 ;;OGCLOSRI@MAIL.DOMAIN.EXT^OGCRegion17DeathNotification@mail.DOMAIN.EXT
 ;;OGCSFCRI@MAIL.DOMAIN.EXT^OGCRegion18DeathNotification@mail.DOMAIN.EXT
 ;;OGCPHORI@MAIL.DOMAIN.EXT^OGCRegion19DeathNotification@mail.DOMAIN.EXT
 ;;OGCPORRI@MAIL.DOMAIN.EXT^OGCRegion20DeathNotification@mail.DOMAIN.EXT
 ;;OGCBUFRI@MAIL.DOMAIN.EXT^OGCRegion21DeathNotification@mail.DOMAIN.EXT
 ;;OGCINDRI@MAIL.DOMAIN.EXT^OGCRegion22DeathNotification@mail.DOMAIN.EXT
 ;;OGCWINRI@MAIL.DOMAIN.EXT^OGCRegion23DeathNotification@mail.DOMAIN.EXT
 ;;END
 ;RCRCUTL
