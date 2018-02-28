
------ parametres de base	-----------------------------
compo_nom 		= "Baie"	
compo_type		=	#baie
compo_toolTip 	=	"Ouverture dans un mur."


--- les parametres du composant	---------
struct compo_params	(
		--- global	-------------
		longueur						= 100,
		hauteur							= 210,
		profondeur					= 20,		
		allege_hauteur 		 		= 100,
		
		--- Traverses	-------------
		traverses 						= #(),		---- liste des traverses par hauteur	----------
		
		--- Traverses	-------------
		sequence 						= #(),		---- La seuqnce qui compose la baie ( ouvrant, fixe  ...)	----------
		
		--- Volets	-------------
		volet								= 1,			----	1:Aucun		2:roulants		3:battants	----------
		volet_double					= false,		----	pour les 'Battants' 	----------
		volet_clos_proba			= 0.,			----	pourcentage de chance d'avoir un volet fermé	----------
		volet_clos_min				= 0.,			----	fermenture minimum du volet fermé	----------
		volet_clos_max				= 100.,		----	fermenture maximum du volet fermé	----------
		
	----fonctions	--------
	private
		fn get_nvl_menuierie =(
			
			struct str_menuierie (
				id 		="Menuis_",
				type 		= "Fxe",
				on create do (
					---- id unique ----
					for i= 1 to 10 do id += ( random 0 9 ) as string
				)
			) --- fin struct menuiserie	------------
			
			str_menuierie()
			
		),
	public
		fn ajouter_menuierie =(
			local nvl_menuiserie = get_nvl_menuierie ()
			append sequence		nvl_menuiserie
		),
		fn supprimer_menuierie =(
			
		)
)

