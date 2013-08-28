GMPLDUP2 ;SLC/JVS -- Duplicate Problem #3;08/28/13
 ;;2.0;Problem List;**12,260002**;Aug 25, 1994
 ;
 ;VARIABLES:
 ;PATIENT  = Pointer to the PATIENT/IHS #9000001
 ;IEN,IFN  = IEN of problem in PROBLEM #9000011
 ;ICD      = Pointer to ICD DIAGNOSIS # 80
 ;PROBLEM  = Pointer to EXPRESSIONS #757.01
 ;FLAG     = Used to exit program
 ;^TMP("GMPLDUP",$J) = Storage of located duplicates
 ;^TMP("GMPLD",$J)      = Temporary storage for duplicates
 ;DUPLICAT= Local array of Current Duplicate being examined
 ;
 Q
TASK ;-TASK JOB
 S ZTRTN="EN^GMPLDUP2"
 S ZTDESC="Hide Duplicate Problem for GMPL*2*12"
 S ZTDTH=$H
 S ZTSAVE=("DUZ")
 S ZTIO=""
 D ^%ZTLOAD
 I $D(ZTSK) D BMES^XPDUTL("Task Number: "_$G(ZTSK))
 I '$D(ZTSK) D BMES^XPDUTL("TASK JOB DID NOT RUN!")
 I '$D(ZTSK) D MES^XPDUTL("Start Task with  D TASK^GMPLDUP2")
 ;
 Q
 ;
EN ; Official entry point
 ;
 D SEARCH
 D CLASS2
 D EXIT
SEARCH ;Search for possible duplicates and locate in ^TMP("GMPLDUP")
 ;S TOTAL=$P(^AUPNPROB(0),"^",3)
 N PATIENT,IEN,ICD,PROBLEM,CNT,CNTR
 K ^TMP("GMPLD",$J)
 S PATIENT=0,ICD=0,PROBLEM=0,CNT=0,CNTR=0
 F  S PATIENT=$O(^AUPNPROB("AC",PATIENT)) Q:PATIENT=""  D  K ^TMP("GMPLD",$J)
 .S IEN=0 F  S IEN=$O(^AUPNPROB("AC",PATIENT,IEN)) Q:IEN=""  D
 ..Q:$P($G(^AUPNPROB(IEN,1)),"^",2)="H"
 ..S ICD=$P($G(^AUPNPROB(IEN,0)),"^",1)
 ..S PROBLEM=$P($G(^AUPNPROB(IEN,1)),"^",1)
 ..S CNT=CNT+1
 ..I '$D(^TMP("GMPLD",$J,PATIENT,ICD,PROBLEM)) D
 ...S ^TMP("GMPLD",$J,PATIENT,ICD,PROBLEM,IEN)=""
 ..E  S ^TMP("GMPLDUP",$J,PATIENT,ICD,PROBLEM,IEN)="",^TMP("GMPLDUP",$J,PATIENT,ICD,PROBLEM,$O(^TMP("GMPLD",$J,PATIENT,ICD,PROBLEM,0)))="" S CNTR=CNTR+1
 Q
CLASS2 ;Eliminate Class 2 Duplicates
 ;
SET2 N IFN,DUPLICAT,PATIENT,ICD,PROBLEM,FLAG,PN,CONDITIO,STATUS
 N FACILITY,GMPLC1,DOC
 S PATIENT=0,FLAG=1,CNT=0,CONDITIO=""
 ;
FIND2 ;
 F  S PATIENT=$O(^TMP("GMPLDUP",$J,PATIENT)) Q:PATIENT=""  D
 .S ICD=0 F  S ICD=$O(^TMP("GMPLDUP",$J,PATIENT,ICD)) Q:ICD=""  D
 ..S PROBLEM=0 F  S PROBLEM=$O(^TMP("GMPLDUP",$J,PATIENT,ICD,PROBLEM)) Q:PROBLEM=""  D  K GMPLC1
 ...S IFN=0 F  S IFN=$O(^TMP("GMPLDUP",$J,PATIENT,ICD,PROBLEM,IFN)) Q:IFN=""  D
 ....;---
 ....;-Look for notes
 ....Q:$D(^AUPNPROB(IFN,11,0))
 ....;-Look for Verified Problem
 ....Q:$P($G(^AUPNPROB(IFN,1)),"^",2)="P"
 ....;-Look for already hidden
 ....Q:$P($G(^AUPNPROB(IFN,1)),"^",2)="H"
 ....;---
 ....S PN=$P($G(^AUPNPROB(IFN,0)),"^",5)
 ....S STATUS=$P($G(^AUPNPROB(IFN,0)),"^",12)
 ....S CONDITIO=$P($G(^AUPNPROB(IFN,1)),"^",2)
 ....;---
 ....I '$D(GMPLC1(PN,STATUS,CONDITIO)) S GMPLC1(PN,STATUS,CONDITIO)=IFN
 ....E  S ^TMP("GMPLREM",$J,IFN)=""
 D HIDE2 Q
HIDE2 ;---Hide Duplicates and count them.
 N IFN,CNT,GMPIFN,%,RET
 S CNT=0
 S IFN=0 F  S IFN=$O(^TMP("GMPLREM",$J,IFN)) Q:IFN=""  D
 .S CNT=CNT+1
 .S GMPIFN=IFN
 .S %=$$DELETE^GMPLAPI2(.RET,GMPIFN,"")
 ;---Send Bulletin
 S XMB="GMPL DUPLICATE PROBLEMS"
 S XMDUZ=$P($$SITE^VASITE,"^",2)_" "_"GMPL*2*12"
 S XMY("SMITH,VAUGHN@ISC-SLC.DOMAIN.EXT")=""
 S XMY(DUZ)=""
 S XMB(1)=$G(CNT)
 D ^XMB
 ;----
 K ^TMP("GMPLREM",$J)
 Q
EXIT ;-KILLS GLOBALS AND EXITS
 K ^TMP("GMPLD",$J),^TMP("GMPLDUP",$J),^TMP("GMPLREM",$J)
 K CNT ;,TOTAL
