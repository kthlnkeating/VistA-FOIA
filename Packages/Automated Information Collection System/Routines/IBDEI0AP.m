IBDEI0AP ; ; 12-JAN-2012
 ;;3.0;IB ENCOUNTER FORM IMP/EXP;;JAN 12, 2012
 Q:'DIFQR(358.3)  F I=1:2 S X=$T(Q+I) Q:X=""  S Y=$E($T(Q+I+1),4,999),X=$E(X,4,999) S:$A(Y)=126 I=I+1,Y=$E(Y,2,999)_$E($T(Q+I+1),5,99) S:$A(Y)=61 Y=$E(Y,2,999) X NO E  S @X=Y
Q Q
 ;;^UTILITY(U,$J,358.3,14440,1,4,0)
 ;;=4^Gout
 ;;^UTILITY(U,$J,358.3,14440,2)
 ;;=^52625
 ;;^UTILITY(U,$J,358.3,14441,0)
 ;;=724.2^^114^922^3
 ;;^UTILITY(U,$J,358.3,14441,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14441,1,3,0)
 ;;=3^724.2
 ;;^UTILITY(U,$J,358.3,14441,1,4,0)
 ;;=4^Low Back Pain, Lumbago
 ;;^UTILITY(U,$J,358.3,14441,2)
 ;;=^71885
 ;;^UTILITY(U,$J,358.3,14442,0)
 ;;=715.90^^114^922^4
 ;;^UTILITY(U,$J,358.3,14442,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14442,1,3,0)
 ;;=3^715.90
 ;;^UTILITY(U,$J,358.3,14442,1,4,0)
 ;;=4^Osteoarthro Unspec
 ;;^UTILITY(U,$J,358.3,14442,2)
 ;;=^272161
 ;;^UTILITY(U,$J,358.3,14443,0)
 ;;=848.9^^114^922^8
 ;;^UTILITY(U,$J,358.3,14443,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14443,1,3,0)
 ;;=3^848.9
 ;;^UTILITY(U,$J,358.3,14443,1,4,0)
 ;;=4^Sprain Nos
 ;;^UTILITY(U,$J,358.3,14443,2)
 ;;=^123990
 ;;^UTILITY(U,$J,358.3,14444,0)
 ;;=727.3^^114^922^1
 ;;^UTILITY(U,$J,358.3,14444,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14444,1,3,0)
 ;;=3^727.3
 ;;^UTILITY(U,$J,358.3,14444,1,4,0)
 ;;=4^Bursitis
 ;;^UTILITY(U,$J,358.3,14444,2)
 ;;=^87364
 ;;^UTILITY(U,$J,358.3,14445,0)
 ;;=714.0^^114^922^7
 ;;^UTILITY(U,$J,358.3,14445,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14445,1,3,0)
 ;;=3^714.0
 ;;^UTILITY(U,$J,358.3,14445,1,4,0)
 ;;=4^Rheumatoid Arthritis
 ;;^UTILITY(U,$J,358.3,14445,2)
 ;;=^10473
 ;;^UTILITY(U,$J,358.3,14446,0)
 ;;=733.90^^114^922^5
 ;;^UTILITY(U,$J,358.3,14446,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14446,1,3,0)
 ;;=3^733.90
 ;;^UTILITY(U,$J,358.3,14446,1,4,0)
 ;;=4^Osteopenia
 ;;^UTILITY(U,$J,358.3,14446,2)
 ;;=^35593
 ;;^UTILITY(U,$J,358.3,14447,0)
 ;;=733.00^^114^922^6
 ;;^UTILITY(U,$J,358.3,14447,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14447,1,3,0)
 ;;=3^733.00
 ;;^UTILITY(U,$J,358.3,14447,1,4,0)
 ;;=4^Osteoporosis Nos
 ;;^UTILITY(U,$J,358.3,14447,2)
 ;;=^87159
 ;;^UTILITY(U,$J,358.3,14448,0)
 ;;=331.0^^114^923^1
 ;;^UTILITY(U,$J,358.3,14448,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14448,1,3,0)
 ;;=3^331.0
 ;;^UTILITY(U,$J,358.3,14448,1,4,0)
 ;;=4^Alzheimer's Disease
 ;;^UTILITY(U,$J,358.3,14448,2)
 ;;=^5679
 ;;^UTILITY(U,$J,358.3,14449,0)
 ;;=438.9^^114^923^2
 ;;^UTILITY(U,$J,358.3,14449,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14449,1,3,0)
 ;;=3^438.9
 ;;^UTILITY(U,$J,358.3,14449,1,4,0)
 ;;=4^CVA, Late Effects
 ;;^UTILITY(U,$J,358.3,14449,2)
 ;;=^269757
 ;;^UTILITY(U,$J,358.3,14450,0)
 ;;=340.^^114^923^5
 ;;^UTILITY(U,$J,358.3,14450,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14450,1,3,0)
 ;;=3^340.
 ;;^UTILITY(U,$J,358.3,14450,1,4,0)
 ;;=4^Multiple Sclerosis
 ;;^UTILITY(U,$J,358.3,14450,2)
 ;;=^79761
 ;;^UTILITY(U,$J,358.3,14451,0)
 ;;=332.0^^114^923^7
 ;;^UTILITY(U,$J,358.3,14451,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14451,1,3,0)
 ;;=3^332.0
 ;;^UTILITY(U,$J,358.3,14451,1,4,0)
 ;;=4^Parkinson's Disease
 ;;^UTILITY(U,$J,358.3,14451,2)
 ;;=^304847
 ;;^UTILITY(U,$J,358.3,14452,0)
 ;;=356.9^^114^923^8
 ;;^UTILITY(U,$J,358.3,14452,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14452,1,3,0)
 ;;=3^356.9
 ;;^UTILITY(U,$J,358.3,14452,1,4,0)
 ;;=4^Periph Neurpthy, Idiopathic
 ;;^UTILITY(U,$J,358.3,14452,2)
 ;;=^123931
 ;;^UTILITY(U,$J,358.3,14453,0)
 ;;=780.39^^114^923^10
 ;;^UTILITY(U,$J,358.3,14453,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14453,1,3,0)
 ;;=3^780.39
 ;;^UTILITY(U,$J,358.3,14453,1,4,0)
 ;;=4^Seizures/Convulsions
 ;;^UTILITY(U,$J,358.3,14453,2)
 ;;=^28162
 ;;^UTILITY(U,$J,358.3,14454,0)
 ;;=907.2^^114^923^11
 ;;^UTILITY(U,$J,358.3,14454,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14454,1,3,0)
 ;;=3^907.2
 ;;^UTILITY(U,$J,358.3,14454,1,4,0)
 ;;=4^Spinal Cord Inj, Late Effects
 ;;^UTILITY(U,$J,358.3,14454,2)
 ;;=^275240
 ;;^UTILITY(U,$J,358.3,14455,0)
 ;;=290.40^^114^923^3
 ;;^UTILITY(U,$J,358.3,14455,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14455,1,3,0)
 ;;=3^290.40
 ;;^UTILITY(U,$J,358.3,14455,1,4,0)
 ;;=4^Dementia
 ;;^UTILITY(U,$J,358.3,14455,2)
 ;;=^303487
 ;;^UTILITY(U,$J,358.3,14456,0)
 ;;=784.0^^114^923^4
 ;;^UTILITY(U,$J,358.3,14456,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14456,1,3,0)
 ;;=3^784.0
 ;;^UTILITY(U,$J,358.3,14456,1,4,0)
 ;;=4^Headache
 ;;^UTILITY(U,$J,358.3,14456,2)
 ;;=^54133
 ;;^UTILITY(U,$J,358.3,14457,0)
 ;;=344.1^^114^923^6
 ;;^UTILITY(U,$J,358.3,14457,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14457,1,3,0)
 ;;=3^344.1
 ;;^UTILITY(U,$J,358.3,14457,1,4,0)
 ;;=4^Paraplegia NOS
 ;;^UTILITY(U,$J,358.3,14457,2)
 ;;=^90028
 ;;^UTILITY(U,$J,358.3,14458,0)
 ;;=344.00^^114^923^9
 ;;^UTILITY(U,$J,358.3,14458,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14458,1,3,0)
 ;;=3^344.00
 ;;^UTILITY(U,$J,358.3,14458,1,4,0)
 ;;=4^Quadriplegia NOS
 ;;^UTILITY(U,$J,358.3,14458,2)
 ;;=^101908
 ;;^UTILITY(U,$J,358.3,14459,0)
 ;;=493.90^^114^924^1
 ;;^UTILITY(U,$J,358.3,14459,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14459,1,3,0)
 ;;=3^493.90
 ;;^UTILITY(U,$J,358.3,14459,1,4,0)
 ;;=4^Asthma
 ;;^UTILITY(U,$J,358.3,14459,2)
 ;;=^269966
 ;;^UTILITY(U,$J,358.3,14460,0)
 ;;=466.0^^114^924^2
 ;;^UTILITY(U,$J,358.3,14460,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14460,1,3,0)
 ;;=3^466.0
 ;;^UTILITY(U,$J,358.3,14460,1,4,0)
 ;;=4^Bronchitis, Acute
 ;;^UTILITY(U,$J,358.3,14460,2)
 ;;=^259084
 ;;^UTILITY(U,$J,358.3,14461,0)
 ;;=496.^^114^924^3
 ;;^UTILITY(U,$J,358.3,14461,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14461,1,3,0)
 ;;=3^496.
 ;;^UTILITY(U,$J,358.3,14461,1,4,0)
 ;;=4^Chr Airway Obstruct (COPD)
 ;;^UTILITY(U,$J,358.3,14461,2)
 ;;=^24355
 ;;^UTILITY(U,$J,358.3,14462,0)
 ;;=162.9^^114^924^5
 ;;^UTILITY(U,$J,358.3,14462,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14462,1,3,0)
 ;;=3^162.9
 ;;^UTILITY(U,$J,358.3,14462,1,4,0)
 ;;=4^Mal Neo Bronch/Lung
 ;;^UTILITY(U,$J,358.3,14462,2)
 ;;=^73521
 ;;^UTILITY(U,$J,358.3,14463,0)
 ;;=462.^^114^924^6
 ;;^UTILITY(U,$J,358.3,14463,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14463,1,3,0)
 ;;=3^462.
 ;;^UTILITY(U,$J,358.3,14463,1,4,0)
 ;;=4^Pharyngitis, Acute
 ;;^UTILITY(U,$J,358.3,14463,2)
 ;;=^2653
 ;;^UTILITY(U,$J,358.3,14464,0)
 ;;=473.9^^114^924^8
 ;;^UTILITY(U,$J,358.3,14464,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14464,1,3,0)
 ;;=3^473.9
 ;;^UTILITY(U,$J,358.3,14464,1,4,0)
 ;;=4^Sinusitis, Chronic
 ;;^UTILITY(U,$J,358.3,14464,2)
 ;;=^123985
 ;;^UTILITY(U,$J,358.3,14465,0)
 ;;=465.9^^114^924^9
 ;;^UTILITY(U,$J,358.3,14465,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14465,1,3,0)
 ;;=3^465.9
 ;;^UTILITY(U,$J,358.3,14465,1,4,0)
 ;;=4^Upper Resp. Infec, Acute (COLD)
 ;;^UTILITY(U,$J,358.3,14465,2)
 ;;=^269878
 ;;^UTILITY(U,$J,358.3,14466,0)
 ;;=786.2^^114^924^4
 ;;^UTILITY(U,$J,358.3,14466,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14466,1,3,0)
 ;;=3^786.2
 ;;^UTILITY(U,$J,358.3,14466,1,4,0)
 ;;=4^Cough
 ;;^UTILITY(U,$J,358.3,14466,2)
 ;;=^28905
 ;;^UTILITY(U,$J,358.3,14467,0)
 ;;=472.0^^114^924^7
 ;;^UTILITY(U,$J,358.3,14467,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14467,1,3,0)
 ;;=3^472.0
 ;;^UTILITY(U,$J,358.3,14467,1,4,0)
 ;;=4^Rhinitis
 ;;^UTILITY(U,$J,358.3,14467,2)
 ;;=^24434
 ;;^UTILITY(U,$J,358.3,14468,0)
 ;;=303.90^^114^925^2
 ;;^UTILITY(U,$J,358.3,14468,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14468,1,3,0)
 ;;=3^303.90
 ;;^UTILITY(U,$J,358.3,14468,1,4,0)
 ;;=4^Alcohol Dependency, Unspec
 ;;^UTILITY(U,$J,358.3,14468,2)
 ;;=^268187
 ;;^UTILITY(U,$J,358.3,14469,0)
 ;;=300.00^^114^925^3
 ;;^UTILITY(U,$J,358.3,14469,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14469,1,3,0)
 ;;=3^300.00
 ;;^UTILITY(U,$J,358.3,14469,1,4,0)
 ;;=4^Anxiety Diorder
 ;;^UTILITY(U,$J,358.3,14469,2)
 ;;=^173573
 ;;^UTILITY(U,$J,358.3,14470,0)
 ;;=311.^^114^925^4
 ;;^UTILITY(U,$J,358.3,14470,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14470,1,3,0)
 ;;=3^311.
 ;;^UTILITY(U,$J,358.3,14470,1,4,0)
 ;;=4^Depressive Disorder
 ;;^UTILITY(U,$J,358.3,14470,2)
 ;;=^35603
 ;;^UTILITY(U,$J,358.3,14471,0)
 ;;=304.90^^114^925^5
 ;;^UTILITY(U,$J,358.3,14471,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14471,1,3,0)
 ;;=3^304.90
 ;;^UTILITY(U,$J,358.3,14471,1,4,0)
 ;;=4^Drug Dependency, Unspec
 ;;^UTILITY(U,$J,358.3,14471,2)
 ;;=^1
 ;;^UTILITY(U,$J,358.3,14472,0)
 ;;=305.1^^114^925^8
 ;;^UTILITY(U,$J,358.3,14472,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14472,1,3,0)
 ;;=3^305.1
 ;;^UTILITY(U,$J,358.3,14472,1,4,0)
 ;;=4^Nicotine Dependency
 ;;^UTILITY(U,$J,358.3,14472,2)
 ;;=^83264
 ;;^UTILITY(U,$J,358.3,14473,0)
 ;;=309.81^^114^925^9
 ;;^UTILITY(U,$J,358.3,14473,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14473,1,3,0)
 ;;=3^309.81
 ;;^UTILITY(U,$J,358.3,14473,1,4,0)
 ;;=4^PTSD, Chronic
 ;;^UTILITY(U,$J,358.3,14473,2)
 ;;=^114716
 ;;^UTILITY(U,$J,358.3,14474,0)
 ;;=303.93^^114^925^1
 ;;^UTILITY(U,$J,358.3,14474,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14474,1,3,0)
 ;;=3^303.93
 ;;^UTILITY(U,$J,358.3,14474,1,4,0)
 ;;=4^Alcohol Dependency in Rem
 ;;^UTILITY(U,$J,358.3,14474,2)
 ;;=^268190
 ;;^UTILITY(U,$J,358.3,14475,0)
 ;;=780.52^^114^925^7
 ;;^UTILITY(U,$J,358.3,14475,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14475,1,3,0)
 ;;=3^780.52
 ;;^UTILITY(U,$J,358.3,14475,1,4,0)
 ;;=4^Insomnia
 ;;^UTILITY(U,$J,358.3,14475,2)
 ;;=^87662
 ;;^UTILITY(U,$J,358.3,14476,0)
 ;;=V15.41^^114^925^6
 ;;^UTILITY(U,$J,358.3,14476,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14476,1,3,0)
 ;;=3^V15.41
 ;;^UTILITY(U,$J,358.3,14476,1,4,0)
 ;;=4^Hx of Physical Abuse/Rape
 ;;^UTILITY(U,$J,358.3,14476,2)
 ;;=^304352
 ;;^UTILITY(U,$J,358.3,14477,0)
 ;;=682.9^^114^926^2
 ;;^UTILITY(U,$J,358.3,14477,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14477,1,3,0)
 ;;=3^682.9
 ;;^UTILITY(U,$J,358.3,14477,1,4,0)
 ;;=4^Cellulitis Unspec
 ;;^UTILITY(U,$J,358.3,14477,2)
 ;;=^21160
 ;;^UTILITY(U,$J,358.3,14478,0)
 ;;=692.9^^114^926^3
 ;;^UTILITY(U,$J,358.3,14478,1,0)
 ;;=^358.31IA^4^2
 ;;^UTILITY(U,$J,358.3,14478,1,3,0)
 ;;=3^692.9
 ;;^UTILITY(U,$J,358.3,14478,1,4,0)
 ;;=4^Dermatitis
 ;;^UTILITY(U,$J,358.3,14478,2)
 ;;=^27800