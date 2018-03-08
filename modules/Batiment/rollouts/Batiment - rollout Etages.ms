( --- fileIn
	
rollout roll_etages "Urba - Bat - Etages" width:171 height:122
(
	local m_plug
	local m_changement = false
	
	listbox 'lbx_etages' "" pos:[10,18] width:150 height:4 align:#left
	button 'btn_ajouter_etages' "+" pos:[10,2] width:16 height:16 align:#left
	
	button 'btn_supprimer_etages' "-" pos:[26,2] width:16 height:16 align:#left
	spinner 'spn_etageMin' "" pos:[68,80] width:40 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl_etage' "Etages :" pos:[10,77] width:50 height:19 align:#left
	spinner 'spn_etageMax' "" pos:[120,80] width:40 height:16 range:[0,1e+13,0] type:#integer align:#left
	label 'lbl_hauteur' "Hauteur :" pos:[10,95] width:55 height:22 align:#left
	checkbutton 'ckb_etageMax' ">" pos:[107,80] width:16 height:16 align:#left
	spinner 'spn_hauteur' "" pos:[68,96] width:92 height:16 range:[0,1e+13,0] type:#worldunits align:#left
/* 	button 'btn_valider' "Valider" pos:[8,116] width:75 height:23 align:#left
	
	button 'btn_annuler' "Annuler" pos:[84,116] width:75 height:23 align:#left
	 */
	fn actualiser = (
		local liste_affichage = #()
		for i = 1 to m_plug.etages_min.count do (
			local affichage = ""
			affichage+= m_plug.etages_min[i] as string  
			if m_plug.etages_max_use[i] do 
				affichage+= " ---> " + m_plug.etages_max[i] as string  
				
			affichage+= " : " + m_plug.etages_hauteurs[i] as string  + "cm."
			
			append liste_affichage affichage
		)
		
		lbx_etages.items = liste_affichage
		
		local enable_prop =  lbx_etages.selection != 0
		btn_supprimer_etages.enabled = enable_prop
		spn_etageMin.enabled = enable_prop
		lbl_etage.enabled = enable_prop
		spn_etageMax.enabled = enable_prop
		lbl_hauteur.enabled = enable_prop
		ckb_etageMax.enabled = enable_prop
		spn_hauteur.enabled = enable_prop
		
		
		if enable_prop do (
			local index = lbx_etages.selection 
			spn_etageMin.value				=	m_plug.etages_min[ index ] 
			ckb_etageMax.checked 			= m_plug.etages_max_use[ index ] 
			if  ckb_etageMax.checked then 
				spn_etageMax.value				=	m_plug.etages_max[ index ] 
			else
				spn_etageMax.indeterminate	=	not ckb_etageMax.checked
			
			spn_hauteur.value					=	m_plug.etages_hauteurs[ index ] 
			
		)
		
		
	)
	
	
	fn set_etage = (
		m_plug.core.set_etage		lbx_etages.selection 		\
												spn_etageMin.value		\
												ckb_etageMax.checked		\
												spn_etageMax.value		\
												spn_hauteur.value
		m_changement = true
		actualiser ()
	)
	fn initialiser  _plug = m_plug = _plug
	
	
/* 	on btn_valider pressed  do (
		m_plug.core.actualiser ()
	)
	on btn_annuler pressed  do
(
	
	) */

	on lbx_etages selected _val do
	(
			actualiser ()
		)
	on btn_ajouter_etages pressed do
	(
			m_plug.core.ajouter_etage ()
		m_changement = true
			actualiser ()
		)
	on btn_supprimer_etages pressed do
	(
			m_plug.core.supprimer_etage lbx_etages.selection 
		m_changement = true
			actualiser ()
		)
	on spn_etageMin changed val do
	(
			
			if val >= spn_etageMax.value do
				spn_etageMax.value = val+1
			
			set_etage	()
			
		)
	on spn_etageMax changed val do
	(
			
			if val <= spn_etageMin.value do
				spn_etageMin.value = val-1
			
			set_etage	()
			
		)
	on ckb_etageMax changed state do
		set_etage	()
	on spn_hauteur changed val do
		set_etage	()
)

) --- fin fil