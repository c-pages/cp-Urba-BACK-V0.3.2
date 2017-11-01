
			------------------------------------------------------------------------------
			----------	Fenetre								 -------------------------
			------------------------------------------------------------------------------
			rollout roll_urba_editeurFacades "urba_editeurFacades" width:250 height:494
			(
				------------  Membres	----------------------------------------------------------------------------------
				---- Pointeurs ----
				local m_prt				---- pointeur vers la structure de controle ----
				
				---- Structures ----
				local m_drag			---- la structure gerant le drag de la fenetre ----
				
				--- ctro des imgtags ---
				local m_titre
				
		--- images bouton fermer ---
				
				local icos_fermer 	= #(	openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg" ,		-- Repos ----
												openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg" ,		-- Survol ----
												openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg" 			-- Pressé ----
												)
				------------  UI	----------------------------------------------------------------------------------		
				---- le bouton pour fermer la fenetre ----
				ImgTag 'ui_btnFermer' "X" pos:[0,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left

				ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
			 
				
				edittext 'edt_nom_facade' "" pos:[85,50] width:153 height:16 align:#left
				label 'lbl_nom_facade' "Nom:" pos:[6,50] width:52 height:15 align:#left
				
				checkbox 'chk_repetable' "Répétable" pos:[6,69] width:75 height:14 align:#left
				checkbox 'chk_etirable' "Etirable" pos:[6,87] width:64 height:14 align:#left
				spinner 'spn_proba' "" pos:[85,139] width:71 height:16 range:[0,1e+13,0] type:#float scale:1 align:#left
				label 'lbl_proba' "Probabilité:" pos:[7,139] width:67 height:15 align:#left
				
				spinner 'spn_largeur' "" pos:[85,105] width:71 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
				label 'lbl_largeur' "Largeur:" pos:[7,103] width:53 height:16 align:#left
				spinner 'spn_largeurMax' "" pos:[169,105] width:71 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
				spinner 'spn_etages' "" pos:[85,122] width:71 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
				label 'lbl_etages' "Etages:" pos:[7,121] width:46 height:16 align:#left
				spinner 'spn_etagesMax' "" pos:[169,122] width:71 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
				
				
				
				dropdownList 'ddl_appliquerA' "" pos:[85,83] width:153 height:21 selection:3 align:#left		--  items:murs_types
					--  items:murs_types
					--  items:murs_types
					--  items:murs_types
					--  items:murs_types
			--  items:murs_types
				label 'lbl_appliquerA' "Appliquer à:" pos:[85,68] width:111 height:15 align:#left
				
				checkbox 'chk_largeur' "" pos:[155,105] width:14 height:14 align:#left
				checkbox 'chk_etages' "" pos:[155,122] width:14 height:14 align:#left
				
				
				
				listbox 'lbx3' "" pos:[7,173] width:232 height:9 align:#left
				button 'btn5' "+" pos:[209,157] width:16 height:16 align:#left
				button 'btn6' "-" pos:[224,157] width:16 height:16 align:#left
				GroupBox 'grp3' "Propriétés" pos:[7,296] width:232 height:186 align:#left
				spinner 'spn11' "" pos:[85,314] width:67 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
				label 'lbl11' "Largeur:" pos:[17,311] width:53 height:16 align:#left
				spinner 'spn12' "" pos:[167,314] width:67 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
				checkbox 'chk7' "" pos:[152,315] width:14 height:14 align:#left
				listbox 'lbx4' "" pos:[16,351] width:214 height:9 align:#left
				button 'btn7' "+" pos:[200,335] width:16 height:16 align:#left
				button 'btn8' "-" pos:[215,335] width:16 height:16 align:#left
				label 'lbl12' "Modèles:" pos:[17,332] width:53 height:16 align:#left
				
				label 'lbl23' "Séquence" pos:[7,156] width:67 height:15 align:#left
				
				button 'btn22' "Enreg.sous" pos:[162,27] width:79 height:21 align:#left
				button 'btn23' "Enregistrer " pos:[84,27] width:79 height:21 align:#left
				button 'btn21' "Charger" pos:[7,27] width:79 height:21 align:#left
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
					
				)
				
				---- Initialisation de la fenetre  -----
				fn initialiser = (
					
					m_drag 		= str_drag 	m_prt:roll_urba_editeurFacades		
					
					m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Editeur de façades"
					m_titre.setCouleur (color 0 0 0)
					m_titre.setCouleurFond ( color 200 200 200 )

					
					-- le bouton fermer --
					ui_btnFermer.pos = [roll_urba_editeurFacades.width - 20,0]
					ui_btnFermer.bitmap = icos_fermer[1]	
					
					actualiser()

				)
				
				
				------------  Evenements	----------------------------------------------------------------------------------
				
				---- Fermer ----
				
				---- Drag ----
				
				on roll_urba_editeurFacades lbuttondown _pos 	do
					m_drag.demarrer ()
				on roll_urba_editeurFacades lbuttonup _pos 	do
					m_drag.arreter ()
				on roll_urba_editeurFacades mouseMove _pos 	do
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
					m_prt.fermer ()
				
				
			) -- fin du rollout ------
			
			