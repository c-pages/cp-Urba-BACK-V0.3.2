
	
( ----	FileIn ----
	
	

------ parametres de base	-----------------------------
compo_nom 		= "Baie simple"	
compo_type		=	#baie
compo_toolTip 	=	"Ouverture dans un mur."



--- les parametres du composant	---------
struct compo_params	(
		
		--- global	-------------
		longueur						= 100,
		etirable							=	true,
		hauteur							= 210,
		profondeur						= 20,		
		allege_hauteur 		 		= 100,
		
		arc_use							=	 false,
		arc_rayon						=	 70,
	
		--- Menuiseries	-------------
		sequence 						= #(),		---- La sequence qui compose la baie ( #fenetre, #fixe, #porte , etc ...)	----------
		traverses 						= #(),		---- liste des traverses par hauteur	----------
		tablette							=	true,
		
		--- Volets	-------------
		volet								= undefined,			----		----------
	
		
	private
		longueur_etirer =0,
	public
		fn set_longueur_etirer 	_lg = longueur_etirer = _lg,
		fn get_longueur_etirer = (
			local result = longueur_etirer
-- 			longueur_etirer = 0
			result
		)
)

--- les rollout du composant	---------
rollout compo_dialog "Baie" width:433 height:500
(
	local m_rollPrt
	local	m_plug
	local m_compo
	local m_dialog_menuiserie	
	
	---- golbal --------------
	edittext 'edt_nom' "" pos:[3,3] width:187 height:16 align:#left
	label 'lbl19' "Longeur:" pos:[15,36] width:49 height:13 align:#left
	spinner 'spn_longueur' "" pos:[116,36] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	label 'lbl21' "Hauteur:" pos:[15,66] width:49 height:13 align:#left
	spinner 'spn_hauteur' "" pos:[116,66] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	GroupBox 'grp1' "Global" pos:[6,21] width:187 height:134 align:#left
	label 'lbl24' "Allège pleine :" pos:[15,96] width:77 height:13 align:#left
	spinner 'spn_allege' "" pos:[116,96] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	label 'lbl29' "Profondeur:" pos:[15,81] width:59 height:13 align:#left
	spinner 'spn_profondeur' "" pos:[116,81] width:70 height:16 range:[-5,100000,0] type:#worldunits scale:1 align:#left
	
	---- traverses --------
	GroupBox 'grp_traverses' "Traverses horizontales" pos:[13,274] width:173 height:104 align:#left
	listbox 'lbx_traverses' "" pos:[21,309] width:158 height:3 align:#left
	button 'btn_ajouter_traverse' "Nouv." pos:[21,293] width:35 height:16 align:#left
	button 'btn_supprimer_traverse' "Supp." pos:[142,293] width:35 height:16 align:#left
	label 'lbl_traverses_ht' "Hauteur:" pos:[21,356] width:49 height:13 align:#left
	spinner 'spn_traverse_ht' "" pos:[109,355] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
	
	---- sequence --------
	GroupBox 'grp_sequence' "Séquence" pos:[13,186] width:173 height:86 align:#left
	listbox 'lbx_sequence' "" pos:[21,222] width:142 height:3 align:#left
	button 'btn_ajouter_element' "Nouv." pos:[21,205] width:35 height:16 align:#left
	button 'btn_supprimer_element' "Supp." pos:[127,205] width:35 height:16 align:#left
	button 'btn_dupliquer_element' "Dup." pos:[55,205] width:35 height:16 toolTip:"Dupliquer l'élément" align:#left
	
	---- volet --------
	GroupBox 'grp_volet' "Volets" pos:[5,418] width:187 height:50 align:#left
	dropdownList 'ddl_volet' "" pos:[17,436] width:161 height:21 items:#("Aucun", "Roulant", "Battant simple", "Battant double") align:#left
	
	button 'btn_sequence_monter' "/\\" pos:[164,221] width:16 height:16 toolTip:"Monter l'élément" align:#left
	button 'btn_sequence_descendre' "\/" pos:[164,236] width:16 height:16 toolTip:"Descendre l'élément" align:#left
	GroupBox 'grp_menuis' "Menuiseries" pos:[6,169] width:187 height:233 align:#left
	
	checkbox 'chk_tablette' "Tablette" pos:[18,382] width:163 height:15 align:#left
		
	checkbox 'chk_etirable' "Etirable" pos:[14,52] width:98 height:15 align:#left
		
	
		
	label 'lbl_rayon' "Rayon :" pos:[15,130] width:49 height:13 align:#left
	spinner 'spn_arc_rayon' "" pos:[116,130] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	checkbox 'chk_arc' "Arc" pos:[14,116] width:98 height:15 align:#left
		
		
		fn actualiser =(
			
			--- global ------
			spn_longueur.value 		= m_compo.params.longueur
			chk_etirable.checked		= m_compo.params.etirable
			edt_nom.text 				=	m_compo.nom
			spn_profondeur.value 	=	m_compo.params.profondeur	
			spn_hauteur.value 		= m_compo.params.hauteur
			spn_allege.value 			=	m_compo.params.allege_hauteur
			
			chk_arc.checked			=	m_compo.params.arc_use
			lbl_rayon.enabled			=	m_compo.params.arc_use
			spn_arc_rayon.enabled	=	m_compo.params.arc_use
			
			if chk_arc.checked then (
				spn_arc_rayon.indeterminate = false
				spn_arc_rayon.value		=	m_compo.params.arc_rayon				
			) else
				spn_arc_rayon.indeterminate = true
			
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
			lbx_sequence.items		=	for element in m_compo.params.sequence collect ( element.nom )
			if lbx_sequence.selection == 0 and lbx_sequence.items.count > 0 do
				lbx_sequence.selection = 1
			
			local sequence_edition	= lbx_sequence.selection != 0
			btn_supprimer_element.enabled	= sequence_edition
			btn_dupliquer_element.enabled	= sequence_edition
			
			chk_tablette.checked = m_compo.params.tablette
			
			--- volet -----------
			local volets_noms = #("-aucun-")
			for constr in m_plug.core.get_constructeurs #facVolets do
				append volets_noms  constr.nom			
			ddl_volet.items = for voletNom in volets_noms collect voletNom
			
			if m_compo.params.volet == undefined then
				ddl_volet.selection = 1
			else 
				ddl_volet.selection = ( findItem volets_noms 	m_compo.params.volet.nom )
-- 				
-- 			format "volets_noms ---> %\n"  volets_noms
-- 			if m_compo.params.volet != undefined then (
-- 				format "m_compo.params.volet.nom  ---> %\n"  m_compo.params.volet.nom 
-- 			format " findItem volets_noms 	 ---> %\n"  ( findItem volets_noms 	m_compo.params.volet.nom )
-- 			
-- 			)
-- 			insertItem "-aucun-"  ddl_volet.items  1
-- 			if m_compo.params.volet 
-- 			ddl_volet.selection 	= m_compo.params.volet 
			
			
			
			
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
		
	
	
	
	
		
		
	
	
	
	
	
	
	
	
	on edt_nom entered txt 	do
	(
		m_compo.nom = txt
		m_rollPrt.actualiser  	sans_params_1:true
		m_rollPrt.changer_un_truc ()
	)
	on spn_longueur changed val 	do
	(
			m_compo.params.longueur 					= val
				format "m_compo.params.arc_rayon : %\n" m_compo.params.arc_rayon
				format "val / 2 : %\n" (val / 2)
				format "m_compo.params.arc_rayon < val / 2 : %\n" (m_compo.params.arc_rayon < (val / 2) )
			if  m_compo.params.arc_rayon < (val / 2) do (
				format "---> PLUS grand\n"
				m_compo.params.arc_rayon 	= val / 2 +.001
				actualiser ()
			)
			m_rollPrt.actualiser 	sans_params_1:true
			m_rollPrt.changer_un_truc ()
		)
	on spn_hauteur changed val 	do
	(
			m_compo.params.hauteur 					= val
			m_rollPrt.changer_un_truc ()
		)
	on spn_allege changed val 	do
	(
			m_compo.params.allege_hauteur 	= val
			m_rollPrt.changer_un_truc ()
		)
	on spn_profondeur changed val 	do
	(
			m_compo.params.profondeur	= val
			m_rollPrt.changer_un_truc ()
		)
	on lbx_traverses selected _index do
		actualiser ()
	on btn_ajouter_traverse pressed do
	(
			ajouter_traverse	()
			m_rollPrt.changer_un_truc ()
		)
	on btn_supprimer_traverse pressed do
	(
			supprimer_traverse	()
			m_rollPrt.changer_un_truc ()
		)
	on spn_traverse_ht changed val 	do
	(
		m_compo.params.traverses[ lbx_traverses.selection ] = val
		actualiser ()
		m_rollPrt.changer_un_truc ()
	)
	on lbx_sequence selected _index  do
	(
			subCompo = m_compo.params.sequence[ _index ] 
			m_rollPrt.set_param_2		subCompo	
		
		)
	on btn_ajouter_element pressed do
	( 
		
		m_plug.core.get_menu_contructeur #facMenuis
		
	)
	on btn_supprimer_element pressed do
	( 
			
			
			deleteItem 	m_compo.params.sequence		lbx_sequence.selection
			
			lbx_sequence.selection 	-= 1 
			
			actualiser () 
			m_rollPrt.changer_un_truc ()
		)
	on btn_dupliquer_element pressed do
	(
			
		)
	on ddl_volet selected _index  	do
	(
			if _index == 1 then 
				m_compo.params.volet  = undefined
			else (
				local constrs 		= m_plug.core.get_constructeurs 	#facVolets
	-- 		format "m_plug.core.get_constructeurs 	#facVolets ---> %\n"  (m_plug.core.get_constructeurs 	#facVolets)
				local nv_volet 	= m_plug.core.creer_element 		#facVolets		idConstructeur:constrs[_index - 1 ].type
	-- 		format "nv_volet ---> %\n"  nv_volet
				m_compo.params.volet  = nv_volet
			)
			m_rollPrt.changer_un_truc ()
			actualiser ()
		)
	on btn_sequence_monter pressed do
	(
			
				
				if lbx_sequence.selection > 1 do (
					local index = lbx_sequence.selection 
					local item = m_compo.params.sequence[ lbx_sequence.selection  ]
					
					--- on bouge le compo -----------
					deleteItem 	m_compo.params.sequence		 index
					insertItem 	item			m_compo.params.sequence			(index - 1)
					lbx_sequence.selection  = index - 1
					m_rollPrt.changer_un_truc ()
					actualiser ()
				)
		)
	on btn_sequence_descendre pressed do
	(
			
				
				if lbx_sequence.selection <  lbx_sequence.items.count  do (
					
					local index = lbx_sequence.selection 
					local item = m_compo.params.sequence[ lbx_sequence.selection  ]
					
					--- on bouge le compo -----------
					deleteItem 	m_compo.params.sequence		 index
					insertItem 	item			m_compo.params.sequence			(index + 1)
					lbx_sequence.selection  = index + 1
					m_rollPrt.changer_un_truc ()
					actualiser ()
				)
		)
	on chk_tablette changed state do
	(
			m_compo.params.tablette = state
			m_rollPrt.changer_un_truc ()
		)
	on chk_etirable changed state do
	(
		
			m_compo.params.etirable = state
			m_rollPrt.actualiser 	sans_params_1:true
			m_rollPrt.changer_un_truc ()
		)
	on spn_arc_rayon changed val 	do
	(
		if val < m_compo.params.longueur / 2 do 
			val = m_compo.params.longueur / 2 +.001
			m_compo.params.arc_rayon 					= val
			m_rollPrt.changer_un_truc ()
					actualiser ()
		)
	on chk_arc changed state do
	(
		
			m_compo.params.arc_use = state
			m_rollPrt.actualiser 	sans_params_1:true
			m_rollPrt.changer_un_truc ()
					actualiser ()
		)
)
	















------ la fonction de construction	---------
fn compo_fnConstruire  		_plug			_ptsIDs_accroche		norm_dir:		this: 	onConstruitLaDalle:false	= (
	
		local onCreer_menuiserie_si_sequenceVide = false
	
		--- Result -------------
		local pt_result_1, pt_result_2, pt_result_3

	-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local ptr_composant  	= 	this
		local ptr_params		  	= 	this.params
		local ptr_geo 				= 	ptr_plug.core.get_geo ()
	
	-------------  constantes 			-----------------------------------------------------------------------------------------------------------------
		local menuis_largeur				=	ptr_plug.const_menuiseries_largeur
		local menuis_epaisseur			=	ptr_plug.const_menuiseries_epaisseur
		local menuis_allege_ht			=	ptr_plug.const_menuiseries_allege_ht
		local menuis_trav_ht			=	ptr_plug.const_menuiseries_trav_ht
	
	-------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
	
		--- Points d'accroche ------------
		local id_ptAccroche_1 	= _ptsIDs_accroche[1]
		local id_ptAccroche_2 	= _ptsIDs_accroche[2]
		local id_ptAccroche_3 	= _ptsIDs_accroche[3]
		
		local ptAccroche_1		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_1	
		local ptAccroche_2		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_2	
		local ptAccroche_3		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_3	
		
		local	etage_hauteur				=	distance ptAccroche_2 	ptAccroche_3
		local longueur						= ptr_params.longueur	+ ptr_params.get_longueur_etirer ()
		
		local allege_hauteur 		 		= ptr_params.allege_hauteur
		local hauteur						= if ptr_params.hauteur == 0 	then	etage_hauteur --	- decalage_epaisseur
																									else 	ptr_params.hauteur --+ allege_hauteur
		local baie_hauteur 				= hauteur - allege_hauteur
		local profondeur					= ptr_params.profondeur		
		local	retombe						= etage_hauteur - (allege_hauteur + hauteur ) 
		
		local	sequence						= ptr_params.sequence
		
		local	vitrage_ep						=	ptr_plug.const_vitrage_epaisseur
		
		local		tablette_hauteur		= 5
		local		tablette_debord			= 5
		local		tablette_cote				= 5
		
		
		
		---- on gere le volet -----
		-- un reset pour mise a jour ------------
		if ptr_params.volet != undefined  and superclassof ptr_params.volet  !=	StructDef do
			ptr_params.volet = undefined
		
		local volet_empriseVert  = if ptr_params.volet != undefined 	 then  ( ptr_params.volet.params.get_emprise_verticale() )
																							else 0
		
	-------------  VECTEURS DIRECTEURS  		-----------------------------------------------------------------------------------------------------------------
		local norm_prof			= norm_dir 	* rotateZ ( matrix3 1 ) 90		
		
		local vec_ep_dalle 	= 	[0,0,1] 		* 	ptr_plug.const_dalle_epaisseur		
		local vec_allege 		= 	[0,0,1] 		*	allege_hauteur
		local vec_rtmb 		= 	[0,0,1] 		*	retombe		
		local vec_ht 			= 	[0,0,1] 		*	hauteur				
		local vec_longueur 	= norm_dir 	*	longueur
		local vec_murEp		=	norm_prof 	*	profondeur	+	norm_prof		*	menuis_epaisseur--	norm_prof *	ptr_plug.const_murExt_epaisseur
		
		local vec_volet_empriseVert  =  [0,0,1] * volet_empriseVert
		
		
		local vec_men_nu				=  norm_prof 	*	profondeur
		local vec_men_ep				=	norm_prof		*	menuis_epaisseur
		local vec_men_lrg				=	norm_dir		*	menuis_largeur
		local vec_men_ht				=	[0,0,1] 			*	menuis_largeur
		local vec_men_allegeHt		=	[0,0,1] 			*	menuis_allege_ht
		local vec_men_travHt		=	[0,0,1] 			*	menuis_trav_ht
		
		local vec_vitrage_ep			=	norm_prof		*	vitrage_ep
		
		local vec_tab_ht			= 	[0,0,1] 			* tablette_hauteur
		local vec_tab_deb		= -norm_prof 	* tablette_debord
		local vec_tab_cote		= norm_dir 		* tablette_cote	
		
		
		
		
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
		
		
		--- tablete ou pas -----		
		local onConstruit_laTablette = this.params.tablette 
			if onConstruit_laTablette do
				if allege_hauteur == 0  and not onConstruitLaDalle do
					onConstruit_laTablette = false		
			
			
		---- LA BAIE -----------------------------------------------------------------------				
		-------	Creation des points 	--------
		--- mur d'allege ----
		local pt_bas 	= ptAccroche_2
		local pt_ht 	= ptAccroche_3
		
		local pt_1 		= pt_bas	+  vec_longueur
		local pt_2 		= pt_1		+  vec_allege 		--		+ [0,0,decalage_epaisseur]
		local pt_3 		= pt_bas	+ 	vec_allege 		--		+ [0,0,decalage_epaisseur]
		
		local pt_4 		= pt_bas	+ 	vec_ht
		local pt_5 		= pt_4		+ 	vec_longueur				
		local pt_6 		= pt_ht		+ 	vec_longueur
		local pt_7 		= pt_3		+ 	vec_murEp
		local pt_8 		= pt_2		+ 	vec_murEp
		local pt_9 		= pt_5		+ 	vec_murEp
		local pt_10		= pt_4		+ 	vec_murEp
		
		--- creation des points --------------
		local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8, pt_9, pt_10 )
		local pts_ids 	= ptr_geo.points 	pts_pos	
		
		--- Result -------------
		pt_result_3 		= pts_ids[6]
		
		----- pour plus loin dans le code ...  le raccord avec les menuiseries, -----
		local pts_baie	= #( pt_3+ vec_men_nu, pt_4+ vec_men_nu, pt_5+ vec_men_nu, pt_2 + vec_men_nu)
		
		
		-------	Creation des faces 	--------
		ptr_geo.face 		#(	id_ptAccroche_2, 	pts_ids[1], 		pts_ids[2], 		pts_ids[3] )		matID:#mur  
		
		local nvlFace = ptr_geo.face 		#(	pts_ids[3], 		pts_ids[2], 		pts_ids[8] , 	pts_ids[7] )		 
		if onConstruit_laTablette 	then		ptr_geo.set_matID 	nvlFace	#menuiserie
												else 		ptr_geo.set_matID 	nvlFace	#mur
		
		---- construction de l'arc ------------
		if ptr_params.arc_use then (
			
			fn get_arc 			longueur:		rayon:		norm_dir:	pt_origine:		nbr_division:12		=(
				
				local result = #(pt_origine)
				
				local dX 				= ( longueur / 2 )
				local dZ 				= sqrt ( rayon^2 - dX ^2 )
				
				for i = 1 to	nbr_division	do (
					local nv_pt = [0,0,0]
					
					nv_pt.x = 		i * ( longueur / nbr_division ) - dX
					nv_pt.z = 		sqrt ( rayon^2 - nv_pt.x ^2 )
					
					nv_pt.x +=		dX
					nv_pt.z -= 	dZ
					
					local pt_result = pt_origine + norm_dir * nv_pt.x
					pt_result.z += nv_pt.z
					append	result		pt_result 
				)
				result
			) -- fin fn get_arc

			local pts_arc_1 = get_arc  longueur:ptr_params.longueur	rayon:ptr_params.arc_rayon		norm_dir:norm_dir	pt_origine:pt_4	
			--- la face au dessus de la baie --------------
			ptr_geo.face 		( pts_arc_1 + #(	pts_ids[6], 		id_ptAccroche_3 ))		matID:#mur 
			
			--- la face au fond de  l'arc --------------
			local pts_arc_2 = get_arc  longueur:ptr_params.longueur	rayon:ptr_params.arc_rayon		norm_dir:norm_dir	pt_origine:(pt_10	 - vec_men_ep  )
			local pts_arc_2_inv = for i = pts_arc_2.count to 1 by	-1	collect	pts_arc_2[i]
			ptr_geo.face 	 pts_arc_2_inv 	matID:#mur 
			
			
			---- epaisseur de l'arc ----------
			for i = 1 to pts_arc_1.count - 1 do (
				
			local face_deLarc = ptr_geo.face 	#(pts_arc_1[i+1], pts_arc_1[i ], pts_arc_2[i], pts_arc_2[i+1])		matID:#mur   smGrp:13
-- 			format  "face_deLarc :%\n	" (face_deLarc	)
-- 			format  "polyop.getFaceSmoothGroup :%\n	" (polyop.getFaceSmoothGroup _plug.delegate	 face_deLarc	)
			)
			
			
			
		) else (
		---- construction san arc ------------
			-- face horizontale retombée -----
			ptr_geo.face 		#(	pts_ids[10], 	pts_ids[9], 		pts_ids[5], 		pts_ids[4] )				matID:#mur 
			-- face verticale retombée -----
			ptr_geo.face 		#(	pts_ids[4], 		pts_ids[5], 		pts_ids[6], 		id_ptAccroche_3 )		matID:#mur 
			
		)
		ptr_geo.face 		#(	pts_ids[3], 		pts_ids[7], 		pts_ids[10],   	pts_ids[4] )				matID:#mur 
		ptr_geo.face 		#(	pts_ids[8], 		pts_ids[2], 		pts_ids[5],   		pts_ids[9] )				matID:#mur 
		
		
		
		-------	  MENUISERIE -	CADRE 	---------------------------------------------------------------------------------------------------------------		
		
		
		--- menuiserie du haut	------------
		local pt_menuiserie_ht				=	pts_baie[2] -  vec_men_ht - vec_volet_empriseVert
		local vecTMP_long 	= (pts_baie[3] - pts_baie[2] ) 
		if sequence.count == 0 and 	onCreer_menuiserie_si_sequenceVide or sequence.count != 0 do
			ptr_geo.tube		pt_menuiserie_ht		vecTMP_long		vec_men_ht				   vec_men_ep			matID:#menuiserie 
		
		local pt_pourVolet = pt_menuiserie_ht + vec_men_ht
		
		--- menuiserie de gauche	------------
		local vecTMP_ht 	= ( pts_baie[2] - pts_baie[1] )	- vec_men_ht		 - vec_volet_empriseVert
		if sequence.count == 0 and 	onCreer_menuiserie_si_sequenceVide or sequence.count != 0 do
			ptr_geo.tube		pt_menuiserie_ht		-vecTMP_ht		vec_men_lrg      vec_men_ep				matID:#menuiserie --	flip:true
		
		
		
		
		--- si besoin on fait la menuiserie du bas	et le vitrage	---------
		if sequence.count == 0 then (
			if onCreer_menuiserie_si_sequenceVide		then (
				ptr_geo.face 		#(	pts_ids[7], 	pts_ids[8], 		pts_ids[9], 		pts_ids[10] )				matID:#mur 
				
				--- menuiserie du bas ------------
				local ptTmp					=	pts_baie[1]  +  vec_men_lrg + vec_men_ht
				local vecTMP_longBas 	= vecTMP_long - 2*vec_men_lrg
				ptr_geo.tube		ptTmp		vecTMP_longBas		-vec_men_ht		vec_men_ep				matID:#menuiserie 
				
				--- menuiserie de droite	------------
				local ptTmp			=	pts_baie[3]  -  vec_men_lrg - vec_men_ht  - vec_volet_empriseVert
				ptr_geo.tube		ptTmp		-vecTMP_ht		vec_men_lrg		vec_men_ep				matID:#menuiserie 	
				
				--- vitrage	------------
				local ptTmp					=	pts_baie[1]  +  vec_men_lrg + vec_men_ht + ( (vec_men_ep - vec_vitrage_ep )/ 2 )
				local vecTMP_htVitr		= vecTMP_ht 	- 	vec_men_ht 
				ptr_geo.tube		ptTmp		vecTMP_htVitr		vecTMP_longBas	vec_vitrage_ep				matID:#vitrage 
				
			)	else 
				ptr_geo.face 		#(	pts_ids[7], 	pts_ids[8], 		pts_ids[9], 		pts_ids[10] )				matID:#mur 
		)  else  (
		
			
			
		--------- la SEQUENCE de MENUISERIE ----------------------------------------------------------------		
			
		---- ANALYSE	---------------
			--- on cherche la longueur pour chaque div de menuiserie	----------
			
			local longueur_a_diviser = longueur - menuis_largeur
			local nbr_div	=	0
			for menuis in sequence do (
				if menuis.params.longueur  == 0 then
					nbr_div+=1
				else longueur_a_diviser -= menuis.params.longueur 
				longueur_a_diviser -= menuis_largeur
			)
			if	nbr_div	==	0  do nbr_div	= 1
			local longueur_div = longueur_a_diviser / nbr_div	--- ( nbr_div - 1 ) * menuis_largeur
			
			
			
		---- CONSTRUCTION	---------------
			-- on construit la sequence  des menuiseries	--------------------
			local pt_menuis = pts_baie[1]  + vec_men_lrg 
			local vec_menDivVert_ht 	= ( pts_baie[2] - pts_baie[1] )	- vec_men_ht  	- vec_volet_empriseVert	
			local menuis_precedant
			for i = 1 to sequence.count	do (
				local		menuis = sequence[i]
				
				
				-- la longueur de l'element ---------------
				local 	menuis_aReseter = false
				if menuis.params.longueur == 0 do (
					menuis.params.longueur  = longueur_div -- menuis_largeur
					menuis_aReseter = true
				)
				
				
				-- on construit la menuiserie --------
				local inverse_ouverture
				if menuis_precedant != undefined and menuis_precedant.type == menuis.type then
					inverse_ouverture = true
				else 
					inverse_ouverture = false
				
-- 				format "menuis.type :%\n" menuis.type
-- 				format "inverse_ouverture :%\n" inverse_ouverture
				
				menuis.construire		_plug		pt_menuis		 		norm_dir:norm_dir		dist_hauteur:(baie_hauteur - volet_empriseVert )		ptr_baie:this 	 inverse_ouverture:inverse_ouverture
				menuis_precedant = menuis
				
				pt_menuis += norm_dir * menuis.params.longueur + norm_dir * menuis_largeur
				local on_construitLaMenuiserieVerticale = true
				if i < sequence.count do (
					menuis_suivant = sequence[i+1]
					if menuis.type == #fenetre and menuis_suivant.type ==#fenetre do (
						on_construitLaMenuiserieVerticale = false
					)
				)
				--- on construit la menuiserie verticale -----------
				if on_construitLaMenuiserieVerticale do
					ptr_geo.tube		pt_menuis		vec_menDivVert_ht		-vec_men_lrg      vec_men_ep		matID:#menuiserie
				
				-- si on a changé la longueur de la menuiserie on reset ------
				if menuis_aReseter do menuis.params.longueur = 0
				
			)
			
		) --- fin else sequence
		
		
		
		-------	  TABLETTE 	---------------------------------------------------------------------------------------------------------------			
	
		
		if onConstruit_laTablette		do (
			
			
			-------	Placement des points 	--------
			local pt_1 		= pt_bas	+  vec_allege 	- 	vec_tab_ht		-	vec_tab_cote	+ vec_tab_deb
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
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[2], 		pts_ids[1] )		 	matID:#menuiserie
			local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[4] )		 	matID:#menuiserie
			local nvlFace = ptr_geo.face 		#(	pts_ids[4], 		pts_ids[3], 		pts_ids[7] , 	pts_ids[8] )		 	matID:#menuiserie
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4], 		pts_ids[8] )		 	matID:#menuiserie	
			local nvlFace = ptr_geo.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7], 		pts_ids[3] )		 	matID:#menuiserie	
			
		)
		
		
		
		if ptr_params.volet != undefined do  (
			ptr_params.volet.params.longueur 		= longueur
			ptr_params.volet.construire		_plug			pt_pourVolet		 		norm_dir:norm_dir		dist_hauteur:( baie_hauteur )			baie_parent:this
			ptr_params.volet.params.longueur 		= 0
			
		)
		
		
		
		
		---- Result final -----------------------------------------------------------------------
		#( pt_result_1, pt_result_2, pt_result_3 )
	)
	


	
	

------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur  	tooltip:compo_tooltip		nom:compo_nom	type:compo_type	params:(compo_params())	dialog:compo_dialog	fnConstruire:compo_fnConstruire

	
	
	
	
	
	
) ----	FileIn ----


	
