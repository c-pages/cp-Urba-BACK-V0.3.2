($Urba_Batiment001.core.get_mgr_surface () ).get_axePrincipal_CORRECT ()
axeP = ($Urba_Batiment001.core.get_mgr_surface () ).get_axePrincipal ()

 ($Urba_Batiment001.core.get_mgr_surface () ).m_outils.get_axePrincipal_orientation		axeP 		$.pos 		
 
 ss = ($.core.get_mgr_surface () ).creer_shape()
 select ss
 
  ($Urba_Batiment001.core.get_mgr_surface () ).est_pignon 12
  
  pts =  ($Urba_Batiment001.core.get_mgr_surface () ).get_points ()  
 ($Urba_Batiment001.core.get_mgr_surface () ).m_outils. chercher_alignements	pts		1		20

axeP 		$.pos 		
 
 
  chercher_alignements	_pts		_idTest		_seuil	