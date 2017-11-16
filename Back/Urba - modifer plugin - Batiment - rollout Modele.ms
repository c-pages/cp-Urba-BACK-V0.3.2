

	------------------------------------------------------------------------------
	----------	Fenetre								 -------------------------
	------------------------------------------------------------------------------
	rollout roll_urba_editeur_modeles "urba_editeurFacadesModeles" width:238 height:229
	(
		
		include "$userScripts\cp - GLOBAL\UI.ms"
		include "$userScripts\cp - GLOBAL\DragDialog.ms"
		
		------------  Membres	----------------------------------------------------------------------------------
		---- Pointeurs ----
		local m_prt				---- pointeur vers la structure de controle ----
		local m_cible			---- le plug cilbé
		local m_composant
		
		---- Structures ----
		local m_drag			---- la structure gerant le drag de la fenetre ----
		
		--- ctro des imgtags ---
		local m_titre
		
		
		local icos_fermer 	= #(	openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg" ,		-- Repos ----
											openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg" ,		-- Survol ----
											openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg" 			-- Pressé ----
										)
		------------  UI	----------------------------------------------------------------------------------		
		---- le bouton pour fermer la fenetre ----
		ImgTag 'ui_btnFermer' "X" pos:[0,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left

		ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
		
		edittext 'edt_nom_composant' "" pos:[6,26] width:220 height:16 align:#left
		listbox 'lbx_modeles' "" pos:[9,59] width:214 height:9 align:#left
		pickbutton 'btn_ajouter_modele' "+" pos:[193,44] width:16 height:16 align:#left
		button 'btn_supprimer_modele' "-" pos:[208,44] width:16 height:16 align:#left
		label 'lbl_modeles' "Modèles:" pos:[10,44] width:53 height:15 align:#left
		
		spinner 'spn_proba_modele' "" pos:[79,198] width:65 height:16 range:[0,1e+13,0] type:#float scale:1 align:#left
		label 'lbl_proba_modele' "Probabilité:" pos:[10,198] width:58 height:15 align:#left
		
		edittext 'edt_nom_modele' "" pos:[79,181] width:104 height:16 align:#left
		label 'lbl_nom' "Nom:" pos:[10,183] width:32 height:15 align:#left
		button 'btn_merge' "Merge" pos:[188,181] width:36 height:18 align:#left
		
		
		------------  Fonctions	----------------------------------------------------------------------------------
		---- Gere l'état du bouton  -----
		fn etatBtnFermer		_etat =(
			case _etat of (
				#Repos : 	ui_btnFermer.bitmap = icos_fermer[1]	
				#Survol : 	ui_btnFermer.bitmap = icos_fermer[2]	
				#Press : 	ui_btnFermer.bitmap = icos_fermer[3]	
			)
		)
		
		
		fn actualiser = (
			
			m_composant = m_prt.m_composant_courant
			local enabled = m_composant.type == #Modele
			
			edt_nom_composant.enabled 	= enabled
			edt_nom_modele.enabled 			= enabled
			lbx_modeles.enabled 				= enabled
			btn_ajouter_modele.enabled 		= enabled
			lbl_modeles.enabled 					= enabled
			
			
			if enabled then (
				edt_nom_composant.text 			= m_composant.nom
				
				if m_composant.modeles.count > 0 do
					lbx_modeles.items = for modele in m_composant.modeles	collect modele.nom
				if lbx_modeles.selection != 0	then (
					spn_proba_modele.indeterminate = false
					spn_proba_modele.value 			= m_composant.modeles_probas[lbx_modeles.selection]					
					edt_nom_modele.text 				= m_composant.modeles[lbx_modeles.selection].nom
				)else (
					spn_proba_modele.indeterminate = true
					edt_nom_modele.text 				= "" 		
				)
			) else (
				edt_nom_composant.text 			= ""				
			)
			enabled =  lbx_modeles.selection != 0	
			
			btn_merge.enabled 					= enabled
			lbl_nom.enabled 						= enabled
			edt_nom_modele.enabled 			= enabled
			btn_supprimer_modele.enabled 	= enabled
			lbl_proba_modele.enabled 			= enabled
			spn_proba_modele.enabled 		= enabled
			
		)
		
		---- Initialisation de la fenetre  -----
		fn initialiser = (
			format "initialiser - roll_urba_editeur_modeles\n"
			m_drag 		= str_drag 								m_prt:roll_urba_editeur_modeles		
			
			m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Editeur de façades"
			m_titre.setCouleur (color 255 255 255 )
-- 			m_titre.setCouleurFond ( color 200 200 200 )

			
			-- le bouton fermer --
			ui_btnFermer.pos = [roll_urba_editeur_modeles.width - 20,0]
			ui_btnFermer.bitmap = icos_fermer[1]	
			
			actualiser()

		)
		
		
		------------  Evenements	----------------------------------------------------------------------------------
	
				 
		
		
		
		
		
		
			--m_prt.fermer ()
		on roll_urba_editeur_modeles lbuttondown _pos 	do
			m_drag.demarrer ()
		on roll_urba_editeur_modeles lbuttonup _pos 	do
			m_drag.arreter ()
		on roll_urba_editeur_modeles mouseMove _pos 	do
			m_drag.suivreSouris ()
		on ui_btnFermer mouseover do
			etatBtnFermer #Survol
		on ui_btnFermer mouseout do
			etatBtnFermer #Repos
		on ui_btnFermer mouseDown do
			etatBtnFermer #Press
		on ui_btnFermer mouseUp do
			etatBtnFermer #Repos
		on ui_btnFermer click do
			destroydialog roll_urba_editeur_modeles
		
		
		
		on edt_nom_composant entered txt do
		(
					m_composant.nom = 	txt
					m_prt.actualiser ()
				)
		on lbx_modeles selected val do ()
		
		
		on btn_ajouter_modele picked 	_node 	do
		(
					m_prt.m_prt.creer_modele		m_composant	 _node	m_cible
					actualiser ()
				)
				
		on lbx_modeles	 selected _sel 	do (
					
					actualiser ()
				)
				
		on btn_supprimer_modele pressed do
		(
					deleteItem	m_composant.modeles				lbx_modeles.selection
					deleteItem	m_composant.modeles_probas	lbx_modeles.selection
					actualiser ()
				)
		on spn_proba_modele changed val do
		(
					m_composant.modeles_probas[lbx_modeles.selection] = val
			
					actualiser ()
				)
		on edt_nom_modele entered txt do
		(
					m_composant.modeles[lbx_modeles.selection].nom = txt
					actualiser ()
				)
		on btn_merge pressed do
		(
-- 					m_prt.creer_modele				state		m_cible
					actualiser ()
				)
	)
	
	
	
	
	
	
	
	
	
	
