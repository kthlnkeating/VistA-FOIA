GMRCPRPS ;SLC/DCM - List Manager GMRC Routine -- List GMRC (Consults/Request) Protocols in abbreviated form. ;5/20/98  14:20
 ;;3.0;CONSULT/REQUEST TRACKING;**1**;DEC 27, 1997
ENL ;List Manager Entry Point
 K ^TMP("GMRCR",$J,"PRS"),TMP
 W !,"Building Report: Please Wait..."
 S FILE="101",FIELDS=".01;1",FLAGS="EZ",TARGET="TMP",MSG="ERROR",TAB="",$P(TAB," ",30)=" ",GMRCCT=1,GMRCBXRF="GMRC"
 F  S GMRCBXRF=$O(^ORD(101,"B",GMRCBXRF)) Q:$E(GMRCBXRF,1,4)'["GMRC"!(GMRCBXRF="")  S IENS=0,IENS=$O(^ORD(101,"B",GMRCBXRF,IENS)) D GETS^DIQ(FILE,IENS,FIELDS,FLAGS,"TMP","ERMSG") D
 .S GMRCPNM=TMP(FILE,IENS_",",.01,"E"),GMRCTXT=TMP(FILE,IENS_",",1,"E")
 .S ^TMP("GMRCR",$J,"PRS",GMRCCT,0)=$E(GMRCPNM,1,39)_" "_$E(TAB,1,39-$L(GMRCPNM))_$E(GMRCTXT,1,40),GMRCCT=GMRCCT+1
 .K TMP Q
 S GMRCCT=GMRCCT-1
QUIT ;Kill off variables
 K ERMSG,FILE,FIELDS,FLAGS,TARGET,MSG,IENS,GMRCBXRF,GMRCPNM,GMRCTXT
 Q