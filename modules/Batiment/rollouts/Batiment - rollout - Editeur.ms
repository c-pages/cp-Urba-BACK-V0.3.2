--Destroy the dialog if it is already open 
-- try(destroyDialog rollout_Urb_Bat_editeur)catch()

(  --- fin FileIn ----------

		--- les subrollout ------------------
	include "$userScripts\cp-Urba\modules\Batiment\\rollouts\Batiment - subroll - general.ms"
	include "$userScripts\cp-Urba\modules\Batiment\\rollouts\Batiment - subroll - facades.ms"
	include "$userScripts\cp-Urba\modules\Batiment\\rollouts\Batiment - subroll - toiture.ms"
	include "$userScripts\cp-Urba\modules\Batiment\\rollouts\Batiment - subroll - materiaux.ms"











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
		local largeur_panneau 	= 218
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
		checkbutton 'ckb_etages' "Etg." pos:[199,3] width:28 height:18 highlightColor:(color 255 255 0) toolitip:"Affiche les façades." align:#left
	-- 	progressBar 'pb_construction' "ProgressBar" pos:[10,24] width:270 height:6 align:#left
		
		
		subRollout 'subRoll' "Sub" pos:[10,46] width:270 height:407 align:#left
		
		subRollout 'subroll_Params_1' "Paramètres" pos:[290,46] width:210 height:407 align:#left
		subRollout 'subroll_Params_2' "Paramètres" pos:[508,46] width:210 height:407 align:#left
		
		--- viewport ---
		/* 
		fn vp_desactiver				=(
		)
		fn vp_activer 		=(
			
		) */
			
		-- actualisations ------
		fn actualiser 	sans_params_1:false		=(
			if sub != undefined do 
				sub.actualiser sans_params_1:sans_params_1
		)
		fn actualiser_nrbre_panneaux 	nbre:	=(
			if nbre != unsupplied do
				nbr_panneau 		= nbre
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
			subroll_Params_1.height	= subRoll.height 
			subroll_Params_2.height	= subRoll.height 
			
			if m_core != undefined do
				m_core.editeur_set_taille		taille
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
		
		---- accessiosn----------
		fn get_facade_courante =  sub_facades.m_facade_courante
		
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
			
			tabs.SelectedIndex = index
			m_core.m_edit_tab = index
			actualiser_nrbre_panneaux 	nbre:0
			
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
		
		fn set_param_1  	_composant =(
			
			for rollAVirer in subroll_Params_1.rollouts do
				removeSubRollout	subroll_Params_1	rollAVirer
		
			--- le subRollout des composants	PANNEAU 1 -------
			if _composant != undefined then (
				addSubRollout	subroll_Params_1		 ( _composant.get_dialog () )
				_composant.initialiser_dialog		m_plug			 	roll_parent:rollout_Urb_Bat_editeur		  ptr_this:_composant
				nbr_panneau = 1
			) else
				nbr_panneau = 0
			actualiser_nrbre_panneaux ()
		)
		
		fn set_param_2  	_composant =(
			
			for rollAVirer in subroll_Params_2.rollouts do
				removeSubRollout	subroll_Params_2	rollAVirer
		
			--- le subRollout des composants	PANNEAU 1 -------
			if _composant != undefined then (
				addSubRollout	subroll_Params_2		 ( _composant.get_dialog () )
				_composant.initialiser_dialog		m_plug			 	roll_parent:rollout_Urb_Bat_editeur		  ptr_this:_composant
				nbr_panneau = 2
			)
			
			actualiser_nrbre_panneaux ()
		)
		
		
		
		
		fn get_compos_selection 	= (
			format "sub.lbx_sequence : %\n" sub.lbx_sequence.items
			format "sub.lbx_sequence.selection : %\n" sub.lbx_sequence.selection
			sub.lbx_sequence.selection
			
		)
		fn get_composant				= sub.m_composant_courant	--	subroll_Params_1.rollouts[1].m_compo
		
		
		
		
		
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
			
			
			local confirmation_fermer = true
			if m_changement do
				confirmation_fermer = queryBox  "Quitter sans enregistrer les modifications ?"
			if confirmation_fermer do (
				
				mgr_VP.desactiver_tout ()
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
		on rollout_Urb_Bat_editeur moved _pos do
			m_core.editeur_set_pos		_pos
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
		
		
		on ckb_dist changed state do (
			
			ckb_facades.checked	 	= not state
			ckb_etages.checked	 	= not state
			
			actualiser_VP ()
			
		)
		on ckb_facades changed state do (
			
			ckb_dist.checked	 		= not state
			ckb_etages.checked	 	= not state
			
			actualiser_VP ()
		)
		on ckb_etages changed state do (
			
			ckb_dist.checked	 		= not state
			ckb_facades.checked	 	= not state
			
			actualiser_VP ()
			
		)
		
		
		
	)
	rollout_Urb_Bat_editeur

) --- fi