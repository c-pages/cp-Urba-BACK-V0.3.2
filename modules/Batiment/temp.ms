mgr_test = $.core.mgr_elements.mgr_facCompos ()
popo = mgr_test.creer_element  /* 	idUnique:"IDPOPO"	 */idConstructeur:#terrasse


mgr_test.enregistrer_parametres		popo	


-- popo.nom = "POopopOIPIPIiiii"
mgr_test.enregistrer_parametres		popo	
popo.params.acrotere_ht = 117
mgr_test.enregistrer_parametres		popo	



mgr_test.get_elements()


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