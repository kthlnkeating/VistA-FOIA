RMPOLF1 ;HIN CIOFO-DRIVER FOR HO LETTERS ;7/8/98
 ;;3.0;PROSTHETICS;**29**;Feb 09, 1996
NAME ;
 S RMPRNAME=$P(RMPRNAME," ",1,2) K RMPRVIEW,RMPRPRIN
 I $P(VADM(5),U)["M" S ^TMP($J,"DW",19,0)="|TAB|"_"Dear Mr. "_RMPRNAME_":"
 E  S ^TMP($J,"DW",19,0)="|TAB|"_"Dear Ms. "_RMPRNAME_":"
 S RV=21 F RI=0:0 S RI=$O(^RMPR(665.2,RMPRFA,1,RI)) Q:RI'>0  Q:^(RI,0)'=" "
 S RI=RI-1 F  S RI=$O(^RMPR(665.2,RMPRFA,1,RI)) Q:RI'>0  S TAB=$S($P(^RMPR(665.2,RMPRFA,1,RI,0),U)["|TAB|":"",1:"|TAB|") S ^TMP($J,"DW",RV,0)=TAB_^(0),RV=RV+1
 I $G(RMPRTFLG) G SETALL^RMPOLF2
EDIT S DIC="^TMP($J,""DW""," D EN^DIWE S RMPRFLAG=1
EDIT1 S %=1 W !,"Do you wish to view this letter" D YN^DICN
 I %<0 G END
 I %=0 W !,"Answer `YES` to view the letter, `NO` to not" G EDIT1
 I %=1 G:$G(RMPRPRIN)'="" PRINT S RMPRPRIN=1,RMPRVIEW=1 G SET^RMPOLF2
ASK ;
 S %=1 W !,"Do you wish to accept this letter" D YN^DICN
 I %<0 G END
 I %=0 W !,"Answer `YES` or `NO`" G ASK
 I %=2 G ASK2
 K RMPRVIEW G:$D(RMPRPRIN) PRINT G SET^RMPOLF2
ASK2 ;DECIDES TO KEEP EDITING LETTER OR DELETE IT
 ; ALREADY SAID NOT TO ACCEPT LETTER
 S %=2 W !,"Do you wish to Delete this letter" D YN^DICN
 I %=1!(%<0) D  Q
 .I $G(RMPRIN)'>0 W $C(7),!!,?35,"Letter Deleted..." D END  Q
 .I $D(^RMPR(665.4,RMPRIN,0)) D DEL^RMPOLF1
 .W $C(7),!!,?35,"Deleted..." H 1 Q
 I %=0 W !,"Enter `YES` to Delete this letter" G ASK2
 G EDIT
 ;
PRALL ;print all letter
 S DIC="^RMPR(665.4,",RMPRPG=0,DHD="[RMPR BLANK]-[RMPR PAGE]"
 S ZTSAVE("^TMP(""RL"",$J,")=""
 S DIS(0)="I $D(^TMP(""RL"",$J,1,D0))"
 S BY="@NUMBER",(TO,FR)="",FLDS="3",L=0,PG=2,DHIT="W @IOF"
 D EN1^DIP
 Q
 ;
PRINT ;VIEW LETTER
 I $G(RMPRIN)'>0 Q:$G(RMPRDA)'>0  S RMPRIN=RMPRDA
 S DFN=$P(^RMPR(665.4,RMPRIN,0),U)
 S RMPRTY=$P(^RMPR(665.4,RMPRIN,0),U,2)
 S RMPR1=^RMPR(665.2,RMPRTY,0)
 S DIC="^RMPR(665.4,",RMPRPG=0,DHD="[RMPR BLANK]-[RMPR PAGE]"
 S BY="@NUMBER",FR=RMPRIN,TO=RMPRIN,FLDS="3",L=0,PG=2
 ;next line is needed, if not a HOME device.
 D EN1^DIP I '$D(POP) S POP=0
 I POP S RMPRGO=$S($D(^RMPR(665.4,RMPRIN,0)):"DEL^RMPOLF1",1:"END^RMPOLF1") D @RMPRGO W ?9," Deleted..." S RMQUIT=1 Q
 G:$G(RMPRVIEW) ASK ;if only a view, go back and ask user to ACCEPT.
EXIT ;common exit point
 ;unlock letter and sets printed date and flag for the patient entry.
 L:$D(RMPRIN) -^RMPR(665.4,RMPRIN,0)
 S RMC=$S(RMPOLCD="A":"RMPOXBAT1",RMPOLCD="B":"RMPOXBAT2",RMPOLCD="C":"RMPOXBAT3",1:"") Q:RMC=""
 S DA(1)=RMPOXITE,DIK="^RMPR(669.9,"_RMPOXITE_","_""""_RMC_""""_","
 S DA=RMDA D ^DIK S RMPRNT=1
 S RMPI=$S(RMPOLCD="A":9,RMPOLCD="B":11,RMPOLCD="C":13,1:"")
 I RMPI S $P(^RMPR(665,DFN,"RMPOA"),U,RMPI)=DT,$P(^RMPR(665,DFN,"RMPOA"),U,RMPI+1)="P"
 K ^TMP("RL",$J,RMPOXITE,"RMPOLST",RMPOLCD,RMPONAM)
 K ^TMP("RL",$J,RMPOXITE,"LTR",RMPONAM)
 K %X,RMPRFFL,RMPRHED,RMPRPRIN,%Y,RMPRDEL,RMPRRVA,DIC,RMPRFA,KILL,DIE,DA,DR,DIK,RMPR1,RMPR2,RMPRDATE,RMPRIN,RMPRL,RMPRNAME,RMPRU,RMPRDELE,FR,RI,RV
 I '$D(RMPRCOMB)!('$D(RMPRFF)) K RMPREND,VADM,VAPA,VA,NAME,RMPRGO,NAME1,RMPRDEN,RMPRFLAG,RMPRNAM1,RMPRNAM2,RMPRFF,J,RP,RO,RZ D KVAR^VADPT
 K DIK,RMC,DA D ^%ZISC
 Q
DEL I $D(RMPRDELE) S %=2 W !,"Are you sure you want to delete this letter" D YN^DICN I %=0 W !,"Answer `YES` to Delete the letter, `NO` to exit" G DEL
 I $D(RMPRDELE),(%<0!(%=2)) G EXIT
 S DIK="^RMPR(665.4,",DA=RMPRIN D ^DIK G EXIT
END Q