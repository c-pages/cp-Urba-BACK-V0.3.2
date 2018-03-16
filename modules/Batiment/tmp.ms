
clearlistener ()

P1_pt1 = $Point001.pos
P1_pt2 = $Point002.pos
P1_pt3 = $Point003.pos
plan_1 = str_plan ()
plan_1.creerFrom_3Points  P1_pt1  P1_pt2 P1_pt3
plan_1.representer_plan 	P1_pt1
  
  
  

P2_pt1 = $Point004.pos
P2_pt2 = $Point005.pos
P2_pt3 = $Point006.pos
plan_2 = str_plan ()
plan_2.creerFrom_3Points  P2_pt1  P2_pt2 P2_pt3
plan_2.representer_plan 	P2_pt1
  
  
droite_faitage = plan_1.get_intersection_avec_plan  	plan_2






P3_pt1 = $Point007.pos
P3_pt2 = $Point008.pos
P3_pt3 = $Point009.pos
plan_3 = str_plan ()
plan_3.creerFrom_3Points  P3_pt1  P3_pt2 P3_pt3
plan_3.representer_plan 	P3_pt1


droite_faitage.get_intersection_plan plan_3

  