--- les rollout du composant	---------
rollout compo_dialog "Baie" width:433 height:621
(
		local m_rollPrt
		local m_compo
		local m_dialog_menuiserie		= filein	 "$userScripts\cp-Urba\modules\Batiment\\rollouts\Batiment - rollout menuiserie.ms"
		
		---- golbal --------------
	edittext 'edt_nom' "" pos:[3,3] width:187 height:16 align:#left
	label 'lbl19' "Longeur:" pos:[11,36] width:49 height:13 align:#left
	spinner 'spn_longueur' "" pos:[116,36] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	label 'lbl21' "Hauteur:" pos:[11,51] width:49 height:13 align:#left
	spinner 'spn_hauteur' "" pos:[116,51] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	GroupBox 'grp1' "Global" pos:[6,21] width:187 height:83 align:#left
	label 'lbl24' "Allège pleine :" pos:[11,81] width:77 height:13 align:#left
	spinner 'spn_allege' "" pos:[116,81] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	label 'lbl29' "Profondeur:" pos:[11,66] width:59 height:13 align:#left
	spinner 'spn_profondeur' "" pos:[116,66] width:70 height:16 range:[-5,100000,0] type:#worldunits scale:1 align:#left
		
		---- traverses --------
	GroupBox 'grp_traverses' "Traverses horizontales" pos:[6,108] width:187 height:104 align:#left
	listbox 'lbx_traverses' "" pos:[17,143] width:166 height:3 align:#left
	button 'btn_ajouter_traverse' "+" pos:[16,123] width:18 height:18 align:#left
	button 'btn_supprimer_traverse' "-" pos:[32,123] width:18 height:18 align:#left
	label 'lbl_traverses_ht' "Hauteur:" pos:[16,190] width:49 height:13 align:#left
	spinner 'spn_traverse_ht' "" pos:[116,189] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
	
	---- sequence --------
	GroupBox 'grp_sequence' "Séquence" pos:[6,215] width:187 height:90 align:#left
	listbox 'lbx_sequence' "" pos:[17,253] width:166 height:3 align:#left
	button 'btn_ajouter_element' "+" pos:[16,232] width:18 height:18 align:#left
	button 'btn_supprimer_element' "-" pos:[33,232] width:18 height:18 align:#left
	button 'btn_dupliquer_element' "Dup." pos:[50,232] width:35 height:18 toolTip:"Dupliquer l'élément" align:#left
	button 'btn_instancier_element' "Inst." pos:[83,232] width:35 height:18 align:#left
	button 'btn_editer_element' "Edit." pos:[147,231] width:35 height:18 align:#left
		
		---- volet --------
	GroupBox 'grp_volet' "Volets" pos:[5,309] width:187 height:119 align:#left
	dropdownList 'ddl_volet' "" pos:[17,327] width:161 height:21 items:#("Aucun", "Roulant", "Battant simple", "Battant double") align:#left
	label 'lbl_volet_proba' "Probabilité (%) :" pos:[23,365] width:80 height:13 align:#left
	spinner 'spn_volet_ferm_proba' "" pos:[106,365] width:70 height:16 range:[0,100,0] scale:1 align:#left
	label 'lbl_volet_max' "Maximum (%) :" pos:[23,395] width:80 height:13 align:#left
	spinner 'spn_volet_ferm_max' "" pos:[106,395] width:70 height:16 range:[0,100,0] scale:1 align:#left
	label 'lbl_volet_min' "Minimum (%) :" pos:[23,380] width:80 height:13 align:#left
	spinner 'spn_volet_ferm_min' "" pos:[106,380] width:70 height:16 range:[0,100,0] scale:1 align:#left
	GroupBox 'grp_volet_fermeture' "Fermeture" pos:[14,348] width:169 height:71 align:#left
		
		fn actualiser =(
			
			--- global ------
			spn_longueur.value 		= m_compo.params.longueur
			edt_nom.text 				=	m_compo.nom
			spn_profondeur.value 	=	m_compo.params.profondeur	
			spn_allege.value 			=	m_compo.params.allege_hauteur
			
			--- traverses -----------
			lbx_traverses.items		=	for ht_trav in m_compo.params.traverses collect (ht_trav as string + "cm." )
			if lbx_traverses.selection == 0 and lbx_traverses.items.count > 0 do
				lbx_traverses.selection = 1
			local traverse_edition	= lbx_traverses.selection != 0
			btn_supprimer_traverse.enabled		= traverse_edition
			lbl_traverses_ht.enabled				= traverse_edition
			spn_traverse_ht.enabled				= traverse_edition
			spn_traverse_ht.Indeterminate		= not traverse_edition
			if traverse_edition do spn_traverse_ht.value = m_compo.params.traverses [ lbx_traverses.selection ]
			
			--- sequence -----------
			lbx_sequence.items		=	for element in m_compo.params.sequence collect ( element.type )
			if lbx_sequence.selection == 0 and lbx_sequence.items.count > 0 do
				lbx_sequence.selection = 1
			local sequence_edition	= lbx_sequence.selection != 0
			btn_supprimer_element.enabled	= sequence_edition
			btn_dupliquer_element.enabled	= sequence_edition
			btn_instancier_element.enabled	= sequence_edition
-- 			btn_editer_element.enabled		= sequence_edition
			
			--- volet -----------
			ddl_volet.selection 	= m_compo.params.volet 
			local volet_edition		= m_compo.params.volet != 1
			lbl_volet_proba.enabled							= volet_edition
			spn_volet_ferm_proba.enabled				= volet_edition
			spn_volet_ferm_proba.Indeterminate		= not volet_edition
			lbl_volet_max.enabled							= volet_edition
			spn_volet_ferm_max.enabled					= volet_edition
			spn_volet_ferm_max.Indeterminate		= not volet_edition
			lbl_volet_min.enabled							= volet_edition
			spn_volet_ferm_min.enabled					= volet_edition
			spn_volet_ferm_min.Indeterminate			= not volet_edition
			grp_volet_fermeture.enabled					= volet_edition
			
		) -- fin actualiser -------
		
		fn ajouter_traverse =(
			local trav_ht  =100
			if m_compo.params.traverses.count == 1 do
				trav_ht = 210
			append m_compo.params.traverses	trav_ht
			lbx_traverses.items		=	for ht_trav in m_compo.params.traverses collect (ht_trav as string + "cm." )
			lbx_traverses.selection += 1
			actualiser	()
		)
		fn supprimer_traverse  =(
			deleteItem m_compo.params.traverses	lbx_traverses.selection
			lbx_traverses.items		=	for ht_trav in m_compo.params.traverses collect (ht_trav as string + "cm." )
			lbx_traverses.selection -= 1
			actualiser	()
		)
		
		----- global -----------
		
		----- traverses -----------
		 ----- volets ------------

	on edt_nom entered txt 	do
	(
				m_compo.nom = txt
				m_rollPrt.actualiser ()
			)
	on spn_longueur changed val 	do
		m_compo.params.longueur 					= val
	on spn_hauteur changed val 	do
		m_compo.params.hauteur 					= val
	on spn_allege changed val 	do
		m_compo.params.allege_hauteur 	= val
	on spn_profondeur changed val 	do
		m_compo.params.profondeur	= val
	on lbx_traverses selected _index do
		actualiser ()
	on btn_ajouter_traverse pressed do
		ajouter_traverse	()
	on btn_editer_element pressed do (
		createDialog	m_dialog_menuiserie	
-- 		m_dialog_menuiserie.m_menuiserie = 
		
	)
	on btn_ajouter_element pressed do (
		m_compo.params.ajouter_menuierie	()
		actualiser ()
	)
	on btn_supprimer_traverse pressed do
		supprimer_traverse	()
	on spn_traverse_ht changed val 	do (
				m_compo.params.traverses[ lbx_traverses.selection ] = val
				actualiser ()
			)
	on ddl_volet selected _index  	do
	(
				m_compo.params.volet = _index
				actualiser ()
			)
	on spn_volet_ferm_proba changed val 	do
		m_compo.params.volet_clos_proba	= val
	on spn_volet_ferm_max changed val 	do
		m_compo.params.volet_clos_max 	= val
	on spn_volet_ferm_min changed val 	do
		m_compo.params.volet_clos_min	= val
)
	
