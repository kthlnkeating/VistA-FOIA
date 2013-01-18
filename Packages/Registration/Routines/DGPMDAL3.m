DGPMDAL3 ;RGI/VSL - PATIENT MOVEMENT DAL; 1/10/2013
 ;;5.3;Registration;**260003**;
GETPMVT(DATA,DFN,AFN,DGDT,MFN,FLDS) ; Get prior movement
 N X,PFN,DGX,AMVT
 D:$G(MFN)>0 GETMVT^DGPMDAL1(.AMVT,MFN,".01;.22")
 S DGX=$S($D(DGDT):DGDT,1:(AMVT(.01,"I")))+($G(AMVT(.22,"I"))/10000000)
 S X=$O(^DGPM("APMV",DFN,AFN,(9999999.9999999-DGX)))
 S PFN=$O(^DGPM("APMV",DFN,AFN,+X,0))
 D GETMVT^DGPMDAL1(.DATA,PFN,FLDS)
 S DATA("ID")=PFN
 Q
GETNMVT(DATA,DFN,AFN,DGDT,MFN,FLDS) ; Get next movement
 N X,NFN,DGX
 D:$G(MFN)>0 GETMVT^DGPMDAL1(.AMVT,MFN,".01;.22")
 S DGX=$S($D(DGDT):DGDT,1:(AMVT(.01,"I")))+($G(AMVT(.22,"I"))/10000000)
 S X=$O(^DGPM("APCA",DFN,AFN,+DGX))
 S PFN=$O(^(+X,0))
 D GETMVT^DGPMDAL1(.DATA,PFN,FLDS)
 S DATA("ID")=PFN
 Q
CANFOL(NMVT,PMVT) ; Can follow movement?
 Q $D(^DG(405.1,NMVT,"F",PMVT,0))
GETAMT(MASTYP) ;find active movement type
 ;input:    MASTYP = IFN of 405.2 entry
 ;output:   IFN of active 405.1 entry
 N I,DGFAC S DGFAC=""
 F I=0:0 S I=$O(^DG(405.1,"AM",MASTYP,I)) Q:'I  I $D(^DG(405.1,+I,0)),$P(^(0),"^",4) S DGFAC=I Q
 Q DGFAC
 ;