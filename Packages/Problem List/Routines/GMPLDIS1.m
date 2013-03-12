GMPLDIS1 ; SLC/MKB -- Displays current/default values for saving ;03/11/13
 ;;2.0;Problem List;**260002**;Aug 25, 1994
ACCEPT(GMPFLD) ; accept current values of problem to save?
 N DIR,X,Y D DISPLAY W !
 S DIR(0)="SAOM^S:SAVE;E:EDIT;Q:QUIT;",DIR("B")="SAVE"
 D BLD^DIALOG(1250000.147,,,"DIR(""A"")")
 S DIR("?")="^D HELP^GMPLDIS1"
 D ^DIR I $D(DUOUT)!($D(DTOUT))!(Y="Q") Q "^"
 Q $S(Y="S":1,1:0)
HELP ; help msg for $$ACCEPT, redisplay values
 N DIR
 S DIR(0)="EA"
 D BLD^DIALOG(1250000.148,,,"DIR(""A"")")
 D ^DIR
 D DISPLAY
 Q
DISPLAY ; display current values for problem in GMPFLD array
 N SP,I,NTS,CMMT,TEXT,PROB S NTS=0,(SP,CMMT)="" Q:$D(GMPFLD)'>9
 F I=1.11,1.12,1.13 S:$P(GMPFLD(I),U) SP=SP_$P(GMPFLD(I),U,2)_U
 S:$L(SP) SP=$E(SP,1,$L(SP)-1) ; strip final "^"
 F I=0:0 S I=$O(GMPFLD(10,"NEW",I)) Q:I'>0  S:$L(GMPFLD(10,"NEW",I)) NTS=NTS+1
 I NTS S CMMT=$$EZBLD^DIALOG($S(NTS=1:1250000.149,1:1250000.150),NTS)
 S PROB=$P(GMPFLD(.05),U,2)
 I $L(PROB)'>68 S TEXT(1)=PROB,TEXT(2)=CMMT,TEXT=2
 I $L(PROB)>68 S:NTS PROB=PROB_" "_CMMT D WRAP^GMPLX(PROB,65,.TEXT)
DIS1 D EN^DDIOL("","","!!")
 D:'VALMCC EN^DDIOL($$REPEAT^XLFSTR("-",79),"","")
 D EN^DDIOL($$EZBLD^DIALOG(1250000.151,TEXT(1)))
 F I=2:1:TEXT D EN^DDIOL("           "_TEXT(I))
 D EN^DDIOL($$EZBLD^DIALOG(1250000.152,$P(GMPFLD(.13),U,2)))
 D:GMPVA EN^DDIOL($$EZBLD^DIALOG(1250000.153,$P(GMPFLD(1.1),U,2)),"","?51")
 D EN^DDIOL($$EZBLD^DIALOG(1250000.154,$P(GMPFLD(.12),U,2)))
 I $P(GMPFLD(.12),U)="A",$L(GMPFLD(1.14)) D EN^DDIOL("/"_$P(GMPFLD(1.14),U,2),"","?0")
 I $P(GMPFLD(.12),U)="I",$L(GMPFLD(1.07)) D EN^DDIOL($$EZBLD^DIALOG(1250000.155,$P(GMPFLD(1.07),U)),"","?0")
 D:GMPVA EN^DDIOL($$EZBLD^DIALOG(1250000.156,$S('$L(SP):$$EZBLD^DIALOG(1250000.157),1:$P(SP,U))),"","?55")
 D EN^DDIOL($$EZBLD^DIALOG(1250000.165,$P(GMPFLD(1.05),U,2)))
 D:$L(SP,U)>1 EN^DDIOL($P(SP,U,2),"","?65")
 I $E(GMPLVIEW("VIEW"))="S" D EN^DDIOL($$EZBLD^DIALOG(1250000.158,$P(GMPFLD(1.06),U,2)))
 E  D EN^DDIOL($$EZBLD^DIALOG(1250000.159,$P(GMPFLD(1.08),U,2)))
 D:$L(SP,U)>2 EN^DDIOL($P(SP,U,3),"","?65")
 N PAR,MSG
 S PAR(1)=$P(GMPFLD(1.09),U,2)
 S PAR(2)=$P(GMPFLD(1.04),U,2)
 D BLD^DIALOG(1250000.160,.PAR,,"MSG")
 D EN^DDIOL(.MSG)
 I $$KCHK^XUSRB("GMPL ICD CODE") D EN^DDIOL($$EZBLD^DIALOG(1250000.161,$P(GMPFLD(.01),U,2)),"","?55")
 D:'VALMCC EN^DDIOL($$REPEAT^XLFSTR("-",79))
 Q
