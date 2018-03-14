
rollout sub_general "" width:255 height:556
(
	local m_rolloutP
	local m_plug
	local m_core
	
	local m_bat
	
	--- Global ------
	GroupBox 'grp_etages' "Etages :" pos:[10,-4] width:235 height:199 align:#left	
	
	
	label 'lbl_nbre' "Nbre. d'étages:" pos:[27,15] width:92 height:15 align:#left
	spinner 'spn_nbres' "" pos:[160,14] width:72 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl_hauteur' "Hauteur :" pos:[27,31] width:76 height:15 align:#left
	spinner 'spn_hauteur' "" pos:[160,29] width:72 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	
	--- etages specifiques -----------
	GroupBox 'grp_etages_specifiques' "Etages spécifiques" pos:[20,48] width:215 height:135 align:#left
	button 'btn_etages_nouveau' "Nouv." pos:[30,64] width:35 height:16 toolTip:"Ajouter	étages spécifiques" align:#left
	button 'btn_etages_supprimer' "Sup." pos:[171,63] width:35 height:16 toolTip:"Supprimer étages spécifiques" align:#left	
	
	listbox 'lbx_etages_specifiques' "" pos:[30,80] width:177 height:4 align:#left
	
	label 'lbl_etage_specifiques' "Etages :" pos:[35,138] width:50 height:19 align:#left
	spinner 'spn_etageMin_specifiques' "" pos:[117,141] width:40 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl_hauteur_specifiques' "Hauteur :" pos:[35,156] width:55 height:22 align:#left
	spinner 'spn_etageMax_specifiques' "" pos:[169,141] width:40 height:16 range:[0,1e+13,0] type:#integer align:#left
	checkbutton 'ckb_etageMax_specifiques' ">" pos:[156,141] width:16 height:16 align:#left
	spinner 'spn_hauteur_specifiques' "" pos:[117,157] width:92 height:16 range:[0,1e+13,0] type:#worldunits align:#left
	
	---- Divers ------
	GroupBox 'grp_divers' "Divers" pos:[10,199] width:235 height:60 align:#left
	label 'lbl_decallageZ' "Décallage (Z):" pos:[27,216] width:92 height:18 align:#left
	spinner 'spn_decallageZ' "" pos:[160,216] width:72 height:16 range:[-1e+13,1e+13,0] type:#worldunits scale:1 align:#left
	checkbox 'chk_interieur' "Cloisons intèrieures" pos:[26,235] width:141 height:16 align:#left
	
	
	
	
	--- rollout------------------
	fn actualiser =(
		
		m_bat			= m_rolloutP.m_batiment
		
		-------- global ------------------------
		spn_nbres.value		=	m_bat.etages_nbre		
		spn_hauteur.value		=	m_bat.etages_hauteur_global
		
		
		-------- etages spécifiques --------------
		--- affichage dans la liste-
		local liste_affichage = #()
		for i = 1 to m_bat.etages_min.count do (
			local affichage = ""
			affichage+= m_bat.etages_min[i] as string  
			if m_bat.etages_max_use[i] do 
				affichage+= " ---> " + m_bat.etages_max[i] as string 				
			affichage+= " : " + m_bat.etages_hauteurs[i] as string  + "cm."			
			append liste_affichage affichage
		)
		lbx_etages_specifiques.items = liste_affichage
		
		--- les boutons ------------
		local enable_prop =  lbx_etages_specifiques.selection != 0
		btn_etages_supprimer.enabled 	= enable_prop
		
		spn_etageMin_specifiques.enabled 	= enable_prop
		lbl_etage_specifiques.enabled 		= enable_prop
		spn_etageMax_specifiques.enabled	= enable_prop
		lbl_hauteur_specifiques.enabled		= enable_prop
		ckb_etageMax_specifiques.enabled	= enable_prop
		spn_hauteur_specifiques.enabled 	= enable_prop
		
		if enable_prop do (
			local index = lbx_etages_specifiques.selection 
			spn_etageMin_specifiques.value					=	m_bat.etages_min[ index ] 
			ckb_etageMax_specifiques.checked 			= m_bat.etages_max_use[ index ] 
			spn_etageMax_specifiques.indeterminate	=	not ckb_etageMax_specifiques.checked
			spn_etageMax_specifiques.enabled				=	ckb_etageMax_specifiques.checked
			if  ckb_etageMax_specifiques.checked do 
				spn_etageMax_specifiques.value				=	m_bat.etages_max[ index ] 
			
			spn_hauteur_specifiques.value					=	m_bat.etages_hauteurs[ index ] 
			
			spn_etageMax_specifiques.range.x = spn_etageMin_specifiques.value		
		)
		
		
	)
	
	fn initialiser  _roll_edit =(
		m_rolloutP 	= _roll_edit
		m_plug			= m_rolloutP.m_plug
		m_core			= m_rolloutP.m_core
		
		spn_etageMax_specifiques.range.x = 0
	)
		
		
		
		
	---- donnees -----------------	
	fn set_etage = (
		m_bat.set_etage		lbx_etages_specifiques.selection 		\
										spn_etageMin_specifiques.value			\
										ckb_etageMax_specifiques.checked		\
										spn_etageMax_specifiques.value			\
										spn_hauteur_specifiques.value
		m_rolloutP.changer_un_truc ()
		actualiser ()
	)
		
		
	
	
	
	
	
	on spn_nbres changed val do (
		m_bat.etages_nbre		= val
		m_rolloutP.changer_un_truc ()
	)
	on spn_hauteur changed val do (
		m_bat.etages_hauteur_global		= val
		m_rolloutP.changer_un_truc ()
	)
	on btn_etages_nouveau pressed do	(
		m_bat.ajouter_etage ()		
		m_rolloutP.changer_un_truc ()
		lbx_etages_specifiques.selection += 1
		actualiser ()
	)
	on btn_etages_supprimer pressed do (
		if lbx_etages_specifiques.selection > 0 do (
			m_bat.supprimer_etage		lbx_etages_specifiques.selection
			m_rolloutP.changer_un_truc ()
			if lbx_etages_specifiques.selection > lbx_etages_specifiques.items.count do
				lbx_etages_specifiques.selection = lbx_etages_specifiques.items.count 
			actualiser ()
		)
	)
	on lbx_etages_specifiques 			selected 	val 		do	actualiser ()
	
	on spn_etageMin_specifiques 	changed 	val 		do 	set_etage ()
	on spn_etageMax_specifiques 	changed 	val 		do	set_etage ()
	on ckb_etageMax_specifiques 	changed 	state 	do	set_etage ()
	on spn_hauteur_specifiques 		changed 	val 		do 	set_etage ()
		
	on spn_decallageZ changed val do	(
		m_bat.decallage_z = val
		m_rolloutP.changer_un_truc ()		
		)
	on chk_interieur changed state do	(
		m_bat.interieur_use = state
		m_rolloutP.changer_un_truc ()
		)
		
) ---- fin rollout general ------