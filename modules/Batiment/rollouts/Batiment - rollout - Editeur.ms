--Destroy the dialog if it is already open 
-- try(destroyDialog rollout_Urb_Bat_editeur)catch()

(  --- fin FileIn ----------


	
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

rollout sub_facades "" width:594 height:789
(


	local m_rolloutP
	local m_core
	local m_plug

	local 	m_bat
	
	edittext 'edt1' "" pos:[13,132] width:207 height:16 align:#left
	button 'btn9' "" pos:[222,132] width:16 height:16 align:#left
	
	spinner 'spn_etages' "" pos:[86,166] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn_etagesMax' "" pos:[163,166] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left		
		
	GroupBox 'grp_global' "Contraintes" pos:[14,149] width:223 height:89 align:#left
					
		
				
				
	spinner 'spn_longueur_min' "" pos:[86,181] width:64 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	spinner 'spn_longueur_max' "" pos:[163,181] width:63 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	checkbutton 'chk_longueur_max' "" pos:[150,181] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	checkbutton 'chk_longueur_min' "" pos:[73,181] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	label 'lbl_longueur' "Long.:" pos:[22,182] width:52 height:15 align:#left
					
		
	checkbutton 'ckb_mur_nord' "Nord" pos:[73,215] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	checkbutton 'ckb_mur_sud' "Sud" pos:[112,215] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	checkbutton 'ckb_mur_est' "Est" pos:[150,215] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	checkbutton 'ckb_mur_ouest' "Ouest" pos:[188,215] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	label 'lbl_appliquerA' "Murs:" pos:[22,198] width:32 height:15 align:#left
					
	dropdownList 'ddl_murs' "" pos:[73,196] width:154 height:21 selection:3 align:#left
		
	checkbutton 'chk_etagesMax' "" pos:[150,166] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	label 'lbl30' "Etages :" pos:[22,166] width:52 height:15 align:#left
	
	checkbutton 'chk_etages' "" pos:[73,166] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	
	
					
	GroupBox 'grp_sequence' "Séquence" pos:[14,239] width:223 height:204 align:#left
		
	button 'btn_monter' "/\\" pos:[213,276] width:16 height:16 toolTip:"Monter le composant." align:#left
	button 'btn_descendre' "\/" pos:[213,291] width:16 height:16 toolTip:"Descendre le composant." align:#left
		
		
		
	button 'btn_dupliquer_composant' "Dup." pos:[58,260] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
	button 'btn_instancier_composant' "Inst." pos:[92,260] width:35 height:16 toolTip:"Créer une instance du composant sélectionné." align:#left
	button 'btn_supprimer_composant' "Sup." pos:[173,260] width:35 height:16 toolTip:"Supprimer" align:#left
		
		
	listbox 'lbx_sequence' "" pos:[24,276] width:187 height:12 align:#left
		
		
		
	
	
	button 'btn29' "Nouv." pos:[24,260] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
	button 'btn15' "/\\" pos:[229,18] width:16 height:16 toolTip:"Monter le composant." align:#left
	button 'btn16' "\/" pos:[229,33] width:16 height:16 toolTip:"Descendre le composant." align:#left
	button 'btn17' "Dup." pos:[44,-1] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
	button 'btn18' "Sup." pos:[193,-1] width:35 height:16 toolTip:"Supprimer" align:#left
	listbox 'lbx3' "" pos:[10,16] width:218 height:7 align:#left
	button 'btn19' "Nouv." pos:[10,-1] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
	checkbutton 'ckb26' "D" pos:[229,95] width:16 height:16 highlightColor:(color 255 255 0) align:#left
	GroupBox 'grp35' "Paramètres" pos:[8,114] width:235 height:337 align:#left
	
	
	fn actualiser =(
		
		m_bat			= m_rolloutP.m_batiment
		
	)
	
	
	fn initialiser  _roll_edit =(
		m_rolloutP 	= _roll_edit
		m_plug			= m_rolloutP.m_plug
		m_core			= m_rolloutP.m_core
	)
	
	
	/* 
	fn changer_taille_rollout 	_taille	=(
		sub02.height = _taille.y - 40
		lbx_sequence.height = sub02.height - lbx_sequence.pos.y - 20
		
	)
	  */
	
	
	
)
rollout sub_toiture "" width:557 height:427
(

	local m_rolloutP
	local m_core
	local m_plug
	local 	m_bat
	
	edittext 'edt1' "" pos:[5,-1] width:222 height:16 align:#left
	button 'btn9' "+" pos:[227,-1] width:18 height:18 align:#left
	label 'lbl_appliquerA' "Type :" pos:[10,20] width:32 height:15 align:#left
					
	dropdownList 'ddl_murs' "" pos:[75,18] width:170 height:21 selection:3 align:#left
	
	subRollout 'subroll_parametres' "Parametres" pos:[20,62] width:205 height:209 align:#left
	GroupBox 'grp_prop' "Propriétés" pos:[10,44] width:235 height:238 align:#left
	
	
	
	fn actualiser =(
		
		m_bat			= m_rolloutP.m_batiment
		
	)
	

	fn initialiser  _roll_edit =(
		m_rolloutP 	= _roll_edit
		m_plug			= m_rolloutP.m_plug
		m_core			= m_rolloutP.m_core
	)
	/* 
	fn changer_taille_rollout 	_taille	=(
		
	) */
	 
		
)
rollout sub_materiaux "" width:255 height:427
(


	local m_rolloutP
	local m_core
	local m_plug
	
	edittext 'edt1' "" pos:[5,0] width:222 height:16 align:#left
	button 'btn9' "+" pos:[227,0] width:18 height:18 align:#left
	
	
	
	fn actualiser =(
		
		m_bat			= m_rolloutP.m_batiment
		
	)
	
	fn initialiser  _roll_edit =(
		m_rolloutP 	= _roll_edit
		m_plug			= m_rolloutP.m_plug
		m_core			= m_rolloutP.m_core
	)
	
	--- Global ------
-- 	GroupBox 'grp_global' "Murs :" pos:[10,56] width:235 height:245 align:#left
	
	/* 
	
	fn changer_taille_rollout 	_taille	=(
		
	)
	  */

)










--Create a rollout
rollout rollout_Urb_Bat_editeur "Urb - Bat - Editeur" width:290 height:600
(
	--- parametres generaux -----
	local m_plug
	local m_core
	local sub				------ le sous_rollout du tab actif
	
	--- les element manipulés ----------------
	local m_batiment
	local m_facade_courante
	local m_facCompo_courant
	local m_toiture
	
	--- parametres fenetre ---------
	local largeur_base 		= 290
	local largeur_panneau 	= 215
	local nbr_panneau 		= 0
	
	--- pour changement efectués ou non ----
	local m_changement = false
	
	local 	mgr_VP 					= fileIn	 "$userScripts\cp-Urba\modules\Batiment\divers\Batiment - Viewport.ms"
	
	dotNetControl 'tabs' "system.windows.forms.tabControl" pos:[10,22] width:270 height:25 align:#left
	button 'btn_valider' "Valider" pos:[10,483] width:96 height:35 align:#left	
	
	
	button 'btn_annuler' "Annuler" pos:[187,483] width:96 height:35 align:#left
	button 'btn_maj' "Maj" pos:[10,3] width:28 height:18 enabled:true align:#left
	
	checkbutton 'ckb_proxy' "Prxy" pos:[64,3] width:28 height:18 enabled:true highlightColor:(color 255 255 0) align:#left
	checkbutton 'ckb_maj_auto' "Auto" pos:[37,3] width:28 height:18 highlightColor:(color 255 255 0) align:#left
	
	checkbutton 'ckb_dist' "Dist" pos:[253,3] width:28 height:18 highlightColor:(color 255 255 0) toolitip:"Affiche les longueur des murs." align:#left
	checkbutton 'ckb_facades' "Fcd." pos:[226,3] width:28 height:18 highlightColor:(color 255 255 0) toolitip:"Affiche les étages." align:#left
	checkbutton 'ckb_etages' "Etg." pos:[199,3] width:28 height:18 highlightColor:(color 255 255 0)  toolitip:"Affiche les façades." align:#left
-- 	progressBar 'pb_construction' "ProgressBar" pos:[10,24] width:270 height:6 align:#left
	
	
	subRollout 'subRoll' "Sub" pos:[10,46] width:270 height:407 align:#left
	
	subRollout 'subroll_Params_1' "Paramètres" pos:[289,56] width:210 height:407 align:#left
	subRollout 'subroll_Params_2' "Paramètres" pos:[508,56] width:210 height:407 align:#left
	
	--- viewport ---
	/* 
	fn vp_desactiver				=(
	)
	fn vp_activer 		=(
		
	) */
		
	-- actualisations ------
	fn actualiser =(
		if sub != undefined do 
			sub.actualiser ()
	)
	fn actualiser_nrbre_panneaux 	=(
		if nbr_panneau > 2 do nbr_panneau = 2
		if nbr_panneau < 0 do nbr_panneau = 0
		rollout_Urb_Bat_editeur.width = largeur_base + nbr_panneau * largeur_panneau
	)
	fn actualiser_taille_rollout 	taille:( getdialogSize rollout_Urb_Bat_editeur )  =(
		
		actualiser_nrbre_panneaux ()
		
		btn_valider.pos.y 		= taille.y - 45
		btn_annuler.pos.y 		= taille.y - 45
		btn_annuler.pos.y 		= taille.y - 45
		subRoll.height 			= taille.y - subRoll.pos.y - 55
		
-- 		subRoll.rollouts[1].changer_taille_rollout 	_taille 
		
	)
	fn actualiser_VP =(
		
		mgr_VP.longueurs		ckb_dist.checked
		mgr_VP.facades			ckb_facades.checked
		mgr_VP.etages			ckb_etages.checked
		
		m_core.m_edit_affiche_dist 		= ckb_dist.checked
		m_core.m_edit_affiche_fcd 		= ckb_facades.checked
		m_core.m_edit_affiche_etages	= ckb_etages.checked
		
		
	)	
	fn actualiser_geo =(
		
		m_core.actualiser 						bat_edition:m_batiment		proxy:ckb_proxy.checked 
		
		m_core.m_edit_maj_auto 			= ckb_maj_auto.checked
		m_core.m_edit_proxy				=	ckb_proxy.checked	
		
	)
	
	
	
	---- changements ----------
	fn changer_un_truc 		=  (
		m_changement = true
		if ckb_maj_auto.checked do 
			actualiser_geo()
	)
	fn onA_changer_unTruc =	m_changement
	fn reset_changement 	=	m_changement = false

	--Add rollouts to the subRollout based on which tab is currently selected. 
	fn ouvrir_tab index	=	(
		--Remove any existing rollouts first. 
 		for x in subRoll.rollouts do removeSubRollout subRoll x
		
		sub=case index of
		(
			default:	sub_general
			1:			sub_facades
			2:			sub_toiture
			3:			sub_materiaux
		)
		addSubRollout subRoll sub
		sub.initialiser  rollout_Urb_Bat_editeur
		sub.actualiser ()
	)
	
	--Tab initilization function.
	fn initTabs tab labels:#() =
	(
		
		tab.tabPages.clear()		
		tab.sizeMode=tab.sizeMode.fixed		
		tab.itemSize=dotnetObject "System.Drawing.Size" ((tab.width/( labels.count /* - 1 */ ) ) - 5)   23
		
 		for x in labels do tab.tabPages.add x
	)
	
	fn set_batiment 	_bat = (
		m_batiment = _bat
		actualiser_geo ()
		actualiser_VP ()
	)
	fn initialiser _plug 		=(
		
		---- pointeurs -------
		m_plug = _plug
		m_core = _plug.core
		
		--- rollout ----------
		actualiser_nrbre_panneaux ()		
		initTabs tabs labels:#("Général", "Façades", "Toiture", "Materiaux")
		
		ckb_dist.checked	 		= m_core.m_edit_affiche_dist
		ckb_facades.checked	 	= m_core.m_edit_affiche_fcd
		ckb_etages.checked	 	= m_core.m_edit_affiche_etages
		
		ckb_maj_auto.checked	= m_core.m_edit_maj_auto
		ckb_proxy.checked	 		= m_core.m_edit_proxy
		
		
	)
	
	
	fn fermer = (
		
		mgr_VP.desactiver_tout ()
		
		local confirmation_fermer = true
		if m_changement do
			confirmation_fermer = queryBox  "Quitter sans enregistrer les modifications ?"
		if confirmation_fermer do (
			m_core.editeur_fermer ()
			reset_changement ()
			
			m_core.actualiser ()
			
		)
	)
	fn valider =(
		
		mgr_VP.desactiver_tout ()
		
		m_core.vider_parametres ()
		m_batiment.enregistrer  m_plug
		m_core.editeur_fermer ()
		
		m_core.actualiser ()
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		
	
	
	on rollout_Urb_Bat_editeur open do
		actualiser_taille_rollout ()
	on rollout_Urb_Bat_editeur resized _taille do
		actualiser_taille_rollout  taille:_taille
	on tabs mouseUp senderArg arg do
		ouvrir_tab 	senderArg.SelectedIndex
	on btn_valider pressed do
		valider ()
	on btn_annuler pressed do
		fermer ()
	on btn_maj pressed do
		actualiser_geo ()
	on ckb_proxy changed state do
		actualiser_geo ()
	on ckb_maj_auto changed state do
		actualiser_geo ()
	on ckb_dist changed state do
		actualiser_VP ()
	on ckb_facades changed state do
		actualiser_VP ()
	on ckb_etages changed state do
		actualiser_VP ()
)

rollout_Urb_Bat_editeur

) --- fin FileIn 