------ la fonction de construction	---------
fn compo_fnConstruire  		_plug			_ptsIDs_accroche		_normDir		_composant 	onConstruitLaDalle:false	= ( 
_ptsIDs_accroche
	)
	
	
fn compo_fnConstruireBACK  		_plug			_ptsIDs_accroche		_normDir		_composant 	onConstruitLaDalle:false	= ( 
-- 		_plug		pts_accroches		_normDir		 _composant	
	
		--- Result -------------
		local pt_result_1, pt_result_2, pt_result_3
	
	
	-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local ptr_composant  	= 	_composant
		local ptr_params		  	= 	_composant.params
		local ptr_geo 				= 	ptr_plug.core.get_geo ()
	
	-------------  constantes locales			-----------------------------------------------------------------------------------------------------------------
		local decalage_epaisseur 		= 1
		local menuis_largeur				=	7.
		local menuis_epaisseur			=	3.
	
	
	-------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
		local longueur						= ptr_params.longueur
		local hauteur						= ptr_params.hauteur
		local profondeur					= ptr_params.profondeur		
		local allege_hauteur 		 		= ptr_params.allege_hauteur
		
		
		
		
		local menuis_largeur				=	ptr_params.menuis_largeur
		local menuis_epaisseur			=	ptr_params.menuis_epaisseur
		local menuis_divisions			=	ptr_params.menuis_divisions
		local menuis_allege_use		=	ptr_params.menuis_allege_use
		local menuis_allege_ht			=	ptr_params.menuis_allege_ht
		local menuis_trav_use			=	ptr_params.menuis_trav_use
		local menuis_trav_ht			=	ptr_params.menuis_trav_ht
		local menuis_ouvrant_use	=	ptr_params.menuis_ouvrant_use
		local menuis_double_use		=	ptr_params.menuis_double_use
		
		local tablette_use					= ptr_params.tablette_use
		local tablette_hauteur 			= ptr_params.tablette_hauteur
		local tablette_debord 			= ptr_params.tablette_debord
		local tablette_cote 				= ptr_params.tablette_cote
		
		local volet							= ptr_params.volet
		local coffre							= ptr_params.coffre		
		
		
		--- Vecteurs directeurs ------------
		local vec_ep_dalle 	= [0,0,1] 		* 	ptr_plug.const_dalle_epaisseur		
		local vec_allege 		= if allege_use 		then 	[0,0,0] 
																	else		[0,0,1] *	allege_hauteur
		local vec_rtmb 		= if hauteur_use 	then 	[0,0,0] 
																	else		[0,0,1] *	( ptr_plug.etages_hauteur - (allege_hauteur + hauteur ) )				
		local norm_prof		= _normDir 	* rotateZ ( matrix3 1 ) 90				
		local vec_ht 				= if hauteur_use 	then 	[0,0,1] *	 ptr_plug.etages_hauteur
																	else		[0,0,1] * 	 hauteur				
		local vec_longueur 	= _normDir * longueur
		local norm_prof		= _normDir * rotateZ ( matrix3 1 ) 90
		local vec_prof			=  norm_prof * profondeur
		
		--- Points d'accroche ------------
		local id_ptAccroche_1 	= _ptsIDs_accroche[1]
		local id_ptAccroche_2 	= _ptsIDs_accroche[2]
		local id_ptAccroche_3 	= _ptsIDs_accroche[3]
		
		local ptAccroche_1		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_1	
		local ptAccroche_2		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_2	
		local ptAccroche_3		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_3	
		
		
	-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
		
		---- LA DALLE  -----------------------------------------------------------------------			
		-------	Creation des points 	--------
		local pt_2 		= ptAccroche_1		+ 	vec_longueur
		local pt_3 		= pt_2					+	vec_ep_dalle
		
		--- creation des points --------------
		local pts_pos 	= #( pt_2, pt_3 )
		local pts_ids 	= ptr_geo.points 	pts_pos		
		
		-------	Creation des faces 	--------
		if onConstruitLaDalle do (
			local nvlFace = ptr_geo.face 		#(	 id_ptAccroche_1, 		pts_ids[1], 		pts_ids[2], 		id_ptAccroche_2	)		
			ptr_geo.set_matID 	nvlFace	#mur
		)
		
		--- Result -------------
		pt_result_1 = pts_ids[1]
		pt_result_2 = pts_ids[2]
		
		
		
		---- LA BAIE -----------------------------------------------------------------------				
		-------	Creation des points 	--------
		--- mur d'allege ----
		local pt_bas 	= ptAccroche_2
		local pt_ht 	= ptAccroche_3
		
		local pt_1 		= pt_bas	+  vec_longueur
		local pt_2 		= pt_1		+  vec_allege + [0,0,decalage_epaisseur]
		local pt_3 		= pt_bas	+ 	vec_allege + [0,0,decalage_epaisseur]
		
		local pt_4 		= pt_bas	+ 	vec_ht
		local pt_5 		= pt_4		+ 	vec_longueur				
		local pt_6 		= pt_ht		+ 	vec_longueur
		local pt_7 		= pt_3		+ 	vec_prof
		local pt_8 		= pt_2		+ 	vec_prof
		local pt_9 		= pt_5		+ 	vec_prof
		local pt_10		= pt_4		+ 	vec_prof
		
		--- creation des points --------------
		local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8, pt_9, pt_10 )
		local pts_ids 	= ptr_geo.points 	pts_pos	
		
		--- Result -------------
		pt_result_3 = pts_ids[6]
		
		
		----- pour plus tard, ...  le raccord avec les menuiseries, et return -----
		local ids_pts_racc_menuis =#(pts_ids[7], pts_ids[8], pts_ids[9], pts_ids[10])
		
		-------	Creation des faces 	--------
		local nvlFace = ptr_geo.face 		#(	id_ptAccroche_2, 	pts_ids[1], 		pts_ids[2], 		pts_ids[3] )		 
		ptr_geo.set_matID 	nvlFace	#mur 	
		
		local nvlFace = ptr_geo.face 		#(	pts_ids[3], 		pts_ids[2], 		pts_ids[8] , 	pts_ids[7] )		 	
		if tablette_use and  onConstruitLaDalle	then		ptr_geo.set_matID 	nvlFace	#menuiserie
																		else 	ptr_geo.set_matID 	nvlFace	#mur
		
		local nvlFace = ptr_geo.face 		#(	pts_ids[10], 	pts_ids[9], 		pts_ids[5], 		pts_ids[4] )
		ptr_geo.set_matID 	nvlFace	#mur
		
		local nvlFace = ptr_geo.face 		#(	pts_ids[4], 		pts_ids[5], 		pts_ids[6], 		id_ptAccroche_3 )
		ptr_geo.set_matID 	nvlFace	#mur
		
		local nvlFace = ptr_geo.face 		#(	pts_ids[3], 		pts_ids[7], 		pts_ids[10],   	pts_ids[4] )
		ptr_geo.set_matID 	nvlFace	#mur
		
		local nvlFace = ptr_geo.face 		#(	pts_ids[8], 		pts_ids[2], 		pts_ids[5],   	pts_ids[9] )
		ptr_geo.set_matID 	nvlFace	#mur
		
		
		
		
		
		
		
		
		--- CADRE MENUISERIE ----------------------------------------------------------------------------------------------------------------		
		
		local vec_men_ep			= norm_prof	*	menuis_epaisseur
		local vec_men_lrg			=	_normDir		*	menuis_largeur
		local vec_men_ht				=	[0,0,1] 		*	menuis_largeur
		local vec_men_allegeHt	=	[0,0,1] 		*	menuis_allege_ht
		local vec_men_travHt		=	[0,0,1] 		*	menuis_trav_ht
		
		-------	Placement des points 	--------
		local pt_A	= ptr_geo.get_vertex	ids_pts_racc_menuis[1]		
		local pt_B	= ptr_geo.get_vertex	ids_pts_racc_menuis[2]		
		local pt_C	= ptr_geo.get_vertex	ids_pts_racc_menuis[3]		
		local pt_D	= ptr_geo.get_vertex	ids_pts_racc_menuis[4]
		
		local pt_1		= pt_A		+ 	vec_men_lrg 	+ 	vec_men_ht
		local pt_2		= pt_B		- 	vec_men_lrg 		+ 	vec_men_ht
		local pt_3		= pt_C		- 	vec_men_lrg 		- 	vec_men_ht
		local pt_4		= pt_D		+ 	vec_men_lrg 	- 	vec_men_ht
		
		local pt_5		= pt_1		+ 	vec_men_ep
		local pt_6		= pt_2		+ 	vec_men_ep
		local pt_7		= pt_3		+ 	vec_men_ep
		local pt_8		= pt_4		+ 	vec_men_ep
		
		
		--- creation des points --------------
		local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
		local pts_ids 	= ptr_geo.points 	pts_pos
		
		----- pour plus tard, ... 
		local pts_pourOuvrant	= #( pt_5, pt_6, pt_7, pt_8  )
		
		---- cadre ------
		local nvlFace = ptr_geo.face 		#(	ids_pts_racc_menuis[1]	, 			ids_pts_racc_menuis[2]	, 			ids_pts_racc_menuis[3]	, 			ids_pts_racc_menuis[4]	 ,
											pts_ids[4], 		pts_ids[3], 		pts_ids[2], 		pts_ids[1] , 	
											pts_ids[4], 		ids_pts_racc_menuis[4]	 )			
		ptr_geo.set_matID 	nvlFace	#menuiserie			
		
		local nvlFace = ptr_geo.face 		#(	pts_ids[1], 	pts_ids[2], 	pts_ids[6],   	pts_ids[5]  )	
		ptr_geo.set_matID 	nvlFace	#menuiserie	
		local nvlFace = ptr_geo.face 		#(	pts_ids[6], 	pts_ids[2], 	pts_ids[3],   	pts_ids[7]  )	
		ptr_geo.set_matID 	nvlFace	#menuiserie	
		local nvlFace = ptr_geo.face 		#(	pts_ids[7], 	pts_ids[3], 	pts_ids[4],   	pts_ids[8]  )	
		ptr_geo.set_matID 	nvlFace	#menuiserie	
		local nvlFace = ptr_geo.face 		#(	pts_ids[1], 	pts_ids[5], 	pts_ids[8],   	pts_ids[4]  )		
		ptr_geo.set_matID 	nvlFace	#menuiserie
		
		--- la face du fond -----------
