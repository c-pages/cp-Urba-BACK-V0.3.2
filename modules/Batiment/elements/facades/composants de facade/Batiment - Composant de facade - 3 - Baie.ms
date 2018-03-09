
	
( ----	FileIn ----
	
	

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
		
		--- Menuiseries	-------------
		sequence 						= #(),		---- La sequence qui compose la baie ( #fenetre, #fixe, #porte , etc ...)	----------
		traverses 						= #(),		---- liste des traverses par hauteur	----------
		tablette							=	true,
		
		--- Volets	-------------
		volet								= 1,			----	1:Aucun		2:roulants		3:battants	----------
		volet_double					= false			----	pour les 'Battants' 	----------
		
)

--- les rollout du composant	---------
rollout compo_dialog "Baie" width:433 height:747
(
	local m_rollPrt
	local	 m_plug
	local m_compo
	local m_dialog_menuiserie	
		
		---- golbal --------------
	edittext 'edt_nom' "" pos:[3,3] width:187 height:16 align:#left
	label 'lbl19' "Longeur:" pos:[15,36] width:49 height:13 align:#left
	spinner 'spn_longueur' "" pos:[116,36] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	label 'lbl21' "Hauteur:" pos:[15,51] width:49 height:13 align:#left
	spinner 'spn_hauteur' "" pos:[116,51] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	GroupBox 'grp1' "Global" pos:[6,21] width:187 height:83 align:#left
	label 'lbl24' "Allège pleine :" pos:[15,81] width:77 height:13 align:#left
	spinner 'spn_allege' "" pos:[116,81] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	label 'lbl29' "Profondeur:" pos:[15,66] width:59 height:13 align:#left
	spinner 'spn_profondeur' "" pos:[116,66] width:70 height:16 range:[-5,100000,0] type:#worldunits scale:1 align:#left
			
			---- traverses --------
	GroupBox 'grp_traverses' "Traverses horizontales" pos:[16,218] width:165 height:104 align:#left
	listbox 'lbx_traverses' "" pos:[24,253] width:150 height:3 align:#left
	button 'btn_ajouter_traverse' "+" pos:[24,233] width:18 height:18 align:#left
	button 'btn_supprimer_traverse' "-" pos:[41,233] width:18 height:18 align:#left
	label 'lbl_traverses_ht' "Hauteur:" pos:[24,300] width:49 height:13 align:#left
	spinner 'spn_traverse_ht' "" pos:[105,299] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
		
		---- sequence --------
	GroupBox 'grp_sequence' "Séquence" pos:[16,130] width:165 height:86 align:#left
	listbox 'lbx_sequence' "" pos:[24,166] width:150 height:3 align:#left
	button 'btn_ajouter_element' "+" pos:[24,147] width:18 height:18 align:#left
	button 'btn_supprimer_element' "-" pos:[41,147] width:18 height:18 align:#left
	button 'btn_dupliquer_element' "Dup." pos:[58,147] width:35 height:18 toolTip:"Dupliquer l'élément" align:#left
	-- 	button 'btn_instancier_element' "Inst." pos:[83,232] width:35 height:18 align:#left
	button 'btn_editer_element' "Edit." pos:[138,147] width:35 height:18 align:#left
			
			---- volet --------
	GroupBox 'grp_volet' "Volets" pos:[5,350] width:187 height:50 align:#left
	dropdownList 'ddl_volet' "" pos:[17,368] width:161 height:21 items:#("Aucun", "Roulant", "Battant simple", "Battant double") align:#left
		
	
	button 'btn_sequence_monter' "/\\" pos:[104,147] width:18 height:18 toolTip:"Monter l'élément" align:#left
	button 'btn_sequence_descendre' "\/" pos:[121,147] width:18 height:18 toolTip:"Descendre l'élément" align:#left
	GroupBox 'grp_menuis' "Menuiseries" pos:[6,113] width:187 height:233 align:#left
	
	 	
		
	checkbox 'chk_tablette' "Tablette" pos:[18,326] width:163 height:15 align:#left
		
		
		
		fn actualiser =(
			
			--- global ------
			spn_longueur.value 		= m_compo.params.longueur
			edt_nom.text 				=	m_compo.nom
			spn_profondeur.value 	=	m_compo.params.profondeur	
			spn_hauteur.value 		= m_compo.params.hauteur
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
			
			---- creation du menu ------------
-- 			local constructeurs_noms = m_plug.core.get_menuiserie_constructeursNoms ()
			
			--- sequence -----------
			lbx_sequence.items		=	for element in m_compo.params.sequence collect ( element.nom )
-- 			if lbx_sequence.selection == 0 and lbx_sequence.items.count > 0 do
-- 				lbx_sequence.selection = 1
			local sequence_edition	= lbx_sequence.selection != 0
			btn_supprimer_element.enabled	= sequence_edition
			btn_dupliquer_element.enabled	= sequence_edition
-- 			btn_instancier_element.enabled	= sequence_edition
-- 			btn_editer_element.enabled		= sequence_edition
			
			chk_tablette.enabled = m_compo.params.tablette
			
			--- volet -----------
			ddl_volet.selection 	= m_compo.params.volet 
			
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
		fn editer_element = (
-- 			m_dialog_menuiserie = ( m_plug.core.get_mgr_facMenuiseries () ).ouvrir_dialog ()	
	-- 		createDialog	m_dialog_menuiserie	
			local menuis = m_compo.params.sequence[ lbx_sequence.selection ]
			m_rollPrt.set_ssComposant		menuis
-- 			format "menuis :%\n" menuis
		)
		
	
		
	
	
		
	on edt_nom entered txt 	do
	(
		m_compo.nom = txt
		m_rollPrt.actualiser ()
		m_rollPrt.on_a_change_un_truc ()
	)
	on spn_longueur changed val 	do (
		m_compo.params.longueur 					= val
		m_rollPrt.actualiser 	sans_subRoll_1:true
		m_rollPrt.on_a_change_un_truc ()
	)
	on spn_hauteur changed val 	do (
		m_compo.params.hauteur 					= val
		m_rollPrt.on_a_change_un_truc ()
	)
	on spn_allege changed val 	do (
		m_compo.params.allege_hauteur 	= val
		m_rollPrt.on_a_change_un_truc ()
	)
	on spn_profondeur changed val 	do (
		m_compo.params.profondeur	= val
		m_rollPrt.on_a_change_un_truc ()
	)
	on lbx_traverses selected _index do
		actualiser ()
	on btn_ajouter_traverse pressed do (
		ajouter_traverse	()
		m_rollPrt.on_a_change_un_truc ()
	)
	on btn_supprimer_traverse pressed do (
		supprimer_traverse	()
		m_rollPrt.on_a_change_un_truc ()
	)
	on spn_traverse_ht changed val 	do
	(
					m_compo.params.traverses[ lbx_traverses.selection ] = val
					actualiser ()
		m_rollPrt.on_a_change_un_truc ()
	
				)
	on lbx_sequence doubleClicked arg do (
		editer_element ()
		m_rollPrt.redim_pour_parametres ()
	)
	
	on lbx_sequence selected _index  do (
		editer_element ()
		m_rollPrt.redim_pour_parametres ()
	)
	
	on btn_ajouter_element pressed do
	( 
		 	local	nv_menuis = m_plug.core.creer_menuiserie		m_compo			 lbx_sequence.selection 	
			m_rollPrt.set_ssComposant		nv_menuis	
			actualiser () 
		m_rollPrt.on_a_change_un_truc ()
			lbx_sequence.selection 	+= 1
		)
	on btn_editer_element pressed do
		editer_element ()
	on ddl_volet selected _index  	do	(
				m_compo.params.volet = _index
				actualiser ()
			)
			
	on chk_tablette changed state do (
		m_compo.params.tablette = state
		m_rollPrt.on_a_change_un_truc ()
	)
)
	
------ la fonction de construction	---------
fn compo_fnConstruire  		_plug			_ptsIDs_accroche		norm_dir:		this: 	onConstruitLaDalle:false	= ( 
	
	
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
		local menuis_trav_ht				=	ptr_plug.const_menuiseries_trav_ht
	
	-------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
	
		--- Points d'accroche ------------
		local id_ptAccroche_1 	= _ptsIDs_accroche[1]
		local id_ptAccroche_2 	= _ptsIDs_accroche[2]
		local id_ptAccroche_3 	= _ptsIDs_accroche[3]
		
		local ptAccroche_1		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_1	
		local ptAccroche_2		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_2	
		local ptAccroche_3		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_3	
		
		
		
		local	etage_hauteur				=	distance ptAccroche_2 	ptAccroche_3
		local longueur						= ptr_params.longueur
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
		
	-------------  VECTEURS DIRECTEURS  		-----------------------------------------------------------------------------------------------------------------
		local norm_prof			= norm_dir 	* rotateZ ( matrix3 1 ) 90		
		
		local vec_ep_dalle 	= 	[0,0,1] 		* 	ptr_plug.const_dalle_epaisseur		
		local vec_allege 		= 	[0,0,1] 		*	allege_hauteur
		local vec_rtmb 			= 	[0,0,1] 		*	retombe		
		local vec_ht 				= 	[0,0,1] 		*	hauteur				
		local vec_longueur 	= norm_dir 	*	longueur
		local vec_murEp		=	norm_prof *	ptr_plug.const_murExt_epaisseur
		
		local vec_men_nu				=  norm_prof 	*	profondeur
		local vec_men_ep				=	norm_prof		*	menuis_epaisseur
		local vec_men_lrg				=	norm_dir		*	menuis_largeur
		local vec_men_ht				=	[0,0,1] 			*	menuis_largeur
		local vec_men_allegeHt		=	[0,0,1] 			*	menuis_allege_ht
		local vec_men_travHt		=	[0,0,1] 			*	menuis_trav_ht
		
		local vec_vitrage_ep			=	norm_prof		*	vitrage_ep
		
		local vec_tab_ht		= 	[0,0,1] 			* tablette_hauteur
		local vec_tab_deb		= -norm_prof 	* tablette_debord
		local vec_tab_cote	= norm_dir 		* tablette_cote	

		
		
		
		
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
		
		ptr_geo.face 		#(	pts_ids[10], 		pts_ids[9], 		pts_ids[5], 		pts_ids[4] )				matID:#mur 
		ptr_geo.face 		#(	pts_ids[4], 		pts_ids[5], 		pts_ids[6], 		id_ptAccroche_3 )		matID:#mur 
		ptr_geo.face 		#(	pts_ids[3], 		pts_ids[7], 		pts_ids[10],   	pts_ids[4] )				matID:#mur 
		ptr_geo.face 		#(	pts_ids[8], 		pts_ids[2], 		pts_ids[5],   		pts_ids[9] )				matID:#mur 
		
		
		
		local onCreer_menuiserie_si_sequenceVide = false
		
		-------	  MENUISERIE -	CADRE 	---------------------------------------------------------------------------------------------------------------		
		--- menuiserie du haut	------------
		local ptTmp				=	pts_baie[2] -  vec_men_ht
		local vecTMP_long 	= (pts_baie[3] - pts_baie[2] ) 
		if onCreer_menuiserie_si_sequenceVide do
			ptr_geo.tube		ptTmp		vecTMP_long		vec_men_ht				   vec_men_ep			matID:#menuiserie 
		
		--- menuiserie de gauche	------------
		local vecTMP_ht 	= ( pts_baie[2] - pts_baie[1] )	- vec_men_ht		
		if onCreer_menuiserie_si_sequenceVide do
			ptr_geo.tube		ptTmp		-vecTMP_ht		vec_men_lrg      vec_men_ep				matID:#menuiserie --	flip:true
		
		
		
		
		--- si besoin on fait la menuiserie du bas	et le vitrage	---------
		if sequence.count == 0 and 	onCreer_menuiserie_si_sequenceVide		then (
			--- menuiserie du bas ------------
			local ptTmp					=	pts_baie[1]  +  vec_men_lrg + vec_men_ht
			local vecTMP_longBas 	= vecTMP_long - 2*vec_men_lrg
			ptr_geo.tube		ptTmp		vecTMP_longBas		-vec_men_ht		vec_men_ep				matID:#menuiserie 
			
			--- menuiserie de droite	------------
			local ptTmp			=	pts_baie[3]  -  vec_men_lrg - vec_men_ht
			ptr_geo.tube		ptTmp		-vecTMP_ht		vec_men_lrg		vec_men_ep				matID:#menuiserie 	
			
			--- vitrage	------------
			local ptTmp					=	pts_baie[1]  +  vec_men_lrg + vec_men_ht + ( (vec_men_ep - vec_vitrage_ep )/ 2 )
			local vecTMP_htVitr		= vecTMP_ht 	- 	vec_men_ht
			ptr_geo.tube		ptTmp		vecTMP_htVitr		vecTMP_longBas	vec_vitrage_ep				matID:#vitrage 
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
			-- on construit la sequence	--------------------
			local pt_menuis = pts_baie[1]  + vec_men_lrg 
			local vec_menDivVert_ht 	= ( pts_baie[2] - pts_baie[1] )	- vec_men_ht  			
			for i = 1 to sequence.count	do (
				local		menuis = sequence[i]
				
				
				-- la longueur de l'element ---------------
				local 	menuis_aReseter = false
				if menuis.params.longueur == 0 do (
					menuis.params.longueur  = longueur_div -- menuis_largeur
					menuis_aReseter = true
				)
				
				
				-- on construit la menuiserie --------
				menuis.construire		_plug	pt_menuis		 		norm_dir:norm_dir		dist_hauteur:baie_hauteur		ptr_baie:this
			
				
				pt_menuis += norm_dir * menuis.params.longueur + norm_dir * menuis_largeur
				
				--- on construit la menuiserie verticale -----------
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
			local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[4] )		 		matID:#menuiserie
			local nvlFace = ptr_geo.face 		#(	pts_ids[4], 		pts_ids[3], 		pts_ids[7] , 	pts_ids[8] )		 		matID:#menuiserie
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4], 		pts_ids[8] )		 	matID:#menuiserie	
			local nvlFace = ptr_geo.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7], 		pts_ids[3] )		 	matID:#menuiserie	
			
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


	
	
	