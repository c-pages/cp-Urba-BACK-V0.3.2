-- mgr_test = $.core.mgr_elements.mgr_facades
-- popo = mgr_test.creer_element  () /* 	idUnique:"IDPOPO"  idConstructeur:#baie	 */  

mgr_test = $.core.mgr_elements.mgr_toiture
popo = mgr_test.creer_element   idConstructeur:#terrasse	 





-- popo.nom = "popo 2 !!"
-- mgr_test.enregistrer_parametres		popo	
popo.params.acrotere_ht = 117
-- popo.etagesMin= 117
mgr_test.enregistrer_parametres		popo	



mgr_test.get_elements()



$.core.mgr_elements.supprimer_facade  popo

-- mgr_test.ouvrir_dialog ()
pipi = mgr_test.get_element_parIndex 1

mgr_test.enregistrer_parametres		pipi	
-- pipi = mgr_test.get_element_parIDUnique "FacCompo_2179418805"
-- pipi.params.longueur = 117
append 	pipi.sequence "IDduComposant BIS"


mgr_test.get_elements()



/* 
popo = $.facades_nom
classof $.facades_id
classof $.etages_hauteur
append popo "pipi" 
*/