-- 		if not menuis_ouvrant_use do (
		local nvlFace = ptr_geo.face 		#(	pts_ids[5], 	pts_ids[6], 	pts_ids[7],   	pts_ids[8]  )		
		ptr_geo.set_matID 	nvlFace	#vitrage
-- 		)
		
		
		
		
		--- TABLETTE  ----------------------------------------------------------------------------------------------------------------		
		if tablette_use and onConstruitLaDalle do (
			
			local vec_tab_ht		= 	[0,0,1] 		* tablette_hauteur
			local vec_tab_deb		= -norm_prof 	* tablette_debord
			local vec_tab_cote	= _normDir 	* tablette_cote					
			
			-------	Placement des points 	--------
			local pt_1 		= pt_bas	+  vec_allege 	- 	vec_tab_ht		-	vec_tab_cote	+ vec_tab_deb + [ 0,0, decalage_epaisseur ]
			local pt_2 		= pt_1		+  2 * vec_tab_cote 				+	vec_longueur 	
			local pt_3 		= pt_2		+ 	vec_tab_ht				
			local pt_4		= pt_1		+ 	vec_tab_ht
			
			local pt_5		= pt_1		-	vec_tab_deb
			local pt_6		= pt_2		-	vec_tab_deb			
			local pt_7		= pt_3		-	vec_tab_deb
			local pt_8		= pt_4		-	vec_tab_deb
			
			--- creation des points --------------
			local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8, pt_9, pt_10 )
			local pts_ids 	= ptr_geo.points 	pts_pos
			
			-------	Creation des faces 	--------
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[2], 		pts_ids[1] )
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[4] )	
			ptr_geo.set_matID 	nvlFace	#menuiserie					
			local nvlFace = ptr_geo.face 		#(	pts_ids[4], 		pts_ids[3], 		pts_ids[7] , 	pts_ids[8] )
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4], 		pts_ids[8] )
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			local nvlFace = ptr_geo.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7], 		pts_ids[3] )	
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			
		)
		
		
		
		
		
		
		
		---  ALLEGE  ----------------------------------------------------------------------------------------------------------------	
		if menuis_allege_use do (
			local vec_allege_ht = vec_men_ht * 1.5
			-------	Placement des points 	--------
			local pt_1 		= pt_bas	+ 	[0,0,1] * menuis_allege_ht	- 	 vec_allege_ht	 + vec_men_lrg + vec_prof
			local pt_2 		= pt_1		+	vec_longueur 			- 2 * vec_men_lrg 
			local pt_3 		= pt_2		+   vec_allege_ht	
			local pt_4		= pt_1		+ 	 vec_allege_ht
			
			local pt_5		= pt_1		+	vec_men_ep
			local pt_6		= pt_2		+	vec_men_ep			
			local pt_7		= pt_3		+	vec_men_ep
			local pt_8		= pt_4		+	vec_men_ep
			
			
			--- creation des points --------------
			local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
			local pts_ids 	= ptr_geo.points 	pts_pos
			
			
			-------	Creation des faces 	--------
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[2], 		pts_ids[1] )
			ptr_geo.set_matID 	nvlFace	#menuiserie						
			local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[4] )	
			ptr_geo.set_matID 	nvlFace	#menuiserie					
			local nvlFace = ptr_geo.face 		#(	pts_ids[4], 		pts_ids[3], 		pts_ids[7] , 	pts_ids[8] )
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			
-- 					-- la face vitre du bas
-- 					local pts_pos 	= #( 	 pts_pourOuvrant[1], pts_pourOuvrant[2] ,pt_6 , pt_5)
-- 					local pts_ids 	= ptr_geo.points 	pts_pos
-- 					local nvlFace = ptr_geo.face 		#(pts_ids[1], 		pts_ids[2]	, 		pts_ids[3] , 	pts_ids[4] )
-- 					ptr_geo.set_matID 	nvlFace	#vitrage			
			
			----- pour plus tard, ... 
