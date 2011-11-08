PSXVND ;BIR/WPB,HTW,PWC-File Release Data at the Remote Facility ;10/29/98  2:13 PM
 ;;2.0;CMOP;**1,2,4,5,14,18,19,15,24,23,27,35,39,36,48,62,58**;11 Apr 97;Build 2
 ;Reference to ^PSDRUG( supported by DBIA #1983
 ;Reference to ^PSRX( supported by DBIA #1977
 ;Reference to ^PS(59 supported by DBIA #1976
 ;Reference to routine CP^PSOCP supported by DBIA #1974
 ;Reference to routine EN^PSOHLSN1 supported by DBIA #2385
 ;Reference to routine EN^RGEQ supported by DBIA #2382
 ;Reference to routine AUTOREL^PSOBPSUT supported by DBIA #4701
 ;Called by Taskman to handle release data
EN H 5 S CNT=1,FROM=XMFROM,ZTREQ="@"
 S DOMAIN=$S($P(XMFROM,"@",2)'="":"@"_$P(FROM,"@",2),$P(XMFROM,"@",2)="":"",1:""),XMSER="S."_XQSOP,TXMZ=XQMSG
 S (X,SITE,DA)=$$KSP^XUPARAM("INST"),DIC="4",DIQ(0)="IE",DR=99,DIQ="PSXUTIL" D EN^DIQ1 S HERE=$G(PSXUTIL(4,SITE,99,"I")) K DA,DIC,DIQ(0),DR
 F  X XMREC I $G(XMRG)'="" S TXMRG=XMRG G:$G(XMER)<0 EXIT1 D:$E(XMRG,1,3)["$RX" GET G:$E(XMRG,1,5)["$$END" MAIL D:$E(XMRG,1,4)["$LOT" LOT S:$E(XMRG,1,5)["$$VND" MSNUM=$P(XMRG,"^",3)
 G EXIT
GET Q:$G(XMRG)=""!($E(XMRG,1,3)'["$RX")
 K FACBAT,BAT,NDC,RELDT,STAT,REASON,XFILL,P515A,P515B,%,RR,ALOT,RXP,RXN,FLAG,FILL,RELD,ZSTAT,RTN,CARRIER,PKGID,SHPDT
 S RX=$P(XMRG,U,2),FACBAT=$P(XMRG,U,3),BAT=$P(FACBAT,"-",2),NDC=$P(XMRG,U,4),RELDT=$P(XMRG,U,5),STAT=$P(XMRG,U,6),REASON=$P($G(XMRG),U,8),XFILL=$P($G(XMRG),U,7)
 S P515A=$P(XMRG,U,9),P515B=$P(XMRG,U,10),DRG=$P(XMRG,U,12),QTY=$P(XMRG,U,11),CARRIER=$P(XMRG,U,13),PKGID=$P(XMRG,U,14),SHPDT=$P(XMRG,U,15)
 S FAC=$P(FACBAT,"-",1)
 Q:FAC'=HERE
 I '$O(^PSRX("B",RX,0)) S FLAG=2 D TMP Q
 S XX=0 F  S XX=$O(^PSRX("B",RX,XX)) Q:XX'>0  S (RXP,RXN)=XX,FLAG=0 D
 .I '$G(BAT) Q
 .I '$D(^PSRX(RXN,0)) S FLAG=2 D TMP Q
 .L +^PSRX(RXN):DTIME I '$T S FLAG=2 D TMP Q
 .I XFILL>0,('$D(^PSRX(RXN,1,XFILL,0))) S FLAG=6 D TMP Q
 .I XFILL>0,($P(^PSRX(RXP,1,XFILL,0),"^",18)'="") S FLAG=1,RLDT=$P(^PSRX(RXP,1,XFILL,0),"^",18) S:STAT=1&(RLDT=RELDT) FLAG=0 D:FLAG=0 TMP1 Q:'$G(FLAG)  D:FLAG=1 TMP Q
 .I XFILL=0,($P(^PSRX(RXP,2),"^",13)'="") S FLAG=1,RLDT=$P(^PSRX(RXP,2),"^",13) S:STAT=1&(RELDT=RLDT) FLAG=0 D:FLAG=0 TMP1 Q:'$G(FLAG)  D:FLAG=1 TMP Q
 .I STAT=2 D
 ..S RXDRG=$P(^PSRX(RXN,0),"^",6),DFN=$P(^PSRX(RXN,0),"^",2)
 ..I $G(RXDRG)]"" S CMOPNM=$P($G(^PSDRUG(RXDRG,0)),"^")
 ..I '$D(^PSDRUG("AQ",RXDRG)) S CMOPYN=1
 ..I $D(^PSDRUG(RXDRG,"ND")) S CMOPID=$P($G(^PSDRUG(RXDRG,"ND")),"^",10)
 ..S DIV=$S(XFILL=0:$P(^PSRX(RXN,2),U,9),XFILL>0:$P(^PSRX(RXN,1,XFILL,0),U,9),1:"")
 ..S ^TMP("PSXCAN1",$J,DIV,DFN,RX)=$G(CMOPNM)_U_$G(CMOPID)_U_$G(QTY)_U_$G(DRG)_U_$G(CMOPYN)_U_REASON_U_$G(XFILL)_U_$G(BAT)
 ..K CMOPNM,CMOPID,DRG,RXDRG,MATCH,CMOPYN,NDF1,NDF2,P1,P2,PSDDA
 .I '$D(^PSRX(RXN,4,0)) S FLAG=5 D TMP Q
 .I '$D(^PSRX(RXN,4,"B",BAT)) S FLAG=4 D TMP Q
 .I $D(^PSRX(RXN,4,"B",BAT)) S RECD=$O(^PSRX(RXN,4,"B",BAT,"")),FILL=$P($G(^PSRX(RXN,4,RECD,0)),U,3),ZSTAT=$P(^PSRX(RXN,4,RECD,0),U,4)
 .I ZSTAT=2 S RTN=0 F  S RTN=$O(^PSRX(RXN,4,RTN)) Q:RTN'>0  I $P(^PSRX(RXN,4,RTN,0),U,3)=FILL&($P(^PSRX(RXN,4,RTN,0),U,1)'=BAT) S DA(1)=RXN,DA=RTN,DIE="^PSRX("_DA(1)_",4,",DR="3////2;8////FILLED IN TRANSMISSION "_BAT D ^DIE K DA,DR,DIE
 .I FILL'=XFILL S FLAG=3 D TMP Q
 .S PSXREF=FILL
 .Q:FLAG>0
 .S PSXXMZ=XMZ
 .D:$G(STAT)=1
 ..N PSOPAR,PSOSITE,X D NOW^%DTC
 ..I $G(PSXREF)>0 S PSOSITE=$P(^PSRX(RXP,1,PSXREF,0),"^",9) G:$G(PSOSITE) PAR
 ..S PSOSITE=$P(^PSRX(RXP,2),"^",9),PSQUIT=0
 ..I '$G(PSOSITE) S Z1=0 F  S Z1=$O(^PS(59,Z1)) Q:Z1=""!(Z1="B")  D  Q:PSQUIT
 ...I $D(^PS(59,Z1,"I"))&($P($G(^PS(59,Z1,"I")),"^")'="") Q:$P($G(^PS(59,Z1,"I")),"^")'>X
 ...S PSOSITE=Z1,PSQUIT=1
 ..Q:'$G(PSOSITE)
PAR ..S PSOPAR=$G(^PS(59,PSOSITE,1))
 ..I $G(PSXREF)>0 S YY=PSXREF
 ..I '$G(PSOSITE)!('$D(PSOPAR)) Q
 ..D CP^PSOCP K YY,X
 .S XMZ=PSXXMZ
 .I $G(FILL)="" Q
 .I $G(STAT)=1 D
 ..I FILL=0 S DA=RXN,DIE="^PSRX(",DR="31///"_RELDT D ^DIE K DIE,DA,DR
 ..I FILL>0 S DA(1)=RXN,DA=FILL,DIE="^PSRX("_RXN_",1,",DR="17///"_RELDT_";10.1///"_RELDT D ^DIE K DIE,DR,DA
 ..; I $$VERSION^XPDUTL("OUTPATIENT PHARMACY")<7 S X="RGEQ" X ^%ZOSF("TEST") I  D EN^RGEQ("RX",RXN)  ;CIRN
 ..I $$VERSION^XPDUTL("OUTPATIENT PHARMACY")>6 D EN^PSOHLSN1(RXN,"ZD")
 .S DA(1)=RXN,DA=RECD,DIE="^PSRX("_RXN_",4,"
 .S DR="3////"_$S(STAT=2:3,STAT=1:1,1:"")_";4////"_NDC_";5////"_$S(STAT=2:RELDT,STAT=1:"",1:"")_";8////"_$S(STAT=2:"^S X=$G(REASON)",STAT=1:"",1:"")_";10////"_$G(CARRIER)_";11////"_$G(PKGID)_";9////"_$G(SHPDT)
 .D ^DIE K DIE,DA,DR
 .I $$PATCH^XPDUTL("PSO*7.0*148") D AUTOREL^PSOBPSUT(RXN,FILL,RELDT,NDC,"C",$S(STAT=1:"S",1:"U"),60)
 I $D(^PSRX(RXN)) L -^PSRX(RXN):0
TMP1 Q:$G(FLAG)'=0!('$G(BAT))
 D NOW^%DTC S PSXTM=%
 S ^TMP($J,"PSXREL",CNT)=RX_"^"_PSXTM_"^"_P515A_"^"_P515B_"^"_XFILL_"^"_HERE
 S CNT=CNT+1
 Q
 ;
LOT S ALOT=$P(XMRG,"|",2)
 I $G(ALOT)'="" D
 .K DD,DO
 .S:'$D(^PSRX(RXN,5,0)) ^PSRX(RXN,5,0)="^52.0401A^^"
 .F RR=1:1 Q:$P(ALOT,"\",RR)=""  S LOT1=$P(ALOT,"\",RR),LOT=$P(LOT1,"^",1),EXDT=$P(LOT1,"^",2) D
 ..S DA(1)=RXN,X=LOT,DIC="^PSRX("_RXN_",5,",DIC("DR")="1////"_EXDT_";2////"_XFILL,DIC(0)="Z"
FF ..D FILE^DICN K DIC("DR"),DIC,DA,LOT,EXDT,DD,DO
 Q
TMP S ^TMP($J,"PSXVND",RX)=FLAG_"^"_XFILL_"^"_P515A_"^"_P515B_"^"_HERE_"^"_$S(FLAG=1:RLDT,1:"") Q
MAIL S XMSUB="CMOP Release Data Acknowledgement",LCNT=1,XMDUZ=.5
MM D XMZ^XMA2 G:XMZ<1 MM
 S ^XMB(3.9,XMZ,2,LCNT,0)="$$RTN^"_MSNUM_"^"_HERE,LCNT=LCNT+1
 F CC=0:0 S CC=$O(^TMP($J,"PSXREL",CC)) Q:CC'>0  D
 .S ^XMB(3.9,XMZ,2,LCNT,0)="$RX^"_$G(^TMP($J,"PSXREL",CC)),LCNT=LCNT+1
 S ^XMB(3.9,XMZ,2,LCNT,0)="$$INV"
 S CC="" F  S CC=$O(^TMP($J,"PSXVND",CC)) Q:CC=""  S RXN=CC D
 .S LCNT=LCNT+1 D NOW^%DTC S PSXTM=%   ;added for PSX*2*36
 .S ^XMB(3.9,XMZ,2,LCNT,0)="$RXN"_"^"_RXN_"^"_$G(^TMP($J,"PSXVND",CC))_"^"_PSXTM
 S ^XMB(3.9,XMZ,2,LCNT+1,0)="$$ENDINV"
 S ^XMB(3.9,XMZ,2,0)="^3.92A^"_LCNT_U_LCNT_U_DT,XMDUN="CMOP Manager"
 K XMY S XMY("S.PSXX CMOP SERVER"_DOMAIN)="" D ENT1^XMD
 ;D ER6^PSXERR Q
 D:$D(^TMP("PSXCAN1",$J)) CAN^PSXMSGS
EXIT S XMSER="S.PSXX CMOP SERVER",XMZ=TXMZ D REMSBMSG^XMA1C
EXIT1 K XMSUB,XMDUZ,XMDUN,XMY,LCNT,XMZ,CC,PSXREL,CNT,Y,X,RR,LOT,LOT1,EXDT,ALOT
 K RXN,RX,DLAYGO,FACBAT,FILL,FROM,NDC,P514,REASON,RELDT,STAT,XMREC,XMRG
 K ^TMP($J,"PSXVND"),^TMP($J,"PSXREL"),RLDT,FLAG,TXMRG,PSXXMZ,ZSTAT,PSXTM
 K XQMSG,XQSOP,XX,ZZZ,%,DAT,DOMAIN,PSXJOB,PSXREF,RECD,RXP,TXMZ,XMZ,XMER
 K XMFROM,XMSER,BAT,PSXREFL,XFILL,FAC,HERE,P515A,P515B,SITE,MSNUM
 K DIQ,DIV,QTY,PSXUTIL,SHPDT,Z1,PSQUIT
 Q