-- 					pts_pourOuvrant[1]		= pt_8
-- 					pts_pourOuvrant[2]		= pt_7
			
		)
		
		
		---  TRAVERSE	  ----------------------------------------------------------------------------------------------------------------	
		if menuis_trav_use do (
			
			local vec_traverse_ht = vec_men_ht * 1.5
			-------	Placement des points 	--------
			local pt_1 		= pt_bas	+ 	[0,0,1] * menuis_trav_ht	- 	 vec_allege_ht	 + vec_men_lrg + vec_prof
			local pt_2 		= pt_1		+	vec_longueur 			- 2 * vec_men_lrg 
			local pt_3 		= pt_2		+   vec_allege_ht	
			local pt_4		= pt_1		+ 	 vec_allege_ht
			
			local pt_5		= pt_1		+	vec_men_ep
			local pt_6		= pt_2		+	vec_men_ep			
			local pt_7		= pt_3		+	vec_men_ep
			local pt_8		= pt_4		+	vec_men_ep
			
			
			--- creation des points --------------
			local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
			local pts_ids 	= ptr_geo.points 	pts_pos
			
			
			-------	Creation des faces 	--------
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[2], 		pts_ids[1] )
			ptr_geo.set_matID 	nvlFace	#menuiserie						
			local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[4] )	
			ptr_geo.set_matID 	nvlFace	#menuiserie					
			local nvlFace = ptr_geo.face 		#(	pts_ids[4], 		pts_ids[3], 		pts_ids[7] , 	pts_ids[8] )
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			
-- 					-- la face vitre du bas
-- 					local pts_pos 	= #( 	 pts_pourOuvrant[1], pts_pourOuvrant[2] ,pt_6 , pt_5)
-- 					local pts_ids 	= ptr_geo.points 	pts_pos
-- 					local nvlFace = ptr_geo.face 		#(pts_ids[1], 		pts_ids[2]	, 		pts_ids[3] , 	pts_ids[4] )
-- 					ptr_geo.set_matID 	nvlFace	#vitrage			
			
			----- pour plus tard, ... 
-- 					pts_pourOuvrant[1]		= pt_8
-- 					pts_pourOuvrant[2]		= pt_7
			
		)
		
		
		local pos_largeur_temp1 = pts_pourOuvrant[1]
		local pos_largeur_temp2 = pts_pourOuvrant[4]
		--- DIVISION  ----------------------------------------------------------------------------------------------------------------	
		for i = 1 to  menuis_divisions  do (
-- 				if menuis_double_use do (
			
			local largeur_vitre = ( distance	pts_pourOuvrant[1] 	pts_pourOuvrant[2] ) / ( menuis_divisions + 1 )
			
			-------	Placement des points 	--------
			local pt_1		= pts_pourOuvrant[1]   			- 		vec_men_lrg - vec_men_ep 	+ _normDir * largeur_vitre * i 
			local pt_2		= pt_1 + 2 * vec_men_lrg
			local pt_3		= pts_pourOuvrant[4]   			+ 		vec_men_lrg - vec_men_ep	+ _normDir * largeur_vitre * i 
			local pt_4		= pt_3  - 2 * vec_men_lrg
			
			local pt_5		= pt_1		+ 	vec_men_ep
			local pt_6		= pt_2		+ 	vec_men_ep
			local pt_7		= pt_3		+ 	vec_men_ep
			local pt_8		= pt_4		+ 	vec_men_ep
			
			--- creation des points --------------
			local pts_pos 	= #( pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
			local pts_ids 	= ptr_geo.points 	pts_pos
			
			---- faces ------
			local nvlFace = ptr_geo.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7],   	pts_ids[3]  )				
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3],   	pts_ids[4]  )				
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4],   	pts_ids[8]  )				
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			
			if menuis_ouvrant_use do (
				
				local pt_1_men = pt_1
				local pt_2_men = pt_2
				local pt_3_men = pt_3
				local pt_4_men = pt_4
				
				local vec_bandeau_ep = vec_men_ep/2
				
				-------	Placement des points 	--------
				local pt_1		= pt_1_men	+ vec_men_lrg * 3/4	-  	vec_bandeau_ep 	-  	vec_men_ht
				local pt_2		= pt_2_men 	- vec_men_lrg * 3/4	-  	vec_bandeau_ep 	-  	vec_men_ht
				local pt_3		= pt_3_men	- vec_men_lrg * 3/4	-  	vec_bandeau_ep 	+  vec_men_ht
				local pt_4		= pt_4_men  	+ vec_men_lrg * 3/4	-  	vec_bandeau_ep 	+  vec_men_ht
				
				local pt_5		= pt_1		+ 	vec_bandeau_ep
				local pt_6		= pt_2		+ 	vec_bandeau_ep
				local pt_7		= pt_3		+ 	vec_bandeau_ep
				local pt_8		= pt_4		+ 	vec_bandeau_ep
				
				--- creation des points --------------
				local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
				local pts_ids 	= ptr_geo.points 	pts_pos
				
				---- faces ------
				local nvlFace = 	ptr_geo.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7],   	pts_ids[3]  )					
				ptr_geo.set_matID 	nvlFace	#menuiserie			
				local nvlFace = 	ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3],   	pts_ids[4]  )					
				ptr_geo.set_matID 	nvlFace	#menuiserie			
				local nvlFace = 	ptr_geo.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4],   	pts_ids[8]  )				
				ptr_geo.set_matID 	nvlFace	#menuiserie			
				
			)
		)
		
		
		
		
		---- Result final -----------------------------------------------------------------------
		#( pt_result_1, pt_result_2, pt_result_3 )
	
	) ---- fin  compo_fnConstruire	--------
	



	
	

------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Modele de base.ms"
--- Creation de la structure mere	-----------------
str_modelBase 	tooltip:compo_tooltip		nom:compo_nom	type:compo_type	params:(compo_params())	dialog:compo_dialog	fnConstruire:compo_fnConstruire

	
	
	
	
	
	
